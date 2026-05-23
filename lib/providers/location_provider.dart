import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_android/geolocator_android.dart';
import 'package:geocoding/geocoding.dart';
import '../services/location_anomaly_service.dart';

class LocationNotifier extends ChangeNotifier {
  static const LatLng _fallbackPosition = LatLng(19.0709485, 72.8760233);
  static const String _fallbackAddress = 'ATLAS SkillTech University';

  LatLng _currentPosition = _fallbackPosition;
  LatLng? _lastGeocodedPosition;
  String _currentAddress = 'Locating...';
  bool _isTracking = false;
  bool _isLoading = false;
  DateTime _lastUpdateTime = DateTime.now();
  StreamSubscription<Position>? _positionStreamSubscription;

  LatLng get currentPosition => _currentPosition;
  String get currentAddress => _currentAddress;
  bool get isTracking => _isTracking;
  bool get isLoading => _isLoading;
  DateTime get lastUpdateTime => _lastUpdateTime;

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
        _currentPosition = _fallbackPosition;
        _currentAddress = _fallbackAddress;
        _isLoading = false;
        notifyListeners();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _currentPosition = _fallbackPosition;
          _currentAddress = _fallbackAddress;
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _currentPosition = _fallbackPosition;
        _currentAddress = _fallbackAddress;
        _isLoading = false;
        notifyListeners();
        return;
      }

      Position? position = await Geolocator.getLastKnownPosition();
      if (position == null) {
        try {
          position = await Geolocator.getCurrentPosition(
            locationSettings: _locationSettings(LocationAccuracy.high, 20),
          );
        } catch (_) {
          try {
            position = await Geolocator.getCurrentPosition(
              locationSettings: _locationSettings(LocationAccuracy.low, 30),
            );
          } catch (_) {
            // Will start tracking stream below to get position asynchronously
          }
        }
      }

      if (position != null) {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _lastGeocodedPosition = _currentPosition;
        await _updateAddressFromPosition(position);
      } else {
        _currentPosition = _fallbackPosition;
        _currentAddress = _fallbackAddress;
      }

    } catch (e) {
      _currentPosition = _fallbackPosition;
      _currentAddress = _fallbackAddress;
    } finally {
      startTracking(); // Always start stream regardless of initial fetch result
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

  LocationSettings _locationSettings(LocationAccuracy accuracy, int timeLimitSeconds) {
    if (Platform.isAndroid) {
      return AndroidSettings(
        accuracy: accuracy,
        timeLimit: Duration(seconds: timeLimitSeconds),
      );
    }
    return LocationSettings(
      accuracy: accuracy,
      timeLimit: Duration(seconds: timeLimitSeconds),
    );
  }

  void startTracking() {
    if (_isTracking) return;
    _isTracking = true;
    notifyListeners();

    final streamSettings = Platform.isAndroid
        ? AndroidSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          )
        : const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: streamSettings,
    ).listen((Position position) {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _lastUpdateTime = DateTime.now();

      // Notify the anomaly watchdog that GPS is still active
      LocationAnomalyService.instance.onLocationUpdated();

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
