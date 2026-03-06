import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/safety_card.dart';
import '../../core/widgets/toggle_row.dart';
import '../../providers/onboarding_provider.dart';

class Step7Consent extends ConsumerWidget {
  const Step7Consent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingProvider);
    final data = onboarding.data;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text('Consent & Privacy', style: AppTypography.h1),
          const SizedBox(height: 24),
          // Terms card
          SafetyCard(
            child: SizedBox(
              height: 150,
              child: SingleChildScrollView(
                child: Text(
                  'Terms of Service & Privacy Policy\n\n'
                  'By using the Tourist Safety application, you agree to the following terms and conditions. '
                  'This application is designed to provide safety monitoring services for tourists. '
                  'Your personal information will be collected and processed for the purpose of ensuring your safety during your stay.\n\n'
                  '1. Data Collection: We collect personal identification, travel details, emergency contacts, '
                  'medical information, and location data.\n\n'
                  '2. Data Usage: Your data will be used exclusively for safety monitoring, emergency response, '
                  'and communication with relevant authorities.\n\n'
                  '3. Data Protection: All data is encrypted and stored in compliance with applicable data protection regulations.\n\n'
                  '4. Data Sharing: Your information may be shared with emergency services, law enforcement, '
                  'and relevant government agencies only in case of emergencies.\n\n'
                  '5. Data Retention: Your data will be retained for the duration of your registered travel period '
                  'and for a reasonable period thereafter for safety records.\n\n'
                  '6. Your Rights: You have the right to access, correct, and request deletion of your personal data '
                  'at any time through the application settings.\n\n'
                  '7. Location Tracking: The application may track your location in real-time to provide safety alerts '
                  'and enable emergency response services.\n\n'
                  'By proceeding, you acknowledge that you have read and understood these terms.',
                  style: AppTypography.caption.copyWith(
                    height: 1.6,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ToggleRow(
            label: 'I agree to the Terms of Service and Privacy Policy',
            subtitle: 'Required',
            value: data.termsAccepted,
            onChanged: (val) => onboarding.setTermsAccepted(val),
          ),
          const Divider(color: AppColors.border),
          ToggleRow(
            label: 'I consent to location tracking for safety monitoring',
            subtitle: 'Required',
            value: data.locationConsent,
            onChanged: (val) => onboarding.setLocationConsent(val),
          ),
          const Divider(color: AppColors.border),
          ToggleRow(
            label: 'I consent to sharing my data with emergency services',
            subtitle: 'Required',
            value: data.dataShareConsent,
            onChanged: (val) => onboarding.setDataShareConsent(val),
          ),
          const Divider(color: AppColors.border),
          ToggleRow(
            label: 'I agree to receive safety alerts and notifications',
            subtitle: 'Optional',
            value: data.alertsConsent,
            onChanged: (val) => onboarding.setAlertsConsent(val),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
