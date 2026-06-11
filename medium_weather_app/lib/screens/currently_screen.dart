import 'package:flutter/material.dart';
import '../models/weather_data.dart';
import '../widgets/location_header.dart';

class CurrentlyScreen extends StatelessWidget {
  final WeatherData weather;

  const CurrentlyScreen({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LocationHeader(weather: weather),
          Text(
            '${weather.currentTemp.toStringAsFixed(1)}°C',
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 8),
          Text(weather.currentDesc, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text('${weather.currentWind.toStringAsFixed(1)} km/h',
              style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}