import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme.dart';
import '../utils/prayer_utils.dart';

/// The timetable table shown on the dashboard, nearby list, and detail pages.
class TimingsCard extends StatelessWidget {
  final PrayerTimings timings;
  final bool compact;

  const TimingsCard({super.key, required this.timings, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final next = nextJamaat(timings);
    final rows = kPrayerNames
        .where((p) => !timings[p].isEmpty)
        .map((p) => _row(context, p, timings[p], isNext: next?.name == p))
        .toList();

    if (rows.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Timings not published yet.',
            style: TextStyle(color: Colors.black54)),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              const Expanded(
                  flex: 3,
                  child: Text('Prayer',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black45))),
              Expanded(
                  flex: 2,
                  child: Text('Adhaan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black45))),
              Expanded(
                  flex: 2,
                  child: Text('Jamaat',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black45))),
            ],
          ),
        ),
        ...rows,
        if (next != null && !compact)
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: AppTheme.lightGreen,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.schedule, size: 16, color: AppTheme.deepGreen),
                const SizedBox(width: 6),
                Text(
                  'Next Jamaat: ${next.name} ${countdownText(next.jamaatTime)}',
                  style: const TextStyle(
                      color: AppTheme.deepGreen, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _row(BuildContext context, String prayer, PrayerTime pt,
      {required bool isNext}) {
    final style = TextStyle(
      fontSize: 15,
      fontWeight: isNext ? FontWeight.w700 : FontWeight.w500,
      color: isNext ? AppTheme.deepGreen : Colors.black87,
    );
    return Container(
      color: isNext ? AppTheme.lightGreen.withValues(alpha: 0.5) : null,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(prayer, style: style)),
          Expanded(
              flex: 2,
              child: Text(formatTime12(pt.adhaan),
                  textAlign: TextAlign.center, style: style)),
          Expanded(
              flex: 2,
              child: Text(formatTime12(pt.jamaat),
                  textAlign: TextAlign.end, style: style)),
        ],
      ),
    );
  }
}
