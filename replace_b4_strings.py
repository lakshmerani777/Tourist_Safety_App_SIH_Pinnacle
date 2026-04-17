import os

replacements = [
    ("'Personal Identity'", "AppLocalizations.of(context)?.personalIdentity ?? 'Personal Identity'"),
    ("'First Name'", "AppLocalizations.of(context)?.firstName ?? 'First Name'"),
    ("'Last Name'", "AppLocalizations.of(context)?.lastName ?? 'Last Name'"),
    ("'Date of Birth'", "AppLocalizations.of(context)?.dob ?? 'Date of Birth'"),
    ("'Nationality'", "AppLocalizations.of(context)?.nationality ?? 'Nationality'"),
    ("'Passport No.'", "AppLocalizations.of(context)?.passportNum ?? 'Passport No.'"),
    ("'Passport/ID Number'", "AppLocalizations.of(context)?.passportNum ?? 'Passport/ID Number'"),
    ("'Passport Expiry Date'", "AppLocalizations.of(context)?.passportExpiry ?? 'Passport Expiry Date'"),
    ("'Passport Expiry'", "AppLocalizations.of(context)?.passportExpiry ?? 'Passport Expiry'"),
    ("'Phone'", "AppLocalizations.of(context)?.phoneNumberLabel ?? 'Phone'"),
    ("'Phone Number'", "AppLocalizations.of(context)?.phoneNumberLabel ?? 'Phone Number'"),
    ("'Phone Verification'", "AppLocalizations.of(context)?.phoneTitle ?? 'Phone Verification'"),
    ("'Enter verification code'", "AppLocalizations.of(context)?.verifyCode ?? 'Enter verification code'"),
    ("'Travel Details'", "AppLocalizations.of(context)?.travelTimeline ?? 'Travel Details'"),
    ("'Travel Timeline'", "AppLocalizations.of(context)?.travelTimeline ?? 'Travel Timeline'"),
    ("'Arrival'", "AppLocalizations.of(context)?.arrivalDate ?? 'Arrival'"),
    ("'Arrival Date'", "AppLocalizations.of(context)?.arrivalDate ?? 'Arrival Date'"),
    ("'Departure'", "AppLocalizations.of(context)?.departureDate ?? 'Departure'"),
    ("'Departure Date'", "AppLocalizations.of(context)?.departureDate ?? 'Departure Date'"),
    ("'Purpose of Visit'", "AppLocalizations.of(context)?.purposeOfVisit ?? 'Purpose of Visit'"),
    ("'Purpose'", "AppLocalizations.of(context)?.purposeOfVisit ?? 'Purpose'"),
    ("'Places to Visit'", "AppLocalizations.of(context)?.placesToVisit ?? 'Places to Visit'"),
    ("'Places Planning to Visit'", "AppLocalizations.of(context)?.placesToVisit ?? 'Places Planning to Visit'"),
    ("'Places'", "AppLocalizations.of(context)?.placesToVisit ?? 'Places'"),
    ("'Emergency Contacts'", "AppLocalizations.of(context)?.yourEmergencyContacts ?? 'Emergency Contacts'"),
    ("'Contact 1'", "AppLocalizations.of(context)?.contact1 ?? 'Contact 1'"),
    ("'Contact 2'", "AppLocalizations.of(context)?.contact2 ?? 'Contact 2'"),
    ("'Contact 1 Name'", "AppLocalizations.of(context)?.fullName ?? 'Contact 1 Name'"),
    ("'Contact 2 Name'", "AppLocalizations.of(context)?.fullName ?? 'Contact 2 Name'"),
    ("'Contact 1 Phone'", "AppLocalizations.of(context)?.phoneNumberLabel ?? 'Contact 1 Phone'"),
    ("'Contact 2 Phone'", "AppLocalizations.of(context)?.phoneNumberLabel ?? 'Contact 2 Phone'"),
    ("'Full Name'", "AppLocalizations.of(context)?.fullName ?? 'Full Name'"),
    ("'Relationship'", "AppLocalizations.of(context)?.relationship ?? 'Relationship'"),
    ("'Stay Details'", "AppLocalizations.of(context)?.stayDetailsTitle ?? 'Stay Details'"),
    ("'Accommodation Type'", "AppLocalizations.of(context)?.accommodationType ?? 'Accommodation Type'"),
    ("'Type'", "AppLocalizations.of(context)?.accommodationType ?? 'Type'"),
    ("'Hotel/Property Name'", "AppLocalizations.of(context)?.propertyName ?? 'Hotel/Property Name'"),
    ("'Property Name'", "AppLocalizations.of(context)?.propertyName ?? 'Property Name'"),
    ("'Property'", "AppLocalizations.of(context)?.propertyName ?? 'Property'"),
    ("'Full Address'", "AppLocalizations.of(context)?.fullAddress ?? 'Full Address'"),
    ("'Address'", "AppLocalizations.of(context)?.fullAddress ?? 'Address'"),
    ("'Room/Unit Number'", "AppLocalizations.of(context)?.roomUnit ?? 'Room/Unit Number'"),
    ("'Room / Unit'", "AppLocalizations.of(context)?.roomUnit ?? 'Room / Unit'"),
    ("'Room'", "AppLocalizations.of(context)?.roomUnit ?? 'Room'"),
    ("'Accommodation Phone'", "AppLocalizations.of(context)?.accommodationPhone ?? 'Accommodation Phone'"),
    ("'Medical Safety'", "AppLocalizations.of(context)?.medicalSafety ?? 'Medical Safety'"),
    ("'Medical Info'", "AppLocalizations.of(context)?.medicalSafety ?? 'Medical Info'"),
    ("'Blood Type'", "AppLocalizations.of(context)?.bloodType ?? 'Blood Type'"),
    ("'Any Allergies?'", "AppLocalizations.of(context)?.allergiesLabel ?? 'Any Allergies?'"),
    ("'Allergies'", "AppLocalizations.of(context)?.allergiesLabel ?? 'Allergies'"),
    ("'Allergy Details'", "AppLocalizations.of(context)?.allergyDetails ?? 'Allergy Details'"),
    ("'Chronic Conditions?'", "AppLocalizations.of(context)?.conditionsLabel ?? 'Chronic Conditions?'"),
    ("'Chronic Conditions'", "AppLocalizations.of(context)?.conditionsLabel ?? 'Chronic Conditions'"),
    ("'Conditions'", "AppLocalizations.of(context)?.conditionsLabel ?? 'Conditions'"),
    ("'Condition Details'", "AppLocalizations.of(context)?.conditionDetails ?? 'Condition Details'"),
    ("'Regular Medications?'", "AppLocalizations.of(context)?.medicationsLabel ?? 'Regular Medications?'"),
    ("'Regular Medications'", "AppLocalizations.of(context)?.medicationsLabel ?? 'Regular Medications'"),
    ("'Medications'", "AppLocalizations.of(context)?.medicationsLabel ?? 'Medications'"),
    ("'Medication Details'", "AppLocalizations.of(context)?.medicationDetails ?? 'Medication Details'"),
    ("'Insurance Policy Number'", "AppLocalizations.of(context)?.insurancePolicy ?? 'Insurance Policy Number'"),
    ("'Insurance'", "AppLocalizations.of(context)?.insurancePolicy ?? 'Insurance'"),
    ("'Consent & Privacy'", "AppLocalizations.of(context)?.consentPrivacy ?? 'Consent & Privacy'"),
    ("'I agree to the Terms of Service and Privacy Policy'", "AppLocalizations.of(context)?.consentTerms ?? 'I agree to the Terms of Service and Privacy Policy'"),
    ("'I consent to location tracking for safety monitoring'", "AppLocalizations.of(context)?.consentLocation ?? 'I consent to location tracking for safety monitoring'"),
    ("'I consent to sharing my data with emergency services'", "AppLocalizations.of(context)?.consentData ?? 'I consent to sharing my data with emergency services'"),
    ("'I agree to receive safety alerts and notifications'", "AppLocalizations.of(context)?.consentAlerts ?? 'I agree to receive safety alerts and notifications'"),
    ("'Required'", "AppLocalizations.of(context)?.reqLabel ?? 'Required'"),
    ("'Optional'", "AppLocalizations.of(context)?.optLabel ?? 'Optional'"),
    ("'Edit'", "AppLocalizations.of(context)?.editBtn ?? 'Edit'"),
    ("'Done'", "AppLocalizations.of(context)?.doneBtn ?? 'Done'"),
    ("'Sign Out'", "AppLocalizations.of(context)?.signOutBtn ?? 'Sign Out'"),
    ("'Delete Account'", "AppLocalizations.of(context)?.deleteAccBtn ?? 'Delete Account'"),
    ("'Are you sure you want to permanently delete your account? This action cannot be undone.'", "AppLocalizations.of(context)?.deleteAccPrompt ?? 'Are you sure you want to permanently delete your account? This action cannot be undone.'"),
    ("'Delete'", "AppLocalizations.of(context)?.deleteBtn ?? 'Delete'"),
    ("'Cancel'", "AppLocalizations.of(context)?.cancelBtn ?? 'Cancel'"),
]

def replace_in_file(path, is_onboarding=False):
    with open(path, 'r') as f:
        content = f.read()

    # Make sure we add import if not there
    if "AppLocalizations" not in content and is_onboarding:
        import_stmt = "import '../../l10n/app_localizations.dart';\n"
        content = content.replace("import 'package:flutter/material.dart';", f"import 'package:flutter/material.dart';\n{import_stmt}")

    for old, new in replacements:
        if new in content:
            continue
        content = content.replace(f"Text({old}", f"Text({new}")
        content = content.replace(f"label: {old}", f"label: {new}")
        content = content.replace(f"title: {old}", f"title: {new}")
        content = content.replace(f"subtitle: {old}", f"subtitle: {new}")
        content = content.replace(f"text: {old}", f"text: {new}")

    with open(path, 'w') as f:
        f.write(content)

base_path = "lib/screens/onboarding"
for file in os.listdir(base_path):
    if file.endswith('.dart'):
        replace_in_file(os.path.join(base_path, file), is_onboarding=True)

replace_in_file("lib/screens/profile_screen.dart", is_onboarding=False)
