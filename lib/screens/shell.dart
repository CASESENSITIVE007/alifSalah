import 'package:flutter/material.dart';

import '../models/models.dart';
import 'home/home_screen.dart';
import 'nearby/nearby_screen.dart';
import 'profile/profile_screen.dart';
import 'qibla/qibla_screen.dart';

/// Main app shell with bottom navigation.
class AppShell extends StatefulWidget {
  final AppUser profile;
  const AppShell({super.key, required this.profile});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(profile: widget.profile),
      const NearbyScreen(),
      const QiblaScreen(),
      ProfileScreen(profile: widget.profile),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.near_me_outlined),
              selectedIcon: Icon(Icons.near_me),
              label: 'Nearby'),
          NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore),
              label: 'Qibla'),
          NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile'),
        ],
      ),
    );
  }
}
