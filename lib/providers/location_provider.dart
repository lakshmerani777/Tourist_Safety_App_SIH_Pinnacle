import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationNotifier extends ChangeNotifier {
  LatLng _currentPosition = const LatLng(19.062641, 72.830899); // Default: Bandra
  LatLng? _lastGeocodedPosition;
  String _currentAddress = 'Locating...';
  bool _isTracking = false;
  bool _isLoading = false;
  StreamSubscription<Position>? _positionStreamSubscription;

  LatLng get currentPosition => _currentPosition;
  String get currentAddress => _currentAddress;
  bool get isTracking => _isTracking;
  bool get isLoading => _isLoading;

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

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
      _lastGeocodedPosition = _currentPosition;
      await _updateAddressFromPosition(position);

      startTracking(); // Automatically begin listening to movement stream

    } catch (e) {
      _currentAddress = 'Failed to get location';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _updateAddressFromPosition(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String address = '${place.street}, ${place.subLocality}';
        // Clean up formatting if empty
        address = address.replaceAll(RegExp(r'^, |, $'), '').trim();
        if (address.isEmpty) {
          address = place.locality ?? 'Unknown Location';
        }
        _currentAddress = address;
      }
    } catch (e) {
      // Retain old address on fail
    }
  }

  void updatePosition(LatLng position) {
    _currentPosition = position;
    notifyListeners();
  }

  void startTracking() {
    if (_isTracking) return;
    _isTracking = true;
    notifyListeners();

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Wait to update stream every 10 meters
      ),
    ).listen((Position position) {
      _currentPosition = LatLng(position.latitude, position.longitude);

      bool shouldUpdateAddress = false;
      if (_lastGeocodedPosition == null) {
        shouldUpdateAddress = true;
      } else {
        final distance = const Distance().as(LengthUnit.Meter, _lastGeocodedPosition!, _currentPosition);
        if (distance > 50) { // Update text address every 50 meters
          shouldUpdateAddress = true;
        }
      }

      if (shouldUpdateAddress) {
        _lastGeocodedPosition = _currentPosition;
        _updateAddressFromPosition(position).then((_) => notifyListeners());
      } else {
        notifyListeners();
      }
    });
  }

  void stopTracking() {
    if (!_isTracking) return;
    _isTracking = false;
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    notifyListeners();
  }
}

final locationProvider = ChangeNotifierProvider<LocationNotifier>((ref) {
  return LocationNotifier();
});
