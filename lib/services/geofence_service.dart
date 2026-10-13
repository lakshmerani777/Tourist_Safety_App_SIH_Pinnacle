import 'dart:async';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import '../models/firestore_models.dart';
import '../providers/location_provider.dart';

class GeofenceService {
  GeofenceService._();
  static final GeofenceService instance = GeofenceService._();

  StreamSubscription<List<UnsafeZone>>? _zoneSub;
  List<UnsafeZone> _currentZones = [];
  final Set<String> _recentlyWarnedZoneIds = {};
  
  BuildContext? _appContext;
  LocationNotifier? _locationNotifier;

  void startService(BuildContext context, LocationNotifier locationNotifier) {
    if (_appContext != null) return; // already started
    _appContext = context;
    _locationNotifier = locationNotifier;

    // Listen to zones
    _zoneSub = FirestoreService().streamUnsafeZones().listen((zones) {
      _currentZones = zones;
    });

    // Listen to location updates
    _locationNotifier!.addListener(_onLocationUpdate);
  }

  void stopService() {
    _zoneSub?.cancel();
    _zoneSub = null;
    _locationNotifier?.removeListener(_onLocationUpdate);
    _locationNotifier = null;
    _appContext = null;
    _recentlyWarnedZoneIds.clear();
  }

  void _onLocationUpdate() {
    if (_locationNotifier == null) return;
    _checkGeofences(_locationNotifier!.currentPosition);
  }

  void _checkGeofences(LatLng currentPos) {
    for (final zone in _currentZones) {
      if (zone.severity.toUpperCase() == 'HIGH') {
        if (_isPointInPolygon(currentPos, zone.polygon)) {
          if (!_recentlyWarnedZoneIds.contains(zone.id)) {
             _recentlyWarnedZoneIds.add(zone.id);
             _triggerWarning(zone);
             
             // Cooldown to prevent spam
             Future.delayed(const Duration(minutes: 5), () {
               _recentlyWarnedZoneIds.remove(zone.id);
             });
          }
        }
      }
    }
  }

  void _triggerWarning(UnsafeZone zone) {
    // 1. Push Notification
    NotificationService.instance.showAlertNotification(
      title: '⚠️ GEOFENCE ALERT',
      body: 'CAUTION: You have entered a HIGH-RISK reported unsafe zone: ${zone.name}',
      severity: 'HIGH',
    );

    // 2. In-app banner overlay
    final context = _appContext;
    if (context == null || !context.mounted) return;
    
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _GeofenceBannerOverlay(
        zone: zone,
        onDismiss: () {
          try { entry.remove(); } catch (_) {}
        },
      ),
    );

    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 8), () {
      try { entry.remove(); } catch (_) {}
    });
  }

  // --- Ray-Casting Math ---
  bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    if (polygon.isEmpty) return false;
    int intersectCount = 0;
    for (int j = 0; j < polygon.length - 1; j++) {
      if (_rayCastIntersect(point, polygon[j], polygon[j + 1])) {
        intersectCount++;
      }
    }
    if (_rayCastIntersect(point, polygon.last, polygon.first)) {
      intersectCount++;
    }
    return (intersectCount % 2) == 1;
  }

  bool _rayCastIntersect(LatLng point, LatLng vertA, LatLng vertB) {
    double aY = vertA.latitude;
    double bY = vertB.latitude;
    double aX = vertA.longitude;
    double bX = vertB.longitude;
    double pY = point.latitude;
    double pX = point.longitude;

    if ((aY > pY && bY > pY) || (aY < pY && bY < pY) || (aX < pX && bX < pX)) {
      return false;
    }
    double m = (aY - bY) / (aX - bX);
    double bee = (-aX) * m + aY;
    double x = (pY - bee) / m;
    return x > pX;
  }
}

class _GeofenceBannerOverlay extends StatefulWidget {
  final UnsafeZone zone;
  final VoidCallback onDismiss;

  const _GeofenceBannerOverlay({required this.zone, required this.onDismiss});

  @override
  State<_GeofenceBannerOverlay> createState() => _GeofenceBannerOverlayState();
}

class _GeofenceBannerOverlayState extends State<_GeofenceBannerOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 12,
      right: 12,
      child: SlideTransition(
        position: _slideAnimation,
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: widget.onDismiss,
            onVerticalDragEnd: (_) => widget.onDismiss(),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444), // Solid Red
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 36),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'GEOFENCE WARNING',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'You have entered: ${widget.zone.name}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Severity: ${widget.zone.severity} - Please stay alert.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
