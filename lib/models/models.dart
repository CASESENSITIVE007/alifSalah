import 'package:cloud_firestore/cloud_firestore.dart';

/// The five daily prayers plus Jumu'ah.
const List<String> kPrayerNames = [
  'Fajr',
  'Dhuhr',
  'Asr',
  'Maghrib',
  'Isha',
  'Jumuah',
];

/// Adhaan + Jamaat time for a single prayer, stored as "HH:mm" 24h strings.
class PrayerTime {
  final String? adhaan;
  final String? jamaat;

  const PrayerTime({this.adhaan, this.jamaat});

  factory PrayerTime.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const PrayerTime();
    return PrayerTime(
      adhaan: map['adhaan'] as String?,
      jamaat: map['jamaat'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        if (adhaan != null) 'adhaan': adhaan,
        if (jamaat != null) 'jamaat': jamaat,
      };

  bool get isEmpty => adhaan == null && jamaat == null;
}

/// Full timetable of a Masjid keyed by prayer name.
class PrayerTimings {
  final Map<String, PrayerTime> times;

  const PrayerTimings(this.times);

  factory PrayerTimings.empty() =>
      PrayerTimings({for (final p in kPrayerNames) p: const PrayerTime()});

  factory PrayerTimings.fromMap(Map<String, dynamic>? map) {
    if (map == null) return PrayerTimings.empty();
    return PrayerTimings({
      for (final p in kPrayerNames)
        p: PrayerTime.fromMap((map[p] as Map?)?.cast<String, dynamic>()),
    });
  }

  Map<String, dynamic> toMap() => {
        for (final e in times.entries)
          if (!e.value.isEmpty) e.key: e.value.toMap(),
      };

  PrayerTime operator [](String prayer) => times[prayer] ?? const PrayerTime();
}

class Masjid {
  final String id;
  final String name;
  final String address;
  final String city;
  final double lat;
  final double lng;
  final String geohash;
  final String imamUid;
  final String imamName;
  final bool verified;
  final PrayerTimings timings;
  final DateTime? timingsUpdatedAt;

  const Masjid({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.lat,
    required this.lng,
    required this.geohash,
    required this.imamUid,
    required this.imamName,
    required this.verified,
    required this.timings,
    this.timingsUpdatedAt,
  });

  factory Masjid.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Masjid(
      id: doc.id,
      name: d['name'] ?? '',
      address: d['address'] ?? '',
      city: d['city'] ?? '',
      lat: (d['lat'] as num?)?.toDouble() ?? 0,
      lng: (d['lng'] as num?)?.toDouble() ?? 0,
      geohash: d['geohash'] ?? '',
      imamUid: d['imamUid'] ?? '',
      imamName: d['imamName'] ?? '',
      verified: d['verified'] ?? false,
      timings:
          PrayerTimings.fromMap((d['timings'] as Map?)?.cast<String, dynamic>()),
      timingsUpdatedAt: (d['timingsUpdatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'nameLower': name.toLowerCase(),
        'address': address,
        'city': city,
        'cityLower': city.toLowerCase(),
        'lat': lat,
        'lng': lng,
        'geohash': geohash,
        'imamUid': imamUid,
        'imamName': imamName,
        'verified': verified,
        'timings': timings.toMap(),
        'timingsUpdatedAt': FieldValue.serverTimestamp(),
      };
}

enum UserRole { muqtadi, imam }

class AppUser {
  final String uid;
  final String name;
  final String phone;
  final UserRole role;
  final List<String> joinedMasjidIds;
  final bool adhaanAlertsEnabled;

  const AppUser({
    required this.uid,
    required this.name,
    required this.phone,
    required this.role,
    required this.joinedMasjidIds,
    this.adhaanAlertsEnabled = true,
  });

  factory AppUser.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      name: d['name'] ?? '',
      phone: d['phone'] ?? '',
      role: d['role'] == 'imam' ? UserRole.imam : UserRole.muqtadi,
      joinedMasjidIds:
          (d['joinedMasjidIds'] as List?)?.cast<String>() ?? const [],
      adhaanAlertsEnabled: d['adhaanAlertsEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'phone': phone,
        'role': role == UserRole.imam ? 'imam' : 'muqtadi',
        'joinedMasjidIds': joinedMasjidIds,
        'adhaanAlertsEnabled': adhaanAlertsEnabled,
      };

  bool get isImam => role == UserRole.imam;
}

class Campaign {
  final String id;
  final String title;
  final String description;

  /// QR image stored as base64 directly in Firestore (small images only)
  /// so Phase 1 needs no Firebase Storage billing setup.
  final String qrBase64;
  final bool active;
  final DateTime? createdAt;

  const Campaign({
    required this.id,
    required this.title,
    required this.description,
    required this.qrBase64,
    required this.active,
    this.createdAt,
  });

  factory Campaign.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Campaign(
      id: doc.id,
      title: d['title'] ?? '',
      description: d['description'] ?? '',
      qrBase64: d['qrBase64'] ?? '',
      active: d['active'] ?? true,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'qrBase64': qrBase64,
        'active': active,
        'createdAt': FieldValue.serverTimestamp(),
      };
}

/// One-way broadcast from the Imam to the community (no replies).
class Announcement {
  final String id;
  final String title;
  final String body;
  final DateTime? createdAt;

  const Announcement({
    required this.id,
    required this.title,
    required this.body,
    this.createdAt,
  });

  factory Announcement.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Announcement(
      id: doc.id,
      title: d['title'] ?? '',
      body: d['body'] ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'body': body,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
