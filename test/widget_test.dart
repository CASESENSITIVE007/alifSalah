import 'package:flutter_test/flutter_test.dart';

import 'package:alif_salah/models/models.dart';
import 'package:alif_salah/utils/geo.dart';
import 'package:alif_salah/utils/prayer_utils.dart';

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

  test('formatTime12 formats correctly', () {
    expect(formatTime12('05:20'), '5:20 AM');
    expect(formatTime12('13:05'), '1:05 PM');
    expect(formatTime12('00:10'), '12:10 AM');
    expect(formatTime12(null), '--:--');
  });
}
