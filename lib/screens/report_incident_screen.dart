import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/widgets/safety_button.dart';
import '../core/widgets/safety_card.dart';
import '../core/widgets/dropdown.dart';
import '../core/widgets/input_field.dart';
import '../l10n/app_localizations.dart';

class ReportIncidentScreen extends ConsumerStatefulWidget {
  const ReportIncidentScreen({super.key});

  @override
  ConsumerState<ReportIncidentScreen> createState() => _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends ConsumerState<ReportIncidentScreen> {
  final _descController = TextEditingController();
  String? _selectedIncidentType;
  String? _selectedIncidentType;
  List<String> get _incidentTypes => [
    AppLocalizations.of(context)?.incidentTheft ?? 'Theft / Pickpocketing',
    AppLocalizations.of(context)?.incidentMedical ?? 'Medical Emergency',
    AppLocalizations.of(context)?.incidentAssault ?? 'Harassment / Assault',
    AppLocalizations.of(context)?.incidentLostItem ?? 'Lost Item',
    AppLocalizations.of(context)?.incidentSuspicious ?? 'Suspicious Activity',
    AppLocalizations.of(context)?.incidentAccident ?? 'Accident / Collision',
    AppLocalizations.of(context)?.incidentOther ?? 'Other'
  ];

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isRecording = false;
  XFile? _attachedMedia;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickMedia() async {
    // Show bottom sheet to choose between Camera or Gallery
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
      if (file != null) {
        setState(() => _attachedMedia = file);
      }
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

    // Show success dialog
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
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.success.withValues(alpha: 0.15),
              ),
              child: const Icon(Icons.check, color: AppColors.success, size: 32),
            ),
            const SizedBox(height: 24),
            Text(AppLocalizations.of(context)?.reportSubmittedTitle ?? 'Report Submitted',
                style: AppTypography.h2, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)?.reportSubmittedMessage ?? 'Your report has been securely submitted to the local authorities. Help is on the way if requested.',
              style: AppTypography.body.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SafetyButton(
              text: AppLocalizations.of(context)?.returnToHome ?? 'Return to Home',
              onPressed: () {
                Navigator.pop(context); // Close dialog
                context.go('/home');    // Go back to home
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get live location formatted text if available
    final locationText = '16th Road, Bandra West'; // Fallback / mock address

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.reportIncidentTitle ?? 'Report Incident', style: AppTypography.h2),
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
            // Incident Type Dropdown
            AppDropdown(
              label: AppLocalizations.of(context)?.incidentTypeLabel ?? 'Incident Type',
              selectedValue: _selectedIncidentType,
              items: _incidentTypes,
              onChanged: (val) => setState(() => _selectedIncidentType = val),
            ),
            const SizedBox(height: 24),

            // Date and Time Fields
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context)?.dateLabel ?? 'Date', style: AppTypography.caption),
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
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, color: AppColors.textSecondary, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat('MMM d, yyyy').format(_selectedDate),
                                style: AppTypography.body,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context)?.timeLabel ?? 'Time', style: AppTypography.caption),
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
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time, color: AppColors.textSecondary, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                _selectedTime.format(context),
                                style: AppTypography.body,
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
            const SizedBox(height: 24),

            // Location
            Text(AppLocalizations.of(context)?.sosLocationLabel ?? 'Location', style: AppTypography.caption),
            const SizedBox(height: 8),
            SafetyCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accentBlue.withValues(alpha: 0.15),
                    ),
                    child: const Icon(Icons.my_location, color: AppColors.accentBlue, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppLocalizations.of(context)?.currentGpsLocation ?? 'Current GPS Location',
                            style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(locationText, style: AppTypography.caption),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/map'),
                    child: Text(AppLocalizations.of(context)?.mapViewButton ?? 'Map View', style: AppTypography.body.copyWith(color: AppColors.accentBlue)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Description Box
            InputField(
              label: AppLocalizations.of(context)?.descriptionLabel ?? 'Description',
              controller: _descController,
              maxLines: 4,
            ),
            const SizedBox(height: 24),

            // Voice Details / Media Upload
            Text(AppLocalizations.of(context)?.attachmentsLabel ?? 'Attachments', style: AppTypography.caption),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _isRecording = !_isRecording);
                    },
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: _isRecording ? AppColors.alertRed.withValues(alpha: 0.1) : AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _isRecording ? AppColors.alertRed : AppColors.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isRecording ? Icons.stop_circle : Icons.mic,
                            color: _isRecording ? AppColors.alertRed : AppColors.accentBlue,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isRecording ? (AppLocalizations.of(context)?.recordingAudio ?? 'Recording...') : (AppLocalizations.of(context)?.voiceNote ?? 'Voice Note'),
                            style: AppTypography.body.copyWith(
                              color: _isRecording ? AppColors.alertRed : AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: _pickMedia,
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: _attachedMedia != null ? AppColors.success.withValues(alpha: 0.1) : AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _attachedMedia != null ? AppColors.success : AppColors.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _attachedMedia != null ? Icons.check_circle : Icons.camera_alt,
                            color: _attachedMedia != null ? AppColors.success : AppColors.accentBlue,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _attachedMedia != null ? (AppLocalizations.of(context)?.mediaAdded ?? 'Media Added') : (AppLocalizations.of(context)?.addMedia ?? 'Add Media'),
                            style: AppTypography.body.copyWith(
                              color: _attachedMedia != null ? AppColors.success : AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 48),

            // Submit Button
            SafetyButton(
              text: AppLocalizations.of(context)?.submitReportButton ?? 'Submit Report',
              onPressed: _submitReport,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
