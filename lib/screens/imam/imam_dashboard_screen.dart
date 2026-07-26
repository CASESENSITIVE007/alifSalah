import 'package:flutter/material.dart';

import '../../l10n/app_lang.dart';
import '../../models/models.dart';
import '../../services/masjid_service.dart';
import '../../theme.dart';
import 'create_masjid_screen.dart';
import 'edit_timings_screen.dart';
import 'manage_campaigns_screen.dart';
import 'post_announcement_screen.dart';

/// Imam admin hub: create the Masjid space, then manage timings,
/// campaigns, and announcements.
class ImamDashboardScreen extends StatelessWidget {
  final AppUser profile;
  const ImamDashboardScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLang.t('imam_dashboard'))),
      body: StreamBuilder<Masjid?>(
        stream: MasjidService.myAdministeredMasjid(profile.uid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final masjid = snap.data;
          if (masjid == null) return _noMasjid(context);

          // 24 hours with zero muqtadis: the space is removed. The imam's
          // account stays — they land back on "Create your Masjid space".
          if (masjid.isExpired) {
            MasjidService.deleteExpiredMasjid(masjid);
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.delete_forever,
                        size: 56, color: Colors.red),
                    const SizedBox(height: 12),
                    Text(
                      AppLang.t('space_deleted'),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (masjid.muqtadiCount == 0)
                Card(
                  color: const Color(0xFFFDECEA),
                  child: ListTile(
                    leading:
                        const Icon(Icons.warning_amber, color: Colors.red),
                    title: Text(
                      AppLang.t('warn_join_now'),
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, color: Colors.red),
                    ),
                    subtitle: Text(AppLang.t('warn_join_now_body')),
                  ),
                ),
              Card(
                color: masjid.verified ? AppTheme.lightGreen : null,
                child: ListTile(
                  leading: Icon(
                    masjid.verified ? Icons.verified : Icons.groups,
                    color:
                        masjid.verified ? AppTheme.gold : Colors.black38,
                  ),
                  title: Text(masjid.name,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  // The community-confirmation mechanism is intentionally
                  // never explained — this is all the imam ever sees.
                  subtitle: Text(masjid.verified
                      ? AppLang.t('verified_masjid')
                      : AppLang.t('need_muqtadis')),
                ),
              ),
              const SizedBox(height: 12),
              _actionCard(
                context,
                icon: Icons.schedule,
                title: AppLang.t('update_timings'),
                subtitle: AppLang.t('update_timings_desc'),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => EditTimingsScreen(masjid: masjid))),
              ),
              _actionCard(
                context,
                icon: Icons.campaign,
                title: AppLang.t('post_announcement'),
                subtitle: AppLang.t('post_announcement_desc'),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            PostAnnouncementScreen(masjidId: masjid.id))),
              ),
              _actionCard(
                context,
                icon: Icons.volunteer_activism,
                title: AppLang.t('campaigns_admin'),
                subtitle: AppLang.t('campaigns_admin_desc'),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            ManageCampaignsScreen(masjidId: masjid.id))),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _noMasjid(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_business, size: 64, color: Colors.black26),
            const SizedBox(height: 16),
            Text(AppLang.t('create_space_title'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              AppLang.t('create_space_body'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.add),
              label: Text(AppLang.t('create_space_btn')),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => CreateMasjidScreen(profile: profile))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionCard(BuildContext context,
      {required IconData icon,
      required String title,
      required String subtitle,
      required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.lightGreen,
          child: Icon(icon, color: AppTheme.deepGreen),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
