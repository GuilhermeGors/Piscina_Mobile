import 'package:flutter/material.dart';
import 'search_bar.dart' as custom;
import 'geolocation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'tabs/currently_tab.dart';
import 'tabs/weekly_tab.dart';
import 'tabs/today_tab.dart';

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
  String _cityName = '';
  String _stateCountry = '';
  Map<String, dynamic> _currentWeather = {};
  List<Map<String, dynamic>> _hourlyWeather = [];
  List<Map<String, dynamic>> _dailyWeather = [];
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    _requestLocationOnStart();
  }

  Future<void> _requestLocationOnStart() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final location = await Location.fetchGeolocation();
      _updateDisplayText(location.name, location.region, location.country, location.latitude, location.longitude);
    } catch (e) {
      debugPrint('Initial location error: $e');
      setState(() {
        _cityName = '';
        _stateCountry = '';
        _currentWeather = {};
        _hourlyWeather = [];
        _dailyWeather = [];
        _errorMessage = 'Unable to fetch location: Please check your connection or try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _updateDisplayText(String cityName, String? state, String? country, double latitude, double longitude) {
    debugPrint('Updating display: city=$cityName, state=$state, country=$country, lat=$latitude, lon=$longitude');
    setState(() {
      if (latitude != 0.0 && longitude != 0.0 && latitude >= -90 && latitude <= 90 && longitude >= -180 && longitude <= 180) {
        _cityName = cityName;
        _stateCountry = state != null && country != null ? '$state, $country' : '';
        _errorMessage = null;
        _fetchWeather(latitude, longitude);
      } else {
        _cityName = '';
        _stateCountry = '';
        _currentWeather = {};
        _hourlyWeather = [];
        _dailyWeather = [];
        _errorMessage = 'Unable to fetch location: Please check your Permissions and try again.';
      }
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
      final url = 'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current=temperature_2m,weathercode,windspeed_10m&hourly=temperature_2m,weathercode,windspeed_10m&daily=weathercode,temperature_2m_max,temperature_2m_min';
      debugPrint('Fetching weather with URL: $url');
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

        debugPrint('Weather data fetched successfully');
      } else {
        final errorData = json.decode(response.body);
        final errorReason = errorData['reason'] ?? 'Unknown error';
        debugPrint('Weather API failed with status: ${response.statusCode}');
        setState(() {
          _cityName = '';
          _stateCountry = '';
          _currentWeather = {};
          _hourlyWeather = [];
          _dailyWeather = [];
          _errorMessage = 'Failed to fetch weather: $errorReason (Status: ${response.statusCode}). Please try again.';
        });
      }
    } catch (e) {
      debugPrint('Error fetching weather: $e');
      setState(() {
        _cityName = '';
        _stateCountry = '';
        _currentWeather = {};
        _hourlyWeather = [];
        _dailyWeather = [];
        _errorMessage = 'No internet connection. Please check your network and try again.';
      });
    }
  }

  final Map<String, IconData> _weatherIcons = {
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

  IconData _getWeatherIcon(String description) {
    return _weatherIcons[description.toLowerCase()] ?? Icons.help_outline;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.jpeg'),
                fit: BoxFit.cover,
                opacity: 0.6,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                AppBar(
                  title: custom.SearchBar(
                    onCitySelected: (cityName, state, country, latitude, longitude) {
                      _updateDisplayText(cityName, state, country, latitude, longitude);
                    },
                    onError: (errorMessage) {
                      setState(() {
                        _cityName = '';
                        _stateCountry = '';
                        _currentWeather = {};
                        _hourlyWeather = [];
                        _dailyWeather = [];
                        _errorMessage = errorMessage;
                      });
                    },
                  ),
                  backgroundColor: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.9),
                  actions: [
                    GeolocationButton(
                      onLocationUpdated: (cityName, state, country, latitude, longitude) {
                        _updateDisplayText(cityName, state, country, latitude, longitude);
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            CurrentlyTab(
                              cityName: _cityName,
                              stateCountry: _stateCountry,
                              currentWeather: _currentWeather,
                              errorMessage: _errorMessage,
                              onTryAgain: _requestLocationOnStart,
                              getWeatherIcon: _getWeatherIcon,
                            ),
                            TodayTab(
                              cityName: _cityName,
                              stateCountry: _stateCountry,
                              hourlyWeather: _hourlyWeather,
                              errorMessage: _errorMessage,
                              onTryAgain: _requestLocationOnStart,
                              getWeatherIcon: _getWeatherIcon,
                            ),
                            WeeklyTab(
                              cityName: _cityName,
                              stateCountry: _stateCountry,
                              dailyWeather: _dailyWeather,
                              errorMessage: _errorMessage,
                              onTryAgain: _requestLocationOnStart,
                              getWeatherIcon: _getWeatherIcon,
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.9),
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