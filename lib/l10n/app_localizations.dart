import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('zh'),
  ];

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Profile Settings'**
  String get profileSettings;

  /// No description provided for @onboardingWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Pinnacle'**
  String get onboardingWelcome;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Tourist Safety'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Protecting every journey'**
  String get appTagline;

  /// No description provided for @govBadge.
  ///
  /// In en, this message translates to:
  /// **'OFFICIAL GOVERNMENT SAFETY SYSTEM'**
  String get govBadge;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @loginWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome back to the Tourist Safety System'**
  String get loginWelcome;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get noAccount;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @errorEmptyEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email.'**
  String get errorEmptyEmail;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get errorInvalidEmail;

  /// No description provided for @errorEmptyPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password.'**
  String get errorEmptyPassword;

  /// No description provided for @errorLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign in failed. Please try again.'**
  String get errorLoginFailed;

  /// No description provided for @registerWelcome.
  ///
  /// In en, this message translates to:
  /// **'Register to access the Tourist Safety System'**
  String get registerWelcome;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterFullName;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @enterConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get enterConfirmPassword;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @errorEmptyName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name.'**
  String get errorEmptyName;

  /// No description provided for @errorCreatePassword.
  ///
  /// In en, this message translates to:
  /// **'Please create a password.'**
  String get errorCreatePassword;

  /// No description provided for @errorShortPassword.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters.'**
  String get errorShortPassword;

  /// No description provided for @errorPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get errorPasswordMismatch;

  /// No description provided for @errorRegisterFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed. Please try again.'**
  String get errorRegisterFailed;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @resetPasswordCaption.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you a link to reset your password'**
  String get resetPasswordCaption;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendResetLink;

  /// No description provided for @rememberPassword.
  ///
  /// In en, this message translates to:
  /// **'Remember your password? '**
  String get rememberPassword;

  /// No description provided for @protectedStatus.
  ///
  /// In en, this message translates to:
  /// **'Protected'**
  String get protectedStatus;

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get currentLocation;

  /// No description provided for @lastUpdatedNow.
  ///
  /// In en, this message translates to:
  /// **'Last updated: Just now'**
  String get lastUpdatedNow;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @reportIncident.
  ///
  /// In en, this message translates to:
  /// **'Report\nIncident'**
  String get reportIncident;

  /// No description provided for @shareLocation.
  ///
  /// In en, this message translates to:
  /// **'Share\nLocation'**
  String get shareLocation;

  /// No description provided for @emergencyContacts.
  ///
  /// In en, this message translates to:
  /// **'Emergency\nContacts'**
  String get emergencyContacts;

  /// No description provided for @safetyMap.
  ///
  /// In en, this message translates to:
  /// **'Safety\nMap'**
  String get safetyMap;

  /// No description provided for @sosText.
  ///
  /// In en, this message translates to:
  /// **'SOS'**
  String get sosText;

  /// No description provided for @recentAlerts.
  ///
  /// In en, this message translates to:
  /// **'Recent Alerts'**
  String get recentAlerts;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get navMap;

  /// No description provided for @navChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get navChat;

  /// No description provided for @navAlerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get navAlerts;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @errorMapSearch.
  ///
  /// In en, this message translates to:
  /// **'Could not open map search'**
  String get errorMapSearch;

  /// No description provided for @searchLocation.
  ///
  /// In en, this message translates to:
  /// **'Search location...'**
  String get searchLocation;

  /// No description provided for @nearbyHospitals.
  ///
  /// In en, this message translates to:
  /// **'Nearby Hospitals'**
  String get nearbyHospitals;

  /// No description provided for @policeStations.
  ///
  /// In en, this message translates to:
  /// **'Police Stations'**
  String get policeStations;

  /// No description provided for @pharmacies.
  ///
  /// In en, this message translates to:
  /// **'Pharmacies'**
  String get pharmacies;

  /// No description provided for @embassies.
  ///
  /// In en, this message translates to:
  /// **'Embassies'**
  String get embassies;

  /// No description provided for @atms.
  ///
  /// In en, this message translates to:
  /// **'ATMs'**
  String get atms;

  /// No description provided for @publicTransit.
  ///
  /// In en, this message translates to:
  /// **'Public Transit'**
  String get publicTransit;

  /// No description provided for @publicRestrooms.
  ///
  /// In en, this message translates to:
  /// **'Public Restrooms'**
  String get publicRestrooms;

  /// No description provided for @touristAttractions.
  ///
  /// In en, this message translates to:
  /// **'Tourist Attractions'**
  String get touristAttractions;

  /// No description provided for @mapLegend.
  ///
  /// In en, this message translates to:
  /// **'Map Legend'**
  String get mapLegend;

  /// No description provided for @legendYourLocation.
  ///
  /// In en, this message translates to:
  /// **'Your Location'**
  String get legendYourLocation;

  /// No description provided for @legendIncidentReports.
  ///
  /// In en, this message translates to:
  /// **'Incident Reports'**
  String get legendIncidentReports;

  /// No description provided for @legendCautionZones.
  ///
  /// In en, this message translates to:
  /// **'Caution Zones'**
  String get legendCautionZones;

  /// No description provided for @legendHighRiskZones.
  ///
  /// In en, this message translates to:
  /// **'High Risk Zones'**
  String get legendHighRiskZones;

  /// No description provided for @legendSafeZones.
  ///
  /// In en, this message translates to:
  /// **'Safe Zones'**
  String get legendSafeZones;

  /// No description provided for @activeBadge.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeBadge;

  /// No description provided for @alertBadge.
  ///
  /// In en, this message translates to:
  /// **'Alert'**
  String get alertBadge;

  /// No description provided for @warningBadge.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warningBadge;

  /// No description provided for @dangerBadge.
  ///
  /// In en, this message translates to:
  /// **'Danger'**
  String get dangerBadge;

  /// No description provided for @safeBadge.
  ///
  /// In en, this message translates to:
  /// **'Safe'**
  String get safeBadge;

  /// No description provided for @mapCopyright.
  ///
  /// In en, this message translates to:
  /// **'Map data © OpenStreetMap contributors'**
  String get mapCopyright;

  /// No description provided for @activeAlerts.
  ///
  /// In en, this message translates to:
  /// **'Active Alerts'**
  String get activeAlerts;

  /// No description provided for @callHelpline.
  ///
  /// In en, this message translates to:
  /// **'Call Tourist Helpline'**
  String get callHelpline;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'en',
    'es',
    'fr',
    'hi',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
