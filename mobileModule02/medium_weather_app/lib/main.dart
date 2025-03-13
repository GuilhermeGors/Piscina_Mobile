import 'package:flutter/material.dart';
import 'search_bar.dart' as custom;
import 'geolocation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _displayText = '';
  Map<String, dynamic> _currentWeather = {};
  List<Map<String, dynamic>> _hourlyWeather = [];
  List<Map<String, dynamic>> _dailyWeather = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0); // Inicia na aba "Current"
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _updateDisplayText(String text) {
    setState(() {
      _displayText = text;
    });
  }

  String getWeatherDescription(int weatherCode) {
    const weatherDescriptions = {
      0: 'Clear sky',
      1: 'Mainly clear',
      2: 'Partly cloudy',
      3: 'Overcast',
      45: 'Fog',
      48: 'Depositing rime fog',
      51: 'Light drizzle',
      53: 'Moderate drizzle',
      55: 'Dense drizzle',
      61: 'Light rain',
      63: 'Moderate rain',
      65: 'Heavy rain',
      71: 'Light snow',
      73: 'Moderate snow',
      75: 'Heavy snow',
      80: 'Light rain showers',
      81: 'Moderate rain showers',
      82: 'Heavy rain showers',
      95: 'Thunderstorm',
      96: 'Thunderstorm with light hail',
      99: 'Thunderstorm with heavy hail',
    };

    return weatherDescriptions[weatherCode] ?? 'Unknown';
  }

  void _fetchWeather(double latitude, double longitude) async {
    try {
      final response = await http.get(Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current=temperature_2m,weathercode,windspeed_10m&hourly=temperature_2m,weathercode,windspeed_10m&daily=weathercode,temperature_2m_max,temperature_2m_min'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final currentWeather = data['current'];
        setState(() {
          _currentWeather = {
            'temperature': currentWeather['temperature_2m'],
            'weatherDescription': getWeatherDescription(currentWeather['weathercode']),
            'windspeed': currentWeather['windspeed_10m'],
          };
        });

        final hourlyData = data['hourly'];
        final times = hourlyData['time'] as List;
        final temperatures = hourlyData['temperature_2m'] as List;
        final weatherCodes = hourlyData['weathercode'] as List;
        final windspeeds = hourlyData['windspeed_10m'] as List;

        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        setState(() {
          _hourlyWeather = List.generate(
            times.length,
            (index) => {
              'time': times[index],
              'temperature': temperatures[index],
              'weatherDescription': getWeatherDescription(weatherCodes[index]),
              'windspeed': windspeeds[index],
            },
          ).where((hourly) {
            final time = DateTime.parse(hourly['time']);
            return time.day == today.day && time.month == today.month && time.year == today.year;
          }).toList();
        });

        // Dados diários (para a semana)
        final dailyData = data['daily'];
        final dates = dailyData['time'] as List;
        final maxTemps = dailyData['temperature_2m_max'] as List;
        final minTemps = dailyData['temperature_2m_min'] as List;
        final dailyWeatherCodes = dailyData['weathercode'] as List;

        setState(() {
          _dailyWeather = List.generate(
            dates.length,
            (index) => {
              'date': dates[index],
              'maxTemperature': maxTemps[index],
              'minTemperature': minTemps[index],
              'weatherDescription': getWeatherDescription(dailyWeatherCodes[index]),
            },
          );
        });

        debugPrint('Weather data fetched: $data');
      } else {
        debugPrint('Failed to fetch weather: ${response.statusCode}');
        setState(() {
          _currentWeather = {};
          _hourlyWeather = [];
          _dailyWeather = [];
        });
      }
    } catch (e) {
      debugPrint('Error fetching weather: $e');
      setState(() {
        _currentWeather = {};
        _hourlyWeather = [];
        _dailyWeather = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: custom.SearchBar(
          onCitySelected: (cityName, latitude, longitude) {
            _updateDisplayText('Weather in $cityName');
            _fetchWeather(latitude, longitude);
          },
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          GeolocationButton(
            onLocationUpdated: (location) {
              _updateDisplayText(location);
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Aba "Currently"
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Current\n$_displayText',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 16),
                if (_currentWeather.isNotEmpty) ...[
                  Text(
                    'Temperature: ${_currentWeather['temperature']}°C',
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Weather: ${_currentWeather['weatherDescription']}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Wind Speed: ${_currentWeather['windspeed']} km/h',
                    style: const TextStyle(fontSize: 18),
                  ),
                ] else
                  const Text(
                    'No current weather data available',
                    style: TextStyle(fontSize: 18),
                  ),
              ],
            ),
          ),
          // Aba "Today"
          Center(
            child: Column(
              children: [
                Text(
                  'Today\n$_displayText',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _hourlyWeather.isNotEmpty
                      ? ListView.builder(
                          itemCount: _hourlyWeather.length,
                          itemBuilder: (context, index) {
                            final hourly = _hourlyWeather[index];
                            final time = hourly['time'] as String;
                            final hour = time.split('T')[1].substring(0, 5); // Extrair apenas HH:MM
                            final temperature = hourly['temperature'] as double;
                            final weatherDescription = hourly['weatherDescription'] as String;
                            final windspeed = hourly['windspeed'] as double;
                            return ListTile(
                              title: Text('Hour: $hour'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Temperature: $temperature°C'),
                                  Text('Weather: $weatherDescription'),
                                  Text('Wind Speed: $windspeed km/h'),
                                ],
                              ),
                            );
                          },
                        )
                      : const Text('No hourly weather data available'),
                ),
              ],
            ),
          ),
          // Aba "Weekly"
          Center(
            child: Column(
              children: [
                Text(
                  'Weekly\n$_displayText',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _dailyWeather.isNotEmpty
                      ? ListView.builder(
                          itemCount: _dailyWeather.length,
                          itemBuilder: (context, index) {
                            final daily = _dailyWeather[index];
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
                      : const Text('No weekly weather data available'),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).colorScheme.inversePrimary,
        child: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.cloud), text: 'Currently'),
            Tab(icon: Icon(Icons.today), text: 'Today'),
            Tab(icon: Icon(Icons.calendar_view_week), text: 'Weekly'),
          ],
        ),
      ),
    );
  }
}