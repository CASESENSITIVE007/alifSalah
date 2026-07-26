import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

import '../l10n/app_lang.dart';
import '../theme.dart';

/// Shows today's Gregorian and Hijri dates side by side, e.g.
/// "Sunday, 26 July 2026  •  11 Safar 1448 AH".
class DateBanner extends StatelessWidget {
  const DateBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final gregorian = DateFormat(
            'EEEE, d MMMM yyyy', AppLang.isUrdu ? 'ur' : 'en')
        .format(now);
    // Arabic month names read naturally in Urdu too.
    HijriCalendar.setLocal(AppLang.isUrdu ? 'ar' : 'en');
    final hijri = HijriCalendar.fromDate(now);
    final hijriText = AppLang.isUrdu
        ? '${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear}ھ'
        : '${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear} AH';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: AppTheme.deepGreen,
        border: Border(
          top: BorderSide(color: Colors.white24, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.brightness_2,
                  color: AppTheme.gold, size: 14),
              const SizedBox(width: 6),
              Text(
                hijriText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            gregorian,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
