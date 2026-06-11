import 'package:flutter/material.dart';
import 'screens/weather_home.dart';
 
void main() => runApp(const MyApp());
 
class MyApp extends StatelessWidget {
  const MyApp({super.key});
 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      home: const WeatherHome(),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:medium_weather_app/widgets/weather_app_bar.dart';


// void main() => runApp(const MyApp());

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Weather App',
//       home: const WeatherHome(),
//     );
//   }
// }

// // ─── Data models ────────────────────────────────────────────

// class CityResult {
//   final String name, region, country;
//   final double lat, lon;
//   CityResult({required this.name, required this.region,
//       required this.country, required this.lat, required this.lon});
// }

// class WeatherData {
//   final String city, region, country;
//   // current
//   final double currentTemp, currentWind;
//   final String currentDesc;
//   // hourly (today)
//   final List<String> hours;
//   final List<double> hourlyTemps, hourlyWinds;
//   final List<String> hourlyDescs;
//   // daily (weekly)
//   final List<String> dates;
//   final List<double> minTemps, maxTemps;
//   final List<String> dailyDescs;

//   WeatherData({
//     required this.city, required this.region, required this.country,
//     required this.currentTemp, required this.currentWind, required this.currentDesc,
//     required this.hours, required this.hourlyTemps,
//     required this.hourlyWinds, required this.hourlyDescs,
//     required this.dates, required this.minTemps,
//     required this.maxTemps, required this.dailyDescs,
//   });
// }

// // ─── WMO weather code → description ─────────────────────────

// String weatherDesc(int code) {
//   if (code == 0) return 'Clear sky';
//   if (code <= 3) return 'Partly cloudy';
//   if (code <= 49) return 'Foggy';
//   if (code <= 59) return 'Drizzle';
//   if (code <= 69) return 'Rain';
//   if (code <= 79) return 'Snow';
//   if (code <= 84) return 'Rain showers';
//   if (code <= 94) return 'Thunderstorm';
//   return 'Hail';
// }

// // ─── API calls ───────────────────────────────────────────────

// Future<List<CityResult>> searchCities(String query) async {
//   final url = Uri.parse(
//     'https://geocoding-api.open-meteo.com/v1/search?name=${Uri.encodeComponent(query)}&count=5&language=en&format=json',
//   );
//   final res = await http.get(url);
//   if (res.statusCode != 200) throw Exception('Connection error');
//   final data = jsonDecode(res.body);
//   if (data['results'] == null) return [];
//   return (data['results'] as List).map((r) => CityResult(
//     name: r['name'] ?? '',
//     region: r['admin1'] ?? '',
//     country: r['country'] ?? '',
//     lat: (r['latitude'] as num).toDouble(),
//     lon: (r['longitude'] as num).toDouble(),
//   )).toList();
// }

// Future<WeatherData> fetchWeather(
//     double lat, double lon, String city, String region, String country) async {
//   final url = Uri.parse(
//     'https://api.open-meteo.com/v1/forecast'
//     '?latitude=$lat&longitude=$lon'
//     '&current=temperature_2m,wind_speed_10m,weather_code'
//     '&hourly=temperature_2m,wind_speed_10m,weather_code'
//     '&daily=temperature_2m_max,temperature_2m_min,weather_code'
//     '&timezone=auto&forecast_days=7',
//   );
//   final res = await http.get(url);
//   if (res.statusCode != 200) throw Exception('Connection error');
//   final d = jsonDecode(res.body);

//   final cur = d['current'];
//   final hourly = d['hourly'];
//   final daily = d['daily'];

//   // Get today's date prefix to filter hourly to today only
//   final todayPrefix = (hourly['time'] as List).first.toString().substring(0, 10);
//   final allHours = List<String>.from(hourly['time']);
//   final todayIndexes = allHours
//       .asMap()
//       .entries
//       .where((e) => e.value.startsWith(todayPrefix))
//       .map((e) => e.key)
//       .toList();

//   return WeatherData(
//     city: city, region: region, country: country,
//     currentTemp: (cur['temperature_2m'] as num).toDouble(),
//     currentWind: (cur['wind_speed_10m'] as num).toDouble(),
//     currentDesc: weatherDesc(cur['weather_code'] as int),
//     hours: todayIndexes.map((i) => allHours[i].substring(11)).toList(),
//     hourlyTemps: todayIndexes.map((i) => (hourly['temperature_2m'][i] as num).toDouble()).toList(),
//     hourlyWinds: todayIndexes.map((i) => (hourly['wind_speed_10m'][i] as num).toDouble()).toList(),
//     hourlyDescs: todayIndexes.map((i) => weatherDesc(hourly['weather_code'][i] as int)).toList(),
//     dates: List<String>.from(daily['time']),
//     minTemps: (daily['temperature_2m_min'] as List).map((v) => (v as num).toDouble()).toList(),
//     maxTemps: (daily['temperature_2m_max'] as List).map((v) => (v as num).toDouble()).toList(),
//     dailyDescs: (daily['weather_code'] as List).map((c) => weatherDesc(c as int)).toList(),
//   );
// }

// // ─── Main widget ─────────────────────────────────────────────

// class WeatherHome extends StatefulWidget {
//   const WeatherHome({super.key});
//   @override
//   State<WeatherHome> createState() => _WeatherHomeState();
// }

// class _WeatherHomeState extends State<WeatherHome> {
//   int _tab = 0;
//   WeatherData? _weather;
//   String? _error;
//   bool _loading = false;

//   // Search
//   final _searchCtrl = TextEditingController();
//   List<CityResult> _suggestions = [];
//   bool _searching = false;

//   // Geolocation
//   String? _geoStatus; // null = not tried yet

//   @override
//   void initState() {
//     super.initState();
//     _requestLocation();
//   }

//   Future<void> _requestLocation() async {
//     setState(() { _loading = true; _error = null; });
//     try {
//       LocationPermission perm = await Geolocator.checkPermission();
//       if (perm == LocationPermission.denied) {
//         perm = await Geolocator.requestPermission();
//       }
//       if (perm == LocationPermission.deniedForever || perm == LocationPermission.denied) {
//         setState(() {
//           _geoStatus = 'Geolocation is not available, please enable it in your App settings.';
//           _loading = false;
//         });
//         return;
//       }
//       final pos = await Geolocator.getCurrentPosition();
//       setState(() { _geoStatus = 'Location: ${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}'; });
//       // Reverse geocode to get city name
//       final cities = await _reverseGeocode(pos.latitude, pos.longitude);
//       if (cities.isNotEmpty) {
//         final c = cities.first;
//         final w = await fetchWeather(pos.latitude, pos.longitude, c.name, c.region, c.country);
//         setState(() { _weather = w; });
//       } else {
//         final w = await fetchWeather(pos.latitude, pos.longitude, 'Current location', '', '');
//         setState(() { _weather = w; });
//       }
//     } catch (e) {
//       setState(() { _error = 'Connection error. Please check your internet.'; });
//     } finally {
//       setState(() { _loading = false; });
//     }
//   }

//   Future<List<CityResult>> _reverseGeocode(double lat, double lon) async {
//     // Open-Meteo doesn't support reverse geocoding — use a simple name
//     // We'll just return empty and show "Current location"
//     return [];
//   }

//   Future<void> _onSearchChanged(String value) async {
//     if (value.length < 2) {
//       setState(() { _suggestions = []; });
//       return;
//     }
//     try {
//       final results = await searchCities(value);
//       setState(() { _suggestions = results; });
//     } catch (_) {
//       setState(() { _suggestions = []; });
//     }
//   }

//   Future<void> _selectCity(CityResult city) async {
//     _searchCtrl.text = city.name;
//     setState(() { _suggestions = []; _loading = true; _error = null; });
//     try {
//       final w = await fetchWeather(city.lat, city.lon, city.name, city.region, city.country);
//       setState(() { _weather = w; });
//     } catch (e) {
//       setState(() { _error = 'Connection error. Please check your internet.'; _weather = null; });
//     } finally {
//       setState(() { _loading = false; });
//     }
//   }

//   Future<void> _searchByText() async {
//     final query = _searchCtrl.text.trim();
//     if (query.isEmpty) return;
//     setState(() { _loading = true; _error = null; _suggestions = []; });
//     try {
//       final cities = await searchCities(query);
//       if (cities.isEmpty) {
//         setState(() { _error = 'Could not find any result for "$query".'; _weather = null; });
//         return;
//       }
//       final c = cities.first;
//       final w = await fetchWeather(c.lat, c.lon, c.name, c.region, c.country);
//       setState(() { _weather = w; });
//     } catch (e) {
//       setState(() { _error = 'Connection error. Please check your internet.'; _weather = null; });
//     } finally {
//       setState(() { _loading = false; });
//     }
//   }

//   // ─── Build ───────────────────────────────────────────────

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: _buildSearchBar(),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.my_location),
//             onPressed: _requestLocation,
//             tooltip: 'Use my location',
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           if (_geoStatus != null && _geoStatus!.startsWith('Geolocation'))
//             Container(
//               width: double.infinity,
//               color: Colors.red.shade100,
//               padding: const EdgeInsets.all(8),
//               child: Text(_geoStatus!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
//             ),
//           if (_suggestions.isNotEmpty) _buildSuggestions(),
//           Expanded(child: _buildBody()),
//         ],
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _tab,
//         onTap: (i) => setState(() { _tab = i; }),
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.circle_outlined), label: 'Currently'),
//           BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Today'),
//           BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Weekly'),
//         ],
//       ),
//     );
//   }

//   Widget _buildSearchBar() {
//     return TextField(
//       controller: _searchCtrl,
//       decoration: const InputDecoration(
//         hintText: 'Search location...',
//         border: InputBorder.none,
//       ),
//       onChanged: _onSearchChanged,
//       onSubmitted: (_) => _searchByText(),
//     );
//   }

//   Widget _buildSuggestions() {
//     return Container(
//       color: Colors.white,
//       child: ListView.builder(
//         shrinkWrap: true,
//         itemCount: _suggestions.length,
//         itemBuilder: (ctx, i) {
//           final c = _suggestions[i];
//           return ListTile(
//             title: Text(c.name),
//             subtitle: Text('${c.region}, ${c.country}'),
//             onTap: () => _selectCity(c),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildBody() {
//     if (_loading) return const Center(child: CircularProgressIndicator());
//     if (_error != null) {
//       return Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 16), textAlign: TextAlign.center),
//         ),
//       );
//     }
//     if (_weather == null) {
//       return Center(
//         child: Text(
//           _geoStatus ?? 'Search for a city to see weather.',
//           textAlign: TextAlign.center,
//           style: const TextStyle(fontSize: 16),
//         ),
//       );
//     }
//     switch (_tab) {
//       case 0: return _buildCurrentTab();
//       case 1: return _buildTodayTab();
//       case 2: return _buildWeeklyTab();
//       default: return const SizedBox();
//     }
//   }

//   // ─── Tab views ───────────────────────────────────────────

//   Widget _locationHeader() {
//     final w = _weather!;
//     return Padding(
//       padding: const EdgeInsets.all(12),
//       child: Column(children: [
//         Text(w.city, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//         if (w.region.isNotEmpty) Text(w.region),
//         if (w.country.isNotEmpty) Text(w.country),
//       ]),
//     );
//   }

//   Widget _buildCurrentTab() {
//     final w = _weather!;
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           _locationHeader(),
//           Text('${w.currentTemp.toStringAsFixed(1)}°C', style: const TextStyle(fontSize: 48)),
//           const SizedBox(height: 8),
//           Text(w.currentDesc, style: const TextStyle(fontSize: 18)),
//           const SizedBox(height: 8),
//           Text('Wind: ${w.currentWind.toStringAsFixed(1)} km/h', style: const TextStyle(fontSize: 16)),
//         ],
//       ),
//     );
//   }

//   Widget _buildTodayTab() {
//     final w = _weather!;
//     return Column(
//       children: [
//         _locationHeader(),
//         Expanded(
//           child: ListView.builder(
//             itemCount: w.hours.length,
//             itemBuilder: (ctx, i) => ListTile(
//               title: Text('${w.hours[i]}  ${w.hourlyTemps[i].toStringAsFixed(1)}°C  ${w.hourlyDescs[i]}'),
//               trailing: Text('${w.hourlyWinds[i].toStringAsFixed(1)} km/h'),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildWeeklyTab() {
//     final w = _weather!;
//     return Column(
//       children: [
//         _locationHeader(),
//         Expanded(
//           child: ListView.builder(
//             itemCount: w.dates.length,
//             itemBuilder: (ctx, i) => ListTile(
//               title: Text(w.dates[i]),
//               subtitle: Text(w.dailyDescs[i]),
//               trailing: Text('${w.minTemps[i].toStringAsFixed(0)}° / ${w.maxTemps[i].toStringAsFixed(0)}°C'),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }