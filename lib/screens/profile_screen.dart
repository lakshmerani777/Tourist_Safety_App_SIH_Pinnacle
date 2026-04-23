import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/widgets/safety_card.dart';
import '../core/widgets/input_field.dart';
import '../core/widgets/dropdown.dart';
import '../core/widgets/safety_button.dart';
import '../core/widgets/date_card.dart';
import '../core/widgets/country_select.dart';
import '../core/widgets/phone_input.dart';
import '../providers/onboarding_provider.dart';
import '../providers/api_providers.dart';
import '../core/widgets/language_switcher.dart';
import '../l10n/app_localizations.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _editingIdentity = false;
  bool _editingPhone = false;
  bool _editingTravel = false;
  bool _editingStay = false;
  bool _editingMedical = false;
  bool _editingEmergency = false;

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(onboardingProvider).data;
    final notifier = ref.read(onboardingProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Gradient hero header
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF0A1628),
                  AppColors.accentBlue.withValues(alpha: 0.06),
                  AppColors.background,
                ],
                stops: const [0.0, 0.65, 1.0],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 20),
                child: Column(
                  children: [
                    // Back button row
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        Text(
                          AppLocalizations.of(context)?.profileSettings ?? 'My Profile',
                          style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Avatar
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.accentBlue,
                            AppColors.accentBlue.withValues(alpha: 0.55),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentBlue.withValues(alpha: 0.3),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _getInitials(data),
                          style: AppTypography.h1.copyWith(color: Colors.white, fontSize: 30),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${data.firstName.isNotEmpty ? data.firstName : "John"} ${data.lastName.isNotEmpty ? data.lastName : "Doe"}',
                      style: AppTypography.h2.copyWith(fontSize: 22),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.flag_outlined, size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          data.nationality?.name ?? 'India',
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Language switcher
                  SafetyCard(
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.accentBlue.withValues(alpha: 0.12),
                          ),
                          child: const Icon(Icons.language, color: AppColors.accentBlue, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          AppLocalizations.of(context)?.language ?? 'Language',
                          style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        const LanguageSwitcher(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  _SectionHeader(
                    title: AppLocalizations.of(context)?.personalIdentity ?? 'Personal Identity',
                    icon: Icons.person,
                    iconColor: AppColors.accentBlue,
                    onEdit: () => setState(() => _editingIdentity = !_editingIdentity),
                    isEditing: _editingIdentity,
                  ),
                  const SizedBox(height: 10),
                  _editingIdentity
                      ? _buildIdentityEditForm(data, notifier)
                      : SafetyCard(
                          child: Column(
                            children: [
                              _InfoRow(label: AppLocalizations.of(context)?.firstName ?? 'First Name', value: data.firstName.isNotEmpty ? data.firstName : 'John'),
                              const Divider(color: AppColors.border, height: 1),
                              _InfoRow(label: AppLocalizations.of(context)?.lastName ?? 'Last Name', value: data.lastName.isNotEmpty ? data.lastName : 'Doe'),
                              const Divider(color: AppColors.border, height: 1),
                              _InfoRow(
                                label: AppLocalizations.of(context)?.dob ?? 'Date of Birth',
                                value: data.dateOfBirth != null ? DateFormat('MMM d, yyyy').format(data.dateOfBirth!) : 'Jan 15, 1990',
                              ),
                              const Divider(color: AppColors.border, height: 1),
                              _InfoRow(label: AppLocalizations.of(context)?.nationality ?? 'Nationality', value: data.nationality?.name ?? 'India'),
                              const Divider(color: AppColors.border, height: 1),
                              _InfoRow(label: AppLocalizations.of(context)?.passportNum ?? 'Passport No.', value: data.passportNumber.isNotEmpty ? data.passportNumber : 'A1234567'),
                              const Divider(color: AppColors.border, height: 1),
                              _InfoRow(
                                label: AppLocalizations.of(context)?.passportExpiry ?? 'Passport Expiry',
                                value: data.passportExpiry != null ? DateFormat('MMM d, yyyy').format(data.passportExpiry!) : 'Dec 31, 2030',
                              ),
                            ],
                          ),
                        ),
                  const SizedBox(height: 20),

                  _SectionHeader(
                    title: AppLocalizations.of(context)?.phoneNumberLabel ?? 'Phone',
                    icon: Icons.phone,
                    iconColor: AppColors.success,
                    onEdit: () => setState(() => _editingPhone = !_editingPhone),
                    isEditing: _editingPhone,
                  ),
                  const SizedBox(height: 10),
                  _editingPhone
                      ? _buildPhoneEditForm(data, notifier)
                      : SafetyCard(
                          child: _InfoRow(
                            label: AppLocalizations.of(context)?.phoneNumberLabel ?? 'Phone',
                            value: data.phoneNumber.isNotEmpty ? '+${data.phoneCode} ${data.phoneNumber}' : 'Not set',
                          ),
                        ),
                  const SizedBox(height: 20),

                  _SectionHeader(
                    title: AppLocalizations.of(context)?.travelTimeline ?? 'Travel Details',
                    icon: Icons.flight,
                    iconColor: AppColors.accentBlue,
                    onEdit: () => setState(() => _editingTravel = !_editingTravel),
                    isEditing: _editingTravel,
                  ),
                  const SizedBox(height: 10),
                  _editingTravel
                      ? _buildTravelEditForm(data, notifier)
                      : SafetyCard(
                          child: Column(
                            children: [
                              _InfoRow(
                                label: AppLocalizations.of(context)?.arrivalDate ?? 'Arrival',
                                value: data.arrivalDate != null ? DateFormat('MMM d, yyyy').format(data.arrivalDate!) : 'Mar 5, 2026',
                              ),
                              const Divider(color: AppColors.border, height: 1),
                              _InfoRow(
                                label: AppLocalizations.of(context)?.departureDate ?? 'Departure',
                                value: data.departureDate != null ? DateFormat('MMM d, yyyy').format(data.departureDate!) : 'Mar 15, 2026',
                              ),
                              const Divider(color: AppColors.border, height: 1),
                              _InfoRow(label: AppLocalizations.of(context)?.purposeOfVisit ?? 'Purpose', value: data.purposeOfVisit ?? 'Tourism'),
                              const Divider(color: AppColors.border, height: 1),
                              _InfoRow(
                                label: AppLocalizations.of(context)?.placesToVisit ?? 'Places',
                                value: data.placesToVisit.isNotEmpty ? data.placesToVisit : 'Gateway of India, Marine Drive',
                              ),
                            ],
                          ),
                        ),
                  const SizedBox(height: 20),

                  _SectionHeader(
                    title: AppLocalizations.of(context)?.yourEmergencyContacts ?? 'Emergency Contacts',
                    icon: Icons.contact_phone,
                    iconColor: AppColors.alertRed,
                    onEdit: () => setState(() => _editingEmergency = !_editingEmergency),
                    isEditing: _editingEmergency,
                  ),
                  const SizedBox(height: 10),
                  _editingEmergency
                      ? _buildEmergencyEditForm(data, notifier)
                      : SafetyCard(
                          child: Column(
                            children: [
                              _InfoRow(
                                label: AppLocalizations.of(context)?.contact1 ?? 'Contact 1',
                                value: data.contact1Name.isNotEmpty ? '${data.contact1Name} (${data.contact1Relationship ?? "Family"})' : 'Jane Doe (Family)',
                              ),
                              const Divider(color: AppColors.border, height: 1),
                              _InfoRow(label: AppLocalizations.of(context)?.phoneNumberLabel ?? 'Phone', value: data.contact1Phone.isNotEmpty ? data.contact1Phone : '+91 1234567890'),
                              const Divider(color: AppColors.border, height: 1),
                              _InfoRow(
                                label: AppLocalizations.of(context)?.contact2 ?? 'Contact 2',
                                value: data.contact2Name.isNotEmpty ? '${data.contact2Name} (${data.contact2Relationship ?? "Friend"})' : 'Bob Smith (Friend)',
                              ),
                              const Divider(color: AppColors.border, height: 1),
                              _InfoRow(label: AppLocalizations.of(context)?.phoneNumberLabel ?? 'Phone', value: data.contact2Phone.isNotEmpty ? data.contact2Phone : '+91 0987654321'),
                            ],
                          ),
                        ),
                  const SizedBox(height: 20),

                  _SectionHeader(
                    title: AppLocalizations.of(context)?.stayDetailsTitle ?? 'Stay Details',
                    icon: Icons.hotel,
                    iconColor: AppColors.accentBlue,
                    onEdit: () => setState(() => _editingStay = !_editingStay),
                    isEditing: _editingStay,
                  ),
                  const SizedBox(height: 10),
                  _editingStay
                      ? _buildStayEditForm(data, notifier)
                      : SafetyCard(
                          child: Column(
                            children: [
                              _InfoRow(label: AppLocalizations.of(context)?.accommodationType ?? 'Type', value: data.accommodationType ?? 'Hotel'),
                              const Divider(color: AppColors.border, height: 1),
                              _InfoRow(label: AppLocalizations.of(context)?.propertyName ?? 'Property', value: data.propertyName.isNotEmpty ? data.propertyName : 'Taj Lands End'),
                              const Divider(color: AppColors.border, height: 1),
                              _InfoRow(
                                label: AppLocalizations.of(context)?.fullAddress ?? 'Address',
                                value: data.fullAddress.isNotEmpty ? data.fullAddress : 'Byramji Jeejeebhoy Rd, Bandra West',
                              ),
                              const Divider(color: AppColors.border, height: 1),
                              _InfoRow(label: AppLocalizations.of(context)?.roomUnit ?? 'Room', value: data.roomNumber.isNotEmpty ? data.roomNumber : '402'),
                            ],
                          ),
                        ),
                  const SizedBox(height: 20),

                  _SectionHeader(
                    title: AppLocalizations.of(context)?.medicalSafety ?? 'Medical Info',
                    icon: Icons.medical_services,
                    iconColor: const Color(0xFFFF6B9D),
                    onEdit: () => setState(() => _editingMedical = !_editingMedical),
                    isEditing: _editingMedical,
                  ),
                  const SizedBox(height: 10),
                  _editingMedical
                      ? _buildMedicalEditForm(data, notifier)
                      : SafetyCard(
                          child: Column(
                            children: [
                              _InfoRow(label: AppLocalizations.of(context)?.bloodType ?? 'Blood Type', value: data.bloodType ?? 'O+'),
                              const Divider(color: AppColors.border, height: 1),
                              _InfoRow(label: AppLocalizations.of(context)?.allergiesLabel ?? 'Allergies', value: data.hasAllergies ? data.allergyDetails : 'None'),
                              const Divider(color: AppColors.border, height: 1),
                              _InfoRow(label: AppLocalizations.of(context)?.conditionsLabel ?? 'Conditions', value: data.hasChronicConditions ? data.conditionDetails : 'None'),
                              const Divider(color: AppColors.border, height: 1),
                              _InfoRow(label: AppLocalizations.of(context)?.medicationsLabel ?? 'Medications', value: data.takesRegularMedication ? data.medicationDetails : 'None'),
                              const Divider(color: AppColors.border, height: 1),
                              _InfoRow(
                                label: AppLocalizations.of(context)?.insurancePolicy ?? 'Insurance',
                                value: data.insurancePolicyNumber.isNotEmpty ? data.insurancePolicyNumber : 'POL-IN-29384',
                              ),
                            ],
                          ),
                        ),

                  const SizedBox(height: 32),

                  // Police / Security Dashboard shortcut
                  GestureDetector(
                    onTap: () => context.push('/police-dashboard'),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.accentBlue.withValues(alpha: 0.12),
                            ),
                            child: const Icon(Icons.shield_outlined, color: AppColors.accentBlue, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Security Dashboard',
                                  style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  'Police & safety management portal',
                                  style: AppTypography.caption.copyWith(fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Digital ID shortcut
                  GestureDetector(
                    onTap: () => context.push('/digital-id'),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppColors.accentBlue.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.accentBlue.withValues(alpha: 0.12),
                            ),
                            child: const Icon(Icons.verified_user_outlined,
                                color: AppColors.accentBlue, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Digital Travel ID',
                                    style: AppTypography.body.copyWith(
                                        fontWeight: FontWeight.w600)),
                                Text('Blockchain-issued credential & QR',
                                    style: AppTypography.caption
                                        .copyWith(fontSize: 11)),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right,
                              color: AppColors.textSecondary, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Account actions
                  SafetyButton(
                    text: AppLocalizations.of(context)?.signOutBtn ?? 'Sign Out',
                    icon: Icons.logout,
                    variant: SafetyButtonVariant.outlined,
                    onPressed: () async {
                      try {
                        await ref.read(apiClientProvider).logout();
                      } catch (_) {}
                      if (context.mounted) context.go('/splash');
                    },
                  ),
                  const SizedBox(height: 12),
                  SafetyButton(
                    text: AppLocalizations.of(context)?.deleteAccBtn ?? 'Delete Account',
                    icon: Icons.delete_forever,
                    variant: SafetyButtonVariant.danger,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: AppColors.card,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: AppColors.border),
                          ),
                          title: Text(AppLocalizations.of(context)?.deleteAccBtn ?? 'Delete Account', style: AppTypography.h2),
                          content: Text(
                            'Are you sure you want to permanently delete your account? This action cannot be undone.',
                            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Cancel', style: AppTypography.body.copyWith(color: AppColors.accentBlue, fontWeight: FontWeight.w600)),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                try {
                                  await ref.read(apiClientProvider).logout();
                                } catch (_) {}
                                if (context.mounted) context.go('/splash');
                              },
                              child: Text('Delete', style: AppTypography.body.copyWith(color: AppColors.alertRed, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(OnboardingData data) {
    final f = data.firstName.isNotEmpty ? data.firstName[0] : 'J';
    final l = data.lastName.isNotEmpty ? data.lastName[0] : 'D';
    return '$f$l'.toUpperCase();
  }

  Widget _buildIdentityEditForm(OnboardingData data, OnboardingNotifier notifier) {
    return SafetyCard(
      child: Column(
        children: [
          InputField(
            label: AppLocalizations.of(context)?.firstName ?? 'First Name',
            controller: TextEditingController(text: data.firstName.isNotEmpty ? data.firstName : ''),
            onChanged: (val) => notifier.setFirstName(val),
          ),
          const SizedBox(height: 12),
          InputField(
            label: AppLocalizations.of(context)?.lastName ?? 'Last Name',
            controller: TextEditingController(text: data.lastName.isNotEmpty ? data.lastName : ''),
            onChanged: (val) => notifier.setLastName(val),
          ),
          const SizedBox(height: 12),
          DateCard(
            label: AppLocalizations.of(context)?.dob ?? 'Date of Birth',
            selectedDate: data.dateOfBirth,
            onDateSelected: (date) => notifier.setDateOfBirth(date),
            lastDate: DateTime.now(),
          ),
          const SizedBox(height: 12),
          CountrySelect(
            label: AppLocalizations.of(context)?.nationality ?? 'Nationality',
            selectedCountry: data.nationality,
            onSelect: (country) => notifier.setNationality(country),
          ),
          const SizedBox(height: 12),
          InputField(
            label: AppLocalizations.of(context)?.passportNum ?? 'Passport/ID Number',
            controller: TextEditingController(text: data.passportNumber.isNotEmpty ? data.passportNumber : ''),
            onChanged: (val) => notifier.setPassportNumber(val),
          ),
          const SizedBox(height: 12),
          DateCard(
            label: AppLocalizations.of(context)?.passportExpiry ?? 'Passport Expiry Date',
            selectedDate: data.passportExpiry,
            onDateSelected: (date) => notifier.setPassportExpiry(date),
            firstDate: DateTime.now(),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneEditForm(OnboardingData data, OnboardingNotifier notifier) {
    return SafetyCard(
      child: PhoneInput(
        label: AppLocalizations.of(context)?.phoneNumberLabel ?? 'Phone Number',
        controller: TextEditingController(text: data.phoneNumber.isNotEmpty ? data.phoneNumber : ''),
        onChanged: (val) => notifier.setPhoneNumber(val),
        onCountryChanged: (country) => notifier.setPhoneCode(country.phoneCode),
      ),
    );
  }

  Widget _buildTravelEditForm(OnboardingData data, OnboardingNotifier notifier) {
    return SafetyCard(
      child: Column(
        children: [
          _EditableDateRow(
            label: AppLocalizations.of(context)?.arrivalDate ?? 'Arrival Date',
            date: data.arrivalDate,
            fallback: 'Mar 5, 2026',
            onPicked: (d) => notifier.setArrivalDate(d),
          ),
          const SizedBox(height: 12),
          _EditableDateRow(
            label: AppLocalizations.of(context)?.departureDate ?? 'Departure Date',
            date: data.departureDate,
            fallback: 'Mar 15, 2026',
            onPicked: (d) => notifier.setDepartureDate(d),
          ),
          const SizedBox(height: 12),
          AppDropdown(
            label: AppLocalizations.of(context)?.purposeOfVisit ?? 'Purpose of Visit',
            selectedValue: data.purposeOfVisit ?? 'Tourism',
            items: const ['Tourism', 'Business', 'Education', 'Medical', 'Other'],
            onChanged: (val) => notifier.setPurposeOfVisit(val),
          ),
          const SizedBox(height: 12),
          InputField(
            label: AppLocalizations.of(context)?.placesToVisit ?? 'Places to Visit',
            controller: TextEditingController(text: data.placesToVisit.isNotEmpty ? data.placesToVisit : 'Gateway of India, Marine Drive'),
            maxLines: 2,
            onChanged: (val) => notifier.setPlacesToVisit(val),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyEditForm(OnboardingData data, OnboardingNotifier notifier) {
    return SafetyCard(
      child: Column(
        children: [
          InputField(
            label: AppLocalizations.of(context)?.fullName ?? 'Contact 1 Name',
            controller: TextEditingController(text: data.contact1Name.isNotEmpty ? data.contact1Name : 'Jane Doe'),
            onChanged: (val) => notifier.setContact1Name(val),
          ),
          const SizedBox(height: 12),
          InputField(
            label: AppLocalizations.of(context)?.phoneNumberLabel ?? 'Contact 1 Phone',
            controller: TextEditingController(text: data.contact1Phone.isNotEmpty ? data.contact1Phone : '+91 1234567890'),
            onChanged: (val) => notifier.setContact1Phone(val),
          ),
          const SizedBox(height: 12),
          InputField(
            label: AppLocalizations.of(context)?.fullName ?? 'Contact 2 Name',
            controller: TextEditingController(text: data.contact2Name.isNotEmpty ? data.contact2Name : 'Bob Smith'),
            onChanged: (val) => notifier.setContact2Name(val),
          ),
          const SizedBox(height: 12),
          InputField(
            label: AppLocalizations.of(context)?.phoneNumberLabel ?? 'Contact 2 Phone',
            controller: TextEditingController(text: data.contact2Phone.isNotEmpty ? data.contact2Phone : '+91 0987654321'),
            onChanged: (val) => notifier.setContact2Phone(val),
          ),
        ],
      ),
    );
  }

  Widget _buildStayEditForm(OnboardingData data, OnboardingNotifier notifier) {
    return SafetyCard(
      child: Column(
        children: [
          AppDropdown(
            label: AppLocalizations.of(context)?.accommodationType ?? 'Accommodation Type',
            selectedValue: data.accommodationType ?? 'Hotel',
            items: const ['Hotel', 'Hostel', 'Airbnb', 'Guest House', 'Relative\'s Home', 'Other'],
            onChanged: (val) => notifier.setAccommodationType(val),
          ),
          const SizedBox(height: 12),
          InputField(
            label: AppLocalizations.of(context)?.propertyName ?? 'Property Name',
            controller: TextEditingController(text: data.propertyName.isNotEmpty ? data.propertyName : 'Taj Lands End'),
            onChanged: (val) => notifier.setPropertyName(val),
          ),
          const SizedBox(height: 12),
          InputField(
            label: AppLocalizations.of(context)?.fullAddress ?? 'Full Address',
            controller: TextEditingController(text: data.fullAddress.isNotEmpty ? data.fullAddress : 'Byramji Jeejeebhoy Rd, Bandra West'),
            maxLines: 2,
            onChanged: (val) => notifier.setFullAddress(val),
          ),
          const SizedBox(height: 12),
          InputField(
            label: AppLocalizations.of(context)?.roomUnit ?? 'Room / Unit',
            controller: TextEditingController(text: data.roomNumber.isNotEmpty ? data.roomNumber : '402'),
            onChanged: (val) => notifier.setRoomNumber(val),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalEditForm(OnboardingData data, OnboardingNotifier notifier) {
    return SafetyCard(
      child: Column(
        children: [
          AppDropdown(
            label: AppLocalizations.of(context)?.bloodType ?? 'Blood Type',
            selectedValue: data.bloodType ?? 'O+',
            items: const ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
            onChanged: (val) => notifier.setBloodType(val),
          ),
          const SizedBox(height: 12),
          InputField(
            label: AppLocalizations.of(context)?.allergiesLabel ?? 'Allergies',
            controller: TextEditingController(text: data.hasAllergies ? data.allergyDetails : ''),
            onChanged: (val) {
              notifier.setHasAllergies(val.isNotEmpty);
              notifier.setAllergyDetails(val);
            },
          ),
          const SizedBox(height: 12),
          InputField(
            label: AppLocalizations.of(context)?.conditionsLabel ?? 'Chronic Conditions',
            controller: TextEditingController(text: data.hasChronicConditions ? data.conditionDetails : ''),
            onChanged: (val) {
              notifier.setHasChronicConditions(val.isNotEmpty);
              notifier.setConditionDetails(val);
            },
          ),
          const SizedBox(height: 12),
          InputField(
            label: AppLocalizations.of(context)?.medicationsLabel ?? 'Regular Medications',
            controller: TextEditingController(text: data.takesRegularMedication ? data.medicationDetails : ''),
            onChanged: (val) {
              notifier.setTakesRegularMedication(val.isNotEmpty);
              notifier.setMedicationDetails(val);
            },
          ),
          const SizedBox(height: 12),
          InputField(
            label: AppLocalizations.of(context)?.insurancePolicy ?? 'Insurance Policy Number',
            controller: TextEditingController(text: data.insurancePolicyNumber.isNotEmpty ? data.insurancePolicyNumber : 'POL-IN-29384'),
            onChanged: (val) => notifier.setInsurancePolicyNumber(val),
          ),
        ],
      ),
    );
  }
}

// ─── Section Header ───
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onEdit;
  final bool isEditing;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.iconColor,
    this.onEdit,
    this.isEditing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: iconColor.withValues(alpha: 0.12),
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 10),
        Text(title, style: AppTypography.body.copyWith(fontWeight: FontWeight.w700, fontSize: 15)),
        const Spacer(),
        if (onEdit != null)
          GestureDetector(
            onTap: onEdit,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isEditing
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.accentBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isEditing ? Icons.check : Icons.edit,
                    color: isEditing ? AppColors.success : AppColors.accentBlue,
                    size: 13,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isEditing ? 'Done' : 'Edit',
                    style: AppTypography.caption.copyWith(
                      fontSize: 12,
                      color: isEditing ? AppColors.success : AppColors.accentBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Info Row (Read-Only) ───
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: AppTypography.caption.copyWith(fontSize: 12)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(value, style: AppTypography.body.copyWith(fontSize: 14, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

// ─── Editable Date Row ───
class _EditableDateRow extends StatelessWidget {
  final String label;
  final DateTime? date;
  final String fallback;
  final ValueChanged<DateTime> onPicked;

  const _EditableDateRow({
    required this.label,
    this.date,
    required this.fallback,
    required this.onPicked,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) onPicked(picked);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: AppColors.textSecondary, size: 18),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.caption.copyWith(fontSize: 11)),
                const SizedBox(height: 2),
                Text(
                  date != null ? DateFormat('MMM d, yyyy').format(date!) : fallback,
                  style: AppTypography.body.copyWith(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
