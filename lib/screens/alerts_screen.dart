import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/widgets/status_badge.dart';
import '../l10n/app_localizations.dart';
import '../services/firestore_service.dart';
import '../models/firestore_models.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final FirestoreService _firestore = FirestoreService();

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.activeAlerts ?? 'Active Alerts', style: AppTypography.h2),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<List<SafetyAlert>>(
        stream: _firestore.streamAlerts(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final alerts = snap.data ?? [];
          if (alerts.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline, color: AppColors.success, size: 48),
                  const SizedBox(height: 12),
                  Text('No active alerts in your area',
                      style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _AlertCard(
                  alert: alert,
                  onCallPressed: () => _makePhoneCall(alert.helplineNumber),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _AlertCard extends StatefulWidget {
  final SafetyAlert alert;
  final VoidCallback onCallPressed;

  const _AlertCard({
    required this.alert,
    required this.onCallPressed,
  });

  @override
  State<_AlertCard> createState() => _AlertCardState();
}

class _AlertCardState extends State<_AlertCard> {
  bool _isExpanded = false;

  Color _getAccentColor() {
    switch (widget.alert.severity) {
      case 'HIGH':
        return AppColors.alertRed;
      case 'MEDIUM':
        return AppColors.warning;
      default:
        return AppColors.accentBlue;
    }
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = _getAccentColor();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isExpanded ? accentColor.withValues(alpha: 0.5) : AppColors.border,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row: Status Badge and Timestamp
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StatusBadge(
                      type: widget.alert.severity == 'HIGH'
                          ? BadgeType.alert
                          : widget.alert.severity == 'MEDIUM'
                              ? BadgeType.warning
                              : BadgeType.active,
                      label: widget.alert.severity,
                    ),
                    Text(
                      _formatTime(widget.alert.issuedAt),
                      style: AppTypography.caption,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Title and Location
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: accentColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.alert.title,
                            style: AppTypography.body.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: AppColors.textSecondary, size: 14),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  widget.alert.location,
                                  style: AppTypography.caption,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
                
                // Expanded Content
                if (_isExpanded) ...[
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 12),
                  Text(
                    widget.alert.description,
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Call Helpline Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.alertRed.withValues(alpha: 0.1),
                        foregroundColor: AppColors.alertRed,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: AppColors.alertRed.withValues(alpha: 0.5)),
                        ),
                      ),
                      onPressed: widget.onCallPressed,
                      icon: const Icon(Icons.phone),
                      label: Text(
                        AppLocalizations.of(context)?.callHelpline ?? 'Call Tourist Helpline',
                        style: AppTypography.body.copyWith(
                          color: AppColors.alertRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
