import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/input_field.dart';
import '../../core/widgets/date_card.dart';
import '../../core/widgets/country_select.dart';
import '../../providers/onboarding_provider.dart';

class Step2Identity extends ConsumerWidget {
  const Step2Identity({super.key});

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
          Text('Personal Identity', style: AppTypography.h1),
          const SizedBox(height: 32),
          InputField(
            label: 'First Name',
            prefixIcon: Icons.person_outline,
            hintText: 'Enter first name',
            onChanged: (val) => onboarding.setFirstName(val),
          ),
          const SizedBox(height: 20),
          InputField(
            label: 'Last Name',
            prefixIcon: Icons.person_outline,
            hintText: 'Enter last name',
            onChanged: (val) => onboarding.setLastName(val),
          ),
          const SizedBox(height: 20),
          DateCard(
            label: 'Date of Birth',
            selectedDate: data.dateOfBirth,
            onDateSelected: (date) => onboarding.setDateOfBirth(date),
            lastDate: DateTime.now(),
          ),
          const SizedBox(height: 20),
          CountrySelect(
            label: 'Nationality',
            selectedCountry: data.nationality,
            onSelect: (country) => onboarding.setNationality(country),
          ),
          const SizedBox(height: 20),
          InputField(
            label: 'Passport/ID Number',
            prefixIcon: Icons.badge_outlined,
            hintText: 'Enter passport or ID number',
            onChanged: (val) => onboarding.setPassportNumber(val),
          ),
          const SizedBox(height: 20),
          DateCard(
            label: 'Passport Expiry Date',
            selectedDate: data.passportExpiry,
            onDateSelected: (date) => onboarding.setPassportExpiry(date),
            firstDate: DateTime.now(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
