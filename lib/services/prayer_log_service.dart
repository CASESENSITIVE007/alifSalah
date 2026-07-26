import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../utils/streak.dart';

/// Per-user prayer log: users/{uid}/prayerLog/{yyyy-MM-dd} documents with
/// a `prayers` map like {Fajr: true, Dhuhr: true, ...}.
class PrayerLogService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static CollectionReference get _log => _db
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('prayerLog');

  /// Live map of dateKey → prayers-completed map, most recent year.
  /// Uses a date-range filter on the document id (yyyy-MM-dd) so no
  /// composite index is needed.
  static Stream<Map<String, Map<String, bool>>> logStream() {
    final yearAgo =
        dateKey(DateTime.now().subtract(const Duration(days: 366)));
    return _log
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: yearAgo)
        .snapshots()
        .map((snap) {
        final result = <String, Map<String, bool>>{};
        for (final doc in snap.docs) {
          final data = doc.data() as Map<String, dynamic>;
          result[doc.id] =
              ((data['prayers'] as Map?) ?? {}).map((k, v) => MapEntry(
                    k.toString(),
                    v == true,
                  ));
        }
        return result;
      });
  }

  static Future<void> setPrayer(
      DateTime day, String prayer, bool done) async {
    await _log.doc(dateKey(day)).set({
      'prayers': {prayer: done},
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
