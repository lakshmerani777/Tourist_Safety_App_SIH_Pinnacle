import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../core/widgets/progress_bar.dart';
import '../core/widgets/navigation_buttons.dart';
import '../core/widgets/safety_button.dart';
import '../providers/onboarding_provider.dart';
import '../providers/api_providers.dart';
import '../services/auth_flow_persistence.dart';
import 'onboarding/step1_phone.dart';
import 'onboarding/step2_identity.dart';
import 'onboarding/step3_travel.dart';
import 'onboarding/step4_emergency.dart';
import 'onboarding/step5_stay.dart';
import 'onboarding/step6_medical.dart';
import 'onboarding/step7_consent.dart';
import '../core/widgets/language_switcher.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, this.restoreStep});

  final int? restoreStep;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.restoreStep != null && widget.restoreStep! >= 1 && widget.restoreStep! <= 7) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ref.read(onboardingProvider).setStep(widget.restoreStep!);
      });
    }
  }

  Future<void> _completeOnboarding() async {
    setState(() => _submitting = true);
    try {
      final data = ref.read(onboardingProvider).data;
      await ref.read(apiClientProvider).submitOnboarding(data.toJson());
    } catch (_) {
      // Non-fatal — profile data can be resubmitted later; continue to home.
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
    AuthFlowPersistence.clearAuthFlow();
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: StepProgressBar(
                      currentStep: step,
                      totalSteps: 7,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const LanguageSwitcher(),
                ],
              ),
            ),
            Expanded(
              child: steps[step - 1],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: step == 7
                  ? SafetyButton(
                      text: _submitting ? 'Saving…' : 'Complete Registration',
                      onPressed: (onboarding.allRequiredConsentsGiven && !_submitting)
                          ? _completeOnboarding
                          : null,
                    )
                  : NavigationButtons(
                      showBack: step > 1,
                      showContinue: step != 1 || onboarding.data.otpVerified,
                      onBack: step > 1
                          ? () {
                              onboarding.previousStep();
                              AuthFlowPersistence.saveOnboardingStep(
                                ref.read(onboardingProvider).currentStep,
                              );
                            }
                          : null,
                      onContinue: (step == 1 && !onboarding.data.otpVerified)
                          ? null
                          : () {
                              onboarding.nextStep();
                              AuthFlowPersistence.saveOnboardingStep(
                                ref.read(onboardingProvider).currentStep,
                              );
                            },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
