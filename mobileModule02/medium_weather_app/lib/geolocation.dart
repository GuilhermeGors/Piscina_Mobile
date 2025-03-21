import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';

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
  }) : _latitude = latitude,
       _longitude = longitude,
       _name = name,
       _region = region,
       _country = country;

  factory Location._fromGeolocation(
    Position position, {
    required String name,
    String? region,
    String? country,
  }) {
    return Location._(
      latitude: position.latitude,
      longitude: position.longitude,
      name: name,
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
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
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

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      debugPrint('No internet connection available.');
      return Location._fromGeolocation(
        position,
        name: 'Current Location (Offline)',
      );
    }
    try {
      final url =
          'https://nominatim.openstreetmap.org/reverse?lat=${position.latitude}&lon=${position.longitude}&format=json';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String city =
            data['address']['city'] ??
            data['address']['town'] ??
            data['address']['village'] ??
            'Unknown City';
        String? region = data['address']['state'] ?? data['address']['region'];
        String? country = data['address']['country'];

        return Location._fromGeolocation(
          position,
          name: city,
          region: region,
          country: country,
        );
      } else {
        debugPrint('Reverse geocoding failed: ${response.statusCode}');
        return Location._fromGeolocation(position, name: 'Unknown Location');
      }
    } catch (e) {
      debugPrint('Geolocation error during reverse geocoding: $e');
      return Location._fromGeolocation(
        position,
        name: 'Current Location (Offline)',
      );
    }
  }
}

class GeolocationButton extends StatefulWidget {
  final Function(
    String,
    double,
    double, {
    String? region,
    String? country,
    bool showCoordinates,
  })
  onLocationUpdated;

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
      widget.onLocationUpdated(
        location.name,
        location.latitude,
        location.longitude,
        region: location.region,
        country: location.country,
      );
    } catch (e) {
      debugPrint('Geolocation error: $e');
      widget.onLocationUpdated('Error: $e', 0.0, 0.0);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon:
          _isLoading
              ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
              : const Icon(Icons.location_on),
      onPressed: _getLocation,
    );
  }
}
