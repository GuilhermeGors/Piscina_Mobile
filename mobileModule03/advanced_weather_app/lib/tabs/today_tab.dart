import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TodayTab extends StatelessWidget {
  final String cityName;
  final String stateCountry;
  final List<Map<String, dynamic>> hourlyWeather;
  final String? errorMessage;
  final VoidCallback onTryAgain;
  final IconData Function(String) getWeatherIcon;

  const TodayTab({
    super.key,
    required this.cityName,
    required this.stateCountry,
    required this.hourlyWeather,
    required this.errorMessage,
    required this.onTryAgain,
    required this.getWeatherIcon,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        SizedBox(height: screenHeight * 0.02),
        Text(
          'Today',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.06,
          ),
        ),
        Text(
          cityName,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.06,
            color: Colors.blue,
          ),
        ),
        if (stateCountry.isNotEmpty)
          Text(
            stateCountry,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              color: Colors.black54,
            ),
          ),
        SizedBox(height: screenHeight * 0.02),
        if (errorMessage != null)
          Column(
            children: [
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: screenWidth * 0.045,
                ),
              ),
              SizedBox(height: screenHeight * 0.015),
              ElevatedButton(
                onPressed: onTryAgain,
                child: Text(
                  'Try Again',
                  style: TextStyle(fontSize: screenWidth * 0.04),
                ),
              ),
            ],
          )
        else
          Expanded(
            child: hourlyWeather.isNotEmpty
                ? Column(
                    children: [
                      SizedBox(
                        height: screenHeight * 0.3,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: true,
                                getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey, strokeWidth: 1),
                                getDrawingVerticalLine: (value) => FlLine(color: Colors.grey, strokeWidth: 1),
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: screenWidth * 0.1,
                                    interval: 4,
                                    getTitlesWidget: (value, meta) {
                                      final index = value.toInt();
                                      if (index >= 0 && index < hourlyWeather.length) {
                                        final hour = hourlyWeather[index]['time'].split('T')[1].substring(0, 5);
                                        return SideTitleWidget(
                                          meta: meta,
                                          space: screenWidth * 0.02,
                                          child: Text(hour, style: TextStyle(color: Colors.black87, fontSize: screenWidth * 0.035)),
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: screenWidth * 0.1,
                                    interval: 5,
                                    getTitlesWidget: (value, meta) => Text('${value.toInt()}°C', style: TextStyle(color: Colors.black87, fontSize: screenWidth * 0.035)),
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey)),
                              minX: 0,
                              maxX: (hourlyWeather.length - 1).toDouble(),
                              minY: (hourlyWeather.map((e) => e['temperature'] as double).reduce((a, b) => a < b ? a : b) - 5).floorToDouble(),
                              maxY: (hourlyWeather.map((e) => e['temperature'] as double).reduce((a, b) => a > b ? a : b) + 5).ceilToDouble(),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: hourlyWeather.asMap().entries.map((entry) => FlSpot(entry.key.toDouble(), entry.value['temperature'] as double)).toList(),
                                  isCurved: true,
                                  gradient: const LinearGradient(colors: [Colors.blueAccent, Colors.cyan], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                                  barWidth: 4,
                                  belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [Colors.blueAccent.withAlpha((0.3 * 255).toInt()), Colors.cyan.withAlpha((0.1 * 255).toInt())], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                                  dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 4, color: Colors.blueAccent, strokeWidth: 2, strokeColor: Colors.white)),
                                ),
                              ],
                              lineTouchData: LineTouchData(
                                touchTooltipData: LineTouchTooltipData(
                                  getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
                                    final hour = hourlyWeather[spot.x.toInt()]['time'].split('T')[1].substring(0, 5);
                                    return LineTooltipItem('$hour\n${spot.y}°C', const TextStyle(color: Colors.white, fontWeight: FontWeight.bold));
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: screenHeight * 0.25,
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
                              width: screenWidth * 0.3,
                              margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(hour, style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.045)),
                                  SizedBox(height: screenHeight * 0.015),
                                  Icon(getWeatherIcon(weatherDescription), size: screenWidth * 0.1, color: Colors.blueAccent),
                                  SizedBox(height: screenHeight * 0.01),
                                  Text('$temperature°C', style: TextStyle(fontSize: screenWidth * 0.04, fontWeight: FontWeight.bold, color: temperature < 20 ? Colors.blue : Colors.red)),
                                  Text(weatherDescription, style: TextStyle(fontSize: screenWidth * 0.035, fontWeight: FontWeight.bold, color: Colors.black87), textAlign: TextAlign.center),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.air, size: screenWidth * 0.04, color: Colors.grey),
                                      SizedBox(width: screenWidth * 0.01),
                                      Text('$windspeed km/h', style: TextStyle(fontSize: screenWidth * 0.03, fontWeight: FontWeight.bold, color: Colors.black)),
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
                : Center(child: Text('No hourly weather data available', style: TextStyle(fontSize: screenWidth * 0.045))),
          ),
      ],
    );
  }
}