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
