import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/widgets/safety_card.dart';
import '../providers/onboarding_provider.dart';
import '../l10n/app_localizations.dart';

class EmergencyContactsScreen extends ConsumerWidget {
  const EmergencyContactsScreen({super.key});

  Future<void> _makeCall(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingProvider);
    final data = onboarding.data;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(AppLocalizations.of(context)?.emergencyContacts ?? 'Emergency Contacts', style: AppTypography.h2),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Government Helplines Header
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.alertRed.withValues(alpha: 0.15),
                  ),
                  child: const Icon(Icons.local_phone,
                      color: AppColors.alertRed, size: 20),
                ),
                const SizedBox(width: 12),
                Text(AppLocalizations.of(context)?.govHelplines ?? 'Government Helplines',
                    style: AppTypography.h2.copyWith(fontSize: 18)),
              ],
            ),
            const SizedBox(height: 16),

            _HelplineCard(
              icon: Icons.tour,
              iconColor: AppColors.accentBlue,
              title: AppLocalizations.of(context)?.touristHelpline ?? 'Tourist Helpline',
              number: '1363',
              onCall: () => _makeCall('1363'),
            ),
            const SizedBox(height: 10),
            _HelplineCard(
              icon: Icons.local_police,
              iconColor: AppColors.accentBlue,
              title: AppLocalizations.of(context)?.policeHelpline ?? 'Police',
              number: '100',
              onCall: () => _makeCall('100'),
            ),
            const SizedBox(height: 10),
            _HelplineCard(
              icon: Icons.local_hospital,
              iconColor: AppColors.success,
              title: AppLocalizations.of(context)?.ambulanceHelpline ?? 'Ambulance',
              number: '102',
              onCall: () => _makeCall('102'),
            ),
            const SizedBox(height: 10),
            _HelplineCard(
              icon: Icons.local_fire_department,
              iconColor: AppColors.warning,
              title: AppLocalizations.of(context)?.fireBrigadeHelpline ?? 'Fire Brigade',
              number: '101',
              onCall: () => _makeCall('101'),
            ),
            const SizedBox(height: 10),
            _HelplineCard(
              icon: Icons.female,
              iconColor: const Color(0xFFE040FB),
              title: AppLocalizations.of(context)?.womensHelpline ?? "Women's Helpline",
              number: '1091',
              onCall: () => _makeCall('1091'),
            ),
            const SizedBox(height: 10),
            _HelplineCard(
              icon: Icons.computer,
              iconColor: AppColors.warning,
              title: AppLocalizations.of(context)?.cyberCrimeHelpline ?? 'Cyber Crime Helpline',
              number: '1930',
              onCall: () => _makeCall('1930'),
            ),

            const SizedBox(height: 32),

            // Personal Emergency Contacts Header
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.accentBlue.withValues(alpha: 0.15),
                  ),
                  child: const Icon(Icons.people,
                      color: AppColors.accentBlue, size: 20),
                ),
                const SizedBox(width: 12),
                Text(AppLocalizations.of(context)?.yourEmergencyContacts ?? 'Your Emergency Contacts',
                    style: AppTypography.h2.copyWith(fontSize: 18)),
              ],
            ),
            const SizedBox(height: 16),

            if (data.contact1Name.isNotEmpty)
              _PersonalContactCard(
                name: data.contact1Name,
                relationship: data.contact1Relationship ?? '',
                phone: data.contact1Phone,
                onCall: () => _makeCall(data.contact1Phone),
              ),
            if (data.contact1Name.isNotEmpty) const SizedBox(height: 10),

            if (data.contact2Name.isNotEmpty)
              _PersonalContactCard(
                name: data.contact2Name,
                relationship: data.contact2Relationship ?? '',
                phone: data.contact2Phone,
                onCall: () => _makeCall(data.contact2Phone),
              ),

            if (data.contact1Name.isEmpty && data.contact2Name.isEmpty)
              SafetyCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.person_add_outlined,
                        color: AppColors.textSecondary, size: 40),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.of(context)?.noContactsAdded ?? 'No personal contacts added yet.',
                      style: AppTypography.body
                          .copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)?.addContactsOnboarding ?? 'Add contacts during onboarding to see them here.',
                      style: AppTypography.caption,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// -- Government helpline card --
class _HelplineCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String number;
  final VoidCallback onCall;

  const _HelplineCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.number,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return SafetyCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: iconColor.withValues(alpha: 0.12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTypography.body
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(number, style: AppTypography.caption),
              ],
            ),
          ),
          // Call button
          GestureDetector(
            onTap: onCall,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.success.withValues(alpha: 0.15),
              ),
              child: const Icon(Icons.call, color: AppColors.success, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}

// -- Personal contact card --
class _PersonalContactCard extends StatelessWidget {
  final String name;
  final String relationship;
  final String phone;
  final VoidCallback onCall;

  const _PersonalContactCard({
    required this.name,
    required this.relationship,
    required this.phone,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return SafetyCard(
      accentColor: AppColors.accentBlue,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentBlue.withValues(alpha: 0.12),
            ),
            child: const Icon(Icons.person,
                color: AppColors.accentBlue, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: AppTypography.body
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  relationship.isNotEmpty
                      ? '$relationship · $phone'
                      : phone,
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onCall,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.success.withValues(alpha: 0.15),
              ),
              child: const Icon(Icons.call, color: AppColors.success, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}
