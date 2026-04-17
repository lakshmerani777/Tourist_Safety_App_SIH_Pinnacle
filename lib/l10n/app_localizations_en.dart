// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get profileSettings => 'Profile Settings';

  @override
  String get onboardingWelcome => 'Welcome to Pinnacle';

  @override
  String get continueButton => 'Continue';

  @override
  String get appTitle => 'Tourist Safety';

  @override
  String get appTagline => 'Protecting every journey';

  @override
  String get govBadge => 'OFFICIAL GOVERNMENT SAFETY SYSTEM';

  @override
  String get signIn => 'Sign In';

  @override
  String get loginWelcome => 'Welcome back to the Tourist Safety System';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get enterEmail => 'Enter your email';

  @override
  String get password => 'Password';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get noAccount => 'Don\'t have an account? ';

  @override
  String get createAccount => 'Create Account';

  @override
  String get errorEmptyEmail => 'Please enter your email.';

  @override
  String get errorInvalidEmail => 'Please enter a valid email address.';

  @override
  String get errorEmptyPassword => 'Please enter your password.';

  @override
  String get errorLoginFailed => 'Sign in failed. Please try again.';

  @override
  String get registerWelcome => 'Register to access the Tourist Safety System';

  @override
  String get fullName => 'Full Name';

  @override
  String get enterFullName => 'Enter your full name';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get enterConfirmPassword => 'Confirm your password';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get errorEmptyName => 'Please enter your full name.';

  @override
  String get errorCreatePassword => 'Please create a password.';

  @override
  String get errorShortPassword => 'Password must be at least 8 characters.';

  @override
  String get errorPasswordMismatch => 'Passwords do not match.';

  @override
  String get errorRegisterFailed => 'Registration failed. Please try again.';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get resetPasswordCaption =>
      'Enter your email and we\'ll send you a link to reset your password';

  @override
  String get sendResetLink => 'Send reset link';

  @override
  String get rememberPassword => 'Remember your password? ';

  @override
  String get protectedStatus => 'Protected';

  @override
  String get currentLocation => 'Current Location';

  @override
  String get lastUpdatedNow => 'Last updated: Just now';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get reportIncident => 'Report\nIncident';

  @override
  String get shareLocation => 'Share\nLocation';

  @override
  String get emergencyContacts => 'Emergency\nContacts';

  @override
  String get safetyMap => 'Safety\nMap';

  @override
  String get sosText => 'SOS';

  @override
  String get recentAlerts => 'Recent Alerts';

  @override
  String get viewAll => 'View All';

  @override
  String get navHome => 'Home';

  @override
  String get navMap => 'Map';

  @override
  String get navChat => 'Chat';

  @override
  String get navAlerts => 'Alerts';

  @override
  String get navProfile => 'Profile';

  @override
  String get errorMapSearch => 'Could not open map search';

  @override
  String get searchLocation => 'Search location...';

  @override
  String get nearbyHospitals => 'Nearby Hospitals';

  @override
  String get policeStations => 'Police Stations';

  @override
  String get pharmacies => 'Pharmacies';

  @override
  String get embassies => 'Embassies';

  @override
  String get atms => 'ATMs';

  @override
  String get publicTransit => 'Public Transit';

  @override
  String get publicRestrooms => 'Public Restrooms';

  @override
  String get touristAttractions => 'Tourist Attractions';

  @override
  String get mapLegend => 'Map Legend';

  @override
  String get legendYourLocation => 'Your Location';

  @override
  String get legendIncidentReports => 'Incident Reports';

  @override
  String get legendCautionZones => 'Caution Zones';

  @override
  String get legendHighRiskZones => 'High Risk Zones';

  @override
  String get legendSafeZones => 'Safe Zones';

  @override
  String get activeBadge => 'Active';

  @override
  String get alertBadge => 'Alert';

  @override
  String get warningBadge => 'Warning';

  @override
  String get dangerBadge => 'Danger';

  @override
  String get safeBadge => 'Safe';

  @override
  String get mapCopyright => 'Map data © OpenStreetMap contributors';

  @override
  String get activeAlerts => 'Active Alerts';

  @override
  String get callHelpline => 'Call Tourist Helpline';

  @override
  String get cancelSosTitle => 'Cancel SOS?';

  @override
  String get cancelSosMessage =>
      'Are you sure you want to cancel the emergency alert?';

  @override
  String get keepActive => 'Keep Active';

  @override
  String get cancelSosButton => 'Cancel SOS';

  @override
  String get sosActivated => 'SOS ACTIVATED';

  @override
  String get sosNotified =>
      'Emergency services have been notified.\nHelp is on the way.';

  @override
  String get sosNameLabel => 'Name';

  @override
  String get sosLocationLabel => 'Location';

  @override
  String get sosTimestampLabel => 'Timestamp';

  @override
  String cancellationAvailableFor(Object countdown) {
    return 'Cancellation available for: ${countdown}s';
  }

  @override
  String get mockLocation => '16th Road, Bandra West';

  @override
  String get reportIncidentTitle => 'Report Incident';

  @override
  String get incidentTheft => 'Theft / Pickpocketing';

  @override
  String get incidentMedical => 'Medical Emergency';

  @override
  String get incidentAssault => 'Harassment / Assault';

  @override
  String get incidentLostItem => 'Lost Item';

  @override
  String get incidentSuspicious => 'Suspicious Activity';

  @override
  String get incidentAccident => 'Accident / Collision';

  @override
  String get incidentOther => 'Other';

  @override
  String get takePhoto => 'Take a photo';

  @override
  String get chooseGallery => 'Choose from gallery';

  @override
  String get errorSelectIncidentType => 'Please select an incident type.';

  @override
  String get reportSubmittedTitle => 'Report Submitted';

  @override
  String get reportSubmittedMessage =>
      'Your report has been securely submitted to the local authorities. Help is on the way if requested.';

  @override
  String get returnToHome => 'Return to Home';

  @override
  String get incidentTypeLabel => 'Incident Type';

  @override
  String get dateLabel => 'Date';

  @override
  String get timeLabel => 'Time';

  @override
  String get currentGpsLocation => 'Current GPS Location';

  @override
  String get mapViewButton => 'Map View';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get attachmentsLabel => 'Attachments';

  @override
  String get recordingAudio => 'Recording...';

  @override
  String get voiceNote => 'Voice Note';

  @override
  String get mediaAdded => 'Media Added';

  @override
  String get addMedia => 'Add Media';

  @override
  String get submitReportButton => 'Submit Report';

  @override
  String get govHelplines => 'Government Helplines';

  @override
  String get touristHelpline => 'Tourist Helpline';

  @override
  String get policeHelpline => 'Police';

  @override
  String get ambulanceHelpline => 'Ambulance';

  @override
  String get fireBrigadeHelpline => 'Fire Brigade';

  @override
  String get womensHelpline => 'Women\'s Helpline';

  @override
  String get cyberCrimeHelpline => 'Cyber Crime Helpline';

  @override
  String get yourEmergencyContacts => 'Your Emergency Contacts';

  @override
  String get noContactsAdded => 'No personal contacts added yet.';

  @override
  String get addContactsOnboarding =>
      'Add contacts during onboarding to see them here.';

  @override
  String get personalIdentity => 'Personal Identity';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get dob => 'Date of Birth';

  @override
  String get nationality => 'Nationality';

  @override
  String get passportNum => 'Passport/ID Number';

  @override
  String get passportExpiry => 'Passport Expiry Date';

  @override
  String get phoneTitle => 'Phone Verification';

  @override
  String get phoneNumberLabel => 'Phone Number';

  @override
  String get verifyCode => 'Enter verification code';

  @override
  String get travelTimeline => 'Travel Timeline';

  @override
  String get arrivalDate => 'Arrival Date';

  @override
  String get departureDate => 'Departure Date';

  @override
  String get purposeOfVisit => 'Purpose of Visit';

  @override
  String get placesToVisit => 'Places Planning to Visit';

  @override
  String get contact1 => 'Contact 1';

  @override
  String get contact2 => 'Contact 2';

  @override
  String get relationship => 'Relationship';

  @override
  String get stayDetailsTitle => 'Stay Details';

  @override
  String get accommodationType => 'Accommodation Type';

  @override
  String get propertyName => 'Hotel/Property Name';

  @override
  String get fullAddress => 'Full Address';

  @override
  String get roomUnit => 'Room/Unit Number';

  @override
  String get accommodationPhone => 'Accommodation Phone';

  @override
  String get medicalSafety => 'Medical Safety';

  @override
  String get bloodType => 'Blood Type';

  @override
  String get allergiesLabel => 'Any Allergies?';

  @override
  String get allergyDetails => 'Allergy Details';

  @override
  String get conditionsLabel => 'Chronic Conditions?';

  @override
  String get conditionDetails => 'Condition Details';

  @override
  String get medicationsLabel => 'Regular Medications?';

  @override
  String get medicationDetails => 'Medication Details';

  @override
  String get insurancePolicy => 'Insurance Policy Number';

  @override
  String get consentPrivacy => 'Consent & Privacy';

  @override
  String get consentTerms =>
      'I agree to the Terms of Service and Privacy Policy';

  @override
  String get consentLocation =>
      'I consent to location tracking for safety monitoring';

  @override
  String get consentData =>
      'I consent to sharing my data with emergency services';

  @override
  String get consentAlerts =>
      'I agree to receive safety alerts and notifications';

  @override
  String get reqLabel => 'Required';

  @override
  String get optLabel => 'Optional';

  @override
  String get editBtn => 'Edit';

  @override
  String get doneBtn => 'Done';

  @override
  String get signOutBtn => 'Sign Out';

  @override
  String get deleteAccBtn => 'Delete Account';

  @override
  String get deleteAccPrompt =>
      'Are you sure you want to permanently delete your account? This action cannot be undone.';

  @override
  String get deleteBtn => 'Delete';

  @override
  String get cancelBtn => 'Cancel';
}
