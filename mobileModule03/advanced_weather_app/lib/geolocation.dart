import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

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
      name: 'Geolocation', // Temporário, será substituído pela geocodificação
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
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      debugPrint('Permission denied, requesting...');
      permission = await Geolocator.requestPermission();
      debugPrint('Permission result: $permission');
      if (permission == LocationPermission.denied) {
        throw 'Geolocation is not available, location permissions are denied';
      } else if (permission == LocationPermission.deniedForever) {
        throw 'Geolocation is permanently denied. Please enable it in settings.';
      }
    }

    debugPrint('Fetching position...');
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      forceAndroidLocationManager: true,
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        debugPrint('Geolocation timed out.');
        throw 'Geolocation request timed out. Please try again.';
      },
    );
    debugPrint('Position fetched: ${position.latitude}, ${position.longitude}');

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        String city = placemark.locality ?? placemark.subLocality ?? 'Unknown City';
        String? region = placemark.administrativeArea;
        String? country = placemark.country;

        debugPrint('Geocoded location: $city, $region, $country');
        return Location._(
          latitude: position.latitude,
          longitude: position.longitude,
          name: city,
          region: region,
          country: country,
        );
      } else {
        debugPrint('No placemarks found for coordinates.');
        return Location._fromGeolocation(position);
      }
    } catch (e) {
      debugPrint('Geocoding error: $e');
      return Location._fromGeolocation(position);
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
      widget.onLocationUpdated('$e', null, null, 0.0, 0.0); // Passa erro com coordenadas inválidas
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