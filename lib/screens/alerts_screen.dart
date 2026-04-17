import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/theme/app_typography.dart';
import '../core/widgets/status_badge.dart';
import '../l10n/app_localizations.dart';

enum AlertSeverity { high, medium, low }

class AlertData {
  final String title;
  final String description;
  final String location;
  final String timeIssued;
  final AlertSeverity severity;
  final String helplineNumber;

  const AlertData({
    required this.title,
    required this.description,
    required this.location,
    required this.timeIssued,
    required this.severity,
    required this.helplineNumber,
  });
}

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  // Mock alerts data for Mumbai
  final List<AlertData> _alerts = [
    const AlertData(
      title: 'Heavy Rainfall Warning',
      description: 'The IMD has issued a Red Alert for Mumbai and surrounding areas. Expected heavy to very heavy rainfall over the next 24 hours. Tourists are advised to avoid coastal areas, beaches (Juhu, Girgaon), and low-lying regions. Stay indoors and avoid unnecessary travel.',
      location: 'Mumbai City & Suburbs',
      timeIssued: '2 hours ago',
      severity: AlertSeverity.high,
      helplineNumber: '1077', // Disaster Management
    ),
    const AlertData(
      title: 'Crowd Surge Warning',
      description: 'Lalbaugcha Raja and surrounding areas are experiencing massive crowd surges. Tourist movement is heavily restricted. Please use designated tourist lanes and avoid carrying valuables. Be aware of your surroundings to prevent stampede-like situations.',
      location: 'Lalbaug, Parel',
      timeIssued: '4 hours ago',
      severity: AlertSeverity.high,
      helplineNumber: '100', // Police
    ),
    const AlertData(
      title: 'Pickpocketing Hotspot',
      description: 'Increased reports of organized pickpocketing and bag snatching incidents near the Gateway of India and Colaba Causeway. Tourists should keep belongings secure, carry bags in front, and avoid interactions with aggressive street vendors.',
      location: 'Colaba / South Mumbai',
      timeIssued: '1 day ago',
      severity: AlertSeverity.medium,
      helplineNumber: '1363', // Tourist Helpline
    ),
    const AlertData(
      title: 'Traffic Diversions (VIP Movement)',
      description: 'Major traffic diversions are in place along the Bandra-Worli Sea Link and Marine Drive due to VIP movement. Expect delays of up to 45 minutes on these routes. Plan airport transfers accordingly.',
      location: 'Bandra-Worli Sea Link / Marine Drive',
      timeIssued: '30 mins ago',
      severity: AlertSeverity.low,
      helplineNumber: '108', // General Help
    ),
  ];

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
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        itemCount: _alerts.length,
        itemBuilder: (context, index) {
          final alert = _alerts[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _AlertCard(
              alert: alert,
              onCallPressed: () => _makePhoneCall(alert.helplineNumber),
            ),
          );
        },
      ),
    );
  }
}

class _AlertCard extends StatefulWidget {
  final AlertData alert;
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
      case AlertSeverity.high:
        return AppColors.alertRed;
      case AlertSeverity.medium:
        return AppColors.warning;
      case AlertSeverity.low:
        return AppColors.accentBlue;
    }
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
                      type: widget.alert.severity == AlertSeverity.high 
                          ? BadgeType.alert 
                          : widget.alert.severity == AlertSeverity.medium 
                              ? BadgeType.warning 
                              : BadgeType.active,
                      label: widget.alert.severity.name.toUpperCase(),
                    ),
                    Text(
                      widget.alert.timeIssued,
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
