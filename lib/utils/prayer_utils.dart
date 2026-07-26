import 'package:flutter/material.dart';

import '../l10n/app_lang.dart';
import '../models/models.dart';

/// Parses an "HH:mm" string into a DateTime today (local time).
DateTime? parseTimeToday(String? hhmm, {DateTime? day}) {
  if (hhmm == null || hhmm.isEmpty) return null;
  final parts = hhmm.split(':');
  if (parts.length != 2) return null;
  final h = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  if (h == null || m == null) return null;
  final d = day ?? DateTime.now();
  return DateTime(d.year, d.month, d.day, h, m);
}

/// Formats "HH:mm" (24h) into a friendly "h:mm AM/PM" string.
String formatTime12(String? hhmm) {
  final dt = parseTimeToday(hhmm);
  if (dt == null) return '--:--';
  final h12 = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
  final ampm = dt.hour >= 12 ? 'PM' : 'AM';
  return '$h12:${dt.minute.toString().padLeft(2, '0')} $ampm';
}

/// Converts "HH:mm" to TimeOfDay for pickers.
TimeOfDay? toTimeOfDay(String? hhmm) {
  final dt = parseTimeToday(hhmm);
  if (dt == null) return null;
  return TimeOfDay(hour: dt.hour, minute: dt.minute);
}

String fromTimeOfDay(TimeOfDay t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

/// Whether [prayer] applies today (Jumu'ah only on Friday).
bool prayerAppliesToday(String prayer, {DateTime? day}) {
  final d = day ?? DateTime.now();
  if (prayer == 'Jumuah') return d.weekday == DateTime.friday;
  if (prayer == 'Dhuhr') return d.weekday != DateTime.friday;
  return true;
}

class NextPrayer {
  final String name;
  final DateTime jamaatTime;
  const NextPrayer(this.name, this.jamaatTime);
}

/// Finds the next upcoming Jamaat from [timings], today or tomorrow.
NextPrayer? nextJamaat(PrayerTimings timings) {
  final now = DateTime.now();
  for (final dayOffset in [0, 1]) {
    final day = now.add(Duration(days: dayOffset));
    final candidates = <NextPrayer>[];
    for (final prayer in kPrayerNames) {
      if (!prayerAppliesToday(prayer, day: day)) continue;
      final t = parseTimeToday(timings[prayer].jamaat, day: day);
      if (t != null && t.isAfter(now)) candidates.add(NextPrayer(prayer, t));
    }
    if (candidates.isNotEmpty) {
      candidates.sort((a, b) => a.jamaatTime.compareTo(b.jamaatTime));
      return candidates.first;
    }
  }
  return null;
}

String countdownText(DateTime target) {
  final diff = target.difference(DateTime.now());
  if (diff.isNegative) return AppLang.t('now');
  final h = diff.inHours;
  final m = diff.inMinutes % 60;
  if (AppLang.isUrdu) {
    if (h > 0) return '$h گھنٹے $m منٹ میں';
    return '$m منٹ میں';
  }
  if (h > 0) return 'in ${h}h ${m}m';
  return 'in ${m}m';
}
