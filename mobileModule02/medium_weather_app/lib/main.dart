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
  String _displayText = 'Weather App';
  Map<String, dynamic> _currentWeather = {};
  List<Map<String, dynamic>> _hourlyWeather = [];
  List<Map<String, dynamic>> _dailyWeather = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    _fetchInitialLocation();
  }

  Future<void> _fetchInitialLocation() async {
    try {
      final location = await Location.fetchGeolocation();
      _updateDisplayText('Weather in ${location.name}', location.latitude, location.longitude);
    } catch (e) {
      debugPrint('Initial geolocation error: $e');
      setState(() {
        _errorMessage = '$e. You can still search by city name.';
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _updateDisplayText(String text, double latitude, double longitude) {
    setState(() {
      // Validar latitude e longitude antes de prosseguir
      if (latitude >= -90 && latitude <= 90 && longitude >= -180 && longitude <= 180) {
        _displayText = text;
        _errorMessage = null;
        _fetchWeather(latitude, longitude);
      } else {
        _displayText = _displayText.isEmpty ? 'Weather App' : _displayText;
        _errorMessage = 'Invalid coordinates received: $text';
        _currentWeather = {};
        _hourlyWeather = [];
        _dailyWeather = [];
      }
    });
  }

  void _handleSearchError(String error) {
    setState(() {
      _errorMessage = error;
      _currentWeather = {};
      _hourlyWeather = [];
      _dailyWeather = [];
    });
  }

  String getWeatherDescription(int weatherCode) {
    const weatherDescriptions = {
      0: 'Clear sky', 1: 'Mainly clear', 2: 'Partly cloudy', 3: 'Overcast', 45: 'Fog', 48: 'Depositing rime fog',
      51: 'Light drizzle', 53: 'Moderate drizzle', 55: 'Dense drizzle', 61: 'Light rain', 63: 'Moderate rain',
      65: 'Heavy rain', 71: 'Light snow', 73: 'Moderate snow', 75: 'Heavy snow', 80: 'Light rain showers',
      81: 'Moderate rain showers', 82: 'Heavy rain showers', 95: 'Thunderstorm', 96: 'Thunderstorm with light hail',
      99: 'Thunderstorm with heavy hail',
    };
    return weatherDescriptions[weatherCode] ?? 'Unknown';
  }

  void _fetchWeather(double latitude, double longitude) async {
    try {
      debugPrint('Fetching weather for lat: $latitude, lon: $longitude');
      final url = 'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current=temperature_2m,weathercode,windspeed_10m&hourly=temperature_2m,weathercode,windspeed_10m&daily=weathercode,temperature_2m_max,temperature_2m_min';
      debugPrint('Weather API URL: $url');
      final response = await http.get(Uri.parse(url));
      debugPrint('Weather API response status: ${response.statusCode}');
      debugPrint('Weather API response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final currentWeather = data['current'];
        setState(() {
          _currentWeather = {
            'temperature': currentWeather['temperature_2m'],
            'weatherDescription': getWeatherDescription(currentWeather['weathercode']),
            'windspeed': currentWeather['windspeed_10m'],
          };
          _errorMessage = null;
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

        final dailyData = data['daily'];
        final dates = dailyData['time'] as List;
        final maxTemps = dailyData['temperature_2m_max'] as List;
        final minTemps = dailyData['temperature_2m_min'] as List;
        final dailyWeatherCodes = data['daily']['weathercode'] as List;

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

        debugPrint('Weather data fetched successfully');
      } else {
        debugPrint('Weather API failed with status: ${response.statusCode}');
        setState(() {
          _currentWeather = {};
          _hourlyWeather = [];
          _dailyWeather = [];
          _errorMessage = 'Failed to fetch weather data. Please try again.';
        });
      }
    } catch (e) {
      debugPrint('Error fetching weather: $e');
      setState(() {
        _currentWeather = {};
        _hourlyWeather = [];
        _dailyWeather = [];
        _errorMessage = 'Error fetching weather. Please check your connection or try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: custom.SearchBar(
          onCitySelected: (cityName, latitude, longitude) {
            _updateDisplayText('Weather in $cityName', latitude, longitude);
          },
          onError: _handleSearchError,
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          GeolocationButton(
            onLocationUpdated: (location, latitude, longitude) {
              _updateDisplayText('Weather in $location', latitude, longitude);
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: TabBarView(
          controller: _tabController,
          children: [
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
                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 18,
                      ),
                    )
                  else if (_currentWeather.isNotEmpty)
                    Column(
                      children: [
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
                      ],
                    )
                  else
                    const Text(
                      'No current weather data available',
                      style: TextStyle(fontSize: 18),
                    ),
                ],
              ),
            ),
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
                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 18,
                      ),
                    )
                  else
                    Expanded(
                      child: _hourlyWeather.isNotEmpty
                          ? ListView.builder(
                              itemCount: _hourlyWeather.length,
                              itemBuilder: (context, index) {
                                final hourly = _hourlyWeather[index];
                                final time = hourly['time'] as String;
                                final hour = time.split('T')[1].substring(0, 5);
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
                          : const Text(
                              'No hourly weather data available',
                              style: TextStyle(fontSize: 18),
                            ),
                    ),
                ],
              ),
            ),
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
                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 18,
                      ),
                    )
                  else
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
                          : const Text(
                              'No weekly weather data available',
                              style: TextStyle(fontSize: 18),
                            ),
                    ),
                ],
              ),
            ),
          ],
        ),
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