import 'package:flutter/material.dart';
import '../models/weather_data.dart';
import '../utils/app_colors.dart';

class LocationHeader extends StatelessWidget {
  final WeatherData weather;

  const LocationHeader({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(children: [
        Text(
          weather.city,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.accentCool,
            letterSpacing: 0.5,
          ),
        ),
        if (weather.region.isNotEmpty || weather.country.isNotEmpty)
          Text(
            [weather.region, weather.country]
                .where((s) => s.isNotEmpty)
                .join(', '),
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
      ]),
    );
  }
}