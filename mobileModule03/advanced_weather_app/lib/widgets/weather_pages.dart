import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

IconData getWeatherIcon(int code) {
  if (code >= 1 && code <= 3) return Icons.cloud;
  if (code >= 45 && code <= 48) return Icons.foggy;
  if (code >= 51 && code <= 67) return Icons.water_drop;
  if (code >= 71 && code <= 86) return Icons.ac_unit;
  if (code >= 95) return Icons.flash_on;
  return Icons.wb_sunny;
}

String getWeatherDescription(int code) {
  if (code >= 1 && code <= 3) return 'Cloudy';
  if (code >= 45 && code <= 48) return 'Fog';
  if (code >= 51 && code <= 67) return 'Rain';
  if (code >= 71 && code <= 86) return 'Snow';
  if (code >= 95) return 'Thunderstorm';
  return 'Clear';
}

class WeatherMessagePage extends StatelessWidget {
  const WeatherMessagePage({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(color: Colors.redAccent),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class CurrentWeatherPage extends StatelessWidget {
  const CurrentWeatherPage({
    super.key,
    required this.cityName,
    required this.regionCountry,
    required this.currentWeatherData,
  });

  final String cityName;
  final String regionCountry;
  final Map<String, dynamic> currentWeatherData;

  @override
  Widget build(BuildContext context) {
    int code = currentWeatherData['weathercode'] ?? 0;
    String description = getWeatherDescription(code);
    IconData iconData = getWeatherIcon(code);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          cityName,
          style: const TextStyle(
            color: Colors.lightBlue,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        if (regionCountry.isNotEmpty)
          Text(
            regionCountry,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        const SizedBox(height: 40),
        Text(
          '${currentWeatherData['temperature']}°C',
          style: const TextStyle(
            color: Colors.orange,
            fontSize: 60,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Text(
          description,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Icon(
          iconData,
          color: Colors.lightBlue,
          size: 80,
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.air, color: Colors.lightBlue, size: 24),
            const SizedBox(width: 8),
            Text(
              '${currentWeatherData['windspeed']} km/h',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class TodayWeatherPage extends StatelessWidget {
  const TodayWeatherPage({
    super.key,
    required this.cityName,
    required this.regionCountry,
    required this.todayWeatherData,
  });

  final String cityName;
  final String regionCountry;
  final Map<String, dynamic> todayWeatherData;

  @override
  Widget build(BuildContext context) {
    // Limit to 24 hours for "Today"
    final times = (todayWeatherData['time'] as List<dynamic>).take(24).toList();
    final temps = (todayWeatherData['temperature_2m'] as List<dynamic>).take(24).toList();
    final winds = (todayWeatherData['wind_speed_10m'] as List<dynamic>).take(24).toList();
    final codes = (todayWeatherData['weathercode'] as List<dynamic>).take(24).toList();

    List<FlSpot> spots = [];
    double minTemp = temps.isNotEmpty ? temps[0].toDouble() : 0;
    double maxTemp = temps.isNotEmpty ? temps[0].toDouble() : 0;
    for (int i = 0; i < times.length; i++) {
      double temp = temps[i].toDouble();
      spots.add(FlSpot(i.toDouble(), temp));
      if (temp < minTemp) minTemp = temp;
      if (temp > maxTemp) maxTemp = temp;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        Text(
          cityName,
          style: const TextStyle(
            color: Colors.lightBlue,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        if (regionCountry.isNotEmpty)
          Text(
            regionCountry,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        const SizedBox(height: 20),
        
        // Chart
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text(
                  'Today temperatures',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: times.length * 40.0, // 40 pixels per hour
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: true,
                            getDrawingHorizontalLine: (value) => FlLine(color: Colors.white24, strokeWidth: 1),
                            getDrawingVerticalLine: (value) => FlLine(color: Colors.white24, strokeWidth: 1),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  if (value < 0 || value >= times.length) return const SizedBox.shrink();
                                  if (value.round() != value) return const SizedBox.shrink();
                                  
                                  final timeStr = times[value.round()].toString().split('T').last.substring(0, 5);
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(timeStr, style: const TextStyle(color: Colors.white, fontSize: 10)),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 2,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  return Text('${value.toInt()}°C', style: const TextStyle(color: Colors.white, fontSize: 10));
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(color: Colors.white24),
                          ),
                          minX: 0,
                          maxX: (times.length - 1).toDouble(),
                          minY: (minTemp - 2).floorToDouble(),
                          maxY: (maxTemp + 2).ceilToDouble(),
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: false,
                              color: Colors.orange,
                              barWidth: 2,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: true),
                              belowBarData: BarAreaData(show: false),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Horizontal list
        SizedBox(
          height: 140,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: times.length,
              itemBuilder: (context, index) {
                final time = times[index].toString().split('T').last.substring(0, 5);
                final temp = temps[index];
                final wind = winds[index];
                final icon = getWeatherIcon(codes[index]);

                return Container(
                  width: 85,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(time, style: const TextStyle(color: Colors.white, fontSize: 14)),
                      Icon(icon, color: Colors.lightBlue, size: 28),
                      Text('${temp.toString()}°C', style: const TextStyle(color: Colors.orange, fontSize: 18, fontWeight: FontWeight.bold)),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.air, color: Colors.white70, size: 14),
                            const SizedBox(width: 4),
                            Text('${wind.toString()}km/h', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class WeeklyWeatherPage extends StatelessWidget {
  const WeeklyWeatherPage({
    super.key,
    required this.cityName,
    required this.regionCountry,
    required this.weeklyWeatherData,
  });

  final String cityName;
  final String regionCountry;
  final Map<String, dynamic> weeklyWeatherData;

  @override
  Widget build(BuildContext context) {
    final timesRaw = weeklyWeatherData['time'] as List<dynamic>;
    final minTemps = weeklyWeatherData['temperature_2m_min'] as List<dynamic>;
    final maxTemps = weeklyWeatherData['temperature_2m_max'] as List<dynamic>;
    final codes = weeklyWeatherData['weathercode'] as List<dynamic>;

    final int count = timesRaw.length < 7 ? timesRaw.length : 7;
    
    List<String> formattedDates = [];
    for (int i = 0; i < count; i++) {
      String dateString = timesRaw[i].toString();
      if (dateString.length >= 10) {
        var parts = dateString.split('-');
        if (parts.length >= 3) {
          formattedDates.add('${parts[2]}/${parts[1]}');
        } else {
          formattedDates.add(dateString);
        }
      } else {
        formattedDates.add(dateString);
      }
    }

    List<FlSpot> minSpots = [];
    List<FlSpot> maxSpots = [];
    double overallMin = minTemps.isNotEmpty ? minTemps[0].toDouble() : 0;
    double overallMax = maxTemps.isNotEmpty ? maxTemps[0].toDouble() : 0;

    for (int i = 0; i < count; i++) {
      double minT = minTemps[i].toDouble();
      double maxT = maxTemps[i].toDouble();
      minSpots.add(FlSpot(i.toDouble(), minT));
      maxSpots.add(FlSpot(i.toDouble(), maxT));
      
      if (minT < overallMin) overallMin = minT;
      if (maxT > overallMax) overallMax = maxT;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        Text(
          cityName,
          style: const TextStyle(
            color: Colors.lightBlue,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        if (regionCountry.isNotEmpty)
          Text(
            regionCountry,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        const SizedBox(height: 20),
        
        // Chart
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text(
                  'Weekly temperatures',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: count * 50.0,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: true,
                            getDrawingHorizontalLine: (value) => FlLine(color: Colors.white24, strokeWidth: 1),
                            getDrawingVerticalLine: (value) => FlLine(color: Colors.white24, strokeWidth: 1),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  if (value < 0 || value >= count) return const SizedBox.shrink();
                                  if (value.round() != value) return const SizedBox.shrink();
                                  
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(formattedDates[value.round()], style: const TextStyle(color: Colors.white, fontSize: 10)),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 5,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  return Text('${value.toInt()}°C', style: const TextStyle(color: Colors.white, fontSize: 10));
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(color: Colors.white24),
                          ),
                          minX: 0,
                          maxX: (count - 1).toDouble(),
                          minY: (overallMin - 5).floorToDouble(),
                          maxY: (overallMax + 5).ceilToDouble(),
                          lineBarsData: [
                            LineChartBarData(
                              spots: minSpots,
                              isCurved: false,
                              color: Colors.lightBlue,
                              barWidth: 2,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: true),
                              belowBarData: BarAreaData(show: false),
                            ),
                            LineChartBarData(
                              spots: maxSpots,
                              isCurved: false,
                              color: Colors.redAccent,
                              barWidth: 2,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: true),
                              belowBarData: BarAreaData(show: false),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Legend
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.circle, color: Colors.lightBlue, size: 10),
                    const SizedBox(width: 4),
                    const Text('Min temperature', style: TextStyle(color: Colors.white, fontSize: 12)),
                    const SizedBox(width: 16),
                    const Icon(Icons.circle, color: Colors.redAccent, size: 10),
                    const SizedBox(width: 4),
                    const Text('Max temperature', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Horizontal list
        SizedBox(
          height: 140,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: count,
              itemBuilder: (context, index) {
                final String date = formattedDates[index];
                final double minT = minTemps[index].toDouble();
                final double maxT = maxTemps[index].toDouble();
                final icon = getWeatherIcon(codes[index]);

                return Container(
                  width: 85,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(date, style: const TextStyle(color: Colors.white, fontSize: 14)),
                      Icon(icon, color: Colors.white, size: 28),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(text: '${maxT.toString()}°C ', style: const TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                            const TextSpan(text: 'max', style: TextStyle(color: Colors.redAccent, fontSize: 10)),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(text: '${minT.toString()}°C ', style: const TextStyle(color: Colors.lightBlue, fontSize: 16, fontWeight: FontWeight.bold)),
                            const TextSpan(text: 'min', style: TextStyle(color: Colors.lightBlue, fontSize: 10)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
