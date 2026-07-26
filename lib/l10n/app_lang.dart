import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight English/Urdu localization. The chosen language is stored
/// on the device and applied app-wide, including RTL layout for Urdu.
class AppLang {
  static final ValueNotifier<String> code = ValueNotifier('en');

  static bool get isUrdu => code.value == 'ur';

  static Future<void> load() async {
    await initializeDateFormatting('ur');
    final prefs = await SharedPreferences.getInstance();
    code.value = prefs.getString('lang') ?? 'en';
  }

  static Future<void> set(String c) async {
    code.value = c;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lang', c);
  }

  /// Translates [key]; falls back to English, then to the key itself.
  static String t(String key) =>
      (code.value == 'ur' ? _ur[key] : null) ?? _en[key] ?? key;

  /// Display name for a prayer (data keys stay English internally).
  static String prayer(String name) => t('prayer_$name');

  static const Map<String, String> _en = {
    // Common
    'app_name': 'Alif-Salah',
    'tagline': 'Your Masjid, in your pocket',
    'retry': 'Retry',
    'cancel': 'Cancel',
    'required': 'Required',
    // Nav
    'nav_home': 'Home',
    'nav_nearby': 'Nearby',
    'nav_qibla': 'Qibla',
    'nav_tracker': 'Tracker',
    'nav_profile': 'Profile',
    // Tracker
    'prayer_tracker': 'Prayer Tracker',
    'todays_prayers': 'Today\'s Prayers',
    'tracker_tip':
        'Mark each prayer after you pray it. A day is complete when all five prayers are marked.',
    'current_streak': 'Current streak',
    'best_streak': 'Best streak',
    'complete_days': 'Complete days',
    'prayers_logged': 'Prayers logged',
    'days': 'days',
    'day_full': 'All 5 prayers',
    'day_partial': 'Some prayers',
    'day_none': 'None',
    // Tasbih
    'tasbih': 'Tasbih Counter',
    'choose_tasbih': 'Choose a Tasbih',
    'tap_to_count': 'Tap anywhere to count',
    'rounds': 'Rounds',
    'reset': 'Reset',
    // Login
    'phone_number': 'Phone number',
    'send_otp': 'Send OTP',
    'enter_code': 'Enter the 6-digit code sent to',
    'verify_continue': 'Verify & Continue',
    'change_number': 'Change number',
    'invalid_code': 'Invalid code. Please try again.',
    'invalid_phone': 'Enter a valid phone number',
    // Profile setup
    'setup_profile': 'Set up your profile',
    'full_name': 'Your full name',
    'i_am': 'I am a…',
    'role_muqtadi': 'Community Member (Muqtadi)',
    'role_muqtadi_desc':
        'Join Masjid spaces, see Jamaat timings, get Adhaan alerts, use the Qibla compass, and donate via QR.',
    'role_imam': 'Imam / Masjid Administrator',
    'role_imam_desc':
        'Create and manage your Masjid\'s space, publish Jamaat timings, and run fundraising campaigns.',
    'continue': 'Continue',
    // Prayers
    'prayer_Fajr': 'Fajr',
    'prayer_Dhuhr': 'Dhuhr',
    'prayer_Asr': 'Asr',
    'prayer_Maghrib': 'Maghrib',
    'prayer_Isha': 'Isha',
    'prayer_Jumuah': 'Jumu\'ah',
    // Timings table
    'prayer_col': 'Prayer',
    'adhaan': 'Adhaan',
    'jamaat': 'Jamaat',
    'not_published': 'Timings not published yet.',
    'next_jamaat': 'Next Jamaat',
    'next': 'Next',
    'now': 'now',
    'updated': 'Updated',
    // Home
    'join_a_masjid': 'Join a Masjid',
    'no_masjid_title': 'No Masjid joined yet',
    'no_masjid_body':
        'Join your local Masjid to see its Jamaat timings here and get Adhaan alerts. Or check the Nearby tab to view timings around you without joining.',
    'manage_my_masjid': 'Manage my Masjid',
    'verified_masjid': 'Verified Masjid',
    // Nearby
    'masjids_near_me': 'Masjids Near Me',
    'search_radius': 'Search radius',
    'show_map': 'Show map',
    'show_list': 'Show list',
    'no_nearby':
        'No Masjids found nearby.\nTry a larger radius, or invite your local Imam to Alif-Salah!',
    'location_needed':
        'Location permission is needed to find nearby Masjids.',
    'location_off': 'Turn on location services to find nearby Masjids.',
    'view_details': 'View details',
    'view_masjid_page': 'View Masjid page',
    'away': 'away',
    // Search
    'find_your_masjid': 'Find your Masjid',
    'search_hint': 'Masjid name or city…',
    'search_prompt': 'Search for your local Masjid to join.',
    'no_results': 'No Masjids found for that search.',
    // Masjid detail
    'imam_label': 'Imam',
    'join_this_masjid': 'Join this Masjid',
    'joined_alerts_on': 'Joined — Adhaan alerts on',
    'leave_q': 'Leave this Masjid?',
    'leave_body': 'You will stop receiving Adhaan alerts for this Masjid.',
    'leave': 'Leave',
    'jamaat_timings': 'Jamaat Timings',
    'announcements': 'Announcements',
    'no_announcements': 'No announcements yet.',
    'campaigns': 'Fundraising Campaigns',
    'no_campaigns': 'No active campaigns.',
    'scan_to_donate': 'Scan with your payment app to donate',
    'pray_here_q': 'Do you pray at this Masjid?',
    'pray_here_body':
        'Confirming helps your community trust that this Masjid space is genuine.',
    'yes_i_pray_here': 'Yes, I pray here',
    'confirmation_recorded': 'JazakAllah khair — confirmation recorded.',
    // Qibla
    'qibla_compass': 'Qibla Compass',
    'facing_qibla': 'Facing the Qibla ✓',
    'rotate_arrow': 'Rotate towards the arrow',
    'qibla_from_north': 'Qibla',
    'heading': 'Heading',
    'compass_unavailable': 'Compass sensor not available on this device.',
    'compass_tip':
        'Hold your phone flat and away from magnets for best accuracy.',
    'qibla_location_needed': 'Location permission needed to compute Qibla.',
    // Profile
    'profile': 'Profile',
    'adhaan_alerts': 'Adhaan buzzer alerts',
    'adhaan_alerts_desc':
        'Notifications at Adhaan time and 10 minutes before Jamaat, for your joined Masjids only.',
    'sign_out': 'Sign out',
    'sign_out_q': 'Sign out?',
    'language': 'Language / زبان',
    // Imam dashboard
    'imam_dashboard': 'Manage my Masjid',
    'need_muqtadis':
        'To get verified, you need more muqtadis to join your Masjid.',
    'warn_join_now': 'Get muqtadis to join immediately',
    'warn_join_now_body':
        'Masjid spaces with no muqtadis are deleted after 24 hours. Share the app with your community now.',
    'space_deleted':
        'Your Masjid space was deleted because no muqtadis joined within 24 hours.\n\nYour account is safe — you can create the space again anytime.',
    'update_timings': 'Update Jamaat timings',
    'update_timings_desc':
        'Publish today\'s Adhaan & Jamaat times. Members see changes instantly.',
    'post_announcement': 'Post an announcement',
    'post_announcement_desc':
        'One-way broadcast to your community. No replies, no noise.',
    'campaigns_admin': 'Fundraising campaigns',
    'campaigns_admin_desc':
        'Start a campaign and upload your Masjid\'s payment QR code.',
    'create_space_title': 'Create your Masjid\'s Community Space',
    'create_space_body':
        'Set up your Masjid so your community can join, see live Jamaat timings, and receive Adhaan alerts.',
    'create_space_btn': 'Create Masjid space',
    // Create masjid
    'masjid_name': 'Masjid name',
    'address_label': 'Address (street / colony)',
    'city': 'City',
    'daily_muqtadis_q': 'How many muqtadis come to your Masjid every day?',
    'minimum': 'Minimum (e.g. 20)',
    'maximum': 'Maximum (e.g. 50)',
    'enter_number': 'Enter a number',
    'gte_min': 'Must be ≥ minimum',
    'location_not_captured': 'Masjid location not captured',
    'location_captured': 'Location captured ✓',
    'capture_hint':
        'Stand inside the Masjid and tap Capture. This powers the "Nearby Masjids" feature.',
    'capture': 'Capture',
    'create_community_space': 'Create Community Space',
    'capture_first': 'Capture the Masjid\'s location before creating the space.',
    'create_note':
        'Your Masjid space is created instantly. The Verified badge is earned as more muqtadis join your community.',
    // Edit timings
    'edit_timings_tip':
        'Tap a time to change it. Jumu\'ah replaces Dhuhr on Fridays.',
    'set': 'Set',
    'publish_timings': 'Publish timings',
    'timings_published': 'Timings published to your community ✓',
    // Announcements
    'announce_tip':
        'Announcements are one-way broadcasts. Community members can read them but cannot reply.',
    'title': 'Title',
    'message': 'Message',
    'broadcast': 'Broadcast to community',
    'broadcast_done': 'Announcement broadcast ✓',
    // Campaigns admin
    'new_campaign': 'New campaign',
    'new_campaign_title': 'New fundraising campaign',
    'campaign_title_hint': 'Title (e.g. Masjid expansion fund)',
    'description_opt': 'Description (optional)',
    'upload_qr': 'Upload payment QR code image',
    'qr_attached': 'QR code attached ✓',
    'launch_campaign': 'Launch campaign',
    'close_campaign': 'Close campaign',
    'no_campaigns_admin':
        'No active campaigns.\nCreate one to start collecting donations.',
  };

  static const Map<String, String> _ur = {
    // Common
    'app_name': 'الف صلاح',
    'tagline': 'آپ کی مسجد، آپ کی جیب میں',
    'retry': 'دوبارہ کوشش کریں',
    'cancel': 'منسوخ',
    'required': 'ضروری ہے',
    // Nav
    'nav_home': 'ہوم',
    'nav_nearby': 'قریبی',
    'nav_qibla': 'قبلہ',
    'nav_tracker': 'ٹریکر',
    'nav_profile': 'پروفائل',
    // Tracker
    'prayer_tracker': 'نماز ٹریکر',
    'todays_prayers': 'آج کی نمازیں',
    'tracker_tip':
        'ہر نماز ادا کرنے کے بعد نشان لگائیں۔ پانچوں نمازیں مکمل ہونے پر دن مکمل شمار ہوتا ہے۔',
    'current_streak': 'موجودہ سلسلہ',
    'best_streak': 'بہترین سلسلہ',
    'complete_days': 'مکمل دن',
    'prayers_logged': 'کل نمازیں',
    'days': 'دن',
    'day_full': 'پانچوں نمازیں',
    'day_partial': 'کچھ نمازیں',
    'day_none': 'کوئی نہیں',
    // Tasbih
    'tasbih': 'تسبیح کاؤنٹر',
    'choose_tasbih': 'تسبیح منتخب کریں',
    'tap_to_count': 'گنتی کے لیے کہیں بھی ٹیپ کریں',
    'rounds': 'چکر',
    'reset': 'ری سیٹ',
    // Login
    'phone_number': 'فون نمبر',
    'send_otp': 'او ٹی پی بھیجیں',
    'enter_code': 'اس نمبر پر بھیجا گیا 6 ہندسوں کا کوڈ درج کریں',
    'verify_continue': 'تصدیق کریں اور جاری رکھیں',
    'change_number': 'نمبر تبدیل کریں',
    'invalid_code': 'غلط کوڈ۔ دوبارہ کوشش کریں۔',
    'invalid_phone': 'درست فون نمبر درج کریں',
    // Profile setup
    'setup_profile': 'اپنا پروفائل بنائیں',
    'full_name': 'آپ کا پورا نام',
    'i_am': 'میں ہوں…',
    'role_muqtadi': 'کمیونٹی ممبر (مقتدی)',
    'role_muqtadi_desc':
        'مسجد اسپیس میں شامل ہوں، جماعت کے اوقات دیکھیں، اذان الرٹس پائیں، قبلہ کمپاس استعمال کریں اور QR سے عطیہ دیں۔',
    'role_imam': 'امام / مسجد منتظم',
    'role_imam_desc':
        'اپنی مسجد کی اسپیس بنائیں اور اس کا انتظام کریں، جماعت کے اوقات شائع کریں اور چندہ مہمات چلائیں۔',
    'continue': 'جاری رکھیں',
    // Prayers
    'prayer_Fajr': 'فجر',
    'prayer_Dhuhr': 'ظہر',
    'prayer_Asr': 'عصر',
    'prayer_Maghrib': 'مغرب',
    'prayer_Isha': 'عشاء',
    'prayer_Jumuah': 'جمعہ',
    // Timings table
    'prayer_col': 'نماز',
    'adhaan': 'اذان',
    'jamaat': 'جماعت',
    'not_published': 'اوقات ابھی شائع نہیں ہوئے۔',
    'next_jamaat': 'اگلی جماعت',
    'next': 'اگلی',
    'now': 'ابھی',
    'updated': 'اپڈیٹ',
    // Home
    'join_a_masjid': 'مسجد میں شامل ہوں',
    'no_masjid_title': 'ابھی کسی مسجد میں شامل نہیں ہوئے',
    'no_masjid_body':
        'اپنی محلے کی مسجد میں شامل ہوں تاکہ یہاں جماعت کے اوقات دیکھیں اور اذان الرٹس پائیں۔ یا قریبی ٹیب میں بغیر شامل ہوئے اوقات دیکھیں۔',
    'manage_my_masjid': 'میری مسجد کا انتظام',
    'verified_masjid': 'تصدیق شدہ مسجد',
    // Nearby
    'masjids_near_me': 'میرے قریب مساجد',
    'search_radius': 'تلاش کا دائرہ',
    'show_map': 'نقشہ دکھائیں',
    'show_list': 'فہرست دکھائیں',
    'no_nearby':
        'قریب کوئی مسجد نہیں ملی۔\nبڑا دائرہ منتخب کریں، یا اپنے امام صاحب کو الف صلاح پر مدعو کریں!',
    'location_needed': 'قریبی مساجد تلاش کرنے کے لیے لوکیشن کی اجازت درکار ہے۔',
    'location_off': 'قریبی مساجد کے لیے لوکیشن سروس آن کریں۔',
    'view_details': 'تفصیلات دیکھیں',
    'view_masjid_page': 'مسجد کا صفحہ دیکھیں',
    'away': 'دور',
    // Search
    'find_your_masjid': 'اپنی مسجد تلاش کریں',
    'search_hint': 'مسجد کا نام یا شہر…',
    'search_prompt': 'شامل ہونے کے لیے اپنی محلے کی مسجد تلاش کریں۔',
    'no_results': 'اس تلاش پر کوئی مسجد نہیں ملی۔',
    // Masjid detail
    'imam_label': 'امام',
    'join_this_masjid': 'اس مسجد میں شامل ہوں',
    'joined_alerts_on': 'شامل ہیں — اذان الرٹس آن',
    'leave_q': 'یہ مسجد چھوڑ دیں؟',
    'leave_body': 'اس مسجد کے اذان الرٹس آنا بند ہو جائیں گے۔',
    'leave': 'چھوڑ دیں',
    'jamaat_timings': 'جماعت کے اوقات',
    'announcements': 'اعلانات',
    'no_announcements': 'ابھی کوئی اعلان نہیں۔',
    'campaigns': 'چندہ مہمات',
    'no_campaigns': 'کوئی فعال مہم نہیں۔',
    'scan_to_donate': 'عطیہ دینے کے لیے اپنی پیمنٹ ایپ سے اسکین کریں',
    'pray_here_q': 'کیا آپ اس مسجد میں نماز پڑھتے ہیں؟',
    'pray_here_body':
        'تصدیق کرنے سے کمیونٹی کو بھروسہ ہوتا ہے کہ یہ مسجد اسپیس اصلی ہے۔',
    'yes_i_pray_here': 'ہاں، میں یہاں نماز پڑھتا ہوں',
    'confirmation_recorded': 'جزاک اللہ خیر — تصدیق درج ہو گئی۔',
    // Qibla
    'qibla_compass': 'قبلہ کمپاس',
    'facing_qibla': 'آپ قبلہ رخ ہیں ✓',
    'rotate_arrow': 'تیر کی سمت گھومیں',
    'qibla_from_north': 'قبلہ',
    'heading': 'رخ',
    'compass_unavailable': 'اس ڈیوائس میں کمپاس سینسر موجود نہیں۔',
    'compass_tip':
        'بہتر درستگی کے لیے فون کو سیدھا رکھیں اور مقناطیس سے دور رکھیں۔',
    'qibla_location_needed': 'قبلہ معلوم کرنے کے لیے لوکیشن کی اجازت درکار ہے۔',
    // Profile
    'profile': 'پروفائل',
    'adhaan_alerts': 'اذان الرٹس',
    'adhaan_alerts_desc':
        'صرف آپ کی شامل شدہ مساجد کے لیے اذان کے وقت اور جماعت سے 10 منٹ پہلے اطلاعات۔',
    'sign_out': 'سائن آؤٹ',
    'sign_out_q': 'سائن آؤٹ کریں؟',
    'language': 'Language / زبان',
    // Imam dashboard
    'imam_dashboard': 'میری مسجد کا انتظام',
    'need_muqtadis':
        'تصدیق شدہ ہونے کے لیے مزید مقتدیوں کا آپ کی مسجد میں شامل ہونا ضروری ہے۔',
    'warn_join_now': 'فوری طور پر مقتدیوں کو شامل کروائیں',
    'warn_join_now_body':
        'جن مسجد اسپیس میں کوئی مقتدی نہ ہو وہ 24 گھنٹے بعد حذف کر دی جاتی ہیں۔ ابھی اپنی کمیونٹی میں ایپ شیئر کریں۔',
    'space_deleted':
        'آپ کی مسجد اسپیس حذف کر دی گئی کیونکہ 24 گھنٹوں میں کوئی مقتدی شامل نہیں ہوا۔\n\nآپ کا اکاؤنٹ محفوظ ہے — آپ کبھی بھی دوبارہ اسپیس بنا سکتے ہیں۔',
    'update_timings': 'جماعت کے اوقات اپڈیٹ کریں',
    'update_timings_desc':
        'آج کے اذان اور جماعت کے اوقات شائع کریں۔ ممبرز کو فوراً نظر آئیں گے۔',
    'post_announcement': 'اعلان کریں',
    'post_announcement_desc':
        'کمیونٹی کے لیے یک طرفہ پیغام۔ نہ جواب، نہ شور۔',
    'campaigns_admin': 'چندہ مہمات',
    'campaigns_admin_desc':
        'مہم شروع کریں اور مسجد کا پیمنٹ QR کوڈ اپلوڈ کریں۔',
    'create_space_title': 'اپنی مسجد کی کمیونٹی اسپیس بنائیں',
    'create_space_body':
        'اپنی مسجد سیٹ اپ کریں تاکہ کمیونٹی شامل ہو، جماعت کے اوقات دیکھے اور اذان الرٹس پائے۔',
    'create_space_btn': 'مسجد اسپیس بنائیں',
    // Create masjid
    'masjid_name': 'مسجد کا نام',
    'address_label': 'پتہ (گلی / محلہ)',
    'city': 'شہر',
    'daily_muqtadis_q': 'روزانہ آپ کی مسجد میں کتنے مقتدی آتے ہیں؟',
    'minimum': 'کم از کم (مثلاً 20)',
    'maximum': 'زیادہ سے زیادہ (مثلاً 50)',
    'enter_number': 'نمبر درج کریں',
    'gte_min': 'کم از کم سے زیادہ ہونا چاہیے',
    'location_not_captured': 'مسجد کی لوکیشن محفوظ نہیں ہوئی',
    'location_captured': 'لوکیشن محفوظ ہو گئی ✓',
    'capture_hint':
        'مسجد کے اندر کھڑے ہو کر کیپچر دبائیں۔ اسی سے "قریبی مساجد" فیچر چلتا ہے۔',
    'capture': 'کیپچر',
    'create_community_space': 'کمیونٹی اسپیس بنائیں',
    'capture_first': 'اسپیس بنانے سے پہلے مسجد کی لوکیشن کیپچر کریں۔',
    'create_note':
        'آپ کی مسجد اسپیس فوراً بن جاتی ہے۔ تصدیق شدہ بیج مزید مقتدیوں کے شامل ہونے سے ملتا ہے۔',
    // Edit timings
    'edit_timings_tip':
        'وقت تبدیل کرنے کے لیے اس پر ٹیپ کریں۔ جمعہ کو ظہر کی جگہ جمعہ ہوتا ہے۔',
    'set': 'سیٹ کریں',
    'publish_timings': 'اوقات شائع کریں',
    'timings_published': 'اوقات کمیونٹی کو شائع ہو گئے ✓',
    // Announcements
    'announce_tip':
        'اعلانات یک طرفہ ہوتے ہیں۔ ممبرز پڑھ سکتے ہیں مگر جواب نہیں دے سکتے۔',
    'title': 'عنوان',
    'message': 'پیغام',
    'broadcast': 'کمیونٹی کو بھیجیں',
    'broadcast_done': 'اعلان بھیج دیا گیا ✓',
    // Campaigns admin
    'new_campaign': 'نئی مہم',
    'new_campaign_title': 'نئی چندہ مہم',
    'campaign_title_hint': 'عنوان (مثلاً مسجد کی توسیع کا فنڈ)',
    'description_opt': 'تفصیل (اختیاری)',
    'upload_qr': 'پیمنٹ QR کوڈ کی تصویر اپلوڈ کریں',
    'qr_attached': 'QR کوڈ منسلک ہو گیا ✓',
    'launch_campaign': 'مہم شروع کریں',
    'close_campaign': 'مہم بند کریں',
    'no_campaigns_admin':
        'کوئی فعال مہم نہیں۔\nعطیات جمع کرنے کے لیے ایک مہم بنائیں۔',
  };
}
