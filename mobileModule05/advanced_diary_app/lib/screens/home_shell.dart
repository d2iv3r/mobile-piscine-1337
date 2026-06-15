import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'agenda_screen.dart';

/// Hosts the two main pages of the app (Profile + Agenda) behind a
/// bottom navigation bar, as required by the Module 05 subject:
/// "Your application must now have 3 pages: login, profile, agenda."
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    ProfileScreen(),
    AgendaScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFE8F5EC),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: Color(0xFF2E7D52)),
            label: 'Profile',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today_rounded, color: Color(0xFF2E7D52)),
            label: 'Agenda',
          ),
        ],
      ),
    );
  }
}