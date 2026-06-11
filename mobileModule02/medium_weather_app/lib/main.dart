import 'dart:async';

import 'package:flutter/material.dart';
import 'package:medium_weather_app/services/weather_service.dart';
import 'package:medium_weather_app/widgets/city_results_list.dart';
import 'package:medium_weather_app/widgets/weather_app_bar.dart';
import 'package:medium_weather_app/widgets/weather_bottom_nav_bar.dart';
import 'package:medium_weather_app/widgets/weather_pages.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _pageController = PageController();
  final _cityController = TextEditingController();
  Timer? _debounce;

  // App status
  int _currentIndex = 0;
  bool _isLoading = false;
  String? _errorMessage;

  // Search suggestions
  List<dynamic> _searchResults = [];

  // Weather data
  String _locationLines = '';
  Map<String, dynamic>? _currentWeather;
  Map<String, dynamic>? _todayWeather;
  Map<String, dynamic>? _weeklyWeather;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _onLocationPressed());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _pageController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  // ── Location ───────────────────────────────────────────────────────────────

  Future<void> _onLocationPressed() async {
    _cityController.clear();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _searchResults = [];
    });

    try {
      final coords = await getCurrentLocation();
      Map<String, dynamic>? city;
      try {
        city = await reverseGeocode(coords.latitude, coords.longitude);
      } catch (_) {}

      city ??= {
        'name': '${coords.latitude.toStringAsFixed(4)}, ${coords.longitude.toStringAsFixed(4)}',
        'admin1': '',
        'country': '',
        'latitude': coords.latitude,
        'longitude': coords.longitude,
      };

      await _fetchWeatherForCity(city);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Geolocation is not available, please enable it in your App settings.';
      });
    }
  }

  // ── Weather fetch ──────────────────────────────────────────────────────────

  Future<void> _fetchWeatherForCity(Map<String, dynamic> city) async {
    setState(() => _isLoading = true);

    try {
      _locationLines = [
        city['name'],
        if ((city['admin1'] ?? '').toString().isNotEmpty) city['admin1'],
        if ((city['country'] ?? '').toString().isNotEmpty) city['country'],
      ].join('\n');

      final results = await Future.wait([
        getCurrentWeather(city['latitude'], city['longitude']),
        getTodayWeather(city['latitude'], city['longitude']),
        getWeeklyWeather(city['latitude'], city['longitude']),
      ]);

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = null;
        _currentWeather = results[0];
        _todayWeather = results[1];
        _weeklyWeather = results[2];
      });
    } catch (e) {
      print('Error fetching weather: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = apiFailureMessage;
      });
    }
  }

  // ── Search ─────────────────────────────────────────────────────────────────

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    if (value.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final results = await searchCity(value);
      if (!mounted) return;

      if (results == null) {
        setState(() {
          _searchResults = [];
          _errorMessage = apiFailureMessage;
        });
      } else if (results.isEmpty) {
        setState(() {
          _searchResults = [];
          _errorMessage = cityNotFoundMessage;
        });
      } else {
        setState(() {
          _searchResults = results;
          _errorMessage = null;
        });
      }
    });
  }

  Future<void> _onSearchSubmitted(String value) async {
    if (value.trim().isEmpty) return;
    _debounce?.cancel();

    final results = await searchCity(value);
    if (!mounted) return;

    if (results == null || results.isEmpty) {
      setState(() {
        _searchResults = [];
        _errorMessage = results == null ? apiFailureMessage : cityNotFoundMessage;
      });
      return;
    }

    await _onCitySelected(results.first);
  }

  Future<void> _onCitySelected(dynamic city) async {
    _cityController.clear();
    setState(() => _searchResults = []);
    await _fetchWeatherForCity(city);
  }

  // ── Tab navigation ─────────────────────────────────────────────────────────

  void _onTabChanged(int index) {
    setState(() => _currentIndex = index);
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
  }

  // ── Pages ──────────────────────────────────────────────────────────────────

  List<Widget> _buildPages() {
    if (_isLoading) {
      const loading = Center(child: CircularProgressIndicator());
      return [loading, loading, loading];
    }

    if (_errorMessage != null) {
      final error = WeatherMessagePage(message: _errorMessage!);
      return [error, error, error];
    }

    if (_currentWeather != null) {
      return [
        CurrentWeatherPage(
          locationLines: _locationLines,
          currentWeatherData: _currentWeather!,
        ),
        TodayWeatherPage(
          locationLines: _locationLines,
          todayWeatherData: _todayWeather!,
        ),
        WeeklyWeatherPage(
          locationLines: _locationLines,
          weeklyWeatherData: _weeklyWeather!,
        ),
      ];
    }

    // Initial idle state
    return [
      const Center(child: Text('Currently')),
      const Center(child: Text('Today')),
      const Center(child: Text('Weekly')),
    ];
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WeatherAppBar(
        controller: _cityController,
        onChanged: _onSearchChanged,
        onSubmitted: _onSearchSubmitted,
        onLocationPressed: _onLocationPressed,
      ),
      body: _searchResults.isNotEmpty
          ? CityResultsList(
              results: _searchResults,
              onCitySelected: _onCitySelected,
            )
          : PageView(
              controller: _pageController,
              onPageChanged: _onTabChanged,
              children: _buildPages(),
            ),
      bottomNavigationBar: WeatherBottomNavBar(
        currentIndex: _currentIndex,
        onTabSelected: _onTabChanged,
      ),
    );
  }
}
