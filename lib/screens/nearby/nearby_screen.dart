import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../l10n/app_lang.dart';
import '../../services/masjid_service.dart';
import '../../theme.dart';
import '../../utils/geo.dart';
import '../../utils/prayer_utils.dart';
import '../../widgets/timings_card.dart';
import '../masjid/masjid_detail_screen.dart';
import 'nearby_map_view.dart';

/// NEARBY MASJIDS — shows Jamaat timings of every Masjid around the user's
/// current location, WITHOUT enrolling. Perfect for travellers in a new
/// city: open the tab and instantly see when Jamaat is at nearby Masjids.
/// (Adhaan notifications remain exclusive to joined Masjids.)
class NearbyScreen extends StatefulWidget {
  const NearbyScreen({super.key});

  @override
  State<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends State<NearbyScreen>
    with AutomaticKeepAliveClientMixin {
  List<NearbyMasjid>? _results;
  String? _error;
  bool _loading = false;
  double _radiusKm = 10;
  bool _showMap = false;
  Position? _position;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final pos = await _getPosition();
      final results = await MasjidService.findNearby(
          pos.latitude, pos.longitude,
          radiusKm: _radiusKm);
      if (mounted) {
        setState(() {
          _position = pos;
          _results = results;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _loading = false;
        });
      }
    }
  }

  Future<Position> _getPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception(AppLang.t('location_off'));
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception(AppLang.t('location_needed'));
    }
    return Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLang.t('masjids_near_me')),
        actions: [
          IconButton(
            tooltip:
                _showMap ? AppLang.t('show_list') : AppLang.t('show_map'),
            icon: Icon(_showMap ? Icons.view_list : Icons.map),
            onPressed: () => setState(() => _showMap = !_showMap),
          ),
          PopupMenuButton<double>(
            icon: const Icon(Icons.tune),
            tooltip: AppLang.t('search_radius'),
            onSelected: (r) {
              _radiusKm = r;
              _refresh();
            },
            itemBuilder: (_) => [
              for (final r in [2.0, 5.0, 10.0, 25.0, 50.0])
                PopupMenuItem(
                  value: r,
                  child: Text(
                      '${r.toInt()} km ${r == _radiusKm ? "  ✓" : ""}'),
                ),
            ],
          ),
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loading ? null : _refresh),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading && _results == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_off, size: 56, color: Colors.black26),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                  onPressed: _refresh, child: Text(AppLang.t('retry'))),
            ],
          ),
        ),
      );
    }
    final results = _results ?? [];
    if (_showMap && _position != null) {
      return NearbyMapView(
        userLat: _position!.latitude,
        userLng: _position!.longitude,
        radiusKm: _radiusKm,
        results: results,
      );
    }
    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mosque, size: 56, color: Colors.black26),
              const SizedBox(height: 12),
              Text(
                AppLang.t('no_nearby'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: results.length,
        itemBuilder: (context, i) => _nearbyCard(results[i]),
      ),
    );
  }

  Widget _nearbyCard(NearbyMasjid item) {
    final masjid = item.masjid;
    final next = nextJamaat(masjid.timings);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        shape: const Border(),
        leading: const CircleAvatar(
          backgroundColor: AppTheme.lightGreen,
          child: Icon(Icons.mosque, color: AppTheme.deepGreen),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(masjid.name,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
            if (masjid.verified) ...[
              const SizedBox(width: 4),
              Tooltip(
                message: AppLang.t('verified_masjid'),
                child: const Icon(Icons.verified,
                    color: AppTheme.gold, size: 16),
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${formatDistance(item.distanceMeters)} • ${masjid.address}',
                maxLines: 1, overflow: TextOverflow.ellipsis),
            if (next != null)
              Text(
                '${AppLang.t('next')}: ${AppLang.prayer(next.name)} ${AppLang.t('jamaat')} ${formatTime12(masjid.timings[next.name].jamaat)} (${countdownText(next.jamaatTime)})',
                style: const TextStyle(
                    color: AppTheme.deepGreen, fontWeight: FontWeight.w600),
              ),
          ],
        ),
        children: [
          TimingsCard(timings: masjid.timings, compact: true),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton.icon(
                icon: const Icon(Icons.info_outline, size: 18),
                label: Text(AppLang.t('view_details')),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          MasjidDetailScreen(masjidId: masjid.id)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
