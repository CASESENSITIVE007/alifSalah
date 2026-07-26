import 'package:flutter_test/flutter_test.dart';

import 'package:alif_salah/models/models.dart';
import 'package:alif_salah/utils/geo.dart';
import 'package:alif_salah/utils/prayer_utils.dart';
import 'package:alif_salah/utils/streak.dart';

void main() {
  test('geohash encodes known location', () {
    // Mecca — well-known geohash prefix.
    final hash = geohashEncode(21.4225, 39.8262, precision: 5);
    expect(hash, 'sgu3f');
  });

  test('qibla bearing from New Delhi points west-southwest', () {
    final bearing = qiblaBearing(28.6139, 77.2090);
    expect(bearing, greaterThan(255));
    expect(bearing, lessThan(275));
  });

  test('distance between two known points', () {
    // ~1.11 km per 0.01 degrees latitude.
    final d = distanceMeters(28.60, 77.20, 28.61, 77.20);
    expect(d, closeTo(1112, 20));
  });

  test('prayer timings round-trip through map', () {
    final timings = PrayerTimings({
      'Fajr': const PrayerTime(adhaan: '05:00', jamaat: '05:20'),
      'Isha': const PrayerTime(adhaan: '20:00', jamaat: '20:15'),
    });
    final restored = PrayerTimings.fromMap(timings.toMap());
    expect(restored['Fajr'].jamaat, '05:20');
    expect(restored['Isha'].adhaan, '20:00');
    expect(restored['Asr'].isEmpty, true);
  });

  test('verification threshold is 60% of average attendance', () {
    expect(verifyThresholdFor(20, 50), 21); // avg 35 → 60% = 21
    expect(verifyThresholdFor(10, 10), 6); // avg 10 → 60% = 6
    expect(verifyThresholdFor(1, 1), 1); // never below 1
    expect(verifyThresholdFor(5, 6), 4); // avg 5.5 → 3.3 → ceil 4
  });

  test('streak counts consecutive complete days', () {
    final today = DateTime(2026, 7, 26);
    final counts = {
      '2026-07-26': 5, // today complete
      '2026-07-25': 5,
      '2026-07-24': 5,
      '2026-07-22': 5, // gap on the 23rd
      '2026-07-21': 3, // partial — breaks
    };
    final stats = computeStreaks(counts, today);
    expect(stats.currentStreak, 3);
    expect(stats.bestStreak, 3);
    expect(stats.completeDays, 4);
    expect(stats.totalPrayers, 23);
  });

  test('streak survives an in-progress today', () {
    final today = DateTime(2026, 7, 26);
    final counts = {
      '2026-07-26': 2, // today not finished yet
      '2026-07-25': 5,
      '2026-07-24': 5,
    };
    final stats = computeStreaks(counts, today);
    expect(stats.currentStreak, 2); // yesterday's streak still alive
  });

  test('formatTime12 formats correctly', () {
    expect(formatTime12('05:20'), '5:20 AM');
    expect(formatTime12('13:05'), '1:05 PM');
    expect(formatTime12('00:10'), '12:10 AM');
    expect(formatTime12(null), '--:--');
  });
}
