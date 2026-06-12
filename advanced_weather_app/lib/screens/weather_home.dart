import 'package:flutter/material.dart';
import '../models/city_result.dart';
import '../models/weather_data.dart';
import '../services/location_service.dart';
import '../services/weather_service.dart';
import '../utils/app_colors.dart';
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
  final PageController _pageController = PageController();
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
      final pos  = await getCurrentPosition();
      final city = await reverseGeolocate(pos.latitude, pos.longitude);
      final w    = await fetchWeather(
        pos.latitude, pos.longitude,
        city['name'] ?? 'Current location',
        city['admin1'] ?? '',
        city['country'] ?? '',
      );
      setState(() { _weather = w; });
      _restoreTab();
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('Geolocation')) {
        setState(() { _geoError = msg.replaceFirst('Exception: ', ''); });
      } else {
        setState(() { _error = 'The service connection is lost, please check your internet connection or try again later.'; });
      }
    } finally {
      setState(() { _loading = false; });
    }
  }

  void _restoreTab() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients && _tab != 0) {
        _pageController.jumpToPage(_tab);
      }
    });
  }

  Future<void> _onSearchChanged(String value) async {
    if (value.length < 2) { setState(() { _suggestions = []; }); return; }
    try {
      final results = await searchCities(value);
      setState(() { _suggestions = results; });
    } catch (_) {
      setState(() { _suggestions = []; });
    }
  }

  void _onTabChanged(int index) {
    setState(() => _tab = index);
    if (_pageController.hasClients) {
      _pageController.animateToPage(index,
          duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
    }
  }

  Future<void> _selectCity(CityResult city) async {
    _searchCtrl.text = city.name;
    FocusScope.of(context).unfocus();
    setState(() { _suggestions = []; _loading = true; _error = null; });
    try {
      final w = await fetchWeather(city.lat, city.lon, city.name, city.region, city.country);
      setState(() { _weather = w; });
      _restoreTab();
    } catch (_) {
      setState(() { _error = 'The service connection is lost, please check your internet connection or try again later.'; _weather = null; });
    } finally {
      setState(() { _loading = false; });
    }
  }

  Future<void> _searchByText() async {
    final query = _searchCtrl.text.trim();
    if (query.isEmpty) return;
    FocusScope.of(context).unfocus();
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
      setState(() { _error = 'The service connection is lost, please check your internet connection or try again later.'; _weather = null; });
    } finally {
      setState(() { _loading = false; });
    }
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.accent));
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, color: AppColors.textSecondary, size: 56),
              const SizedBox(height: 16),
              Text(_error!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 15),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }
    if (_weather == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _geoError != null ? '📍' : '🔍',
                style: const TextStyle(fontSize: 56),
              ),
              const SizedBox(height: 16),
              Text(
                _geoError ?? 'Search for a city to see the weather.',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 15),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    return PageView(
      controller: _pageController,
      onPageChanged: (i) => setState(() => _tab = i),
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
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.bgTop, AppColors.bgBottom],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Container(
                  color: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: custom.SearchBar(
                            controller: _searchCtrl,
                            onChanged: _onSearchChanged,
                            onSubmitted: _searchByText,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _requestLocation,
                        child: Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const Icon(Icons.near_me, color: AppColors.accentCool, size: 22),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_suggestions.isNotEmpty)
                  SuggestionList(suggestions: _suggestions, onSelect: _selectCity),
                Expanded(child: _buildBody()),
                _buildBottomNav(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    const items = [
      {'icon': Icons.circle_outlined, 'label': 'Currently'},
      {'icon': Icons.calendar_today,  'label': 'Today'},
      {'icon': Icons.calendar_month,  'label': 'Weekly'},
    ];

    return Container(
      color: AppColors.bgTop.withValues(alpha: 0.5),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final active = _tab == i;
          return GestureDetector(
            onTap: () => _onTabChanged(i),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  items[i]['icon'] as IconData,
                  color: active ? AppColors.accent : AppColors.textSecondary,
                  size: 22,
                ),
                const SizedBox(height: 4),
                Text(
                  items[i]['label'] as String,
                  style: TextStyle(
                    color: active ? AppColors.accent : AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 2, width: active ? 24 : 0,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}