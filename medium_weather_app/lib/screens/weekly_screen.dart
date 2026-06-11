import 'package:flutter/material.dart';
import '../models/weather_data.dart';
import '../widgets/location_header.dart';

class WeeklyScreen extends StatelessWidget {
  final WeatherData weather;

  const WeeklyScreen({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LocationHeader(weather: weather),
        Expanded(
          child: ListView.builder(
            itemCount: weather.dates.length,
            itemBuilder: (ctx, i) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(weather.dates[i], style: const TextStyle(fontSize: 16)),
                    Text('${weather.minTemps[i].toStringAsFixed(0)}°C', style: const TextStyle(fontSize: 16)),
                    Text('${weather.maxTemps[i].toStringAsFixed(0)}°C', style: const TextStyle(fontSize: 16)),
                    Text(weather.dailyDescs[i], style: const TextStyle(fontSize: 16)),
                  ],
                ),
              );
            },
            // itemBuilder: (ctx, i) => ListTile(
            //   title: Text(weather.dates[i]),
            //   subtitle: Text(weather.dailyDescs[i]),
            //   trailing: Text(
            //     '${weather.minTemps[i].toStringAsFixed(0)}° / '
            //     '${weather.maxTemps[i].toStringAsFixed(0)}°C',
            //   ),
            // ),
          ),
        ),
      ],
    );
  }
}