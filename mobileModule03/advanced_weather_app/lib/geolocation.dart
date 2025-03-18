import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Location {
  final double _latitude;
  final double _longitude;
  final String _name;
  final String? _region;
  final String? _country;

  const Location._({
    required double latitude,
    required double longitude,
    required String name,
    String? region,
    String? country,
  })  : _latitude = latitude,
        _longitude = longitude,
        _name = name,
        _region = region,
        _country = country;

  factory Location._fromGeolocation(Position position, Map<String, dynamic> geocodeData) {
    // Extract city, state, and country from geocode data
    final address = geocodeData['address'] ?? {};
    String city = address['city'] ?? address['town'] ?? address['village'] ?? 'Unknown City';
    String? region = address['state'] ?? address['region'];
    String? country = address['country'];

    return Location._(
      latitude: position.latitude,
      longitude: position.longitude,
      name: city,
      region: region,
      country: country,
    );
  }

  double get latitude => _latitude;
  double get longitude => _longitude;
  String get name => _name;
  String? get region => _region;
  String? get country => _country;

  static Future<Location> fetchGeolocation() async {
    debugPrint('Checking location services...');
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Location services disabled.');
      throw 'Geolocation is not available, please enable it.';
    }

    debugPrint('Checking permission...');
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      debugPrint('Permission denied, requesting...');
      permission = await Geolocator.requestPermission();
      debugPrint('Permission result: $permission');
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        throw 'Geolocation is not available, location permissions are denied';
      }
    }

    debugPrint('Fetching position...');
    Position position = await Geolocator.getCurrentPosition().timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        debugPrint('Geolocation timed out.');
        throw 'Geolocation request timed out. Please try again.';
      },
    );
    debugPrint('Position fetched: ${position.latitude}, ${position.longitude}');

    // Reverse geocode using Nominatim API
    final url = 'https://nominatim.openstreetmap.org/reverse?lat=${position.latitude}&lon=${position.longitude}&format=json';
    debugPrint('Fetching geocode data from: $url');
    final response = await http.get(Uri.parse(url));
    debugPrint('Geocode API status: ${response.statusCode}');
    debugPrint('Geocode API response: ${response.body}');

    if (response.statusCode == 200) {
      final geocodeData = json.decode(response.body);
      return Location._fromGeolocation(position, geocodeData);
    } else {
      debugPrint('Failed to fetch geocode data: ${response.statusCode}');
      return Location._(
        latitude: position.latitude,
        longitude: position.longitude,
        name: 'Unknown Location',
        region: null,
        country: null,
      );
    }
  }
}

class GeolocationButton extends StatefulWidget {
  final Function(String, String?, String?, double, double) onLocationUpdated;

  const GeolocationButton({required this.onLocationUpdated, super.key});

  @override
  GeolocationButtonState createState() => GeolocationButtonState();
}

class GeolocationButtonState extends State<GeolocationButton> {
  bool _isLoading = false;

  Future<void> _getLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final location = await Location.fetchGeolocation();
      widget.onLocationUpdated(location.name, location.region, location.country, location.latitude, location.longitude);
    } catch (e) {
      debugPrint('Geolocation error: $e');
      widget.onLocationUpdated('$e', null, null, 0.0, 0.0);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: _isLoading
          ? const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            )
          : const Icon(Icons.location_on),
      onPressed: _getLocation,
    );
  }
}