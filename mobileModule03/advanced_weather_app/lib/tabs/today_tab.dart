import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TodayTab extends StatelessWidget {
  final String cityName;
  final String stateCountry;
  final List<Map<String, dynamic>> hourlyWeather;
  final String? errorMessage;

  const TodayTab({
    Key? key,
    required this.cityName,
    required this.stateCountry,
    required this.hourlyWeather,
    required this.errorMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 16),
          const Text(
            'Today',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          Text(
            cityName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.blue,
            ),
          ),
          if (stateCountry.isNotEmpty)
            Text(
              stateCountry,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: Colors.black54),
            ),
          const SizedBox(height: 16),
          if (errorMessage != null)
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 18),
            )
          else
            Expanded(
              child: hourlyWeather.isNotEmpty
                  ? Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: SizedBox(
                            height: 250,
                            child: LineChart(
                              LineChartData(
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: true,
                                  getDrawingHorizontalLine: (value) {
                                    return FlLine(
                                      color: Colors.grey,
                                      strokeWidth: 1,
                                    );
                                  },
                                  getDrawingVerticalLine: (value) {
                                    return FlLine(
                                      color: Colors.grey,
                                      strokeWidth: 1,
                                    );
                                  },
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 40,
                                      interval: 4,
                                      getTitlesWidget: (value, meta) {
                                        final index = value.toInt();
                                        if (index >= 0 && index < hourlyWeather.length) {
                                          final hour = hourlyWeather[index]['time']
                                              .split('T')[1]
                                              .substring(0, 5);
                                          return SideTitleWidget(
                                            meta: meta,
                                            space: 8,
                                            child: Text(
                                              hour,
                                              style: const TextStyle(
                                                color: Colors.black87,
                                                fontSize: 12,
                                              ),
                                            ),
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 40,
                                      interval: 5,
                                      getTitlesWidget: (value, meta) {
                                        return Text(
                                          '${value.toInt()}°C',
                                          style: const TextStyle(
                                            color: Colors.black87,
                                            fontSize: 12,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                borderData: FlBorderData(
                                  show: true,
                                  border: Border.all(color: Colors.grey),
                                ),
                                minX: 0,
                                maxX: (hourlyWeather.length - 1).toDouble(),
                                minY: (hourlyWeather.map((e) => e['temperature'] as double).reduce((a, b) => a < b ? a : b) - 5).floorToDouble(),
                                maxY: (hourlyWeather.map((e) => e['temperature'] as double).reduce((a, b) => a > b ? a : b) + 5).ceilToDouble(),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: hourlyWeather
                                        .asMap()
                                        .entries
                                        .map((entry) => FlSpot(
                                              entry.key.toDouble(),
                                              entry.value['temperature'] as double,
                                            ))
                                        .toList(),
                                    isCurved: true,
                                    gradient: const LinearGradient(
                                      colors: [Colors.blueAccent, Colors.cyan],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    barWidth: 4,
                                    belowBarData: BarAreaData(
                                      show: true,
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.blueAccent.withAlpha((0.3 * 255).toInt()),
                                          Colors.cyan.withAlpha((0.1 * 255).toInt()),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                    dotData: FlDotData(
                                      show: true,
                                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                                        radius: 4,
                                        color: Colors.blueAccent,
                                        strokeWidth: 2,
                                        strokeColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                                lineTouchData: LineTouchData(
                                  touchTooltipData: LineTouchTooltipData(
                                    getTooltipItems: (touchedSpots) {
                                      return touchedSpots.map((spot) {
                                        final hour = hourlyWeather[spot.x.toInt()]['time'].split('T')[1].substring(0, 5);
                                        return LineTooltipItem(
                                          '$hour\n${spot.y}°C',
                                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        );
                                      }).toList();
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 150,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: hourlyWeather.length,
                            itemBuilder: (context, index) {
                              final hourly = hourlyWeather[index];
                              final time = hourly['time'] as String;
                              final hour = time.split('T')[1].substring(0, 5);
                              final temperature = hourly['temperature'] as double;
                              final weatherDescription = hourly['weatherDescription'] as String;
                              final windspeed = hourly['windspeed'] as double;

                              return Container(
                                width: 120,
                                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      hour,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Icon(
                                      _getWeatherIcon(weatherDescription),
                                      size: 32,
                                      color: Colors.blueAccent,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '$temperature°C',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      weatherDescription,
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      textAlign: TextAlign.center,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.air, size: 16, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(
                                          '$windspeed km/h',
                                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  : const Text(
                      'No hourly weather data available',
                      style: TextStyle(fontSize: 18),
                    ),
            ),
        ],
      ),
    );
  }

  IconData _getWeatherIcon(String description) {
    final Map<String, IconData> weatherIcons = {
      'clear sky': Icons.wb_sunny,
      'mainly clear': Icons.wb_sunny,
      'partly cloudy': Icons.wb_cloudy,
      'overcast': Icons.cloud,
      'fog': Icons.foggy,
      'depositing rime fog': Icons.foggy,
      'light drizzle': Icons.umbrella,
      'moderate drizzle': Icons.umbrella,
      'dense drizzle': Icons.umbrella,
      'light rain': Icons.umbrella,
      'moderate rain': Icons.umbrella,
      'heavy rain': Icons.umbrella,
      'light snow': Icons.ac_unit,
      'moderate snow': Icons.ac_unit,
      'heavy snow': Icons.ac_unit,
      'light rain showers': Icons.grain,
      'moderate rain showers': Icons.grain,
      'heavy rain showers': Icons.grain,
      'thunderstorm': Icons.flash_on,
      'thunderstorm with light hail': Icons.flash_on,
      'thunderstorm with heavy hail': Icons.flash_on,
    };
    return weatherIcons[description.toLowerCase()] ?? Icons.help_outline;
  }
}