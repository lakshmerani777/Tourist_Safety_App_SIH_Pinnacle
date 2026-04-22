import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/widgets/safety_card.dart';
import '../core/widgets/safety_button.dart';
import '../providers/sos_provider.dart';
import '../providers/api_providers.dart';
import '../providers/onboarding_provider.dart';
import '../providers/location_provider.dart';
import '../l10n/app_localizations.dart';

class SOSActivatedScreen extends ConsumerStatefulWidget {
  const SOSActivatedScreen({super.key});

  @override
  ConsumerState<SOSActivatedScreen> createState() =>
      _SOSActivatedScreenState();
}

class _SOSActivatedScreenState extends ConsumerState<SOSActivatedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  bool _sosSent = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sosProvider).activateSOS();
    });
  }

  void _maybeTriggerSOS(int countdown) {
    if (countdown == 0 && !_sosSent) {
      _sosSent = true;
      _sendSOSToBackend();
    }
  }

  Future<void> _sendSOSToBackend() async {
    final location = ref.read(locationProvider);
    final profile = ref.read(onboardingProvider).data;
    final name = profile.firstName.isNotEmpty
        ? '${profile.firstName} ${profile.lastName}'.trim()
        : 'Tourist';
    final nationality = profile.nationality?.name ?? '';

    try {
      await ref.read(apiClientProvider).triggerSOS(
        latitude: location.currentPosition.latitude,
        longitude: location.currentPosition.longitude,
        address: location.currentAddress,
        touristName: name,
        nationality: nationality,
      );
    } catch (_) {
      // SOS is best-effort via API; Firestore already records via FirestoreService.
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _cancelSOS() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(AppLocalizations.of(context)?.cancelSosTitle ?? 'Cancel SOS?', style: AppTypography.h2),
        content: Text(
          AppLocalizations.of(context)?.cancelSosMessage ?? 'Are you sure you want to cancel the emergency alert?',
          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                Text(AppLocalizations.of(context)?.keepActive ?? 'Keep Active', style: const TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              ref.read(sosProvider).cancelSOS();
              Navigator.pop(ctx);
              context.go('/home');
            },
            child: Text(AppLocalizations.of(context)?.cancelSosButton ?? 'Cancel SOS',
                style: const TextStyle(color: AppColors.alertRed)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sos = ref.watch(sosProvider);
    _maybeTriggerSOS(sos.countdown);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.alertRed.withValues(alpha: 0.12),
                AppColors.background,
              ],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                const SizedBox(height: 16),

                // Current Location Banner
                SafetyCard(
                  accentColor: AppColors.accentBlue,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accentBlue.withValues(alpha: 0.15),
                        ),
                        child: const Icon(Icons.my_location,
                            color: AppColors.accentBlue, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)?.currentLocation ?? 'Current Location',
                              style: AppTypography.caption.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.accentBlue,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              AppLocalizations.of(context)?.mockLocation ?? '16th Road, Bandra West',
                              style: AppTypography.body.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Pulsing ring
                AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnim.value,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.alertRed.withValues(alpha: 0.4),
                            width: 3,
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.alertRed.withValues(alpha: 0.2),
                              border: Border.all(
                                color: AppColors.alertRed.withValues(alpha: 0.6),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.shield,
                              size: 48,
                              color: AppColors.alertRed,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),

                Text(
                  AppLocalizations.of(context)?.sosActivated ?? 'SOS ACTIVATED',
                  style: AppTypography.h1.copyWith(
                    color: AppColors.alertRed,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context)?.sosNotified ?? 'Emergency services have been notified.\nHelp is on the way.',
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // User Details Card
                SafetyCard(
                  accentColor: AppColors.alertRed,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DetailRow(AppLocalizations.of(context)?.sosNameLabel ?? 'Name', 'Tourist User'),
                      const Divider(color: AppColors.border, height: 20),
                      _DetailRow(AppLocalizations.of(context)?.sosLocationLabel ?? 'Location', AppLocalizations.of(context)?.mockLocation ?? '16th Road, Bandra West'),
                      const Divider(color: AppColors.border, height: 20),
                      _DetailRow(AppLocalizations.of(context)?.sosTimestampLabel ?? 'Timestamp', _getCurrentTime()),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Countdown Bar
                if (sos.countdown > 0) ...[
                  SafetyCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          AppLocalizations.of(context)?.cancellationAvailableFor(sos.countdown) ?? 'Cancellation available for: ${sos.countdown}s',
                          style: AppTypography.caption,
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: sos.countdown / 10,
                            minHeight: 6,
                            backgroundColor: AppColors.border,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.alertRed),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Cancel Button
                if (sos.countdown > 0)
                  SafetyButton(
                    text: AppLocalizations.of(context)?.cancelSosButton ?? 'Cancel SOS',
                    variant: SafetyButtonVariant.outlined,
                    onPressed: _cancelSOS,
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.caption),
        Text(value,
            style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
