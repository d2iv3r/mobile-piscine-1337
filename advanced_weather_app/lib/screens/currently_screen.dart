import 'package:flutter/material.dart';
import '../models/weather_data.dart';
import '../utils/app_colors.dart';
import '../utils/weather_icons.dart';
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
          const SizedBox(height: 16),
          Text(
            weatherIcon(weather.currentCode),
            style: const TextStyle(fontSize: 80),
          ),
          const SizedBox(height: 16),
          Text(
            '${weather.currentTemp.toStringAsFixed(1)}°C',
            style: const TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.w200,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            weather.currentDesc,
            style: const TextStyle(
              fontSize: 20,
              color: AppColors.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.air, color: AppColors.accentCool, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${weather.currentWind.toStringAsFixed(1)} km/h',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}