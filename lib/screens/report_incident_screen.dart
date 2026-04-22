import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/widgets/safety_button.dart';
import '../core/widgets/safety_card.dart';
import '../core/widgets/input_field.dart';
import '../l10n/app_localizations.dart';
import '../services/firestore_service.dart';
import '../models/firestore_models.dart';
import '../providers/location_provider.dart';

class ReportIncidentScreen extends ConsumerStatefulWidget {
  const ReportIncidentScreen({super.key});

  @override
  ConsumerState<ReportIncidentScreen> createState() => _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends ConsumerState<ReportIncidentScreen> {
  final _descController = TextEditingController();
  final FirestoreService _firestore = FirestoreService();
  String? _selectedIncidentType;

  List<_IncidentTypeItem> get _incidentTypes => [
    _IncidentTypeItem(Icons.shopping_bag_outlined, AppLocalizations.of(context)?.incidentTheft ?? 'Theft / Pickpocketing', AppColors.warning),
    _IncidentTypeItem(Icons.medical_services_outlined, AppLocalizations.of(context)?.incidentMedical ?? 'Medical Emergency', const Color(0xFFFF6B9D)),
    _IncidentTypeItem(Icons.person_off_outlined, AppLocalizations.of(context)?.incidentAssault ?? 'Harassment / Assault', AppColors.alertRed),
    _IncidentTypeItem(Icons.search, AppLocalizations.of(context)?.incidentLostItem ?? 'Lost Item', AppColors.accentBlue),
    _IncidentTypeItem(Icons.visibility_outlined, AppLocalizations.of(context)?.incidentSuspicious ?? 'Suspicious Activity', AppColors.warning),
    _IncidentTypeItem(Icons.car_crash_outlined, AppLocalizations.of(context)?.incidentAccident ?? 'Accident / Collision', AppColors.alertRed),
    _IncidentTypeItem(Icons.more_horiz, AppLocalizations.of(context)?.incidentOther ?? 'Other', AppColors.textSecondary),
  ];

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isRecording = false;
  XFile? _attachedMedia;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickMedia() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.textPrimary),
              title: Text(AppLocalizations.of(context)?.takePhoto ?? 'Take a photo', style: AppTypography.body),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.textPrimary),
              title: Text(AppLocalizations.of(context)?.chooseGallery ?? 'Choose from gallery', style: AppTypography.body),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source != null) {
      final file = await _picker.pickImage(source: source);
      if (file != null) setState(() => _attachedMedia = file);
    }
  }

  void _submitReport() {
    if (_selectedIncidentType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)?.errorSelectIncidentType ?? 'Please select an incident type.', style: AppTypography.caption),
          backgroundColor: AppColors.alertRed,
        ),
      );
      return;
    }
    final locationState = ref.read(locationProvider);
    final incident = IncidentReport(
      id: '',
      type: _selectedIncidentType!,
      description: _descController.text.trim(),
      latitude: locationState.currentPosition.latitude,
      longitude: locationState.currentPosition.longitude,
      address: locationState.currentAddress,
      reportedAt: DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day,
        _selectedTime.hour, _selectedTime.minute,
      ),
    );
    _firestore.submitIncident(incident);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.success.withValues(alpha: 0.15),
              ),
              child: const Icon(Icons.check, color: AppColors.success, size: 34),
            ),
            const SizedBox(height: 20),
            Text(AppLocalizations.of(context)?.reportSubmittedTitle ?? 'Report Submitted',
                style: AppTypography.h2, textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text(
              AppLocalizations.of(context)?.reportSubmittedMessage ??
                  'Your report has been securely submitted to the local authorities.',
              style: AppTypography.body.copyWith(color: AppColors.textSecondary, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SafetyButton(
              text: AppLocalizations.of(context)?.returnToHome ?? 'Return to Home',
              onPressed: () {
                Navigator.pop(context);
                context.go('/home');
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);
    final locationText = locationState.currentAddress.isNotEmpty
        ? locationState.currentAddress
        : '16th Road, Bandra West';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
          Container(
            color: AppColors.background,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accentBlue.withValues(alpha: 0.15),
                      ),
                      child: const Icon(Icons.report_problem_outlined, color: AppColors.accentBlue, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      AppLocalizations.of(context)?.reportIncidentTitle ?? 'Report Incident',
                      style: AppTypography.h2,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info banner
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.accentBlue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.accentBlue.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: AppColors.accentBlue, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Your report will be sent securely to local authorities.',
                            style: AppTypography.caption.copyWith(color: AppColors.accentBlue),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Incident type grid
                  Text(
                    AppLocalizations.of(context)?.incidentTypeLabel ?? 'Incident Type',
                    style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 2.8,
                    children: _incidentTypes.map((item) {
                      final isSelected = _selectedIncidentType == item.label;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedIncidentType = item.label),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? item.color.withValues(alpha: 0.12) : AppColors.card,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? item.color : AppColors.border,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(item.icon, color: isSelected ? item.color : AppColors.textSecondary, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.label,
                                  style: AppTypography.caption.copyWith(
                                    color: isSelected ? item.color : AppColors.textSecondary,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    fontSize: 11,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Date and Time
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppLocalizations.of(context)?.dateLabel ?? 'Date', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedDate,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime.now(),
                                );
                                if (date != null) setState(() => _selectedDate = date);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                decoration: BoxDecoration(
                                  color: AppColors.card,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_today, color: AppColors.textSecondary, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        DateFormat('MMM d, yyyy').format(_selectedDate),
                                        style: AppTypography.body.copyWith(fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppLocalizations.of(context)?.timeLabel ?? 'Time', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: _selectedTime,
                                );
                                if (time != null) setState(() => _selectedTime = time);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                decoration: BoxDecoration(
                                  color: AppColors.card,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.access_time, color: AppColors.textSecondary, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _selectedTime.format(context),
                                        style: AppTypography.body.copyWith(fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Location
                  Text(AppLocalizations.of(context)?.sosLocationLabel ?? 'Location', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  SafetyCard(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.accentBlue.withValues(alpha: 0.15),
                          ),
                          child: const Icon(Icons.my_location, color: AppColors.accentBlue, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)?.currentGpsLocation ?? 'Current GPS Location',
                                style: AppTypography.body.copyWith(fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                              const SizedBox(height: 2),
                              Text(locationText, style: AppTypography.caption.copyWith(fontSize: 12)),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push('/map'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            minimumSize: Size.zero,
                          ),
                          child: Text(
                            AppLocalizations.of(context)?.mapViewButton ?? 'Map',
                            style: AppTypography.caption.copyWith(color: AppColors.accentBlue, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Description
                  InputField(
                    label: AppLocalizations.of(context)?.descriptionLabel ?? 'Description',
                    controller: _descController,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 20),

                  // Attachments
                  Text(AppLocalizations.of(context)?.attachmentsLabel ?? 'Attachments', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isRecording = !_isRecording),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            height: 56,
                            decoration: BoxDecoration(
                              color: _isRecording ? AppColors.alertRed.withValues(alpha: 0.1) : AppColors.card,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _isRecording ? AppColors.alertRed : AppColors.border,
                                width: _isRecording ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _isRecording ? Icons.stop_circle : Icons.mic,
                                  color: _isRecording ? AppColors.alertRed : AppColors.accentBlue,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _isRecording
                                      ? (AppLocalizations.of(context)?.recordingAudio ?? 'Recording...')
                                      : (AppLocalizations.of(context)?.voiceNote ?? 'Voice Note'),
                                  style: AppTypography.body.copyWith(
                                    color: _isRecording ? AppColors.alertRed : AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: _pickMedia,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            height: 56,
                            decoration: BoxDecoration(
                              color: _attachedMedia != null ? AppColors.success.withValues(alpha: 0.1) : AppColors.card,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _attachedMedia != null ? AppColors.success : AppColors.border,
                                width: _attachedMedia != null ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _attachedMedia != null ? Icons.check_circle : Icons.camera_alt,
                                  color: _attachedMedia != null ? AppColors.success : AppColors.accentBlue,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _attachedMedia != null
                                      ? (AppLocalizations.of(context)?.mediaAdded ?? 'Media Added')
                                      : (AppLocalizations.of(context)?.addMedia ?? 'Add Media'),
                                  style: AppTypography.body.copyWith(
                                    color: _attachedMedia != null ? AppColors.success : AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  SafetyButton(
                    text: AppLocalizations.of(context)?.submitReportButton ?? 'Submit Report',
                    onPressed: _submitReport,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IncidentTypeItem {
  final IconData icon;
  final String label;
  final Color color;
  const _IncidentTypeItem(this.icon, this.label, this.color);
}
