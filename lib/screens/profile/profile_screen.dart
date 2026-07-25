import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../../theme.dart';

class ProfileScreen extends StatelessWidget {
  final AppUser profile;
  const ProfileScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppTheme.lightGreen,
                child: Icon(Icons.person, color: AppTheme.deepGreen),
              ),
              title: Text(profile.name,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(
                  '${profile.phone}\n${profile.isImam ? "Imam / Administrator" : "Community Member (Muqtadi)"}'),
              isThreeLine: true,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: SwitchListTile(
              secondary:
                  const Icon(Icons.notifications_active, color: AppTheme.gold),
              title: const Text('Adhaan buzzer alerts'),
              subtitle: const Text(
                  'Notifications at Adhaan time and 10 minutes before Jamaat, for your joined Masjids only.'),
              value: profile.adhaanAlertsEnabled,
              onChanged: (v) async {
                await AuthService.setAdhaanAlerts(v);
                if (!v) await NotificationService.cancelAll();
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Sign out'),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Sign out?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel')),
                      TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Sign out')),
                    ],
                  ),
                );
                if (confirm == true) {
                  await NotificationService.cancelAll();
                  await AuthService.signOut();
                }
              },
            ),
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text('Alif-Salah v1.0 — Phase 1\nYour Masjid, in your pocket',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black38, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
