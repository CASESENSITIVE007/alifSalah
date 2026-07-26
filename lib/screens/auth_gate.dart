import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/auth_service.dart';
import 'auth/login_screen.dart';
import 'auth/profile_setup_screen.dart';
import 'shell.dart';

/// Routes to Login → Profile setup → Main app based on auth state.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.authState,
      builder: (context, authSnap) {
        if (authSnap.connectionState == ConnectionState.waiting) {
          return const _Splash();
        }
        if (authSnap.data == null) return const LoginScreen();

        return StreamBuilder<AppUser?>(
          stream: AuthService.profileStream,
          builder: (context, profileSnap) {
            if (profileSnap.connectionState == ConnectionState.waiting) {
              return const _Splash();
            }
            final profile = profileSnap.data;
            if (profile == null) return const ProfileSetupScreen();
            return AppShell(profile: profile);
          },
        );
      },
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset('assets/icon/app_icon.png',
                  width: 110, height: 110, fit: BoxFit.cover),
            ),
            const SizedBox(height: 16),
            const Text('Alif-Salah',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20))),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
