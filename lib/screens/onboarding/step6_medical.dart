import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/dropdown.dart';
import '../../core/widgets/toggle_row.dart';
import '../../core/widgets/input_field.dart';
import '../../providers/onboarding_provider.dart';

class Step6Medical extends ConsumerWidget {
  const Step6Medical({super.key});

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
          Text(AppLocalizations.of(context)?.medicalSafety ?? 'Medical Safety', style: AppTypography.h1),
          const SizedBox(height: 32),
          AppDropdown(
            label: AppLocalizations.of(context)?.bloodType ?? 'Blood Type',
            selectedValue: data.bloodType,
            items: const [
              'A+', 'A−', 'B+', 'B−', 'O+', 'O−', 'AB+', 'AB−',
            ],
            onChanged: (val) => onboarding.setBloodType(val),
          ),
          const SizedBox(height: 20),
          ToggleRow(
            label: 'Do you have any allergies?',
            subtitle: 'Food, drug, or environmental allergies',
            value: data.hasAllergies,
            onChanged: (val) => onboarding.setHasAllergies(val),
          ),
          if (data.hasAllergies) ...[
            const SizedBox(height: 8),
            InputField(
              label: AppLocalizations.of(context)?.allergyDetails ?? 'Allergy Details',
              hintText: 'Describe your allergies...',
              maxLines: 3,
              onChanged: (val) => onboarding.setAllergyDetails(val),
            ),
          ],
          const SizedBox(height: 12),
          ToggleRow(
            label: 'Do you have chronic conditions?',
            subtitle: 'Diabetes, asthma, heart conditions, etc.',
            value: data.hasChronicConditions,
            onChanged: (val) => onboarding.setHasChronicConditions(val),
          ),
          if (data.hasChronicConditions) ...[
            const SizedBox(height: 8),
            InputField(
              label: AppLocalizations.of(context)?.conditionDetails ?? 'Condition Details',
              hintText: 'Describe your conditions...',
              maxLines: 3,
              onChanged: (val) => onboarding.setConditionDetails(val),
            ),
          ],
          const SizedBox(height: 12),
          ToggleRow(
            label: 'Do you take regular medications?',
            subtitle: 'Prescription or over-the-counter medications',
            value: data.takesRegularMedication,
            onChanged: (val) => onboarding.setTakesRegularMedication(val),
          ),
          if (data.takesRegularMedication) ...[
            const SizedBox(height: 8),
            InputField(
              label: 'Medication List',
              hintText: 'List your medications...',
              maxLines: 3,
              onChanged: (val) => onboarding.setMedicationDetails(val),
            ),
          ],
          const SizedBox(height: 20),
          InputField(
            label: 'Travel Insurance Policy Number (Optional)',
            prefixIcon: Icons.health_and_safety_outlined,
            hintText: 'Enter policy number',
            onChanged: (val) => onboarding.setInsurancePolicyNumber(val),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
