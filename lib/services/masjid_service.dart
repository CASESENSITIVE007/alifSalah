import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/models.dart';
import '../utils/geo.dart';

/// A Masjid paired with its distance from the user's location.
class NearbyMasjid {
  final Masjid masjid;
  final double distanceMeters;
  const NearbyMasjid(this.masjid, this.distanceMeters);
}

/// All Firestore operations for Masjid community spaces.
class MasjidService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static CollectionReference get _masjids => _db.collection('masjids');

  // ---------- Reading ----------

  static Stream<Masjid?> masjidStream(String id) => _masjids
      .doc(id)
      .snapshots()
      .map((doc) => doc.exists ? Masjid.fromDoc(doc) : null);

  static Stream<List<Masjid>> joinedMasjidsStream(List<String> ids) {
    if (ids.isEmpty) return Stream.value(const []);
    // Firestore whereIn supports up to 30 ids; Phase 1 users join a handful.
    return _masjids
        .where(FieldPath.documentId, whereIn: ids.take(30).toList())
        .snapshots()
        .map((snap) => snap.docs
            .map(Masjid.fromDoc)
            .where((m) => !m.isExpired)
            .toList());
  }

  static Stream<Masjid?> myAdministeredMasjid(String imamUid) => _masjids
      .where('imamUid', isEqualTo: imamUid)
      .limit(1)
      .snapshots()
      .map((snap) =>
          snap.docs.isEmpty ? null : Masjid.fromDoc(snap.docs.first));

  /// Text search by masjid name or city (prefix match, lowercase fields).
  static Future<List<Masjid>> search(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];
    final byName = await _masjids
        .orderBy('nameLower')
        .startAt([q]).endAt(['$q~']).limit(20).get();
    final byCity = await _masjids
        .orderBy('cityLower')
        .startAt([q]).endAt(['$q~']).limit(20).get();
    final seen = <String>{};
    final results = <Masjid>[];
    for (final doc in [...byName.docs, ...byCity.docs]) {
      if (seen.add(doc.id)) {
        final masjid = Masjid.fromDoc(doc);
        if (!masjid.isExpired) results.add(masjid);
      }
    }
    return results;
  }

  /// THE NEARBY FEATURE: finds all Masjids within [radiusKm] of the given
  /// location using geohash range queries. No enrollment required — anyone
  /// in any city can see local Jamaat timings.
  static Future<List<NearbyMasjid>> findNearby(
    double lat,
    double lng, {
    double radiusKm = 10,
  }) async {
    final radiusM = radiusKm * 1000;
    final bounds = geohashQueryBounds(lat, lng, radiusM);

    final futures = bounds.map((b) => _masjids
        .orderBy('geohash')
        .startAt([b[0]]).endAt([b[1]]).get());
    final snapshots = await Future.wait(futures);

    final seen = <String>{};
    final results = <NearbyMasjid>[];
    for (final snap in snapshots) {
      for (final doc in snap.docs) {
        if (!seen.add(doc.id)) continue;
        final masjid = Masjid.fromDoc(doc);
        if (masjid.isExpired) continue;
        final dist = distanceMeters(lat, lng, masjid.lat, masjid.lng);
        if (dist <= radiusM) results.add(NearbyMasjid(masjid, dist));
      }
    }
    results.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    return results;
  }

  // ---------- Membership ----------

  static Future<void> joinMasjid(String masjidId) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final batch = _db.batch();
    batch.update(_db.collection('users').doc(uid), {
      'joinedMasjidIds': FieldValue.arrayUnion([masjidId]),
    });
    batch.update(_masjids.doc(masjidId), {
      'memberUids': FieldValue.arrayUnion([uid]),
    });
    await batch.commit();
  }

  static Future<void> leaveMasjid(String masjidId) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final batch = _db.batch();
    batch.update(_db.collection('users').doc(uid), {
      'joinedMasjidIds': FieldValue.arrayRemove([masjidId]),
    });
    batch.update(_masjids.doc(masjidId), {
      'memberUids': FieldValue.arrayRemove([uid]),
    });
    await batch.commit();
  }

  /// Deletes an expired Masjid space (24h with zero muqtadis). The imam's
  /// login account is untouched — their dashboard simply returns to
  /// "Create your Masjid space" so they can start again.
  static Future<void> deleteExpiredMasjid(Masjid masjid) async {
    if (!masjid.isExpired) return;
    await _masjids.doc(masjid.id).delete();
    // Remove it from the imam's own joined list.
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await _db.collection('users').doc(uid).update({
      'joinedMasjidIds': FieldValue.arrayRemove([masjid.id]),
    });
  }

  // ---------- Imam administration ----------

  static Future<String> createMasjid({
    required String name,
    required String address,
    required String city,
    required double lat,
    required double lng,
    required String imamName,
    required int muqtadiMin,
    required int muqtadiMax,
  }) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final masjid = Masjid(
      id: '',
      name: name,
      address: address,
      city: city,
      lat: lat,
      lng: lng,
      geohash: geohashEncode(lat, lng),
      imamUid: uid,
      imamName: imamName,
      // Verified via silent community confirmation, not by an admin.
      verified: false,
      timings: PrayerTimings.empty(),
      muqtadiMin: muqtadiMin,
      muqtadiMax: muqtadiMax,
      verifyThreshold: verifyThresholdFor(muqtadiMin, muqtadiMax),
      verifyDeadline: DateTime.now().add(const Duration(hours: 72)),
    );
    final ref = await _masjids.add(masjid.toMap());
    // The imam automatically joins their own masjid.
    await joinMasjid(ref.id);
    return ref.id;
  }

  /// A joined muqtadi confirms this Masjid is genuine. If the (hidden)
  /// threshold is reached within the 72-hour window, the verified badge
  /// is granted in the same write. Security rules enforce: one vote per
  /// member, joined members only, threshold and deadline respected.
  static Future<void> verifyMasjid(Masjid masjid) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    if (!masjid.canBeVerifiedBy(uid)) return;
    final reachesThreshold =
        masjid.verifierUids.length + 1 >= masjid.verifyThreshold;
    await _masjids.doc(masjid.id).update({
      'verifierUids': FieldValue.arrayUnion([uid]),
      if (reachesThreshold) 'verified': true,
    });
  }

  static Future<void> updateTimings(
      String masjidId, PrayerTimings timings) async {
    await _masjids.doc(masjidId).update({
      'timings': timings.toMap(),
      'timingsUpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ---------- Campaigns ----------

  static Stream<List<Campaign>> campaignsStream(String masjidId) => _masjids
      .doc(masjidId)
      .collection('campaigns')
      .where('active', isEqualTo: true)
      .snapshots()
      .map((snap) => snap.docs.map(Campaign.fromDoc).toList());

  static Future<void> createCampaign(String masjidId, Campaign c) =>
      _masjids.doc(masjidId).collection('campaigns').add(c.toMap());

  static Future<void> closeCampaign(String masjidId, String campaignId) =>
      _masjids
          .doc(masjidId)
          .collection('campaigns')
          .doc(campaignId)
          .update({'active': false});

  // ---------- Announcements (one-way broadcast) ----------

  static Stream<List<Announcement>> announcementsStream(String masjidId) =>
      _masjids
          .doc(masjidId)
          .collection('announcements')
          .orderBy('createdAt', descending: true)
          .limit(20)
          .snapshots()
          .map((snap) => snap.docs.map(Announcement.fromDoc).toList());

  static Future<void> postAnnouncement(String masjidId, Announcement a) =>
      _masjids.doc(masjidId).collection('announcements').add(a.toMap());
}
