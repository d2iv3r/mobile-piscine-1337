import 'package:flutter/material.dart';

/// A simple [PageView] wrapper. The [BottomNavigationBar] lives in the
/// [Scaffold] and is NOT included here to avoid duplication.
class WeatherPageView extends StatelessWidget {
  const WeatherPageView({
    super.key,
    required this.pageController,
    required this.pages,
    required this.onPageChanged,
  });

  final PageController pageController;
  final List<Widget> pages;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: pageController,
      onPageChanged: onPageChanged,
      children: pages,
    );
  }
}
