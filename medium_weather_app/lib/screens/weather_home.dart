import 'package:flutter/material.dart';
import '../models/city_result.dart';
import '../models/weather_data.dart';
import '../services/location_service.dart';
import '../services/weather_service.dart';
import '../widgets/suggestion_list.dart';
import '../widgets/search_bar.dart' as custom;
import 'currently_screen.dart';
import 'today_screen.dart';
import 'weekly_screen.dart';

class WeatherHome extends StatefulWidget {
  const WeatherHome({super.key});

  @override
  State<WeatherHome> createState() => _WeatherHomeState();
}

class _WeatherHomeState extends State<WeatherHome> {
  int _tab = 0;
  WeatherData? _weather;
  String? _error;
  bool _loading = false;
  String? _geoError;
  final PageController _pageController = PageController(initialPage: 0);

  final _searchCtrl = TextEditingController();
  List<CityResult> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _requestLocation();
  }

   @override
  void dispose() {
    _pageController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _requestLocation() async {
    setState(() { _loading = true; _error = null; _geoError = null; });
    try {
      final pos = await getCurrentPosition();
      final city = await reverseGeolocate(pos.latitude, pos.longitude);
      if (city.isNotEmpty) {
        final w = await fetchWeather(pos.latitude, pos.longitude, city['name'], city['admin1'], city['country']);
        setState(() { _weather = w; });
        _restoreTab();
      } else {
        final w = await fetchWeather(pos.latitude, pos.longitude, 'Current location', '', '');
        setState(() { _weather = w; });
        _restoreTab();
      }
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('Geolocation')) {
        setState(() { _geoError = msg; });
      } else {
        setState(() { _error = 'The service connection is lost, please check your internet connection or try again later'; });
      }
    } finally {
      setState(() { _loading = false; });
    }
  }

  Future<void> _onSearchChanged(String value) async {
    if (value.length < 2) {
      setState(() { _suggestions = []; });
      return;
    }
    try {
      final results = await searchCities(value);
      setState(() { _suggestions = results; });
    } catch (_) {
      setState(() { _suggestions = []; });
    }
  }

  void _restoreTab() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients && _tab != 0) {
        _pageController.jumpToPage(_tab);
      }
    });
  }

  void _onTabChanged(int index) {
    setState(() => _tab = index);
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _selectCity(CityResult city) async {
    _searchCtrl.text = city.name;
    setState(() { _suggestions = []; _loading = true; _error = null; });
    try {
      final w = await fetchWeather(city.lat, city.lon, city.name, city.region, city.country);
      setState(() { _weather = w; });
      _restoreTab();
    } catch (_) {
      setState(() { _error = 'The service connection is lost, please check your internet connection or try again later'; _weather = null; });
    } finally {
      setState(() { _loading = false; });
    }
  }

  Future<void> _searchByText() async {
    final query = _searchCtrl.text.trim();
    if (query.isEmpty) return;
    setState(() { _loading = true; _error = null; _suggestions = []; });
    try {
      final cities = await searchCities(query);
      if (cities.isEmpty) {
        setState(() { _error = 'Could not find any result for "$query".'; _weather = null; });
        return;
      }
      final c = cities.first;
      final w = await fetchWeather(c.lat, c.lon, c.name, c.region, c.country);
      setState(() { _weather = w; });
      _restoreTab();
    } catch (_) {
      setState(() { _error = 'The service connection is lost, please check your internet connection or try again later'; _weather = null; });
    } finally {
      setState(() { _loading = false; });
    }
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
            child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(_error!,
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center),
            ),
          );
    }
    if (_weather == null) {
      if(_geoError != null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(_geoError!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center),
          ),
        );
      }
      return Center(
        child: Text(
          'Search for a city to see weather.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
      );
    }
    return PageView(
      controller: _pageController,
      onPageChanged: (index) => setState(() => _tab = index),
      children: [
        CurrentlyScreen(weather: _weather!),
        TodayScreen(weather: _weather!),
        WeeklyScreen(weather: _weather!),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 48, 62, 73),
        title: custom.SearchBar(
          controller: _searchCtrl,
          onChanged: _onSearchChanged,
          onSubmitted: _searchByText,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.near_me, color: Colors.white),
            onPressed: _requestLocation,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_geoError != null)
            Container(
              width: double.infinity,
              color: Colors.red.shade100,
              padding: const EdgeInsets.all(8),
              child: Text(_geoError!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center),
            ),
          if (_suggestions.isNotEmpty)
            SuggestionList(suggestions: _suggestions, onSelect: _selectCity),
          Expanded(child: _buildBody()),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: _onTabChanged,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.now_widgets), label: 'Currently'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Today'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Weekly'),
        ],
      ),
    );
  }
}