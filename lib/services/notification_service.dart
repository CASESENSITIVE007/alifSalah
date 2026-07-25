import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

import '../models/models.dart';
import '../utils/prayer_utils.dart';

/// Adhaan buzzer notifications — scheduled locally from the Jamaat/Adhaan
/// timetable of the Masjids the user has JOINED. Nearby (non-enrolled)
/// masjids never trigger notifications.
class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static const _channel = AndroidNotificationDetails(
    'adhaan_buzzer',
    'Adhaan Buzzer',
    channelDescription: 'Alerts at Adhaan time for your joined Masjids',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
  );

  static Future<void> init() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      // Fall back to the default local location.
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();
    _initialized = true;
  }

  /// Reschedules all Adhaan alerts for the user's joined masjids.
  /// Called whenever the joined list or any timetable changes.
  static Future<void> rescheduleForMasjids(List<Masjid> masjids,
      {required bool enabled}) async {
    await init();
    await _plugin.cancelAll();
    if (!enabled) return;

    int notifId = 0;
    final now = DateTime.now();

    // Schedule for today and tomorrow; refreshed on every app open and
    // whenever the imam updates timings (Firestore stream).
    for (final masjid in masjids) {
      for (final dayOffset in [0, 1]) {
        final day = now.add(Duration(days: dayOffset));
        for (final prayer in kPrayerNames) {
          if (!prayerAppliesToday(prayer, day: day)) continue;
          final pt = masjid.timings[prayer];
          final adhaanAt = parseTimeToday(pt.adhaan, day: day);
          if (adhaanAt != null && adhaanAt.isAfter(now)) {
            await _schedule(
              id: notifId++,
              when: adhaanAt,
              title: '$prayer Adhaan — ${masjid.name}',
              body: pt.jamaat != null
                  ? 'Jamaat at ${formatTime12(pt.jamaat)}. Prepare for Salah.'
                  : 'It is time for $prayer.',
            );
          }
          // A second alert 10 minutes before Jamaat.
          final jamaatAt = parseTimeToday(pt.jamaat, day: day);
          if (jamaatAt != null) {
            final reminder = jamaatAt.subtract(const Duration(minutes: 10));
            if (reminder.isAfter(now)) {
              await _schedule(
                id: notifId++,
                when: reminder,
                title: '$prayer Jamaat in 10 minutes',
                body: '${masjid.name} — Jamaat at ${formatTime12(pt.jamaat)}',
              );
            }
          }
          if (notifId > 120) return; // platform scheduling limits
        }
      }
    }
  }

  static Future<void> _schedule({
    required int id,
    required DateTime when,
    required String title,
    required String body,
  }) async {
    try {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(when, tz.local),
        notificationDetails: const NotificationDetails(
            android: _channel, iOS: DarwinNotificationDetails()),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (_) {
      // Exact alarms may be denied; skip silently rather than crash.
    }
  }

  static Future<void> cancelAll() => _plugin.cancelAll();
}
