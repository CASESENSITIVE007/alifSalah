import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../l10n/app_lang.dart';
import '../../services/masjid_service.dart';
import '../../theme.dart';
import '../../utils/geo.dart';
import '../../utils/prayer_utils.dart';
import '../../widgets/timings_card.dart';
import '../masjid/masjid_detail_screen.dart';

/// Interactive OpenStreetMap for travellers: every nearby Masjid is a
/// tappable marker showing its Jamaat timings — no enrollment needed.
class NearbyMapView extends StatelessWidget {
  final double userLat;
  final double userLng;
  final double radiusKm;
  final List<NearbyMasjid> results;

  const NearbyMapView({
    super.key,
    required this.userLat,
    required this.userLng,
    required this.radiusKm,
    required this.results,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(userLat, userLng),
        initialZoom: _zoomForRadius(radiusKm),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.alifsalah.alif_salah',
        ),
        // Search radius.
        CircleLayer(
          circles: [
            CircleMarker(
              point: LatLng(userLat, userLng),
              radius: radiusKm * 1000,
              useRadiusInMeter: true,
              color: AppTheme.deepGreen.withValues(alpha: 0.06),
              borderColor: AppTheme.deepGreen.withValues(alpha: 0.35),
              borderStrokeWidth: 1.5,
            ),
          ],
        ),
        MarkerLayer(
          markers: [
            // The traveller.
            Marker(
              point: LatLng(userLat, userLng),
              width: 22,
              height: 22,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4),
                  ],
                ),
              ),
            ),
            // Every nearby Masjid.
            for (final item in results)
              Marker(
                point: LatLng(item.masjid.lat, item.masjid.lng),
                width: 44,
                height: 44,
                child: GestureDetector(
                  onTap: () => _showMasjidSheet(context, item),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: item.masjid.verified
                              ? AppTheme.gold
                              : AppTheme.deepGreen,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: const [
                            BoxShadow(color: Colors.black38, blurRadius: 4),
                          ],
                        ),
                        child: const Icon(Icons.mosque,
                            color: Colors.white, size: 18),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const RichAttributionWidget(
          attributions: [
            TextSourceAttribution('© OpenStreetMap contributors'),
          ],
        ),
      ],
    );
  }

  /// Picks an initial zoom that roughly fits the search radius on screen.
  double _zoomForRadius(double km) {
    if (km <= 2) return 14.5;
    if (km <= 5) return 13.5;
    if (km <= 10) return 12.5;
    if (km <= 25) return 11;
    return 10;
  }

  void _showMasjidSheet(BuildContext context, NearbyMasjid item) {
    final masjid = item.masjid;
    final next = nextJamaat(masjid.timings);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.55,
        maxChildSize: 0.85,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppTheme.lightGreen,
                  child: Icon(Icons.mosque, color: AppTheme.deepGreen),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(masjid.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 17)),
                          ),
                          if (masjid.verified) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.verified,
                                color: AppTheme.gold, size: 18),
                          ],
                        ],
                      ),
                      Text(
                        '${formatDistance(item.distanceMeters)} ${AppLang.t('away')} • ${masjid.address}',
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 12.5),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (next != null)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: AppTheme.lightGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${AppLang.t('next')}: ${AppLang.prayer(next.name)} ${AppLang.t('jamaat')} ${formatTime12(masjid.timings[next.name].jamaat)} (${countdownText(next.jamaatTime)})',
                  style: const TextStyle(
                      color: AppTheme.deepGreen, fontWeight: FontWeight.w600),
                ),
              ),
            const SizedBox(height: 8),
            TimingsCard(timings: masjid.timings, compact: true),
            const SizedBox(height: 8),
            FilledButton.icon(
              icon: const Icon(Icons.info_outline, size: 18),
              label: Text(AppLang.t('view_masjid_page')),
              onPressed: () {
                Navigator.pop(sheetContext);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => MasjidDetailScreen(masjidId: masjid.id)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
