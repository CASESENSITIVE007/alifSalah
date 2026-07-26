import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_lang.dart';
import '../../services/prayer_log_service.dart';
import '../../theme.dart';
import '../../utils/streak.dart';

/// Prayer streak tracker: tick off each prayer, watch your streak grow,
/// and review the month at a glance.
class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen>
    with AutomaticKeepAliveClientMixin {
  late DateTime _month;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
  }

  /// The five daily slots; Friday shows Jumu'ah in the Dhuhr slot.
  List<String> get _todaySlots {
    final isFriday = DateTime.now().weekday == DateTime.friday;
    return ['Fajr', isFriday ? 'Jumuah' : 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
  }

  /// Storage always uses the Dhuhr key so streaks work across weekdays.
  String _storageKey(String slot) => slot == 'Jumuah' ? 'Dhuhr' : slot;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(title: Text(AppLang.t('prayer_tracker'))),
      body: StreamBuilder<Map<String, Map<String, bool>>>(
        stream: PrayerLogService.logStream(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final log = snap.data!;
          final counts = {
            for (final e in log.entries)
              e.key: e.value.values.where((v) => v).length
          };
          final today = DateTime.now();
          final stats = computeStreaks(counts, today);
          final todayLog = log[dateKey(today)] ?? {};

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _streakHeader(stats),
              const SizedBox(height: 16),
              Text(AppLang.t('todays_prayers'),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(AppLang.t('tracker_tip'),
                  style: const TextStyle(
                      fontSize: 12.5, color: Colors.black54)),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    for (final slot in _todaySlots)
                      CheckboxListTile(
                        value: todayLog[_storageKey(slot)] ?? false,
                        activeColor: AppTheme.deepGreen,
                        title: Text(AppLang.prayer(slot),
                            style: const TextStyle(
                                fontWeight: FontWeight.w600)),
                        onChanged: (v) => PrayerLogService.setPrayer(
                            today, _storageKey(slot), v ?? false),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _calendarCard(counts, today),
              const SizedBox(height: 8),
              _legend(),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _streakHeader(StreakStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_fire_department,
                    color: AppTheme.gold, size: 40),
                const SizedBox(width: 8),
                Text('${stats.currentStreak}',
                    style: const TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.deepGreen)),
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child: Text(AppLang.t('days'),
                      style: const TextStyle(
                          fontSize: 16, color: Colors.black54)),
                ),
              ],
            ),
            Text(AppLang.t('current_streak'),
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.black54)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _stat('${stats.bestStreak}', AppLang.t('best_streak')),
                _stat('${stats.completeDays}', AppLang.t('complete_days')),
                _stat('${stats.totalPrayers}', AppLang.t('prayers_logged')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.deepGreen)),
        Text(label,
            style: const TextStyle(fontSize: 11.5, color: Colors.black54)),
      ],
    );
  }

  Widget _calendarCard(Map<String, int> counts, DateTime today) {
    final locale = AppLang.isUrdu ? 'ur' : 'en';
    final monthTitle = DateFormat('MMMM yyyy', locale).format(_month);
    final firstOfMonth = _month;
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    // Monday-first grid offset.
    final leadingBlanks = (firstOfMonth.weekday - 1) % 7;
    final canGoForward = _month.isBefore(DateTime(today.year, today.month));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => setState(() =>
                      _month = DateTime(_month.year, _month.month - 1)),
                ),
                Expanded(
                  child: Text(monthTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: canGoForward
                      ? () => setState(() =>
                          _month = DateTime(_month.year, _month.month + 1))
                      : null,
                ),
              ],
            ),
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              children: [
                for (int i = 0; i < leadingBlanks; i++)
                  const SizedBox.shrink(),
                for (int day = 1; day <= daysInMonth; day++)
                  _dayCell(
                      DateTime(_month.year, _month.month, day), counts, today),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dayCell(DateTime date, Map<String, int> counts, DateTime today) {
    final isFuture = date.isAfter(today);
    final count = counts[dateKey(date)] ?? 0;
    final isToday = dateKey(date) == dateKey(today);

    Color bg;
    Color fg;
    if (isFuture) {
      bg = Colors.transparent;
      fg = Colors.black26;
    } else if (count >= kPrayersPerDay) {
      bg = AppTheme.deepGreen;
      fg = Colors.white;
    } else if (count > 0) {
      bg = AppTheme.lightGreen;
      fg = AppTheme.deepGreen;
    } else {
      bg = Colors.black.withValues(alpha: 0.05);
      fg = Colors.black38;
    }

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: isToday
            ? Border.all(color: AppTheme.gold, width: 2)
            : null,
      ),
      alignment: Alignment.center,
      child: Text('${date.day}',
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
    );
  }

  Widget _legend() {
    Widget item(Color color, String label, {Color? border}) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
                border: border != null ? Border.all(color: border) : null,
              ),
            ),
            const SizedBox(width: 4),
            Text(label,
                style:
                    const TextStyle(fontSize: 11, color: Colors.black54)),
          ],
        );

    return Wrap(
      spacing: 16,
      runSpacing: 4,
      alignment: WrapAlignment.center,
      children: [
        item(AppTheme.deepGreen, AppLang.t('day_full')),
        item(AppTheme.lightGreen, AppLang.t('day_partial')),
        item(Colors.black.withValues(alpha: 0.05), AppLang.t('day_none'),
            border: Colors.black12),
      ],
    );
  }
}
