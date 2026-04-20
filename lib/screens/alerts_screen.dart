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
  String _filter = 'ALL';

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Gradient header
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF120A0A), AppColors.background],
                stops: [0.0, 1.0],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.alertRed.withValues(alpha: 0.15),
                          ),
                          child: const Icon(Icons.notifications_active, color: AppColors.alertRed, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          AppLocalizations.of(context)?.activeAlerts ?? 'Active Alerts',
                          style: AppTypography.h2,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Severity filter chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(left: 16),
                      child: Row(
                        children: [
                          _FilterChip(label: 'All', value: 'ALL', selected: _filter == 'ALL', onTap: () => setState(() => _filter = 'ALL')),
                          const SizedBox(width: 8),
                          _FilterChip(label: 'High', value: 'HIGH', selected: _filter == 'HIGH', color: AppColors.alertRed, onTap: () => setState(() => _filter = 'HIGH')),
                          const SizedBox(width: 8),
                          _FilterChip(label: 'Medium', value: 'MEDIUM', selected: _filter == 'MEDIUM', color: AppColors.warning, onTap: () => setState(() => _filter = 'MEDIUM')),
                          const SizedBox(width: 8),
                          _FilterChip(label: 'Low', value: 'LOW', selected: _filter == 'LOW', color: AppColors.accentBlue, onTap: () => setState(() => _filter = 'LOW')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Alert list
          Expanded(
            child: StreamBuilder<List<SafetyAlert>>(
              stream: _firestore.streamAlerts(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.alertRed),
                  );
                }
                final allAlerts = snap.data ?? [];
                final alerts = _filter == 'ALL'
                    ? allAlerts
                    : allAlerts.where((a) => a.severity == _filter).toList();

                if (alerts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.success.withValues(alpha: 0.1),
                          ),
                          child: const Icon(Icons.check_circle_outline, color: AppColors.success, size: 36),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _filter == 'ALL' ? 'No active alerts in your area' : 'No $_filter severity alerts',
                          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'You\'re all clear',
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: alerts.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _AlertCard(
                        alert: alerts[index],
                        onCallPressed: () => _makePhoneCall(alerts[index].helplineNumber),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.value,
    required this.selected,
    this.color = AppColors.accentBlue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.15) : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            color: selected ? color : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _AlertCard extends StatefulWidget {
  final SafetyAlert alert;
  final VoidCallback onCallPressed;

  const _AlertCard({required this.alert, required this.onCallPressed});

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
        border: Border(
          left: BorderSide(color: accentColor, width: 4),
          top: BorderSide(color: _isExpanded ? accentColor.withValues(alpha: 0.3) : AppColors.border),
          right: BorderSide(color: _isExpanded ? accentColor.withValues(alpha: 0.3) : AppColors.border),
          bottom: BorderSide(color: _isExpanded ? accentColor.withValues(alpha: 0.3) : AppColors.border),
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
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accentColor.withValues(alpha: 0.15),
                      ),
                      child: Icon(Icons.warning_amber_rounded, color: accentColor, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.alert.title,
                            style: AppTypography.body.copyWith(fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: AppColors.textSecondary, size: 12),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  widget.alert.location,
                                  style: AppTypography.caption.copyWith(fontSize: 11),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        StatusBadge(
                          type: widget.alert.severity == 'HIGH'
                              ? BadgeType.alert
                              : widget.alert.severity == 'MEDIUM'
                                  ? BadgeType.warning
                                  : BadgeType.active,
                          label: widget.alert.severity,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(widget.alert.issuedAt),
                          style: AppTypography.caption.copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ],
                ),

                if (_isExpanded) ...[
                  const SizedBox(height: 14),
                  Divider(color: accentColor.withValues(alpha: 0.2), height: 1),
                  const SizedBox(height: 14),
                  Text(
                    widget.alert.description,
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
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
                          side: BorderSide(color: AppColors.alertRed.withValues(alpha: 0.4)),
                        ),
                      ),
                      onPressed: widget.onCallPressed,
                      icon: const Icon(Icons.phone, size: 18),
                      label: Text(
                        AppLocalizations.of(context)?.callHelpline ?? 'Call Tourist Helpline',
                        style: AppTypography.body.copyWith(
                          color: AppColors.alertRed,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
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
