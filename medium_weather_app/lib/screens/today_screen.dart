import 'package:flutter/material.dart';
import '../models/weather_data.dart';
import '../widgets/location_header.dart';

class TodayScreen extends StatelessWidget {
  final WeatherData weather;

  const TodayScreen({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LocationHeader(weather: weather),
        Expanded(
          child: ListView.builder(
            itemCount: weather.hours.length,
            itemBuilder: (ctx, i) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(weather.hours[i], style: const TextStyle(fontSize: 16)),
                    Text('${weather.hourlyTemps[i].toStringAsFixed(1)}°C', style: const TextStyle(fontSize: 16)),
                    Text(weather.hourlyDescs[i], style: const TextStyle(fontSize: 16)),
                    Text('${weather.hourlyWinds[i].toStringAsFixed(1)} km/h', style: const TextStyle(fontSize: 16)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}