import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/widgets/safety_card.dart';
import '../core/widgets/input_field.dart';
import '../core/widgets/dropdown.dart';
import '../providers/onboarding_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
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
      appBar: AppBar(
        title: Text('My Profile', style: AppTypography.h2),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Avatar & Name Header
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.accentBlue,
                          AppColors.accentBlue.withValues(alpha: 0.6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _getInitials(data),
                        style: AppTypography.h1.copyWith(
                          color: Colors.white,
                          fontSize: 28,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${data.firstName.isNotEmpty ? data.firstName : "John"} ${data.lastName.isNotEmpty ? data.lastName : "Doe"}',
                    style: AppTypography.h2.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.nationality?.name ?? 'India',
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ─── SECTION 1: PERSONAL IDENTITY (Read-Only) ───
            _SectionHeader(
              title: 'Personal Identity',
              icon: Icons.person,
              locked: true,
            ),
            const SizedBox(height: 12),
            SafetyCard(
              child: Column(
                children: [
                  _InfoRow(label: 'First Name', value: data.firstName.isNotEmpty ? data.firstName : 'John'),
                  const Divider(color: AppColors.border, height: 1),
                  _InfoRow(label: 'Last Name', value: data.lastName.isNotEmpty ? data.lastName : 'Doe'),
                  const Divider(color: AppColors.border, height: 1),
                  _InfoRow(
                    label: 'Date of Birth',
                    value: data.dateOfBirth != null
                        ? DateFormat('MMM d, yyyy').format(data.dateOfBirth!)
                        : 'Jan 15, 1990',
                  ),
                  const Divider(color: AppColors.border, height: 1),
                  _InfoRow(label: 'Nationality', value: data.nationality?.name ?? 'India'),
                  const Divider(color: AppColors.border, height: 1),
                  _InfoRow(
                    label: 'Passport No.',
                    value: data.passportNumber.isNotEmpty ? data.passportNumber : 'A1234567',
                  ),
                  const Divider(color: AppColors.border, height: 1),
                  _InfoRow(
                    label: 'Passport Expiry',
                    value: data.passportExpiry != null
                        ? DateFormat('MMM d, yyyy').format(data.passportExpiry!)
                        : 'Dec 31, 2030',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.lock, color: AppColors.textSecondary, size: 14),
                const SizedBox(width: 6),
                Text(
                  'Contact support to update identity details.',
                  style: AppTypography.caption.copyWith(fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ─── SECTION 2: PHONE ───
            _SectionHeader(title: 'Phone', icon: Icons.phone, locked: true),
            const SizedBox(height: 12),
            SafetyCard(
              child: _InfoRow(
                label: 'Phone',
                value: data.phoneNumber.isNotEmpty
                    ? '+${data.phoneCode} ${data.phoneNumber}'
                    : '+91 9876543210',
              ),
            ),
            const SizedBox(height: 24),

            // ─── SECTION 3: TRAVEL DETAILS (Editable) ───
            _SectionHeader(
              title: 'Travel Details',
              icon: Icons.flight,
              onEdit: () => setState(() => _editingTravel = !_editingTravel),
              isEditing: _editingTravel,
            ),
            const SizedBox(height: 12),
            _editingTravel
                ? _buildTravelEditForm(data, notifier)
                : SafetyCard(
                    child: Column(
                      children: [
                        _InfoRow(
                          label: 'Arrival',
                          value: data.arrivalDate != null
                              ? DateFormat('MMM d, yyyy').format(data.arrivalDate!)
                              : 'Mar 5, 2026',
                        ),
                        const Divider(color: AppColors.border, height: 1),
                        _InfoRow(
                          label: 'Departure',
                          value: data.departureDate != null
                              ? DateFormat('MMM d, yyyy').format(data.departureDate!)
                              : 'Mar 15, 2026',
                        ),
                        const Divider(color: AppColors.border, height: 1),
                        _InfoRow(label: 'Purpose', value: data.purposeOfVisit ?? 'Tourism'),
                        const Divider(color: AppColors.border, height: 1),
                        _InfoRow(
                          label: 'Places',
                          value: data.placesToVisit.isNotEmpty
                              ? data.placesToVisit
                              : 'Gateway of India, Marine Drive',
                        ),
                      ],
                    ),
                  ),
            const SizedBox(height: 24),

            // ─── SECTION 4: EMERGENCY CONTACTS (Editable) ───
            _SectionHeader(
              title: 'Emergency Contacts',
              icon: Icons.contact_phone,
              onEdit: () => setState(() => _editingEmergency = !_editingEmergency),
              isEditing: _editingEmergency,
            ),
            const SizedBox(height: 12),
            _editingEmergency
                ? _buildEmergencyEditForm(data, notifier)
                : SafetyCard(
                    child: Column(
                      children: [
                        _InfoRow(
                          label: 'Contact 1',
                          value: data.contact1Name.isNotEmpty
                              ? '${data.contact1Name} (${data.contact1Relationship ?? "Family"})'
                              : 'Jane Doe (Family)',
                        ),
                        const Divider(color: AppColors.border, height: 1),
                        _InfoRow(
                          label: 'Phone',
                          value: data.contact1Phone.isNotEmpty ? data.contact1Phone : '+91 1234567890',
                        ),
                        const Divider(color: AppColors.border, height: 1),
                        _InfoRow(
                          label: 'Contact 2',
                          value: data.contact2Name.isNotEmpty
                              ? '${data.contact2Name} (${data.contact2Relationship ?? "Friend"})'
                              : 'Bob Smith (Friend)',
                        ),
                        const Divider(color: AppColors.border, height: 1),
                        _InfoRow(
                          label: 'Phone',
                          value: data.contact2Phone.isNotEmpty ? data.contact2Phone : '+91 0987654321',
                        ),
                      ],
                    ),
                  ),
            const SizedBox(height: 24),

            // ─── SECTION 5: STAY DETAILS (Editable) ───
            _SectionHeader(
              title: 'Stay Details',
              icon: Icons.hotel,
              onEdit: () => setState(() => _editingStay = !_editingStay),
              isEditing: _editingStay,
            ),
            const SizedBox(height: 12),
            _editingStay
                ? _buildStayEditForm(data, notifier)
                : SafetyCard(
                    child: Column(
                      children: [
                        _InfoRow(label: 'Type', value: data.accommodationType ?? 'Hotel'),
                        const Divider(color: AppColors.border, height: 1),
                        _InfoRow(
                          label: 'Property',
                          value: data.propertyName.isNotEmpty ? data.propertyName : 'Taj Lands End',
                        ),
                        const Divider(color: AppColors.border, height: 1),
                        _InfoRow(
                          label: 'Address',
                          value: data.fullAddress.isNotEmpty
                              ? data.fullAddress
                              : 'Byramji Jeejeebhoy Rd, Bandra West',
                        ),
                        const Divider(color: AppColors.border, height: 1),
                        _InfoRow(
                          label: 'Room',
                          value: data.roomNumber.isNotEmpty ? data.roomNumber : '402',
                        ),
                      ],
                    ),
                  ),
            const SizedBox(height: 24),

            // ─── SECTION 6: MEDICAL INFO (Editable) ───
            _SectionHeader(
              title: 'Medical Info',
              icon: Icons.medical_services,
              onEdit: () => setState(() => _editingMedical = !_editingMedical),
              isEditing: _editingMedical,
            ),
            const SizedBox(height: 12),
            _editingMedical
                ? _buildMedicalEditForm(data, notifier)
                : SafetyCard(
                    child: Column(
                      children: [
                        _InfoRow(label: 'Blood Type', value: data.bloodType ?? 'O+'),
                        const Divider(color: AppColors.border, height: 1),
                        _InfoRow(label: 'Allergies', value: data.hasAllergies ? data.allergyDetails : 'None'),
                        const Divider(color: AppColors.border, height: 1),
                        _InfoRow(
                          label: 'Conditions',
                          value: data.hasChronicConditions ? data.conditionDetails : 'None',
                        ),
                        const Divider(color: AppColors.border, height: 1),
                        _InfoRow(
                          label: 'Medications',
                          value: data.takesRegularMedication ? data.medicationDetails : 'None',
                        ),
                        const Divider(color: AppColors.border, height: 1),
                        _InfoRow(
                          label: 'Insurance',
                          value: data.insurancePolicyNumber.isNotEmpty
                              ? data.insurancePolicyNumber
                              : 'POL-IN-29384',
                        ),
                      ],
                    ),
                  ),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  String _getInitials(OnboardingData data) {
    final f = data.firstName.isNotEmpty ? data.firstName[0] : 'J';
    final l = data.lastName.isNotEmpty ? data.lastName[0] : 'D';
    return '$f$l'.toUpperCase();
  }

  // ─── EDIT FORMS ───

  Widget _buildTravelEditForm(OnboardingData data, OnboardingNotifier notifier) {
    return SafetyCard(
      child: Column(
        children: [
          _EditableDateRow(
            label: 'Arrival Date',
            date: data.arrivalDate,
            fallback: 'Mar 5, 2026',
            onPicked: (d) => notifier.setArrivalDate(d),
          ),
          const SizedBox(height: 12),
          _EditableDateRow(
            label: 'Departure Date',
            date: data.departureDate,
            fallback: 'Mar 15, 2026',
            onPicked: (d) => notifier.setDepartureDate(d),
          ),
          const SizedBox(height: 12),
          AppDropdown(
            label: 'Purpose of Visit',
            selectedValue: data.purposeOfVisit ?? 'Tourism',
            items: const ['Tourism', 'Business', 'Education', 'Medical', 'Other'],
            onChanged: (val) => notifier.setPurposeOfVisit(val),
          ),
          const SizedBox(height: 12),
          InputField(
            label: 'Places to Visit',
            controller: TextEditingController(
              text: data.placesToVisit.isNotEmpty ? data.placesToVisit : 'Gateway of India, Marine Drive',
            ),
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
            label: 'Contact 1 Name',
            controller: TextEditingController(
              text: data.contact1Name.isNotEmpty ? data.contact1Name : 'Jane Doe',
            ),
            onChanged: (val) => notifier.setContact1Name(val),
          ),
          const SizedBox(height: 12),
          InputField(
            label: 'Contact 1 Phone',
            controller: TextEditingController(
              text: data.contact1Phone.isNotEmpty ? data.contact1Phone : '+91 1234567890',
            ),
            onChanged: (val) => notifier.setContact1Phone(val),
          ),
          const SizedBox(height: 12),
          InputField(
            label: 'Contact 2 Name',
            controller: TextEditingController(
              text: data.contact2Name.isNotEmpty ? data.contact2Name : 'Bob Smith',
            ),
            onChanged: (val) => notifier.setContact2Name(val),
          ),
          const SizedBox(height: 12),
          InputField(
            label: 'Contact 2 Phone',
            controller: TextEditingController(
              text: data.contact2Phone.isNotEmpty ? data.contact2Phone : '+91 0987654321',
            ),
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
            label: 'Accommodation Type',
            selectedValue: data.accommodationType ?? 'Hotel',
            items: const ['Hotel', 'Hostel', 'Airbnb', 'Guest House', 'Relative\'s Home', 'Other'],
            onChanged: (val) => notifier.setAccommodationType(val),
          ),
          const SizedBox(height: 12),
          InputField(
            label: 'Property Name',
            controller: TextEditingController(
              text: data.propertyName.isNotEmpty ? data.propertyName : 'Taj Lands End',
            ),
            onChanged: (val) => notifier.setPropertyName(val),
          ),
          const SizedBox(height: 12),
          InputField(
            label: 'Full Address',
            controller: TextEditingController(
              text: data.fullAddress.isNotEmpty ? data.fullAddress : 'Byramji Jeejeebhoy Rd, Bandra West',
            ),
            maxLines: 2,
            onChanged: (val) => notifier.setFullAddress(val),
          ),
          const SizedBox(height: 12),
          InputField(
            label: 'Room / Unit',
            controller: TextEditingController(
              text: data.roomNumber.isNotEmpty ? data.roomNumber : '402',
            ),
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
            label: 'Blood Type',
            selectedValue: data.bloodType ?? 'O+',
            items: const ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
            onChanged: (val) => notifier.setBloodType(val),
          ),
          const SizedBox(height: 12),
          InputField(
            label: 'Allergies',
            controller: TextEditingController(
              text: data.hasAllergies ? data.allergyDetails : '',
            ),
            onChanged: (val) {
              notifier.setHasAllergies(val.isNotEmpty);
              notifier.setAllergyDetails(val);
            },
          ),
          const SizedBox(height: 12),
          InputField(
            label: 'Chronic Conditions',
            controller: TextEditingController(
              text: data.hasChronicConditions ? data.conditionDetails : '',
            ),
            onChanged: (val) {
              notifier.setHasChronicConditions(val.isNotEmpty);
              notifier.setConditionDetails(val);
            },
          ),
          const SizedBox(height: 12),
          InputField(
            label: 'Regular Medications',
            controller: TextEditingController(
              text: data.takesRegularMedication ? data.medicationDetails : '',
            ),
            onChanged: (val) {
              notifier.setTakesRegularMedication(val.isNotEmpty);
              notifier.setMedicationDetails(val);
            },
          ),
          const SizedBox(height: 12),
          InputField(
            label: 'Insurance Policy Number',
            controller: TextEditingController(
              text: data.insurancePolicyNumber.isNotEmpty ? data.insurancePolicyNumber : 'POL-IN-29384',
            ),
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
  final bool locked;
  final VoidCallback? onEdit;
  final bool isEditing;

  const _SectionHeader({
    required this.title,
    required this.icon,
    this.locked = false,
    this.onEdit,
    this.isEditing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.accentBlue, size: 20),
        const SizedBox(width: 8),
        Text(title, style: AppTypography.body.copyWith(fontWeight: FontWeight.w600, fontSize: 16)),
        const Spacer(),
        if (locked)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock, color: AppColors.textSecondary, size: 12),
                const SizedBox(width: 4),
                Text('Locked', style: AppTypography.caption.copyWith(fontSize: 11)),
              ],
            ),
          ),
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
                    size: 14,
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
            child: Text(
              label,
              style: AppTypography.caption.copyWith(fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: AppTypography.body.copyWith(fontSize: 14),
            ),
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
