import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

const String cityNotFoundMessage =
    'The service connection is lost, please check your internet connection or try again later';
const String apiFailureMessage =
    'Could not find any result for the supplied address or coordinates.';

Future<Position> getCurrentLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
      'Location permissions are permanently denied, we cannot request permissions.',
    );
  }

  return Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );
}

Future<List<dynamic>?> searchCity(String cityName) async {
  try {
    final encodedCityName = Uri.encodeQueryComponent(cityName);
    final apiUrl =
        'https://geocoding-api.open-meteo.com/v1/search?name=$encodedCityName&count=5&language=en&format=json';
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['results'] ?? [];
    }
    throw Exception('Failed to load city data');
  } catch (e) {
    return null;
  }
}

Future<Map<String, dynamic>?> reverseGeocode(
  double latitude,
  double longitude,
) async {
  try {
    final apiUrl =
        'https://geocoding-api.open-meteo.com/v1/reverse?latitude=$latitude&longitude=$longitude&count=1&language=en&format=json';
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['results'];
      if (results is List && results.isNotEmpty) {
        return Map<String, dynamic>.from(results.first as Map);
      }
      return null;
    }
    throw Exception('Failed to load city data');
  } catch (e) {
    rethrow;
  }
}

Future<Map<String, dynamic>> getCurrentWeather(
  double latitude,
  double longitude,
) async {
  try {
    final apiUrl =
        'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current_weather=true';
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['current_weather'] ?? {};
    }
    throw Exception('Failed to load weather data');
  } catch (e) {
    rethrow;
  }
}

Future<Map<String, dynamic>> getTodayWeather(
  double latitude,
  double longitude,
) async {
  try {
    final apiUrl =
        'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&hourly=weathercode,temperature_2m,wind_speed_10m';
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['hourly'] ?? {};
    }
    throw Exception('Failed to load weather data');
  } catch (e) {
    rethrow;
  }
}

Future<Map<String, dynamic>> getWeeklyWeather(
  double latitude,
  double longitude,
) async {
  try {
    final apiUrl =
        'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&daily=temperature_2m_max,temperature_2m_min,wind_speed_10m_max,weathercode&timezone=auto';
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['daily'] ?? {};
    }
    throw Exception('Failed to load weather data');
  } catch (e) {
    rethrow;
  }
}
