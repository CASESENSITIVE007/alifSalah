import 'dart:math' as math;

/// Geospatial helpers: geohash encoding (for Firestore range queries),
/// haversine distance, and the Qibla bearing calculation.

const double kaabaLat = 21.4225;
const double kaabaLng = 39.8262;

const String _base32 = '0123456789bcdefghjkmnpqrstuvwxyz';

/// Encodes a lat/lng into a geohash of [precision] characters.
String geohashEncode(double lat, double lng, {int precision = 9}) {
  double latMin = -90, latMax = 90, lngMin = -180, lngMax = 180;
  final buffer = StringBuffer();
  bool evenBit = true;
  int idx = 0, bit = 0;

  while (buffer.length < precision) {
    if (evenBit) {
      final mid = (lngMin + lngMax) / 2;
      if (lng >= mid) {
        idx = idx * 2 + 1;
        lngMin = mid;
      } else {
        idx = idx * 2;
        lngMax = mid;
      }
    } else {
      final mid = (latMin + latMax) / 2;
      if (lat >= mid) {
        idx = idx * 2 + 1;
        latMin = mid;
      } else {
        idx = idx * 2;
        latMax = mid;
      }
    }
    evenBit = !evenBit;
    if (++bit == 5) {
      buffer.write(_base32[idx]);
      bit = 0;
      idx = 0;
    }
  }
  return buffer.toString();
}

/// Geohash cell dimensions (approx, meters) per precision level.
/// Used to pick a prefix length that covers the search radius.
const Map<int, double> _cellSizeMeters = {
  1: 5000000,
  2: 1250000,
  3: 156000,
  4: 39100,
  5: 4890,
  6: 1220,
  7: 153,
  8: 38.2,
  9: 4.77,
};

/// Returns the geohash prefix length whose cell is at least [radiusMeters].
int precisionForRadius(double radiusMeters) {
  for (int p = 9; p >= 1; p--) {
    if (_cellSizeMeters[p]! >= radiusMeters) return p;
  }
  return 1;
}

/// Returns the geohash query bounds (prefix ranges) covering a circle of
/// [radiusMeters] around (lat, lng): the center cell plus its 8 neighbors.
List<List<String>> geohashQueryBounds(
    double lat, double lng, double radiusMeters) {
  final p = precisionForRadius(radiusMeters);

  // Derive neighbor cells by offsetting the coordinate by one cell size.
  final latDelta = 180 / math.pow(2, (5 * p / 2).floor());
  final lngDelta = 360 / math.pow(2, (5 * p / 2).ceil());

  final prefixes = <String>{};
  for (final dLat in [-1, 0, 1]) {
    for (final dLng in [-1, 0, 1]) {
      final nLat = (lat + dLat * latDelta).clamp(-90.0, 90.0);
      var nLng = lng + dLng * lngDelta;
      if (nLng > 180) nLng -= 360;
      if (nLng < -180) nLng += 360;
      prefixes.add(geohashEncode(nLat, nLng, precision: p));
    }
  }

  // Each prefix becomes a [start, end] range for Firestore orderBy queries.
  return [
    for (final prefix in prefixes) [prefix, '$prefix~']
  ];
}

/// Haversine distance in meters between two coordinates.
double distanceMeters(double lat1, double lng1, double lat2, double lng2) {
  const r = 6371000.0;
  final dLat = _rad(lat2 - lat1);
  final dLng = _rad(lng2 - lng1);
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_rad(lat1)) *
          math.cos(_rad(lat2)) *
          math.sin(dLng / 2) *
          math.sin(dLng / 2);
  return 2 * r * math.atan2(math.sqrt(a), math.sqrt(1 - a));
}

/// Great-circle initial bearing (degrees from true north) from the user's
/// position to the Kaaba in Mecca.
double qiblaBearing(double lat, double lng) {
  final phi1 = _rad(lat);
  final phi2 = _rad(kaabaLat);
  final dLng = _rad(kaabaLng - lng);
  final y = math.sin(dLng) * math.cos(phi2);
  final x = math.cos(phi1) * math.sin(phi2) -
      math.sin(phi1) * math.cos(phi2) * math.cos(dLng);
  final deg = _deg(math.atan2(y, x));
  return (deg + 360) % 360;
}

String formatDistance(double meters) {
  if (meters < 1000) return '${meters.round()} m';
  return '${(meters / 1000).toStringAsFixed(1)} km';
}

double _rad(double deg) => deg * math.pi / 180;
double _deg(double rad) => rad * 180 / math.pi;
