import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'firebase_options.dart';
import 'l10n/app_lang.dart';
import 'screens/auth_gate.dart';
import 'services/notification_service.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await AppLang.load();
  await NotificationService.init();
  runApp(const AlifSalahApp());
}

class AlifSalahApp extends StatelessWidget {
  const AlifSalahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLang.code,
      builder: (context, langCode, _) => MaterialApp(
        // Rebuilding under a new key re-creates every screen, so a language
        // switch applies instantly across the whole app.
        key: ValueKey(langCode),
        title: 'Alif-Salah',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        locale: Locale(langCode),
        supportedLocales: const [Locale('en'), Locale('ur')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const AuthGate(),
      ),
    );
  }
}
