import 'dart:async';

import 'package:flutter/material.dart';
import 'package:medium_weather_app/widgets/city_results_list.dart';
import 'package:medium_weather_app/widgets/search_controls.dart';
import 'package:medium_weather_app/widgets/weather_page_view.dart';
import 'package:medium_weather_app/widgets/weather_pages.dart';
import 'package:medium_weather_app/services/weather_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:medium_weather_app/widgets/weatherBottomNavBar.dart';

void main() {
  runApp(const MainApp());
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentLocationWeather();
    });
  }

  Future<void> _loadCurrentLocationWeather() async {
    final permission = await Permission.location.status;
    if (permission.isGranted) {
      try {
        final coordinates = await getCurrentLocation();
        final city = await reverseGeocode(
          coordinates.latitude,
          coordinates.longitude,
        ).catchError((_) {
          _showErrorPages(apiFailureMessage);
          return null;
        });

        if (!mounted) {
          return;
        }

        await updatePages(
          city ?? {
            'name': 'Current location',
            'admin1': '',
            'country': '',
            'latitude': coordinates.latitude,
            'longitude': coordinates.longitude,
          },
        );
      } catch (error) {
        _showLocationError(error.toString());
      }
    } else {
      await _requestLocationPermission();
    }
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      await _loadCurrentLocationWeather();
    } else if (status.isDenied) {
      _showLocationError(
        'Geolocation is not available. please enable it in your App settings',
      );
    } else if (status.isPermanentlyDenied) {
      _showLocationError(
        'Geolocation is not available. please enable it in your App settings',
      );
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _pageController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _showLocationError(String message) {
    _showErrorPages(message);
  }

  void _showErrorPages(String message) {
    if (!mounted) {
      return;
    }

    setState(() {
      showCityData = true;
      pages[0] = WeatherMessagePage(message: message);
      pages[1] = WeatherMessagePage(message: message);
      pages[2] = WeatherMessagePage(message: message);
    });
  }

  int currentIndex = 0;
  final TextEditingController _cityController = TextEditingController();

  final List<Widget> pages = [
    Center(child: Text('Currently')),
    Center(child: Text('Today')),
    Center(child: Text('Weekly')),
  ];

  List<dynamic> result = [];
  bool showCityData = false;

  Future<void> updatePages(dynamic city) async {
    try {
      final currentWeatherData = await getCurrentWeather(
        city['latitude'],
        city['longitude'],
      );
      final todayWeatherData = await getTodayWeather(
        city['latitude'],
        city['longitude'],
      );
      final weeklyWeatherData = await getWeeklyWeather(
        city['latitude'],
        city['longitude'],
      );

      if (!mounted) {
        return;
      }

      setState(() {
        final locationLines = [
          city['name'],
          if ((city['admin1'] ?? '').toString().isNotEmpty) city['admin1'],
          if ((city['country'] ?? '').toString().isNotEmpty) city['country'],
        ].join('\n');

        pages[0] = CurrentWeatherPage(
          locationLines: locationLines,
          currentWeatherData: currentWeatherData,
        );
        pages[1] = TodayWeatherPage(
          locationLines: locationLines,
          todayWeatherData: todayWeatherData,
        );
        pages[2] = WeeklyWeatherPage(
          locationLines: locationLines,
          weeklyWeatherData: weeklyWeatherData,
        );
        showCityData = true;
      });
    } catch (error) {
      _showErrorPages(apiFailureMessage);
    }
  }

  void _handleOnSearchChanged(String value) {
    _searchDebounce?.cancel();

    if (value.trim().isEmpty) {
      setState(() {
        result = [];
        showCityData = false;
      });
      return;
    }

    setState(() {
      showCityData = false;
    });

    _searchDebounce = Timer(const Duration(milliseconds: 500), () async {
      final results = await searchCity(value);
      if (!mounted) {
        return;
      }

      if (results == null) {
        _showErrorPages(apiFailureMessage);
        return;
      }

      if (results.isEmpty) {
        _showErrorPages(cityNotFoundMessage);
        return;
      }

      setState(() {
        result = results;
      });
    });
  }

  Future<void> _submitSearch(String value) async {
    final results = await searchCity(value);
    if (!mounted) {
      return;
    }

    if (results == null) {
      _showErrorPages(apiFailureMessage);
      return;
    }

    if (results.isEmpty) {
      _showErrorPages(cityNotFoundMessage);
      return;
    }

    setState(() {
      showCityData = true;
    });

    await updatePages(results.first);
  }

  void _handleOnTab(int value) {
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        value,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
    setState(() {
      currentIndex = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SearchControls(
          controller: _cityController,
          onChanged: _handleOnSearchChanged,
          onSubmitted: _submitSearch,
          onLocationPressed: _loadCurrentLocationWeather,
        ),
      ),

      body: PageView(
          controller: _pageController,
          onPageChanged: _handleOnTab,
          children: [
            Text('Currently'),
            Text('Today'),
            Text('Weekly'),
          ],
        ),
        
      bottomNavigationBar: WeatherBottomNavBar(
        currentIndex: currentIndex,
        onTabSelected: _handleOnTab,
      ),
      
      // body: showCityData
      //     ? WeatherPageView(
      //         pageController: _pageController,
      //         pages: pages,
      //         currentIndex: index,
      //         onPageChanged: (newIndex) {
      //           setState(() {
      //             index = newIndex;
      //           });
      //         },
      //         onTabSelected: (newIndex) {
      //           if (_pageController.hasClients) {
      //             _pageController.animateToPage(
      //               newIndex,
      //               duration: const Duration(milliseconds: 250),
      //               curve: Curves.easeInOut,
      //             );
      //           }
      //           setState(() {
      //             index = newIndex;
      //           });
      //         },
      //       )
      //     : CityResultsList(
      //         results: result,
      //         onCitySelected: (city) async {
      //           setState(() {
      //             showCityData = true;
      //           });
      //           await updatePages(city);
      //         },
      //       ),
          
    );
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomePage());
  }
}
