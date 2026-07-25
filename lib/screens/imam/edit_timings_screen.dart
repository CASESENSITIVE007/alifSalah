import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../services/masjid_service.dart';
import '../../theme.dart';
import '../../utils/prayer_utils.dart';

/// Imam edits the daily Adhaan & Jamaat timetable. Members' dashboards
/// update in real time and their Adhaan alerts are rescheduled.
class EditTimingsScreen extends StatefulWidget {
  final Masjid masjid;
  const EditTimingsScreen({super.key, required this.masjid});

  @override
  State<EditTimingsScreen> createState() => _EditTimingsScreenState();
}

class _EditTimingsScreenState extends State<EditTimingsScreen> {
  late Map<String, PrayerTime> _times;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _times = Map.of(widget.masjid.timings.times);
  }

  Future<void> _pick(String prayer, bool isJamaat) async {
    final current = _times[prayer] ?? const PrayerTime();
    final initial =
        toTimeOfDay(isJamaat ? current.jamaat : current.adhaan) ??
            const TimeOfDay(hour: 5, minute: 0);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;
    setState(() {
      _times[prayer] = PrayerTime(
        adhaan: isJamaat ? current.adhaan : fromTimeOfDay(picked),
        jamaat: isJamaat ? fromTimeOfDay(picked) : current.jamaat,
      );
    });
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    await MasjidService.updateTimings(
        widget.masjid.id, PrayerTimings(_times));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Timings published to your community ✓')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Jamaat timings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Tap a time to change it. Jumu\'ah replaces Dhuhr on Fridays.',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 12),
          for (final prayer in kPrayerNames) _prayerRow(prayer),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _busy ? null : _save,
            child: _busy
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Text('Publish timings'),
          ),
        ],
      ),
    );
  }

  Widget _prayerRow(String prayer) {
    final pt = _times[prayer] ?? const PrayerTime();
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Text(prayer,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15)),
            ),
            _timeChip('Adhaan', pt.adhaan, () => _pick(prayer, false)),
            const SizedBox(width: 8),
            _timeChip('Jamaat', pt.jamaat, () => _pick(prayer, true)),
          ],
        ),
      ),
    );
  }

  Widget _timeChip(String label, String? value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: value == null ? Colors.black.withValues(alpha: 0.04) : AppTheme.lightGreen,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: value == null ? Colors.black12 : AppTheme.deepGreen),
        ),
        child: Column(
          children: [
            Text(label,
                style: const TextStyle(fontSize: 10, color: Colors.black54)),
            Text(
              value == null ? 'Set' : formatTime12(value),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color:
                    value == null ? Colors.black38 : AppTheme.deepGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
