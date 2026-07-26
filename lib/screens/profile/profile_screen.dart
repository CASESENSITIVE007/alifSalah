import 'package:flutter/material.dart';

import '../../l10n/app_lang.dart';
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
      appBar: AppBar(title: Text(AppLang.t('profile'))),
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
                  '${profile.phone}\n${profile.isImam ? AppLang.t('role_imam') : AppLang.t('role_muqtadi')}'),
              isThreeLine: true,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: SwitchListTile(
              secondary:
                  const Icon(Icons.notifications_active, color: AppTheme.gold),
              title: Text(AppLang.t('adhaan_alerts')),
              subtitle: Text(AppLang.t('adhaan_alerts_desc')),
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
              title: Text(AppLang.t('sign_out')),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(AppLang.t('sign_out_q')),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(AppLang.t('cancel'))),
                      TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(AppLang.t('sign_out'))),
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
                style:
                    const TextStyle(color: Colors.black38, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
