import 'package:flutter/material.dart';

import '../l10n/app_lang.dart';
import '../models/models.dart';
import 'home/home_screen.dart';
import 'nearby/nearby_screen.dart';
import 'profile/profile_screen.dart';
import 'qibla/qibla_screen.dart';
import 'tracker/tracker_screen.dart';

/// Main app shell with bottom navigation.
class AppShell extends StatefulWidget {
  final AppUser profile;
  const AppShell({super.key, required this.profile});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  /// Kept across rebuilds (e.g. a language switch re-creates the tree)
  /// so the user stays on the tab they were viewing.
  static int _lastIndex = 0;

  late int _index = _lastIndex;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(profile: widget.profile),
      const NearbyScreen(),
      const QiblaScreen(),
      const TrackerScreen(),
      ProfileScreen(profile: widget.profile),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() {
          _index = i;
          _lastIndex = i;
        }),
        destinations: [
          NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: AppLang.t('nav_home')),
          NavigationDestination(
              icon: const Icon(Icons.near_me_outlined),
              selectedIcon: const Icon(Icons.near_me),
              label: AppLang.t('nav_nearby')),
          NavigationDestination(
              icon: const Icon(Icons.explore_outlined),
              selectedIcon: const Icon(Icons.explore),
              label: AppLang.t('nav_qibla')),
          NavigationDestination(
              icon: const Icon(Icons.calendar_month_outlined),
              selectedIcon: const Icon(Icons.calendar_month),
              label: AppLang.t('nav_tracker')),
          NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: const Icon(Icons.person),
              label: AppLang.t('nav_profile')),
        ],
      ),
    );
  }
}
