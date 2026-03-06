import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class LocationNotifier extends ChangeNotifier {
  LatLng _currentPosition = const LatLng(28.6139, 77.2090); // Default: New Delhi
  bool _isTracking = false;

  LatLng get currentPosition => _currentPosition;
  bool get isTracking => _isTracking;

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
