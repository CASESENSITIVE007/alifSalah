import 'dart:convert';

import 'package:flutter/material.dart';

import '../../l10n/app_lang.dart';
import '../../models/models.dart';
import '../../services/auth_service.dart';
import '../../services/masjid_service.dart';
import '../../theme.dart';
import '../../widgets/timings_card.dart';

/// Full Masjid space: timings, join/leave, announcements, and fundraising
/// campaigns with scannable QR codes. Viewable by anyone (no enrollment
/// needed to see timings); joining enables Adhaan alerts.
class MasjidDetailScreen extends StatelessWidget {
  final String masjidId;
  final AppUser? profile;

  const MasjidDetailScreen({super.key, required this.masjidId, this.profile});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Masjid?>(
      stream: MasjidService.masjidStream(masjidId),
      builder: (context, masjidSnap) {
        final masjid = masjidSnap.data;
        return StreamBuilder<AppUser?>(
          stream: AuthService.profileStream,
          builder: (context, profileSnap) {
            final user = profileSnap.data ?? profile;
            return Scaffold(
              appBar: AppBar(title: Text(masjid?.name ?? 'Masjid')),
              body: masjid == null
                  ? const Center(child: CircularProgressIndicator())
                  : _body(context, masjid, user),
            );
          },
        );
      },
    );
  }

  Widget _body(BuildContext context, Masjid masjid, AppUser? user) {
    final joined = user?.joinedMasjidIds.contains(masjid.id) ?? false;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(masjid.name,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    if (masjid.verified)
                      Tooltip(
                        message: AppLang.t('verified_masjid'),
                        child: const Icon(Icons.verified,
                            color: AppTheme.gold, size: 22),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('${masjid.address}, ${masjid.city}',
                    style: const TextStyle(color: Colors.black54)),
                Text('${AppLang.t('imam_label')}: ${masjid.imamName}',
                    style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 12),
                if (user != null)
                  FilledButton.icon(
                    icon: Icon(joined ? Icons.check : Icons.add),
                    style: joined
                        ? FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.deepGreen,
                            side: const BorderSide(color: AppTheme.deepGreen),
                          )
                        : null,
                    label: Text(joined
                        ? AppLang.t('joined_alerts_on')
                        : AppLang.t('join_this_masjid')),
                    onPressed: () => joined
                        ? _confirmLeave(context, masjid)
                        : MasjidService.joinMasjid(masjid.id),
                  ),
              ],
            ),
          ),
        ),
        // Silent community verification: joined members simply confirm they
        // pray here. Thresholds and deadlines are never shown to anyone.
        if (user != null &&
            joined &&
            user.uid != masjid.imamUid &&
            masjid.canBeVerifiedBy(user.uid)) ...[
          const SizedBox(height: 12),
          Card(
            color: AppTheme.lightGreen,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLang.t('pray_here_q'),
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(
                    AppLang.t('pray_here_body'),
                    style: const TextStyle(
                        fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: FilledButton.icon(
                      icon: const Icon(Icons.how_to_reg, size: 18),
                      label: Text(AppLang.t('yes_i_pray_here')),
                      onPressed: () async {
                        await MasjidService.verifyMasjid(masjid);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(AppLang.t(
                                      'confirmation_recorded'))));
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        Text(AppLang.t('jamaat_timings'),
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Card(child: TimingsCard(timings: masjid.timings)),
        const SizedBox(height: 16),
        Text(AppLang.t('announcements'),
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        StreamBuilder<List<Announcement>>(
          stream: MasjidService.announcementsStream(masjid.id),
          builder: (context, snap) {
            final items = snap.data ?? [];
            if (items.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(AppLang.t('no_announcements'),
                      style: const TextStyle(color: Colors.black54)),
                ),
              );
            }
            return Column(
              children: [
                for (final a in items)
                  Card(
                    child: ListTile(
                      leading:
                          const Icon(Icons.campaign, color: AppTheme.deepGreen),
                      title: Text(a.title,
                          style:
                              const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(a.body),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        Text(AppLang.t('campaigns'),
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        StreamBuilder<List<Campaign>>(
          stream: MasjidService.campaignsStream(masjid.id),
          builder: (context, snap) {
            final items = snap.data ?? [];
            if (items.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(AppLang.t('no_campaigns'),
                      style: const TextStyle(color: Colors.black54)),
                ),
              );
            }
            return Column(
              children: [for (final c in items) _campaignCard(context, c)],
            );
          },
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _campaignCard(BuildContext context, Campaign c) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.volunteer_activism,
                    color: AppTheme.gold, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(c.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ],
            ),
            if (c.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(c.description,
                  style: const TextStyle(color: Colors.black54)),
            ],
            if (c.qrBase64.isNotEmpty) ...[
              const SizedBox(height: 12),
              Center(
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        base64Decode(c.qrBase64),
                        width: 220,
                        height: 220,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) =>
                            const Text('QR code unavailable'),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppLang.t('scan_to_donate'),
                      style: const TextStyle(
                          fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLeave(BuildContext context, Masjid masjid) async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${AppLang.t('leave_q')} (${masjid.name})'),
        content: Text(AppLang.t('leave_body')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppLang.t('cancel'))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(AppLang.t('leave'))),
        ],
      ),
    );
    if (leave == true) await MasjidService.leaveMasjid(masjid.id);
  }
}
