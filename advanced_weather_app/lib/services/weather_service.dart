import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/city_result.dart';
import '../models/weather_data.dart';

String weatherDesc(int code) {
  if (code == 0) return 'Clear sky';
  if (code <= 2) return 'Partly cloudy';
  if (code == 3) return 'Overcast';
  if (code <= 49) return 'Foggy';
  if (code <= 59) return 'Drizzle';
  if (code <= 69) return 'Rain';
  if (code <= 79) return 'Snow';
  if (code <= 84) return 'Rain showers';
  if (code <= 94) return 'Thunderstorm';
  return 'Hail';
}

Future<Map<String, dynamic>> reverseGeolocate(double lat, double lon) async {
  final url = Uri.parse(
    'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=jsonv2',
  );
  final res = await http.get(url, headers: {'User-Agent': 'WeatherApp/1.0'});
  if (res.statusCode != 200) throw Exception('Connection error');
  final data = jsonDecode(res.body);
  if (data['address'] == null) {
    throw 'Geolocation error: Unable to determine city.';
  }
  return {
    'name': data['address']['city'] ??
        data['address']['town'] ??
        data['address']['village'] ??
        'Unknown location',
    'admin1': data['address']['state'] ?? '',
    'country': data['address']['country'] ?? '',
  };
}

Future<List<CityResult>> searchCities(String query) async {
  final url = Uri.parse(
    'https://geocoding-api.open-meteo.com/v1/search'
    '?name=${Uri.encodeComponent(query)}&count=5&language=en&format=json',
  );
  final res = await http.get(url);
  if (res.statusCode != 200) throw Exception('Connection error');
  final data = jsonDecode(res.body);
  if (data['results'] == null) return [];
  return (data['results'] as List)
      .map((r) => CityResult(
            name: r['name'] ?? '',
            region: r['admin1'] ?? '',
            country: r['country'] ?? '',
            lat: (r['latitude'] as num).toDouble(),
            lon: (r['longitude'] as num).toDouble(),
          ))
      .toList();
}

Future<WeatherData> fetchWeather(
    double lat, double lon, String city, String region, String country) async {
  final url = Uri.parse(
    'https://api.open-meteo.com/v1/forecast'
    '?latitude=$lat&longitude=$lon'
    '&current=temperature_2m,wind_speed_10m,weather_code'
    '&hourly=temperature_2m,wind_speed_10m,weather_code'
    '&daily=temperature_2m_max,temperature_2m_min,weather_code'
    '&timezone=auto&forecast_days=7',
  );
  final res = await http.get(url);
  if (res.statusCode != 200) throw Exception('Connection error');
  final d = jsonDecode(res.body);

  final cur    = d['current'];
  final hourly = d['hourly'];
  final daily  = d['daily'];

  final todayPrefix = (hourly['time'] as List).first.toString().substring(0, 10);
  final allHours    = List<String>.from(hourly['time']);
  final todayIdx    = allHours
      .asMap()
      .entries
      .where((e) => e.value.startsWith(todayPrefix))
      .map((e) => e.key)
      .toList();

  return WeatherData(
    city: city, region: region, country: country,
    currentTemp: (cur['temperature_2m'] as num).toDouble(),
    currentWind: (cur['wind_speed_10m'] as num).toDouble(),
    currentDesc: weatherDesc(cur['weather_code'] as int),
    currentCode: cur['weather_code'] as int,
    hours:       todayIdx.map((i) => allHours[i].substring(11)).toList(),
    hourlyTemps: todayIdx.map((i) => (hourly['temperature_2m'][i] as num).toDouble()).toList(),
    hourlyWinds: todayIdx.map((i) => (hourly['wind_speed_10m'][i] as num).toDouble()).toList(),
    hourlyDescs: todayIdx.map((i) => weatherDesc(hourly['weather_code'][i] as int)).toList(),
    hourlyCodes: todayIdx.map((i) => hourly['weather_code'][i] as int).toList(),
    dates:       List<String>.from(daily['time']),
    minTemps:    (daily['temperature_2m_min'] as List).map((v) => (v as num).toDouble()).toList(),
    maxTemps:    (daily['temperature_2m_max'] as List).map((v) => (v as num).toDouble()).toList(),
    dailyDescs:  (daily['weather_code'] as List).map((c) => weatherDesc(c as int)).toList(),
    dailyCodes:  (daily['weather_code'] as List).map((c) => c as int).toList(),
  );
}