import 'package:flutter/material.dart';

import '../../l10n/app_lang.dart';
import '../../models/models.dart';
import '../../services/masjid_service.dart';

/// One-way broadcast to the community. No replies — zero noise by design.
class PostAnnouncementScreen extends StatefulWidget {
  final String masjidId;
  const PostAnnouncementScreen({super.key, required this.masjidId});

  @override
  State<PostAnnouncementScreen> createState() =>
      _PostAnnouncementScreenState();
}

class _PostAnnouncementScreenState extends State<PostAnnouncementScreen> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  bool _busy = false;

  Future<void> _post() async {
    if (_title.text.trim().isEmpty) return;
    setState(() => _busy = true);
    await MasjidService.postAnnouncement(
      widget.masjidId,
      Announcement(
          id: '', title: _title.text.trim(), body: _body.text.trim()),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLang.t('broadcast_done'))));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLang.t('post_announcement'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            AppLang.t('announce_tip'),
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _title,
            decoration: InputDecoration(labelText: AppLang.t('title')),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _body,
            maxLines: 5,
            decoration: InputDecoration(
                labelText: AppLang.t('message'), alignLabelWithHint: true),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _busy ? null : _post,
            child: _busy
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : Text(AppLang.t('broadcast')),
          ),
        ],
      ),
    );
  }
}
