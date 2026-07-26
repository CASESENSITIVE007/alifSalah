import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';

import '../../l10n/app_lang.dart';
import '../../theme.dart';
import '../../utils/geo.dart';

/// Qibla compass: combines the magnetometer heading with the great-circle
/// bearing from the user's GPS position to the Kaaba.
class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen>
    with AutomaticKeepAliveClientMixin {
  double? _qiblaBearing;
  String? _error;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _locate();
  }

  Future<void> _locate() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception(AppLang.t('qibla_location_needed'));
      }
      final pos = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() =>
            _qiblaBearing = qiblaBearing(pos.latitude, pos.longitude));
      }
    } catch (e) {
      if (mounted) {
        setState(
            () => _error = e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(title: Text(AppLang.t('qibla_compass'))),
      body: _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(
                        onPressed: () {
                          setState(() => _error = null);
                          _locate();
                        },
                        child: Text(AppLang.t('retry'))),
                  ],
                ),
              ),
            )
          : _qiblaBearing == null
              ? const Center(child: CircularProgressIndicator())
              : StreamBuilder<CompassEvent>(
                  stream: FlutterCompass.events,
                  builder: (context, snap) {
                    final heading = snap.data?.heading;
                    if (heading == null) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            AppLang.t('compass_unavailable'),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                    return _compass(heading);
                  },
                ),
    );
  }

  Widget _compass(double heading) {
    final qibla = _qiblaBearing!;
    // Angle the needle must point at on screen.
    final angle = (qibla - heading) * math.pi / 180;
    final aligned = ((qibla - heading).abs() % 360) < 5 ||
        ((qibla - heading).abs() % 360) > 355;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            aligned
                ? AppLang.t('facing_qibla')
                : AppLang.t('rotate_arrow'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: aligned ? AppTheme.deepGreen : Colors.black54,
            ),
          ),
          const SizedBox(height: 32),
          Stack(
            alignment: Alignment.center,
            children: [
              // Compass rose rotates opposite to the device heading.
              Transform.rotate(
                angle: -heading * math.pi / 180,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                        color: aligned ? AppTheme.deepGreen : Colors.black12,
                        width: 3),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 12,
                          offset: Offset(0, 4)),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      for (final d in ['N', 'E', 'S', 'W'])
                        Align(
                          alignment: {
                            'N': Alignment.topCenter,
                            'E': Alignment.centerRight,
                            'S': Alignment.bottomCenter,
                            'W': Alignment.centerLeft,
                          }[d]!,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(d,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: d == 'N'
                                        ? Colors.red
                                        : Colors.black45)),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Qibla needle.
              Transform.rotate(
                angle: angle,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.navigation,
                        size: 90,
                        color: aligned ? AppTheme.deepGreen : AppTheme.gold),
                    const SizedBox(height: 90),
                  ],
                ),
              ),
              const Icon(Icons.mosque, size: 28, color: AppTheme.deepGreen),
            ],
          ),
          const SizedBox(height: 32),
          Text(
              '${AppLang.t('qibla_from_north')}: ${qibla.toStringAsFixed(1)}°',
              style: const TextStyle(color: Colors.black54)),
          Text('${AppLang.t('heading')}: ${heading.toStringAsFixed(0)}°',
              style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              AppLang.t('compass_tip'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.black38),
            ),
          ),
        ],
      ),
    );
  }
}
