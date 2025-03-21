import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart' as intl;

class WeeklyTab extends StatelessWidget {
  final String cityName;
  final String stateCountry;
  final List<Map<String, dynamic>> dailyWeather;
  final String? errorMessage;
  final VoidCallback onTryAgain;
  final IconData Function(String) getWeatherIcon;

  const WeeklyTab({
    super.key,
    required this.cityName,
    required this.stateCountry,
    required this.dailyWeather,
    required this.errorMessage,
    required this.onTryAgain,
    required this.getWeatherIcon,
  });

  String _getDayOfWeek(String date) {
    final dateTime = DateTime.parse(date);
    return intl.DateFormat('EEE').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        SizedBox(height: screenHeight * 0.02),
        Text(
          'Weekly',
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
            child: dailyWeather.isNotEmpty
                ? Column(
                    children: [
                      Expanded(
                        flex: 3, // 60% do espaço disponível (aproximadamente 0.3 / (0.3 + 0.25))
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
                                    interval: 1,
                                    getTitlesWidget: (value, meta) {
                                      final index = value.toInt();
                                      if (index >= 0 && index < dailyWeather.length) {
                                        final day = _getDayOfWeek(dailyWeather[index]['date']);
                                        return SideTitleWidget(
                                          meta: meta,
                                          space: screenWidth * 0.02,
                                          child: Text(day, style: TextStyle(color: Colors.black87, fontSize: screenWidth * 0.035)),
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
                              maxX: (dailyWeather.length - 1).toDouble(),
                              minY: (dailyWeather.map((e) => e['minTemperature'] as double).reduce((a, b) => a < b ? a : b) - 5).floorToDouble(),
                              maxY: (dailyWeather.map((e) => e['maxTemperature'] as double).reduce((a, b) => a > b ? a : b) + 5).ceilToDouble(),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: dailyWeather.asMap().entries.map((entry) => FlSpot(entry.key.toDouble(), entry.value['maxTemperature'] as double)).toList(),
                                  isCurved: true,
                                  gradient: const LinearGradient(colors: [Colors.redAccent, Colors.orange], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                                  barWidth: 4,
                                  dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 4, color: Colors.redAccent, strokeWidth: 2, strokeColor: Colors.white)),
                                ),
                                LineChartBarData(
                                  spots: dailyWeather.asMap().entries.map((entry) => FlSpot(entry.key.toDouble(), entry.value['minTemperature'] as double)).toList(),
                                  isCurved: true,
                                  gradient: const LinearGradient(colors: [Colors.blueAccent, Colors.cyan], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                                  barWidth: 4,
                                  dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 4, color: Colors.blueAccent, strokeWidth: 2, strokeColor: Colors.white)),
                                ),
                              ],
                              lineTouchData: LineTouchData(
                                touchTooltipData: LineTouchTooltipData(
                                  getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
                                    final index = spot.x.toInt();
                                    final day = _getDayOfWeek(dailyWeather[index]['date']);
                                    final temp = spot.y;
                                    final isMax = spot.barIndex == 0;
                                    return LineTooltipItem('$day\n${isMax ? 'Max' : 'Min'}: $temp°C', const TextStyle(color: Colors.white, fontWeight: FontWeight.bold));
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2, // 40% do espaço disponível (aproximadamente 0.25 / (0.3 + 0.25))
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: dailyWeather.length,
                          itemBuilder: (context, index) {
                            final daily = dailyWeather[index];
                            final date = daily['date'] as String;
                            final dayOfWeek = _getDayOfWeek(date);
                            final maxTemperature = daily['maxTemperature'] as double;
                            final minTemperature = daily['minTemperature'] as double;
                            final weatherDescription = daily['weatherDescription'] as String;
                            final windspeed = daily['windspeed'] as double?;
                            return Container(
                              width: screenWidth * 0.3,
                              margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(dayOfWeek, style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.045)),
                                  SizedBox(height: screenHeight * 0.015),
                                  Icon(getWeatherIcon(weatherDescription), size: screenWidth * 0.1, color: Colors.blueAccent),
                                  SizedBox(height: screenHeight * 0.01),
                                  Text('Max: $maxTemperature°C', style: TextStyle(fontSize: screenWidth * 0.04, fontWeight: FontWeight.bold, color: maxTemperature < 20 ? Colors.blue : Colors.red)),
                                  Text('Min: $minTemperature°C', style: TextStyle(fontSize: screenWidth * 0.04, fontWeight: FontWeight.bold, color: minTemperature < 20 ? Colors.blue : Colors.red)),
                                  Text(weatherDescription, style: TextStyle(fontSize: screenWidth * 0.035, fontWeight: FontWeight.bold, color: Colors.black87), textAlign: TextAlign.center),
                                  if (windspeed != null)
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
                : Center(child: Text('No weekly weather data available', style: TextStyle(fontSize: screenWidth * 0.045))),
          ),
      ],
    );
  }
}