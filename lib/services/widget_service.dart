import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

/// Service to communicate with the Android home-screen safety widget.
///
/// Uses a MethodChannel to:
/// - Push safety status updates (protected/unsafe) to the native widget.
/// - Receive navigation requests when the widget's SOS button is tapped.
class WidgetService {
  WidgetService._();

  static const _channel = MethodChannel(
    'com.example.tourist_safety_app_sih_pinnacle/widget',
  );

  static GoRouter? _router;

  /// Initialise the service. Call once from your app's top-level widget
  /// (e.g. in `initState` of the home screen) so the method-channel listener
  /// is ready to handle widget-triggered navigation.
  static void init(GoRouter router) {
    _router = router;
    _channel.setMethodCallHandler(_handleMethod);

    // Check if the app was cold-launched from the widget.
    _checkInitialRoute();
  }

  /// Push the current safety status to the widget so it can display
  /// "PROTECTED" (green) or "UNSAFE" (red).
  static Future<void> updateSafetyStatus({required bool isProtected}) async {
    try {
      await _channel.invokeMethod('updateSafetyStatus', {
        'isProtected': isProtected,
      });
    } on PlatformException catch (_) {
      // Widget may not exist yet – swallow gracefully.
    }
  }

  // --- private helpers ---------------------------------------------------

  static Future<void> _checkInitialRoute() async {
    try {
      final route = await _channel.invokeMethod<String>('getInitialRoute');
      if (route != null && _router != null) {
        _router!.push(route);
      }
    } on PlatformException catch (_) {
      // No initial route – normal app launch.
    }
  }

  static Future<dynamic> _handleMethod(MethodCall call) async {
    if (call.method == 'navigateTo') {
      final route = call.arguments as String?;
      if (route != null && _router != null) {
        _router!.push(route);
      }
    }
  }
}
