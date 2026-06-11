import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/weather_data.dart';
import '../utils/app_colors.dart';
import '../utils/weather_icons.dart';
import '../widgets/location_header.dart';

class TodayScreen extends StatelessWidget {
  final WeatherData weather;
  const TodayScreen({super.key, required this.weather});

  List<FlSpot> _spots() {
    return List.generate(
      weather.hourlyTemps.length,
      (i) => FlSpot(i.toDouble(), weather.hourlyTemps[i]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final temps  = weather.hourlyTemps;
    final minY   = (temps.reduce((a, b) => a < b ? a : b) - 2).floorToDouble();
    final maxY   = (temps.reduce((a, b) => a > b ? a : b) + 2).ceilToDouble();

    // Show every 3 hours on x-axis
    final xLabels = <int, String>{};
    for (int i = 0; i < weather.hours.length; i += 3) {
      xLabels[i] = weather.hours[i].substring(0, 5);
    }

    return Column(
      children: [
        LocationHeader(weather: weather),

        // ── Chart ──────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Container(
            height: 180,
            padding: const EdgeInsets.fromLTRB(8, 12, 16, 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Today temperatures',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 8),
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
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 22,
                            getTitlesWidget: (val, _) {
                              final label = xLabels[val.toInt()];
                              if (label == null) return const SizedBox();
                              return Text(label,
                                  style: const TextStyle(
                                      color: AppColors.textSecondary, fontSize: 9));
                            },
                          ),
                        ),
                        topTitles:   AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _spots(),
                          isCurved: true,
                          color: AppColors.accent,
                          barWidth: 2,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                              radius: 3,
                              color: AppColors.accent,
                              strokeWidth: 0,
                            ),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppColors.accent.withValues(alpha: 0.15),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // ── Hourly list ────────────────────────────────────────
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: weather.hours.length,
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
                    width: 52,
                    child: Text(
                      weather.hours[i].substring(0, 5),
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    ),
                  ),
                  Text(
                    weatherIcon(weather.hourlyCodes[i]),
                    style: const TextStyle(fontSize: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      weather.hourlyDescs[i],
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ),
                  Text(
                    '${weather.hourlyTemps[i].toStringAsFixed(1)}°C',
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Row(
                    children: [
                      const Icon(Icons.air, color: AppColors.accentCool, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        weather.hourlyWinds[i].toStringAsFixed(1),
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}