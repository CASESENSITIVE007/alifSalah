/// Pure streak computations over a map of dateKey (yyyy-MM-dd) →
/// number of prayers completed that day (0–5).
library;

const int kPrayersPerDay = 5;

String dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

class StreakStats {
  final int currentStreak;
  final int bestStreak;
  final int completeDays;
  final int totalPrayers;

  const StreakStats({
    required this.currentStreak,
    required this.bestStreak,
    required this.completeDays,
    required this.totalPrayers,
  });
}

StreakStats computeStreaks(Map<String, int> counts, DateTime today) {
  bool isComplete(DateTime d) => (counts[dateKey(d)] ?? 0) >= kPrayersPerDay;

  // Current streak: consecutive complete days ending today, or ending
  // yesterday when today is still in progress.
  int current = 0;
  var day = isComplete(today)
      ? today
      : DateTime(today.year, today.month, today.day - 1);
  while (isComplete(day)) {
    current++;
    day = DateTime(day.year, day.month, day.day - 1);
  }

  // Best streak + totals over the whole log.
  int best = current, run = 0, completeDays = 0, totalPrayers = 0;
  final sortedKeys = counts.keys.toList()..sort();
  DateTime? prev;
  for (final key in sortedKeys) {
    final parts = key.split('-').map(int.parse).toList();
    final d = DateTime(parts[0], parts[1], parts[2]);
    totalPrayers += (counts[key] ?? 0).clamp(0, kPrayersPerDay);
    if ((counts[key] ?? 0) >= kPrayersPerDay) {
      completeDays++;
      final consecutive = prev != null &&
          d.difference(prev).inDays == 1;
      run = consecutive ? run + 1 : 1;
      if (run > best) best = run;
      prev = d;
    } else {
      prev = null;
      run = 0;
    }
  }

  return StreakStats(
    currentStreak: current,
    bestStreak: best,
    completeDays: completeDays,
    totalPrayers: totalPrayers,
  );
}
