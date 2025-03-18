import 'package:flutter/material.dart';

class CurrentlyTab extends StatelessWidget {
  final String cityName;
  final String stateCountry;
  final Map<String, dynamic> currentWeather;
  final String? errorMessage;

  const CurrentlyTab({
    Key? key,
    required this.cityName,
    required this.stateCountry,
    required this.currentWeather,
    required this.errorMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Text(
              cityName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 28,
                color: Colors.blue,
              ),
            ),
            if (stateCountry.isNotEmpty)
              Text(
                stateCountry,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, color: Colors.black54),
              ),
            const SizedBox(height: 20),
            if (errorMessage != null)
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 18),
              )
            else if (currentWeather.isNotEmpty)
              Column(
                children: [
                  Icon(
                    _getWeatherIcon(currentWeather['weatherDescription']),
                    size: 64,
                    color: Colors.blueAccent,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${currentWeather['temperature']}°C',
                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentWeather['weatherDescription'],
                    style: const TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.air, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Wind: ${currentWeather['windspeed']} km/h',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ],
              )
            else
              const Text(
                'No current weather data available',
                style: TextStyle(fontSize: 18),
              ),
            const SizedBox(height: 20),
          ],
        ),
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