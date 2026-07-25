import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/models.dart';
import '../../services/masjid_service.dart';
import '../../theme.dart';

/// Imam creates/closes fundraising campaigns and uploads the Masjid's
/// payment QR code image (stored compactly in Firestore).
class ManageCampaignsScreen extends StatefulWidget {
  final String masjidId;
  const ManageCampaignsScreen({super.key, required this.masjidId});

  @override
  State<ManageCampaignsScreen> createState() => _ManageCampaignsScreenState();
}

class _ManageCampaignsScreenState extends State<ManageCampaignsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fundraising campaigns')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('New campaign'),
        onPressed: () => _showCreateSheet(context),
      ),
      body: StreamBuilder<List<Campaign>>(
        stream: MasjidService.campaignsStream(widget.masjidId),
        builder: (context, snap) {
          final items = snap.data ?? [];
          if (items.isEmpty) {
            return const Center(
              child: Text('No active campaigns.\nCreate one to start collecting donations.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54)),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
            children: [
              for (final c in items)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 15)),
                        if (c.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(c.description,
                              style: const TextStyle(color: Colors.black54)),
                        ],
                        if (c.qrBase64.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Center(
                            child: Image.memory(base64Decode(c.qrBase64),
                                width: 160, height: 160),
                          ),
                        ],
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            icon: const Icon(Icons.close, size: 18),
                            label: const Text('Close campaign'),
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.red),
                            onPressed: () => MasjidService.closeCampaign(
                                widget.masjidId, c.id),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showCreateSheet(BuildContext context) async {
    final title = TextEditingController();
    final description = TextEditingController();
    String? qrBase64;
    bool busy = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('New fundraising campaign',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              TextField(
                controller: title,
                decoration: const InputDecoration(
                    labelText: 'Title (e.g. Masjid expansion fund)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: description,
                maxLines: 2,
                decoration:
                    const InputDecoration(labelText: 'Description (optional)'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: Icon(
                    qrBase64 == null ? Icons.qr_code : Icons.check_circle,
                    color: qrBase64 == null ? null : AppTheme.deepGreen),
                label: Text(qrBase64 == null
                    ? 'Upload payment QR code image'
                    : 'QR code attached ✓'),
                onPressed: () async {
                  final picker = ImagePicker();
                  final file = await picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 600,
                    maxHeight: 600,
                    imageQuality: 80,
                  );
                  if (file != null) {
                    final bytes = await file.readAsBytes();
                    if (bytes.length > 700 * 1024) {
                      if (sheetContext.mounted) {
                        ScaffoldMessenger.of(sheetContext).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Image too large. Use a smaller QR image.')));
                      }
                      return;
                    }
                    setSheetState(() => qrBase64 = base64Encode(bytes));
                  }
                },
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: busy
                    ? null
                    : () async {
                        if (title.text.trim().isEmpty) return;
                        setSheetState(() => busy = true);
                        await MasjidService.createCampaign(
                          widget.masjidId,
                          Campaign(
                            id: '',
                            title: title.text.trim(),
                            description: description.text.trim(),
                            qrBase64: qrBase64 ?? '',
                            active: true,
                          ),
                        );
                        if (sheetContext.mounted) {
                          Navigator.pop(sheetContext);
                        }
                      },
                child: const Text('Launch campaign'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
