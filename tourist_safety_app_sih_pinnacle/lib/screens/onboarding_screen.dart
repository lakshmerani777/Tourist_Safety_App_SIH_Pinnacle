import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../core/widgets/progress_bar.dart';
import '../core/widgets/navigation_buttons.dart';
import '../core/widgets/safety_button.dart';
import '../providers/onboarding_provider.dart';
import 'onboarding/step1_phone.dart';
import 'onboarding/step2_identity.dart';
import 'onboarding/step3_travel.dart';
import 'onboarding/step4_emergency.dart';
import 'onboarding/step5_stay.dart';
import 'onboarding/step6_medical.dart';
import 'onboarding/step7_consent.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingProvider);
    final step = onboarding.currentStep;

    final steps = const [
      Step1Phone(),
      Step2Identity(),
      Step3Travel(),
      Step4Emergency(),
      Step5Stay(),
      Step6Medical(),
      Step7Consent(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: StepProgressBar(
                currentStep: step,
                totalSteps: 7,
              ),
            ),
            // Step Content
            Expanded(
              child: steps[step - 1],
            ),
            // Navigation Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: step == 7
                  ? SafetyButton(
                      text: 'Complete Registration',
                      onPressed: onboarding.allRequiredConsentsGiven
                          ? () => context.go('/home')
                          : null,
                    )
                  : NavigationButtons(
                      showBack: step > 1,
                      onBack: step > 1 ? () => onboarding.previousStep() : null,
                      onContinue: () => onboarding.nextStep(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
