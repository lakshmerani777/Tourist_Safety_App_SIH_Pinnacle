import 'dart:async';
import 'package:flutter/material.dart';
import 'notification_service.dart';
import 'firestore_service.dart';

/// Monitors GPS updates and flags anomalies when location stops updating
/// while the user is actively sharing with authorities.
class LocationAnomalyService {
  LocationAnomalyService._();
  static final LocationAnomalyService instance = LocationAnomalyService._();

  final FirestoreService _firestore = FirestoreService();

  Timer? _watchdogTimer;
  DateTime _lastLocationUpdate = DateTime.now();
  bool _isMonitoring = false;
  bool _anomalyFlagged = false;
  String? _sessionId;

  /// Threshold: if no GPS update for this duration, flag anomaly.
  static const Duration anomalyThreshold = Duration(minutes: 2);

  /// How often the watchdog checks for stale location.
  static const Duration checkInterval = Duration(seconds: 30);

  bool get isMonitoring => _isMonitoring;
  bool get isAnomalyFlagged => _anomalyFlagged;

  /// Start monitoring for location anomalies.
  /// Call when authorities sharing is turned ON.
  void startMonitoring(String sessionId) {
    if (_isMonitoring) return;
    _sessionId = sessionId;
    _lastLocationUpdate = DateTime.now();
    _anomalyFlagged = false;
    _isMonitoring = true;

    _watchdogTimer?.cancel();
    _watchdogTimer = Timer.periodic(checkInterval, (_) => _checkForAnomaly());

    debugPrint('[AnomalyService] Started monitoring session: $sessionId');
  }

  /// Stop monitoring. Call when sharing is turned OFF.
  void stopMonitoring() {
    _watchdogTimer?.cancel();
    _watchdogTimer = null;
    _isMonitoring = false;

    if (_anomalyFlagged && _sessionId != null) {
      _clearAnomaly();
    }
    _anomalyFlagged = false;
    _sessionId = null;

    debugPrint('[AnomalyService] Stopped monitoring');
  }

  /// Call this every time a new GPS position is received.
  void onLocationUpdated() {
    _lastLocationUpdate = DateTime.now();

    // If we previously flagged an anomaly, clear it now
    if (_anomalyFlagged && _sessionId != null) {
      _clearAnomaly();
      _anomalyFlagged = false;
      NotificationService.instance.cancelAnomalyNotification();
      debugPrint('[AnomalyService] Anomaly cleared — location resumed');
    }
  }

  /// Periodic watchdog check.
  void _checkForAnomaly() {
    if (!_isMonitoring || _sessionId == null) return;

    final elapsed = DateTime.now().difference(_lastLocationUpdate);

    if (elapsed >= anomalyThreshold && !_anomalyFlagged) {
      _anomalyFlagged = true;
      debugPrint('[AnomalyService] ⚠️ Anomaly detected! No GPS update for ${elapsed.inSeconds}s');

      // Fire local notification
      NotificationService.instance.showAnomalyNotification();

      // Flag in Firestore for the dashboard
      _firestore.flagLocationAnomaly(_sessionId!).catchError((e) {
        debugPrint('[AnomalyService] Firestore flag error: $e');
      });
    }
  }

  /// Clear the anomaly flag in Firestore.
  void _clearAnomaly() {
    if (_sessionId == null) return;
    _firestore.clearLocationAnomaly(_sessionId!).catchError((e) {
      debugPrint('[AnomalyService] Firestore clear error: $e');
    });
  }
}
