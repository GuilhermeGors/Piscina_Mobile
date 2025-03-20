import 'package:flutter/material.dart';
import 'search_bar.dart' as custom;
import 'geolocation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart' as intl;
import 'dart:async'; // Para TimeoutException
import 'dart:io';

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

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _cityName = 'Weather App';
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
      final location = await Location.fetchGeolocation().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Geolocation request timed out.');
        },
      );
      _updateDisplayText(
        location.name,
        location.region,
        location.country,
        location.latitude,
        location.longitude,
      );
    } on TimeoutException catch (e) {
      debugPrint('Timeout error in geolocation: $e');
      setState(() {
        _errorMessage =
            'No internet connection or slow response. Please check your network and try again.';
      });
    } on HttpException catch (e) {
      debugPrint('HttpException in geolocation: $e');
      setState(() {
        _errorMessage =
            'No internet connection. Please check your network and try again.';
      });
    } on SocketException catch (e) {
      debugPrint('SocketException in geolocation: $e');
      setState(() {
        _errorMessage =
            'No internet connection. Please check your network and try again.';
      });
    } catch (e) {
      debugPrint('Initial location error: $e');
      setState(() {
        _errorMessage =
            'An error occurred: $e. You can still search by city name.';
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

  void _updateDisplayText(
    String cityName,
    String? state,
    String? country,
    double latitude,
    double longitude,
  ) {
    debugPrint(
      'Updating display: city=$cityName, state=$state, country=$country, lat=$latitude, lon=$longitude',
    );
    setState(() {
      if (latitude != 0.0 &&
          longitude != 0.0 &&
          latitude >= -90 &&
          latitude <= 90 &&
          longitude >= -180 &&
          longitude <= 180) {
        _cityName = cityName;
        _stateCountry =
            state != null && country != null ? '$state, $country' : '';
        _errorMessage = null;
        _fetchWeather(latitude, longitude);
      } else {
        _cityName = _cityName.isEmpty ? 'Weather App' : _cityName;
        _stateCountry = '';
        _errorMessage =
            'Failed to retrieve valid coordinates from your location. Please try again.';
        _currentWeather = {};
        _hourlyWeather = [];
        _dailyWeather = [];
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
      final url =
          'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current=temperature_2m,weathercode,windspeed_10m&hourly=temperature_2m,weathercode,windspeed_10m&daily=weathercode,temperature_2m_max,temperature_2m_min';
      debugPrint('Fetching weather with URL: $url');
      final response = await http
          .get(Uri.parse(url))
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException('Weather API request timed out.');
            },
          );
      debugPrint('Weather API response status: ${response.statusCode}');
      debugPrint('Weather API response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Verifica se os dados esperados existem
        if (data == null ||
            data['current'] == null ||
            data['hourly'] == null ||
            data['daily'] == null) {
          throw Exception(
            'Invalid response from weather API: missing required fields.',
          );
        }

        final currentWeather = data['current'];
        setState(() {
          _currentWeather = {
            'temperature': currentWeather['temperature_2m'] ?? 0.0,
            'weatherDescription': getWeatherDescription(
              currentWeather['weathercode'] ?? 0,
            ),
            'windspeed': currentWeather['windspeed_10m'] ?? 0.0,
          };
          _errorMessage = null;
        });

        final hourlyData = data['hourly'];
        // Verifica se os campos de hourly existem e são listas
        if (hourlyData['time'] is List &&
            hourlyData['temperature_2m'] is List &&
            hourlyData['weathercode'] is List &&
            hourlyData['windspeed_10m'] is List) {
          final times = hourlyData['time'] as List;
          final temperatures = hourlyData['temperature_2m'] as List;
          final weatherCodes = hourlyData['weathercode'] as List;
          final windspeeds = hourlyData['windspeed_10m'] as List;

          // Verifica se todas as listas têm o mesmo tamanho
          if (times.length == temperatures.length &&
              times.length == weatherCodes.length &&
              times.length == windspeeds.length) {
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            setState(() {
              _hourlyWeather =
                  List.generate(
                    times.length,
                    (index) => {
                      'time': times[index],
                      'temperature': temperatures[index] ?? 0.0,
                      'weatherDescription': getWeatherDescription(
                        weatherCodes[index] ?? 0,
                      ),
                      'windspeed': windspeeds[index] ?? 0.0,
                    },
                  ).where((hourly) {
                    final time = DateTime.parse(hourly['time']);
                    return time.day == today.day &&
                        time.month == today.month &&
                        time.year == today.year;
                  }).toList();
            });
          } else {
            throw Exception(
              'Hourly weather data lists have inconsistent lengths.',
            );
          }
        } else {
          throw Exception(
            'Invalid hourly weather data: missing or incorrect fields.',
          );
        }

        final dailyData = data['daily'];
        // Verifica se os campos de daily existem e são listas
        if (dailyData['time'] is List &&
            dailyData['temperature_2m_max'] is List &&
            dailyData['temperature_2m_min'] is List &&
            dailyData['weathercode'] is List) {
          final dates = dailyData['time'] as List;
          final maxTemps = dailyData['temperature_2m_max'] as List;
          final minTemps = dailyData['temperature_2m_min'] as List;
          final dailyWeatherCodes = dailyData['weathercode'] as List;

          // Verifica se todas as listas têm o mesmo tamanho
          if (dates.length == maxTemps.length &&
              dates.length == minTemps.length &&
              dates.length == dailyWeatherCodes.length) {
            setState(() {
              _dailyWeather =
                  List.generate(
                    dates.length,
                    (index) => {
                      'date': dates[index],
                      'maxTemperature': maxTemps[index] ?? 0.0,
                      'minTemperature': minTemps[index] ?? 0.0,
                      'weatherDescription': getWeatherDescription(
                        dailyWeatherCodes[index] ?? 0,
                      ),
                    },
                  ).take(7).toList();
            });
          } else {
            throw Exception(
              'Daily weather data lists have inconsistent lengths.',
            );
          }
        } else {
          throw Exception(
            'Invalid daily weather data: missing or incorrect fields.',
          );
        }

        debugPrint('Weather data fetched successfully');
      } else {
        final errorData = json.decode(response.body);
        final errorReason = errorData['reason'] ?? 'Unknown error';
        debugPrint('Weather API failed with status: ${response.statusCode}');
        setState(() {
          _currentWeather = {};
          _hourlyWeather = [];
          _dailyWeather = [];
          _errorMessage =
              'Failed to fetch weather: $errorReason (Status: ${response.statusCode}). Please try again.';
        });
      }
    } on TimeoutException catch (e) {
      debugPrint('Timeout error fetching weather: $e');
      setState(() {
        _currentWeather = {};
        _hourlyWeather = [];
        _dailyWeather = [];
        _errorMessage =
            'No internet connection or slow response. Please check your network and try again.';
      });
    } on http.ClientException catch (e) {
      debugPrint('ClientException fetching weather: $e');
      setState(() {
        _currentWeather = {};
        _hourlyWeather = [];
        _dailyWeather = [];
        _errorMessage =
            'No internet connection. Please check your network and try again.';
      });
    } on SocketException catch (e) {
      debugPrint('SocketException fetching weather: $e');
      setState(() {
        _currentWeather = {};
        _hourlyWeather = [];
        _dailyWeather = [];
        _errorMessage =
            'No internet connection. Please check your network and try again.';
      });
    } catch (e) {
      debugPrint('Error fetching weather: $e');
      setState(() {
        _currentWeather = {};
        _hourlyWeather = [];
        _dailyWeather = [];
        _errorMessage = 'Error fetching weather: $e. Please try again.';
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

  String _getDayOfWeek(String date) {
    final dateTime = DateTime.parse(date);
    return intl.DateFormat('EEE').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          Column(
            children: [
              AppBar(
                title: custom.SearchBar(
                  onCitySelected: (
                    cityName,
                    state,
                    country,
                    latitude,
                    longitude,
                  ) {
                    _updateDisplayText(
                      cityName,
                      state,
                      country,
                      latitude,
                      longitude,
                    );
                  },
                ),
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.inversePrimary.withOpacity(0.9),
                actions: [
                  GeolocationButton(
                    onLocationUpdated: (
                      cityName,
                      state,
                      country,
                      latitude,
                      longitude,
                    ) {
                      _updateDisplayText(
                        cityName,
                        state,
                        country,
                        latitude,
                        longitude,
                      );
                    },
                  ),
                ],
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child:
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : TabBarView(
                            controller: _tabController,
                            children: [
                              SingleChildScrollView(
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const SizedBox(height: 20),
                                      Text(
                                        _cityName,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 28,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      if (_stateCountry.isNotEmpty)
                                        Text(
                                          _stateCountry,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      const SizedBox(height: 50),
                                      if (_errorMessage != null)
                                        Column(
                                          children: [
                                            Text(
                                              _errorMessage!,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                color: Colors.red,
                                                fontSize: 18,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            ElevatedButton(
                                              onPressed:
                                                  _requestLocationOnStart,
                                              child: const Text('Try Again'),
                                            ),
                                          ],
                                        )
                                      else if (_currentWeather.isNotEmpty)
                                        Column(
                                          children: [
                                            Icon(
                                              _getWeatherIcon(
                                                _currentWeather['weatherDescription'],
                                              ),
                                              size: 64,
                                              color: Colors.blueAccent,
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              '${_currentWeather['temperature']}°C',
                                              style: TextStyle(
                                                fontSize: 48,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    (_currentWeather['temperature']
                                                                as double) <
                                                            20
                                                        ? Colors.blue
                                                        : Colors.red,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              _currentWeather['weatherDescription'],
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontStyle: FontStyle.italic,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(Icons.air, size: 24),
                                                const SizedBox(width: 8),
                                                Text(
                                                  '${_currentWeather['windspeed']} km/h',
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
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
                              ),
                              Center(
                                child: Column(
                                  children: [
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Today',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                      ),
                                    ),
                                    Text(
                                      _cityName,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    if (_stateCountry.isNotEmpty)
                                      Text(
                                        _stateCountry,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    const SizedBox(height: 16),
                                    if (_errorMessage != null)
                                      Column(
                                        children: [
                                          Text(
                                            _errorMessage!,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Colors.red,
                                              fontSize: 18,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          ElevatedButton(
                                            onPressed: _requestLocationOnStart,
                                            child: const Text('Try Again'),
                                          ),
                                        ],
                                      )
                                    else
                                      Expanded(
                                        child:
                                            _hourlyWeather.isNotEmpty
                                                ? Column(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 16.0,
                                                          ),
                                                      child: SizedBox(
                                                        height: 280,
                                                        child: LineChart(
                                                          LineChartData(
                                                            gridData: FlGridData(
                                                              show: true,
                                                              drawVerticalLine:
                                                                  true,
                                                              getDrawingHorizontalLine: (
                                                                value,
                                                              ) {
                                                                return FlLine(
                                                                  color:
                                                                      Colors
                                                                          .grey,
                                                                  strokeWidth:
                                                                      1,
                                                                );
                                                              },
                                                              getDrawingVerticalLine: (
                                                                value,
                                                              ) {
                                                                return FlLine(
                                                                  color:
                                                                      Colors
                                                                          .grey,
                                                                  strokeWidth:
                                                                      1,
                                                                );
                                                              },
                                                            ),
                                                            titlesData: FlTitlesData(
                                                              show: true,
                                                              rightTitles: const AxisTitles(
                                                                sideTitles:
                                                                    SideTitles(
                                                                      showTitles:
                                                                          false,
                                                                    ),
                                                              ),
                                                              topTitles: const AxisTitles(
                                                                sideTitles:
                                                                    SideTitles(
                                                                      showTitles:
                                                                          false,
                                                                    ),
                                                              ),
                                                              bottomTitles: AxisTitles(
                                                                sideTitles: SideTitles(
                                                                  showTitles:
                                                                      true,
                                                                  reservedSize:
                                                                      40,
                                                                  interval: 4,
                                                                  getTitlesWidget: (
                                                                    value,
                                                                    meta,
                                                                  ) {
                                                                    final index =
                                                                        value
                                                                            .toInt();
                                                                    if (index >=
                                                                            0 &&
                                                                        index <
                                                                            _hourlyWeather.length) {
                                                                      final hour = _hourlyWeather[index]['time']
                                                                          .split(
                                                                            'T',
                                                                          )[1]
                                                                          .substring(
                                                                            0,
                                                                            5,
                                                                          );
                                                                      return SideTitleWidget(
                                                                        meta:
                                                                            meta,
                                                                        space:
                                                                            8,
                                                                        child: Text(
                                                                          hour,
                                                                          style: const TextStyle(
                                                                            color:
                                                                                Colors.black87,
                                                                            fontSize:
                                                                                12,
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
                                                                  showTitles:
                                                                      true,
                                                                  reservedSize:
                                                                      30,
                                                                  interval: 5,
                                                                  getTitlesWidget: (
                                                                    value,
                                                                    meta,
                                                                  ) {
                                                                    return Text(
                                                                      '${value.toInt()}°C',
                                                                      style: const TextStyle(
                                                                        color:
                                                                            Colors.black87,
                                                                        fontSize:
                                                                            12,
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                            ),
                                                            borderData: FlBorderData(
                                                              show: true,
                                                              border: Border.all(
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                            ),
                                                            minX: 0,
                                                            maxX:
                                                                (_hourlyWeather
                                                                            .length -
                                                                        1)
                                                                    .toDouble(),
                                                            minY:
                                                                (_hourlyWeather
                                                                            .map(
                                                                              (
                                                                                e,
                                                                              ) =>
                                                                                  e['temperature']
                                                                                      as double,
                                                                            )
                                                                            .reduce((a, b) => a < b ? a : b) -
                                                                        5)
                                                                    .floorToDouble(),
                                                            maxY:
                                                                (_hourlyWeather
                                                                            .map(
                                                                              (
                                                                                e,
                                                                              ) =>
                                                                                  e['temperature']
                                                                                      as double,
                                                                            )
                                                                            .reduce((a, b) => a > b ? a : b) +
                                                                        5)
                                                                    .ceilToDouble(),
                                                            lineBarsData: [
                                                              LineChartBarData(
                                                                spots:
                                                                    _hourlyWeather
                                                                        .asMap()
                                                                        .entries
                                                                        .map(
                                                                          (
                                                                            entry,
                                                                          ) => FlSpot(
                                                                            entry.key.toDouble(),
                                                                            entry.value['temperature']
                                                                                as double,
                                                                          ),
                                                                        )
                                                                        .toList(),
                                                                isCurved: true,
                                                                gradient: const LinearGradient(
                                                                  colors: [
                                                                    Colors
                                                                        .blueAccent,
                                                                    Colors.cyan,
                                                                  ],
                                                                  begin:
                                                                      Alignment
                                                                          .topCenter,
                                                                  end:
                                                                      Alignment
                                                                          .bottomCenter,
                                                                ),
                                                                barWidth: 4,
                                                                belowBarData: BarAreaData(
                                                                  show: true,
                                                                  gradient: LinearGradient(
                                                                    colors: [
                                                                      Colors.blueAccent.withAlpha(
                                                                        (0.3 * 255)
                                                                            .toInt(),
                                                                      ),
                                                                      Colors.cyan.withAlpha(
                                                                        (0.1 * 255)
                                                                            .toInt(),
                                                                      ),
                                                                    ],
                                                                    begin:
                                                                        Alignment
                                                                            .topCenter,
                                                                    end:
                                                                        Alignment
                                                                            .bottomCenter,
                                                                  ),
                                                                ),
                                                                dotData: FlDotData(
                                                                  show: true,
                                                                  getDotPainter:
                                                                      (
                                                                        spot,
                                                                        percent,
                                                                        barData,
                                                                        index,
                                                                      ) => FlDotCirclePainter(
                                                                        radius:
                                                                            4,
                                                                        color:
                                                                            Colors.blueAccent,
                                                                        strokeWidth:
                                                                            2,
                                                                        strokeColor:
                                                                            Colors.white,
                                                                      ),
                                                                ),
                                                              ),
                                                            ],
                                                            lineTouchData: LineTouchData(
                                                              touchTooltipData: LineTouchTooltipData(
                                                                getTooltipItems: (
                                                                  touchedSpots,
                                                                ) {
                                                                  return touchedSpots.map((
                                                                    spot,
                                                                  ) {
                                                                    final hour = _hourlyWeather[spot
                                                                            .x
                                                                            .toInt()]['time']
                                                                        .split(
                                                                          'T',
                                                                        )[1]
                                                                        .substring(
                                                                          0,
                                                                          5,
                                                                        );
                                                                    return LineTooltipItem(
                                                                      '$hour\n${spot.y}°C',
                                                                      const TextStyle(
                                                                        color:
                                                                            Colors.white,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
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
                                                      height: 300,
                                                      child: ListView.builder(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        itemCount:
                                                            _hourlyWeather
                                                                .length,
                                                        itemBuilder: (
                                                          context,
                                                          index,
                                                        ) {
                                                          final hourly =
                                                              _hourlyWeather[index];
                                                          final time =
                                                              hourly['time']
                                                                  as String;
                                                          final hour = time
                                                              .split('T')[1]
                                                              .substring(0, 5);
                                                          final temperature =
                                                              hourly['temperature']
                                                                  as double;
                                                          final weatherDescription =
                                                              hourly['weatherDescription']
                                                                  as String;
                                                          final windspeed =
                                                              hourly['windspeed']
                                                                  as double;

                                                          return Container(
                                                            width: 120,
                                                            margin:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      8.0,
                                                                ),
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Text(
                                                                  hour,
                                                                  style: const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        16,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 15,
                                                                ),
                                                                Icon(
                                                                  _getWeatherIcon(
                                                                    weatherDescription,
                                                                  ),
                                                                  size: 50,
                                                                  color:
                                                                      Colors
                                                                          .blueAccent,
                                                                ),
                                                                const SizedBox(
                                                                  height: 8,
                                                                ),
                                                                Text(
                                                                  '$temperature°C',
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color:
                                                                        temperature <
                                                                                20
                                                                            ? Colors.blue
                                                                            : Colors.red,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  weatherDescription,
                                                                  style: const TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color:
                                                                        Colors
                                                                            .black87,
                                                                  ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    const Icon(
                                                                      Icons.air,
                                                                      size: 16,
                                                                      color:
                                                                          Colors
                                                                              .grey,
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 4,
                                                                    ),
                                                                    Text(
                                                                      '$windspeed km/h',
                                                                      style: const TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color:
                                                                            Colors.black,
                                                                      ),
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
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                  ),
                                                ),
                                      ),
                                  ],
                                ),
                              ),
                              Center(
                                child: Column(
                                  children: [
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Weekly',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                      ),
                                    ),
                                    Text(
                                      _cityName,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    if (_stateCountry.isNotEmpty)
                                      Text(
                                        _stateCountry,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    const SizedBox(height: 16),
                                    if (_errorMessage != null)
                                      Column(
                                        children: [
                                          Text(
                                            _errorMessage!,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Colors.red,
                                              fontSize: 18,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          ElevatedButton(
                                            onPressed: _requestLocationOnStart,
                                            child: const Text('Try Again'),
                                          ),
                                        ],
                                      )
                                    else
                                      Expanded(
                                        child:
                                            _dailyWeather.isNotEmpty
                                                ? Column(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 16.0,
                                                          ),
                                                      child: SizedBox(
                                                        height: 280,
                                                        child: LineChart(
                                                          LineChartData(
                                                            gridData: FlGridData(
                                                              show: true,
                                                              drawVerticalLine:
                                                                  true,
                                                              getDrawingHorizontalLine: (
                                                                value,
                                                              ) {
                                                                return FlLine(
                                                                  color:
                                                                      Colors
                                                                          .grey,
                                                                  strokeWidth:
                                                                      1,
                                                                );
                                                              },
                                                              getDrawingVerticalLine: (
                                                                value,
                                                              ) {
                                                                return FlLine(
                                                                  color:
                                                                      Colors
                                                                          .grey,
                                                                  strokeWidth:
                                                                      1,
                                                                );
                                                              },
                                                            ),
                                                            titlesData: FlTitlesData(
                                                              show: true,
                                                              rightTitles: const AxisTitles(
                                                                sideTitles:
                                                                    SideTitles(
                                                                      showTitles:
                                                                          false,
                                                                    ),
                                                              ),
                                                              topTitles: const AxisTitles(
                                                                sideTitles:
                                                                    SideTitles(
                                                                      showTitles:
                                                                          false,
                                                                    ),
                                                              ),
                                                              bottomTitles: AxisTitles(
                                                                sideTitles: SideTitles(
                                                                  showTitles:
                                                                      true,
                                                                  reservedSize:
                                                                      40,
                                                                  interval: 1,
                                                                  getTitlesWidget: (
                                                                    value,
                                                                    meta,
                                                                  ) {
                                                                    final index =
                                                                        value
                                                                            .toInt();
                                                                    if (index >=
                                                                            0 &&
                                                                        index <
                                                                            _dailyWeather.length) {
                                                                      final day =
                                                                          _getDayOfWeek(
                                                                            _dailyWeather[index]['date'],
                                                                          );
                                                                      return SideTitleWidget(
                                                                        meta:
                                                                            meta,
                                                                        space:
                                                                            8,
                                                                        child: Text(
                                                                          day,
                                                                          style: const TextStyle(
                                                                            color:
                                                                                Colors.black87,
                                                                            fontSize:
                                                                                12,
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
                                                                  showTitles:
                                                                      true,
                                                                  reservedSize:
                                                                      40,
                                                                  interval: 5,
                                                                  getTitlesWidget: (
                                                                    value,
                                                                    meta,
                                                                  ) {
                                                                    return Text(
                                                                      '${value.toInt()}°C',
                                                                      style: const TextStyle(
                                                                        color:
                                                                            Colors.black87,
                                                                        fontSize:
                                                                            12,
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                            ),
                                                            borderData: FlBorderData(
                                                              show: true,
                                                              border: Border.all(
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                            ),
                                                            minX: 0,
                                                            maxX:
                                                                (_dailyWeather
                                                                            .length -
                                                                        1)
                                                                    .toDouble(),
                                                            minY:
                                                                (_dailyWeather
                                                                            .map(
                                                                              (
                                                                                e,
                                                                              ) =>
                                                                                  e['minTemperature']
                                                                                      as double,
                                                                            )
                                                                            .reduce((a, b) => a < b ? a : b) -
                                                                        5)
                                                                    .floorToDouble(),
                                                            maxY:
                                                                (_dailyWeather
                                                                            .map(
                                                                              (
                                                                                e,
                                                                              ) =>
                                                                                  e['maxTemperature']
                                                                                      as double,
                                                                            )
                                                                            .reduce((a, b) => a > b ? a : b) +
                                                                        5)
                                                                    .ceilToDouble(),
                                                            lineBarsData: [
                                                              LineChartBarData(
                                                                spots:
                                                                    _dailyWeather
                                                                        .asMap()
                                                                        .entries
                                                                        .map(
                                                                          (
                                                                            entry,
                                                                          ) => FlSpot(
                                                                            entry.key.toDouble(),
                                                                            entry.value['maxTemperature']
                                                                                as double,
                                                                          ),
                                                                        )
                                                                        .toList(),
                                                                isCurved: true,
                                                                gradient: const LinearGradient(
                                                                  colors: [
                                                                    Colors
                                                                        .redAccent,
                                                                    Colors
                                                                        .orange,
                                                                  ],
                                                                  begin:
                                                                      Alignment
                                                                          .topCenter,
                                                                  end:
                                                                      Alignment
                                                                          .bottomCenter,
                                                                ),
                                                                barWidth: 4,
                                                                dotData: FlDotData(
                                                                  show: true,
                                                                  getDotPainter:
                                                                      (
                                                                        spot,
                                                                        percent,
                                                                        barData,
                                                                        index,
                                                                      ) => FlDotCirclePainter(
                                                                        radius:
                                                                            4,
                                                                        color:
                                                                            Colors.redAccent,
                                                                        strokeWidth:
                                                                            2,
                                                                        strokeColor:
                                                                            Colors.white,
                                                                      ),
                                                                ),
                                                              ),
                                                              LineChartBarData(
                                                                spots:
                                                                    _dailyWeather
                                                                        .asMap()
                                                                        .entries
                                                                        .map(
                                                                          (
                                                                            entry,
                                                                          ) => FlSpot(
                                                                            entry.key.toDouble(),
                                                                            entry.value['minTemperature']
                                                                                as double,
                                                                          ),
                                                                        )
                                                                        .toList(),
                                                                isCurved: true,
                                                                gradient: const LinearGradient(
                                                                  colors: [
                                                                    Colors
                                                                        .blueAccent,
                                                                    Colors.cyan,
                                                                  ],
                                                                  begin:
                                                                      Alignment
                                                                          .topCenter,
                                                                  end:
                                                                      Alignment
                                                                          .bottomCenter,
                                                                ),
                                                                barWidth: 4,
                                                                dotData: FlDotData(
                                                                  show: true,
                                                                  getDotPainter:
                                                                      (
                                                                        spot,
                                                                        percent,
                                                                        barData,
                                                                        index,
                                                                      ) => FlDotCirclePainter(
                                                                        radius:
                                                                            4,
                                                                        color:
                                                                            Colors.blueAccent,
                                                                        strokeWidth:
                                                                            2,
                                                                        strokeColor:
                                                                            Colors.white,
                                                                      ),
                                                                ),
                                                              ),
                                                            ],
                                                            lineTouchData: LineTouchData(
                                                              touchTooltipData: LineTouchTooltipData(
                                                                getTooltipItems: (
                                                                  touchedSpots,
                                                                ) {
                                                                  return touchedSpots.map((
                                                                    spot,
                                                                  ) {
                                                                    final index =
                                                                        spot.x
                                                                            .toInt();
                                                                    final day =
                                                                        _getDayOfWeek(
                                                                          _dailyWeather[index]['date'],
                                                                        );
                                                                    final temp =
                                                                        spot.y;
                                                                    final isMax =
                                                                        spot.barIndex ==
                                                                        0;
                                                                    return LineTooltipItem(
                                                                      '$day\n${isMax ? 'Max' : 'Min'}: $temp°C',
                                                                      const TextStyle(
                                                                        color:
                                                                            Colors.white,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
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
                                                      height: 300,
                                                      child: ListView.builder(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        itemCount:
                                                            _dailyWeather
                                                                .length,
                                                        itemBuilder: (
                                                          context,
                                                          index,
                                                        ) {
                                                          final daily =
                                                              _dailyWeather[index];
                                                          final date =
                                                              daily['date']
                                                                  as String;
                                                          final dayOfWeek =
                                                              _getDayOfWeek(
                                                                date,
                                                              );
                                                          final maxTemperature =
                                                              daily['maxTemperature']
                                                                  as double;
                                                          final minTemperature =
                                                              daily['minTemperature']
                                                                  as double;
                                                          final weatherDescription =
                                                              daily['weatherDescription']
                                                                  as String;

                                                          return Container(
                                                            width: 120,
                                                            margin:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      8.0,
                                                                ),
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Text(
                                                                  dayOfWeek,
                                                                  style: const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        18,
                                                                    color:
                                                                        Colors
                                                                            .black87,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 15,
                                                                ),
                                                                Icon(
                                                                  _getWeatherIcon(
                                                                    weatherDescription,
                                                                  ),
                                                                  size: 50,
                                                                  color:
                                                                      Colors
                                                                          .blueAccent,
                                                                ),
                                                                const SizedBox(
                                                                  height: 8,
                                                                ),
                                                                Text(
                                                                  'Max: $maxTemperature°C',
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color:
                                                                        maxTemperature <
                                                                                20
                                                                            ? Colors.blue
                                                                            : Colors.red,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  'Min: $minTemperature°C',
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color:
                                                                        minTemperature <
                                                                                20
                                                                            ? Colors.blue
                                                                            : Colors.red,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  weatherDescription,
                                                                  style: const TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color:
                                                                        Colors
                                                                            .black87,
                                                                  ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
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
                                                  'No weekly weather data available',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                  ),
                                                ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                ),
              ),
              BottomAppBar(
                color: Theme.of(
                  context,
                ).colorScheme.inversePrimary.withOpacity(0.9),
                child: TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(icon: Icon(Icons.cloud), text: 'Currently'),
                    Tab(icon: Icon(Icons.today), text: 'Today'),
                    Tab(icon: Icon(Icons.calendar_view_week), text: 'Weekly'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
