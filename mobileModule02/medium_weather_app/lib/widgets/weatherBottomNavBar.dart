import 'package:flutter/material.dart';

class WeatherBottomNavBar extends StatelessWidget {
  const WeatherBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTabSelected,
          items: const [
            BottomNavigationBarItem(label: 'Currently', icon: Icon(Icons.now_widgets)),
            BottomNavigationBarItem(label: 'Today', icon: Icon(Icons.today)),
            BottomNavigationBarItem(label: 'Weekly', icon: Icon(Icons.calendar_view_week)),
          ],
        );
  }
}