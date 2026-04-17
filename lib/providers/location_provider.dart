import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationNotifier extends ChangeNotifier {
  LatLng _currentPosition = const LatLng(19.062641, 72.830899); // Default: Bandra
  String _currentAddress = 'Locating...';
  bool _isTracking = false;
  bool _isLoading = false;

  LatLng get currentPosition => _currentPosition;
  String get currentAddress => _currentAddress;
  bool get isTracking => _isTracking;
  bool get isLoading => _isLoading;

  Future<void> fetchCurrentLocation() async {
    _isLoading = true;
    notifyListeners();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _currentAddress = 'Location services disabled';
        _isLoading = false;
        notifyListeners();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _currentAddress = 'Location permission denied';
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _currentAddress = 'Location permissions permanently denied';
        _isLoading = false;
        notifyListeners();
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _currentPosition = LatLng(position.latitude, position.longitude);

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          _currentAddress = '${place.street}, ${place.subLocality}';
          // Clean up formatting if empty
          _currentAddress = _currentAddress.replaceAll(RegExp(r'^, |, $'), '').trim();
          if (_currentAddress.isEmpty) {
            _currentAddress = place.locality ?? 'Unknown Location';
          }
        }
      } catch (e) {
        _currentAddress = 'Address unavailable';
      }

    } catch (e) {
      _currentAddress = 'Failed to get location';
    }

    _isLoading = false;
    notifyListeners();
  }

  void updatePosition(LatLng position) {
    _currentPosition = position;
    notifyListeners();
  }

  void startTracking() {
    _isTracking = true;
    notifyListeners();
  }

  void stopTracking() {
    _isTracking = false;
    notifyListeners();
  }
}

final locationProvider = ChangeNotifierProvider<LocationNotifier>((ref) {
  return LocationNotifier();
});
