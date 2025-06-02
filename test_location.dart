import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  print(
      'Testing location functionality on ${kIsWeb ? 'Web' : 'Native'} platform...');

  if (!kIsWeb) {
    // Test permission handling
    print('Checking location permission...');
    try {
      var status = await Permission.location.status;
      print('Location permission status: $status');

      if (status.isDenied) {
        print('Requesting location permission...');
        status = await Permission.location.request();
        print('Permission after request: $status');
      }
    } catch (e) {
      print('Permission handling error: $e');
    }

    // Test location service status
    print('Checking if location services are enabled...');
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      print('Location services enabled: $serviceEnabled');
    } catch (e) {
      print('Location service check error: $e');
    }
  }

  // Test getting current position
  print('Attempting to get current position...');
  try {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: Duration(seconds: 10),
    );
    print('Position obtained: ${position.latitude}, ${position.longitude}');

    // Test geocoding
    print('Attempting to get address from coordinates...');
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address =
            '${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}';
        print('Address: $address');
      } else {
        print('No address found for coordinates');
      }
    } catch (e) {
      print('Geocoding error: $e');
    }
  } catch (e) {
    print('Position error: $e');
  }

  print('Location test completed.');
}
