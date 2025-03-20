import 'package:flutter/material.dart';

class CurrentlyTab extends StatelessWidget {
  final String cityName;
  final String stateCountry;
  final Map<String, dynamic> currentWeather;
  final String? errorMessage;
  final VoidCallback onTryAgain;
  final IconData Function(String) getWeatherIcon;

  const CurrentlyTab({
    super.key,
    required this.cityName,
    required this.stateCountry,
    required this.currentWeather,
    required this.errorMessage,
    required this.onTryAgain,
    required this.getWeatherIcon,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
            children: [
            SizedBox(height: screenHeight * 0.03),
            Text(
              'Currently',
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
              fontSize: screenWidth * 0.07,
              color: Colors.blue,
              ),
            ),
            if (stateCountry.isNotEmpty)
              Text(
                stateCountry,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  color: Colors.black54,
                ),
              ),
            SizedBox(height: screenHeight * 0.05),
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
            else if (currentWeather.isNotEmpty)
              Column(
                children: [
                  Icon(
                    getWeatherIcon(currentWeather['weatherDescription']),
                    size: screenWidth * 0.15,
                    color: Colors.blueAccent,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    '${currentWeather['temperature']}°C',
                    style: TextStyle(
                      fontSize: screenWidth * 0.12,
                      fontWeight: FontWeight.bold,
                      color: (currentWeather['temperature'] as double) < 20 ? Colors.blue : Colors.red,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    currentWeather['weatherDescription'],
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.air, size: screenWidth * 0.06),
                      SizedBox(width: screenWidth * 0.02),
                      Text(
                        '${currentWeather['windspeed']} km/h',
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            else
              Text(
                'No current weather data available',
                style: TextStyle(fontSize: screenWidth * 0.045),
              ),
            SizedBox(height: screenHeight * 0.03),
          ],
        ),
      ),
    );
  }
}