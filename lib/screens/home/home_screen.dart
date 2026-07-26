import 'package:flutter/material.dart';

import '../../l10n/app_lang.dart';
import '../../models/models.dart';
import '../../services/masjid_service.dart';
import '../../services/notification_service.dart';
import '../../theme.dart';
import '../../widgets/date_banner.dart';
import '../../widgets/timings_card.dart';
import '../masjid/masjid_detail_screen.dart';
import '../masjid/search_masjid_screen.dart';
import '../imam/imam_dashboard_screen.dart';
import '../tasbih/tasbih_screen.dart';

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
          IconButton(
            tooltip: AppLang.t('tasbih'),
            icon: const Icon(Icons.grain),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const TasbihScreen())),
          ),
          if (profile.isImam)
            IconButton(
              tooltip: AppLang.t('manage_my_masjid'),
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
        label: Text(AppLang.t('join_a_masjid')),
      ),
      body: Column(
        children: [
          const DateBanner(),
          Expanded(
            child: profile.joinedMasjidIds.isEmpty
                ? _emptyState(context)
                : StreamBuilder<List<Masjid>>(
                    stream: MasjidService.joinedMasjidsStream(
                        profile.joinedMasjidIds),
                    builder: (context, snap) {
                      if (!snap.hasData) {
                        return const Center(
                            child: CircularProgressIndicator());
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
          ),
        ],
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
                            '${AppLang.t('updated')} ${_ago(masjid.timingsUpdatedAt!)}',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 11),
                          ),
                      ],
                    ),
                  ),
                  if (masjid.verified)
                    Tooltip(
                      message: AppLang.t('verified_masjid'),
                      child: const Icon(Icons.verified,
                          color: AppTheme.gold, size: 18),
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
            Text(AppLang.t('no_masjid_title'),
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              AppLang.t('no_masjid_body'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
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
