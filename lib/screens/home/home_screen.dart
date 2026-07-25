import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../services/masjid_service.dart';
import '../../services/notification_service.dart';
import '../../theme.dart';
import '../../widgets/timings_card.dart';
import '../masjid/masjid_detail_screen.dart';
import '../masjid/search_masjid_screen.dart';
import '../imam/imam_dashboard_screen.dart';

/// Home dashboard: live Jamaat timings of the user's joined Masjids.
/// Also (re)schedules Adhaan buzzer notifications whenever timings change —
/// notifications fire ONLY for joined Masjids.
class HomeScreen extends StatelessWidget {
  final AppUser profile;
  const HomeScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alif-Salah'),
        actions: [
          if (profile.isImam)
            IconButton(
              tooltip: 'Manage my Masjid',
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ImamDashboardScreen(profile: profile)),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SearchMasjidScreen())),
        icon: const Icon(Icons.add),
        label: const Text('Join a Masjid'),
      ),
      body: profile.joinedMasjidIds.isEmpty
          ? _emptyState(context)
          : StreamBuilder<List<Masjid>>(
              stream:
                  MasjidService.joinedMasjidsStream(profile.joinedMasjidIds),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final masjids = snap.data!;
                // Keep Adhaan alerts in sync with the latest timetable.
                NotificationService.rescheduleForMasjids(masjids,
                    enabled: profile.adhaanAlertsEnabled);

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                  children: [
                    for (final masjid in masjids)
                      _masjidCard(context, masjid),
                  ],
                );
              },
            ),
    );
  }

  Widget _masjidCard(BuildContext context, Masjid masjid) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  MasjidDetailScreen(masjidId: masjid.id, profile: profile)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppTheme.deepGreen,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.mosque, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(masjid.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16)),
                        if (masjid.timingsUpdatedAt != null)
                          Text(
                            'Updated ${_ago(masjid.timingsUpdatedAt!)}',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 11),
                          ),
                      ],
                    ),
                  ),
                  if (!masjid.verified)
                    const Tooltip(
                      message: 'Pending verification',
                      child:
                          Icon(Icons.hourglass_top, color: AppTheme.gold, size: 18),
                    ),
                ],
              ),
            ),
            TimingsCard(timings: masjid.timings),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mosque, size: 64, color: Colors.black26),
            const SizedBox(height: 16),
            const Text('No Masjid joined yet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text(
              'Join your local Masjid to see its Jamaat timings here and get Adhaan alerts. Or check the Nearby tab to view timings around you without joining.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  String _ago(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
