import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/weather_data.dart';
import '../utils/app_colors.dart';
import '../utils/weather_icons.dart';
import '../widgets/location_header.dart';

class WeeklyScreen extends StatelessWidget {
  final WeatherData weather;
  const WeeklyScreen({super.key, required this.weather});

  String _formatDate(String date) {
    final d = DateTime.tryParse(date);
    if (d == null) return date;
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[d.weekday - 1]}\n${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
  }

  String _shortDate(String date) {
    final d = DateTime.tryParse(date);
    if (d == null) return date;
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final minAll = weather.minTemps.reduce((a, b) => a < b ? a : b);
    final maxAll = weather.maxTemps.reduce((a, b) => a > b ? a : b);
    final minY   = (minAll - 2).floorToDouble();
    final maxY   = (maxAll + 2).ceilToDouble();

    List<FlSpot> minSpots() => List.generate(
        weather.minTemps.length, (i) => FlSpot(i.toDouble(), weather.minTemps[i]));
    List<FlSpot> maxSpots() => List.generate(
        weather.maxTemps.length, (i) => FlSpot(i.toDouble(), weather.maxTemps[i]));

    return SingleChildScrollView(
      child: Column(
        children: [
        LocationHeader(weather: weather),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Container(
            height: 190,
            padding: const EdgeInsets.fromLTRB(8, 12, 16, 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Weekly temperatures',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 4),

                Row(children: [
                  _legendDot(AppColors.chartMin), const SizedBox(width: 4),
                  const Text('Min', style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                  const SizedBox(width: 12),
                  _legendDot(AppColors.chartMax), const SizedBox(width: 4),
                  const Text('Max', style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                ]),
                const SizedBox(height: 4),
                Expanded(
                  child: LineChart(
                    LineChartData(
                      minY: minY, maxY: maxY,
                      gridData: FlGridData(
                        show: true,
                        getDrawingHorizontalLine: (_) =>
                            const FlLine(color: Colors.white10, strokeWidth: 1),
                        getDrawingVerticalLine: (_) =>
                            const FlLine(color: Colors.white10, strokeWidth: 1),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 36,
                            getTitlesWidget: (val, _) => Text(
                              '${val.toInt()}°',
                              style: const TextStyle(
                                  color: AppColors.textSecondary, fontSize: 10),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            getTitlesWidget: (val, _) {
                              final i = val.toInt();
                              if (i < 0 || i >= weather.dates.length) return const SizedBox();
                              return Text(
                                _shortDate(weather.dates[i]),
                                style: const TextStyle(
                                    color: AppColors.textSecondary, fontSize: 9),
                                textAlign: TextAlign.center,
                              );
                            },
                          ),
                        ),
                        topTitles:   AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      lineBarsData: [
                        _line(minSpots(), AppColors.chartMin),
                        _line(maxSpots(), AppColors.chartMax),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: weather.dates.length,
          itemBuilder: (ctx, i) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: Text(
                      _formatDate(weather.dates[i]),
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ),
                  Text(weatherIcon(weather.dailyCodes[i]),
                      style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      weather.dailyDescs[i],
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${weather.maxTemps[i].toStringAsFixed(0)}°C',
                        style: const TextStyle(
                          color: AppColors.chartMax,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${weather.minTemps[i].toStringAsFixed(0)}°C',
                        style: const TextStyle(
                          color: AppColors.chartMin,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
      ),
    );
  }

  LineChartBarData _line(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 2,
      dotData: FlDotData(
        show: true,
        getDotPainter: (_, __, ___, ____) =>
            FlDotCirclePainter(radius: 3, color: color, strokeWidth: 0),
      ),
      belowBarData: BarAreaData(show: false),
    );
  }

  Widget _legendDot(Color color) => Container(
      width: 10, height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle));
}