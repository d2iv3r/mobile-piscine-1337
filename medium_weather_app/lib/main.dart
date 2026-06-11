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