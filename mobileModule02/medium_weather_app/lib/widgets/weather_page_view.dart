import 'package:flutter/material.dart';

class WeatherPageView extends StatelessWidget {
  const WeatherPageView({
    super.key,
    required this.pageController,
    required this.pages,
    required this.currentIndex,
    required this.onPageChanged,
    required this.onTabSelected,
  });

  final PageController pageController;
  final List<Widget> pages;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView(
            controller: pageController,
            onPageChanged: onPageChanged,
            children: pages,
          ),
        ),
        BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTabSelected,
          items: const [
            BottomNavigationBarItem(
              label: 'Currently',
              icon: Icon(Icons.now_widgets),
            ),
            BottomNavigationBarItem(label: 'Today', icon: Icon(Icons.today)),
            BottomNavigationBarItem(
              label: 'Weekly',
              icon: Icon(Icons.calendar_view_week),
            ),
          ],
        ),
      ],
    );
  }
}
