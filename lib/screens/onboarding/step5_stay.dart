import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/input_field.dart';
import '../../core/widgets/dropdown.dart';
import '../../core/widgets/phone_input.dart';
import '../../providers/onboarding_provider.dart';

class Step5Stay extends ConsumerWidget {
  const Step5Stay({super.key});

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
          Text(AppLocalizations.of(context)?.stayDetailsTitle ?? 'Stay Details', style: AppTypography.h1),
          const SizedBox(height: 32),
          AppDropdown(
            label: AppLocalizations.of(context)?.accommodationType ?? 'Accommodation Type',
            selectedValue: data.accommodationType,
            items: const [
              'Hotel',
              'Hostel',
              'Airbnb',
              'With Family',
              'Other',
            ],
            onChanged: (val) => onboarding.setAccommodationType(val),
          ),
          const SizedBox(height: 20),
          InputField(
            label: AppLocalizations.of(context)?.propertyName ?? 'Hotel/Property Name',
            prefixIcon: Icons.business_outlined,
            hintText: 'Enter property name',
            onChanged: (val) => onboarding.setPropertyName(val),
          ),
          const SizedBox(height: 20),
          InputField(
            label: AppLocalizations.of(context)?.fullAddress ?? 'Full Address',
            prefixIcon: Icons.location_on_outlined,
            hintText: 'Enter full address',
            maxLines: 2,
            onChanged: (val) => onboarding.setFullAddress(val),
          ),
          const SizedBox(height: 20),
          InputField(
            label: AppLocalizations.of(context)?.roomUnit ?? 'Room/Unit Number',
            prefixIcon: Icons.meeting_room_outlined,
            hintText: 'Enter room or unit number',
            onChanged: (val) => onboarding.setRoomNumber(val),
          ),
          const SizedBox(height: 20),
          PhoneInput(
            label: AppLocalizations.of(context)?.accommodationPhone ?? 'Accommodation Phone',
            onChanged: (val) => onboarding.setAccommodationPhone(val),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
