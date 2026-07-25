import 'dart:convert';

import 'package:flutter/material.dart';

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
                      const Icon(Icons.verified,
                          color: AppTheme.deepGreen, size: 20)
                    else
                      const Tooltip(
                        message: 'Pending verification',
                        child: Icon(Icons.hourglass_top,
                            color: AppTheme.gold, size: 20),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('${masjid.address}, ${masjid.city}',
                    style: const TextStyle(color: Colors.black54)),
                Text('Imam: ${masjid.imamName}',
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
                        ? 'Joined — Adhaan alerts on'
                        : 'Join this Masjid'),
                    onPressed: () => joined
                        ? _confirmLeave(context, masjid)
                        : MasjidService.joinMasjid(masjid.id),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Jamaat Timings',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Card(child: TimingsCard(timings: masjid.timings)),
        const SizedBox(height: 16),
        const Text('Announcements',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        StreamBuilder<List<Announcement>>(
          stream: MasjidService.announcementsStream(masjid.id),
          builder: (context, snap) {
            final items = snap.data ?? [];
            if (items.isEmpty) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No announcements yet.',
                      style: TextStyle(color: Colors.black54)),
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
        const Text('Fundraising Campaigns',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        StreamBuilder<List<Campaign>>(
          stream: MasjidService.campaignsStream(masjid.id),
          builder: (context, snap) {
            final items = snap.data ?? [];
            if (items.isEmpty) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No active campaigns.',
                      style: TextStyle(color: Colors.black54)),
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
                    const Text(
                      'Scan with your payment app to donate',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
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
        title: Text('Leave ${masjid.name}?'),
        content: const Text(
            'You will stop receiving Adhaan alerts for this Masjid.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Leave')),
        ],
      ),
    );
    if (leave == true) await MasjidService.leaveMasjid(masjid.id);
  }
}
