import 'package:flutter/material.dart';
import '../models/weather_data.dart';

class LocationHeader extends StatelessWidget {
  final WeatherData weather;

  const LocationHeader({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        Text(weather.city,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        if (weather.region.isNotEmpty) Text(weather.region),
        if (weather.country.isNotEmpty) Text(weather.country),
      ]),
    );
  }
}