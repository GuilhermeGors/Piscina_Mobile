import 'package:flutter/material.dart';

class WeeklyTab extends StatelessWidget {
  final String cityName;
  final String stateCountry;
  final List<Map<String, dynamic>> dailyWeather;
  final String? errorMessage;

  const WeeklyTab({
    Key? key,
    required this.cityName,
    required this.stateCountry,
    required this.dailyWeather,
    required this.errorMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 16),
          const Text(
            'Weekly',
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
              child: dailyWeather.isNotEmpty
                  ? ListView.builder(
                      itemCount: dailyWeather.length,
                      itemBuilder: (context, index) {
                        final daily = dailyWeather[index];
                        final date = daily['date'] as String;
                        final maxTemperature = daily['maxTemperature'] as double;
                        final minTemperature = daily['minTemperature'] as double;
                        final weatherDescription = daily['weatherDescription'] as String;
                        return ListTile(
                          title: Text('Date: $date'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Max Temperature: $maxTemperature°C'),
                              Text('Min Temperature: $minTemperature°C'),
                              Text('Weather: $weatherDescription'),
                            ],
                          ),
                        );
                      },
                    )
                  : const Text(
                      'No weekly weather data available',
                      style: TextStyle(fontSize: 18),
                    ),
            ),
        ],
      ),
    );
  }
}