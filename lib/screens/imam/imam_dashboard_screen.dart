import 'package:flutter/material.dart';

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
      appBar: AppBar(title: const Text('Manage my Masjid')),
      body: StreamBuilder<Masjid?>(
        stream: MasjidService.myAdministeredMasjid(profile.uid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final masjid = snap.data;
          if (masjid == null) return _noMasjid(context);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: masjid.verified ? AppTheme.lightGreen : null,
                child: ListTile(
                  leading: Icon(
                    masjid.verified ? Icons.verified : Icons.hourglass_top,
                    color:
                        masjid.verified ? AppTheme.deepGreen : AppTheme.gold,
                  ),
                  title: Text(masjid.name,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(masjid.verified
                      ? 'Verified Masjid'
                      : 'Pending verification — your space is visible, and will show a verified badge once approved.'),
                ),
              ),
              const SizedBox(height: 12),
              _actionCard(
                context,
                icon: Icons.schedule,
                title: 'Update Jamaat timings',
                subtitle:
                    'Publish today\'s Adhaan & Jamaat times. Members see changes instantly.',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => EditTimingsScreen(masjid: masjid))),
              ),
              _actionCard(
                context,
                icon: Icons.campaign,
                title: 'Post an announcement',
                subtitle:
                    'One-way broadcast to your community. No replies, no noise.',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            PostAnnouncementScreen(masjidId: masjid.id))),
              ),
              _actionCard(
                context,
                icon: Icons.volunteer_activism,
                title: 'Fundraising campaigns',
                subtitle:
                    'Start a campaign and upload your Masjid\'s payment QR code.',
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
            const Text('Create your Masjid\'s Community Space',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text(
              'Set up your Masjid so your community can join, see live Jamaat timings, and receive Adhaan alerts.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Create Masjid space'),
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
