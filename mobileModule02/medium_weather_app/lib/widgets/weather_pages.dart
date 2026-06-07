import 'package:flutter/material.dart';

class WeatherMessagePage extends StatelessWidget {
  const WeatherMessagePage({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(color: Colors.red),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class CurrentWeatherPage extends StatelessWidget {
  const CurrentWeatherPage({
    super.key,
    required this.locationLines,
    required this.currentWeatherData,
  });

  final String locationLines;
  final Map<String, dynamic> currentWeatherData;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$locationLines\n${currentWeatherData['temperature']}°C\n${currentWeatherData['weathercode']}\n${currentWeatherData['windspeed']} km/h',
        textAlign: TextAlign.center,
      ),
    );
  }
}

class TodayWeatherPage extends StatelessWidget {
  const TodayWeatherPage({
    super.key,
    required this.locationLines,
    required this.todayWeatherData,
  });

  final String locationLines;
  final Map<String, dynamic> todayWeatherData;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '$locationLines\n',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: todayWeatherData['time'].length,
            itemBuilder: (context, index) {
              final time = todayWeatherData['time'][index].toString().split('T').last;
              final temp = todayWeatherData['temperature_2m'][index];
              final wind = todayWeatherData['wind_speed_10m'][index];
              final description = todayWeatherData['weathercode'][index];

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(time.substring(0, 5)),
                    Text('${temp.toString()}°C'),
                    Text('${wind.toString()} km/h'),
                    Text('$description'),
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

class WeeklyWeatherPage extends StatelessWidget {
  const WeeklyWeatherPage({
    super.key,
    required this.locationLines,
    required this.weeklyWeatherData,
  });

  final String locationLines;
  final Map<String, dynamic> weeklyWeatherData;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '$locationLines\n',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: weeklyWeatherData['time'].length,
            itemBuilder: (context, index) {
              final time = weeklyWeatherData['time'][index].toString();
              final minTemp = weeklyWeatherData['temperature_2m_min'][index];
              final maxTemp = weeklyWeatherData['temperature_2m_max'][index];
              final wind = weeklyWeatherData['wind_speed_10m_max'][index];
              final description = weeklyWeatherData['weathercode'][index];

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(time.length >= 10 ? time.substring(0, 10) : time),
                    Text('${minTemp.toString()}°C'),
                    Text('${maxTemp.toString()}°C'),
                    Text('${wind.toString()} km/h'),
                    Text('$description'),
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
