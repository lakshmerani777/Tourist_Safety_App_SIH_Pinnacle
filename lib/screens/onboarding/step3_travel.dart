import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/date_card.dart';
import '../../core/widgets/dropdown.dart';
import '../../core/widgets/input_field.dart';
import '../../providers/onboarding_provider.dart';

class Step3Travel extends ConsumerWidget {
  const Step3Travel({super.key});

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
          Text('Travel Timeline', style: AppTypography.h1),
          const SizedBox(height: 32),
          DateCard(
            label: 'Arrival Date',
            selectedDate: data.arrivalDate,
            onDateSelected: (date) => onboarding.setArrivalDate(date),
          ),
          const SizedBox(height: 20),
          DateCard(
            label: 'Departure Date',
            selectedDate: data.departureDate,
            onDateSelected: (date) => onboarding.setDepartureDate(date),
          ),
          const SizedBox(height: 20),
          AppDropdown(
            label: 'Purpose of Visit',
            selectedValue: data.purposeOfVisit,
            items: const [
              'Tourism',
              'Business',
              'Medical',
              'Education',
              'Transit',
            ],
            onChanged: (val) => onboarding.setPurposeOfVisit(val),
          ),
          const SizedBox(height: 20),
          InputField(
            label: 'Places Planning to Visit',
            hintText: 'Enter places you plan to visit...',
            maxLines: 3,
            prefixIcon: Icons.place_outlined,
            onChanged: (val) => onboarding.setPlacesToVisit(val),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
