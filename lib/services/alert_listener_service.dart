import 'dart:async';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import '../models/firestore_models.dart';

/// Listens to the Firestore `alerts` collection in real-time and fires a
/// local notification + in-app banner whenever a *new* alert is created
/// from the police dashboard.
class AlertListenerService {
  AlertListenerService._();
  static final AlertListenerService instance = AlertListenerService._();

  StreamSubscription<List<SafetyAlert>>? _subscription;
  final Set<String> _knownAlertIds = {};
  bool _initialSnapshotProcessed = false;

  /// Holds a reference to the current BuildContext for showing in-app banners.
  BuildContext? _appContext;

  /// Start listening. Call once from the home screen's initState.
  /// Pass the BuildContext so in-app banners can be shown.
  void startListening(BuildContext context) {
    // Don't double-subscribe
    if (_subscription != null) return;

    _appContext = context;

    _subscription = FirestoreService().streamAlerts().listen((alerts) {
      if (!_initialSnapshotProcessed) {
        // First snapshot: seed known IDs so we don't notify for old alerts
        for (final alert in alerts) {
          _knownAlertIds.add(alert.id);
        }
        _initialSnapshotProcessed = true;
        debugPrint('[AlertListener] Seeded ${_knownAlertIds.length} existing alert IDs');
        return;
      }

      // Subsequent snapshots: detect new alerts
      for (final alert in alerts) {
        if (!_knownAlertIds.contains(alert.id)) {
          _knownAlertIds.add(alert.id);
          debugPrint('[AlertListener] New alert detected: ${alert.title}');
          _onNewAlert(alert);
        }
      }
    });

    debugPrint('[AlertListener] Started listening for new alerts');
  }

  /// Stop listening. Call from dispose if needed.
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _knownAlertIds.clear();
    _initialSnapshotProcessed = false;
    _appContext = null;
    debugPrint('[AlertListener] Stopped listening');
  }

  /// Handle a new alert: fire a local notification and show an in-app banner.
  void _onNewAlert(SafetyAlert alert) {
    // 1. Local push notification (works even if app is backgrounded)
    NotificationService.instance.showAlertNotification(
      title: alert.title,
      body: '${alert.description}${alert.location.isNotEmpty ? '\n📍 ${alert.location}' : ''}',
      severity: alert.severity,
    );

    // 2. In-app overlay banner (if app is in foreground)
    _showInAppBanner(alert);
  }

  void _showInAppBanner(SafetyAlert alert) {
    final context = _appContext;
    if (context == null || !context.mounted) return;

    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _AlertBannerOverlay(
        alert: alert,
        onDismiss: () {
          try { entry.remove(); } catch (_) {}
        },
      ),
    );

    overlay.insert(entry);

    // Auto-dismiss after 6 seconds
    Future.delayed(const Duration(seconds: 6), () {
      try {
        entry.remove();
      } catch (_) {}
    });
  }
}

/// Animated in-app alert banner shown at the top of the screen.
class _AlertBannerOverlay extends StatefulWidget {
  final SafetyAlert alert;
  final VoidCallback onDismiss;

  const _AlertBannerOverlay({required this.alert, required this.onDismiss});

  @override
  State<_AlertBannerOverlay> createState() => _AlertBannerOverlayState();
}

class _AlertBannerOverlayState extends State<_AlertBannerOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

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
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _severityColor {
    switch (widget.alert.severity) {
      case 'HIGH':
        return const Color(0xFFEF4444);
      case 'MEDIUM':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF3B82F6);
    }
  }

  IconData get _severityIcon {
    switch (widget.alert.severity) {
      case 'HIGH':
        return Icons.warning_rounded;
      case 'MEDIUM':
        return Icons.error_outline_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 12,
      right: 12,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: widget.onDismiss,
              onVerticalDragEnd: (_) => widget.onDismiss(),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _severityColor.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _severityColor.withValues(alpha: 0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _severityColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_severityIcon, color: _severityColor, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Text(
                                '🚨 POLICE ALERT',
                                style: TextStyle(
                                  color: _severityColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _severityColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  widget.alert.severity,
                                  style: TextStyle(
                                    color: _severityColor,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.alert.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (widget.alert.description.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              widget.alert.description,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
