import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

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

  factory Location._fromGeolocation(Position position) {
    return Location._(
      latitude: position.latitude,
      longitude: position.longitude,
      name: 'Geolocation',
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
    return Location._fromGeolocation(position);
  }
}

class GeolocationButton extends StatefulWidget {
  final Function(String, double, double) onLocationUpdated;

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
      widget.onLocationUpdated(location.name, location.latitude, location.longitude);
    } catch (e) {
      debugPrint('Geolocation error: $e');
      widget.onLocationUpdated('$e. You can still search by city name.', 0.0, 0.0);
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