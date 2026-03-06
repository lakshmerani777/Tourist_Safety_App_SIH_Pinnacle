import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/input_field.dart';
import '../../core/widgets/dropdown.dart';
import '../../core/widgets/phone_input.dart';
import '../../core/widgets/safety_card.dart';
import '../../providers/onboarding_provider.dart';

class Step4Emergency extends ConsumerWidget {
  const Step4Emergency({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingProvider);
    final data = onboarding.data;

    const relationships = [
      'Spouse',
      'Parent',
      'Sibling',
      'Friend',
      'Colleague',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text('Emergency Contacts', style: AppTypography.h1),
          const SizedBox(height: 24),
          // Contact 1
          SafetyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Contact 1', style: AppTypography.h2),
                const SizedBox(height: 16),
                InputField(
                  label: 'Full Name',
                  prefixIcon: Icons.person_outline,
                  hintText: 'Contact name',
                  onChanged: (val) => onboarding.setContact1Name(val),
                ),
                const SizedBox(height: 16),
                AppDropdown(
                  label: 'Relationship',
                  selectedValue: data.contact1Relationship,
                  items: relationships,
                  onChanged: (val) =>
                      onboarding.setContact1Relationship(val),
                ),
                const SizedBox(height: 16),
                PhoneInput(
                  label: 'Phone Number',
                  onChanged: (val) => onboarding.setContact1Phone(val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Contact 2
          SafetyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Contact 2', style: AppTypography.h2),
                const SizedBox(height: 16),
                InputField(
                  label: 'Full Name',
                  prefixIcon: Icons.person_outline,
                  hintText: 'Contact name',
                  onChanged: (val) => onboarding.setContact2Name(val),
                ),
                const SizedBox(height: 16),
                AppDropdown(
                  label: 'Relationship',
                  selectedValue: data.contact2Relationship,
                  items: relationships,
                  onChanged: (val) =>
                      onboarding.setContact2Relationship(val),
                ),
                const SizedBox(height: 16),
                PhoneInput(
                  label: 'Phone Number',
                  onChanged: (val) => onboarding.setContact2Phone(val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
