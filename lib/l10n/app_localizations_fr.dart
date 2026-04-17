// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get language => 'Langue';

  @override
  String get selectLanguage => 'Choisir la langue';

  @override
  String get profileSettings => 'Paramètres du profil';

  @override
  String get onboardingWelcome => 'Bienvenue sur Pinnacle';

  @override
  String get continueButton => 'Continuer';

  @override
  String get appTitle => 'Sécurité des Touristes';

  @override
  String get appTagline => 'Protéger chaque voyage';

  @override
  String get govBadge => 'SYSTÈME OFFICIEL DE SÉCURITÉ GOUVERNEMENTAL';

  @override
  String get signIn => 'Se connecter';

  @override
  String get loginWelcome =>
      'Bienvenue sur le Système de Sécurité des Touristes';

  @override
  String get emailAddress => 'Adresse email';

  @override
  String get enterEmail => 'Entrez votre email';

  @override
  String get password => 'Mot de passe';

  @override
  String get enterPassword => 'Entrez votre mot de passe';

  @override
  String get forgotPassword => 'Mot de passe oublié?';

  @override
  String get noAccount => 'Vous n\'avez pas de compte? ';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get errorEmptyEmail => 'Veuillez entrer votre email.';

  @override
  String get errorInvalidEmail => 'Veuillez entrer une adresse email valide.';

  @override
  String get errorEmptyPassword => 'Veuillez entrer votre mot de passe.';

  @override
  String get errorLoginFailed => 'Échec de la connexion. Veuillez réessayer.';

  @override
  String get registerWelcome =>
      'Inscrivez-vous pour accéder au Système de Sécurité';

  @override
  String get fullName => 'Nom complet';

  @override
  String get enterFullName => 'Entrez votre nom complet';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get enterConfirmPassword => 'Confirmez votre mot de passe';

  @override
  String get alreadyHaveAccount => 'Vous avez déjà un compte? ';

  @override
  String get errorEmptyName => 'Veuillez entrer votre nom complet.';

  @override
  String get errorCreatePassword => 'Veuillez créer un mot de passe.';

  @override
  String get errorShortPassword =>
      'Le mot de passe doit comporter au moins 8 caractères.';

  @override
  String get errorPasswordMismatch => 'Les mots de passe ne correspondent pas.';

  @override
  String get errorRegisterFailed =>
      'L\'inscription a échoué. Veuillez réessayer.';

  @override
  String get resetPassword => 'Réinitialiser le mot de passe';

  @override
  String get resetPasswordCaption =>
      'Entrez votre adresse email et nous vous enverrons un lien d\'accès';

  @override
  String get sendResetLink => 'Envoyer le lien';

  @override
  String get rememberPassword => 'Vous vous souvenez de votre mot de passe? ';
}
