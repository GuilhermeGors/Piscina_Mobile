import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class GeolocationButton extends StatefulWidget {
  final Function(String) onLocationUpdated;

  const GeolocationButton({required this.onLocationUpdated, super.key});

  @override
  GeolocationButtonState createState() => GeolocationButtonState();
}

class GeolocationButtonState extends State<GeolocationButton> {
  Future<void> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      widget.onLocationUpdated('Location services are disabled.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        widget.onLocationUpdated('Permission Denied :|');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      widget.onLocationUpdated('Permission Denied Forever >:C');
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    widget.onLocationUpdated('Lat: ${position.latitude}, Lon: ${position.longitude}');
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.location_on),
      onPressed: _getLocation,
    );
  }
}
