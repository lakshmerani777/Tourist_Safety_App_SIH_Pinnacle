import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';

// ----- Models -----

class OnboardingData {
  // Step 1: Phone
  String phoneNumber;
  String phoneCode;
  String otpCode;
  bool otpVerified;

  // Step 2: Identity
  String firstName;
  String lastName;
  DateTime? dateOfBirth;
  Country? nationality;
  String passportNumber;
  DateTime? passportExpiry;

  // Step 3: Travel
  DateTime? arrivalDate;
  DateTime? departureDate;
  String? purposeOfVisit;
  String placesToVisit;

  // Step 4: Emergency Contacts
  String contact1Name;
  String? contact1Relationship;
  String contact1Phone;
  String contact2Name;
  String? contact2Relationship;
  String contact2Phone;

  // Step 5: Stay Details
  String? accommodationType;
  String propertyName;
  String fullAddress;
  String roomNumber;
  String accommodationPhone;

  // Step 6: Medical
  String? bloodType;
  bool hasAllergies;
  String allergyDetails;
  bool hasChronicConditions;
  String conditionDetails;
  bool takesRegularMedication;
  String medicationDetails;
  String insurancePolicyNumber;

  // Step 7: Consent
  bool termsAccepted;
  bool locationConsent;
  bool dataShareConsent;
  bool alertsConsent;

  Map<String, dynamic> toJson() => {
    'phone_number': phoneNumber,
    'phone_code': phoneCode,
    'otp_verified': otpVerified,
    'first_name': firstName,
    'last_name': lastName,
    'date_of_birth': dateOfBirth?.toIso8601String(),
    'nationality': nationality?.name,
    'nationality_code': nationality?.countryCode,
    'passport_number': passportNumber,
    'passport_expiry': passportExpiry?.toIso8601String(),
    'arrival_date': arrivalDate?.toIso8601String(),
    'departure_date': departureDate?.toIso8601String(),
    'purpose_of_visit': purposeOfVisit,
    'places_to_visit': placesToVisit,
    'contact1_name': contact1Name,
    'contact1_relationship': contact1Relationship,
    'contact1_phone': contact1Phone,
    'contact2_name': contact2Name,
    'contact2_relationship': contact2Relationship,
    'contact2_phone': contact2Phone,
    'accommodation_type': accommodationType,
    'property_name': propertyName,
    'full_address': fullAddress,
    'room_number': roomNumber,
    'accommodation_phone': accommodationPhone,
    'blood_type': bloodType,
    'has_allergies': hasAllergies,
    'allergy_details': allergyDetails,
    'has_chronic_conditions': hasChronicConditions,
    'condition_details': conditionDetails,
    'takes_regular_medication': takesRegularMedication,
    'medication_details': medicationDetails,
    'insurance_policy_number': insurancePolicyNumber,
    'terms_accepted': termsAccepted,
    'location_consent': locationConsent,
    'data_share_consent': dataShareConsent,
    'alerts_consent': alertsConsent,
  };

  void updateFromMap(Map<String, dynamic> data) {
    if (data['first_name'] != null) firstName = data['first_name'];
    if (data['last_name'] != null) lastName = data['last_name'];
    if (data['phone_number'] != null) phoneNumber = data['phone_number'];
    if (data['phone_code'] != null) phoneCode = data['phone_code'];
    if (data['nationality'] != null) {
      // Nationality might need proper Country object, but name is enough for display
    }
    if (data['passport_number'] != null) passportNumber = data['passport_number'];
    if (data['purpose_of_visit'] != null) purposeOfVisit = data['purpose_of_visit'];
    if (data['places_to_visit'] != null) placesToVisit = data['places_to_visit'];
    if (data['full_address'] != null) fullAddress = data['full_address'];
    if (data['property_name'] != null) propertyName = data['property_name'];
    if (data['blood_type'] != null) bloodType = data['blood_type'];
    if (data['insurance_policy_number'] != null) insurancePolicyNumber = data['insurance_policy_number'];
    if (data['contact1_name'] != null) contact1Name = data['contact1_name'];
    if (data['contact1_phone'] != null) contact1Phone = data['contact1_phone'];
    if (data['contact2_name'] != null) contact2Name = data['contact2_name'];
    if (data['contact2_phone'] != null) contact2Phone = data['contact2_phone'];
    
    // Dates
    if (data['date_of_birth'] != null) dateOfBirth = DateTime.tryParse(data['date_of_birth']);
    if (data['passport_expiry'] != null) passportExpiry = DateTime.tryParse(data['passport_expiry']);
    if (data['arrival_date'] != null) arrivalDate = DateTime.tryParse(data['arrival_date']);
    if (data['departure_date'] != null) departureDate = DateTime.tryParse(data['departure_date']);

    // Booleans
    if (data['has_allergies'] != null) hasAllergies = data['has_allergies'] == true;
    if (data['has_chronic_conditions'] != null) hasChronicConditions = data['has_chronic_conditions'] == true;
    if (data['takes_regular_medication'] != null) takesRegularMedication = data['takes_regular_medication'] == true;
    
    if (data['allergy_details'] != null) allergyDetails = data['allergy_details'];
    if (data['condition_details'] != null) conditionDetails = data['condition_details'];
    if (data['medication_details'] != null) medicationDetails = data['medication_details'];
  }

  OnboardingData({
    this.phoneNumber = '',
    this.phoneCode = '91',
    this.otpCode = '',
    this.otpVerified = false,
    this.firstName = '',
    this.lastName = '',
    this.dateOfBirth,
    this.nationality,
    this.passportNumber = '',
    this.passportExpiry,
    this.arrivalDate,
    this.departureDate,
    this.purposeOfVisit,
    this.placesToVisit = '',
    this.contact1Name = '',
    this.contact1Relationship,
    this.contact1Phone = '',
    this.contact2Name = '',
    this.contact2Relationship,
    this.contact2Phone = '',
    this.accommodationType,
    this.propertyName = '',
    this.fullAddress = '',
    this.roomNumber = '',
    this.accommodationPhone = '',
    this.bloodType,
    this.hasAllergies = false,
    this.allergyDetails = '',
    this.hasChronicConditions = false,
    this.conditionDetails = '',
    this.takesRegularMedication = false,
    this.medicationDetails = '',
    this.insurancePolicyNumber = '',
    this.termsAccepted = false,
    this.locationConsent = false,
    this.dataShareConsent = false,
    this.alertsConsent = false,
  });
}

// ----- Notifier -----

class OnboardingNotifier extends ChangeNotifier {
  final OnboardingData _data = OnboardingData();
  int _currentStep = 1;

  OnboardingData get data => _data;
  int get currentStep => _currentStep;

  void loadProfile(Map<String, dynamic> profileJson) {
    _data.updateFromMap(profileJson);
    notifyListeners();
  }

  void setStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  void nextStep() {
    if (_currentStep < 7) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 1) {
      _currentStep--;
      notifyListeners();
    }
  }

  // Step 1
  void setPhoneNumber(String value) {
    _data.phoneNumber = value;
    notifyListeners();
  }

  void setPhoneCode(String value) {
    _data.phoneCode = value;
    notifyListeners();
  }

  void setOtpCode(String value) {
    _data.otpCode = value;
    notifyListeners();
  }

  void setOtpVerified(bool value) {
    _data.otpVerified = value;
    notifyListeners();
  }

  // Step 2
  void setFirstName(String val) {
    _data.firstName = val;
    notifyListeners();
  }

  void setLastName(String val) {
    _data.lastName = val;
    notifyListeners();
  }

  void setDateOfBirth(DateTime val) {
    _data.dateOfBirth = val;
    notifyListeners();
  }

  void setNationality(Country val) {
    _data.nationality = val;
    notifyListeners();
  }

  void setPassportNumber(String val) {
    _data.passportNumber = val;
    notifyListeners();
  }

  void setPassportExpiry(DateTime val) {
    _data.passportExpiry = val;
    notifyListeners();
  }

  // Step 3
  void setArrivalDate(DateTime val) {
    _data.arrivalDate = val;
    notifyListeners();
  }

  void setDepartureDate(DateTime val) {
    _data.departureDate = val;
    notifyListeners();
  }

  void setPurposeOfVisit(String val) {
    _data.purposeOfVisit = val;
    notifyListeners();
  }

  void setPlacesToVisit(String val) {
    _data.placesToVisit = val;
    notifyListeners();
  }

  // Step 4
  void setContact1Name(String val) {
    _data.contact1Name = val;
    notifyListeners();
  }

  void setContact1Relationship(String val) {
    _data.contact1Relationship = val;
    notifyListeners();
  }

  void setContact1Phone(String val) {
    _data.contact1Phone = val;
    notifyListeners();
  }

  void setContact2Name(String val) {
    _data.contact2Name = val;
    notifyListeners();
  }

  void setContact2Relationship(String val) {
    _data.contact2Relationship = val;
    notifyListeners();
  }

  void setContact2Phone(String val) {
    _data.contact2Phone = val;
    notifyListeners();
  }

  // Step 5
  void setAccommodationType(String val) {
    _data.accommodationType = val;
    notifyListeners();
  }

  void setPropertyName(String val) {
    _data.propertyName = val;
    notifyListeners();
  }

  void setFullAddress(String val) {
    _data.fullAddress = val;
    notifyListeners();
  }

  void setRoomNumber(String val) {
    _data.roomNumber = val;
    notifyListeners();
  }

  void setAccommodationPhone(String val) {
    _data.accommodationPhone = val;
    notifyListeners();
  }

  // Step 6
  void setBloodType(String val) {
    _data.bloodType = val;
    notifyListeners();
  }

  void setHasAllergies(bool val) {
    _data.hasAllergies = val;
    notifyListeners();
  }

  void setAllergyDetails(String val) {
    _data.allergyDetails = val;
    notifyListeners();
  }

  void setHasChronicConditions(bool val) {
    _data.hasChronicConditions = val;
    notifyListeners();
  }

  void setConditionDetails(String val) {
    _data.conditionDetails = val;
    notifyListeners();
  }

  void setTakesRegularMedication(bool val) {
    _data.takesRegularMedication = val;
    notifyListeners();
  }

  void setMedicationDetails(String val) {
    _data.medicationDetails = val;
    notifyListeners();
  }

  void setInsurancePolicyNumber(String val) {
    _data.insurancePolicyNumber = val;
    notifyListeners();
  }

  // Step 7
  void setTermsAccepted(bool val) {
    _data.termsAccepted = val;
    notifyListeners();
  }

  void setLocationConsent(bool val) {
    _data.locationConsent = val;
    notifyListeners();
  }

  void setDataShareConsent(bool val) {
    _data.dataShareConsent = val;
    notifyListeners();
  }

  void setAlertsConsent(bool val) {
    _data.alertsConsent = val;
    notifyListeners();
  }

  bool get allRequiredConsentsGiven =>
      _data.termsAccepted && _data.locationConsent && _data.dataShareConsent;
}

// ----- Provider -----

final onboardingProvider = ChangeNotifierProvider<OnboardingNotifier>((ref) {
  return OnboardingNotifier();
});
