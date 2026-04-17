// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get language => 'Idioma';

  @override
  String get selectLanguage => 'Seleccionar idioma';

  @override
  String get profileSettings => 'Configuración de perfil';

  @override
  String get onboardingWelcome => 'Bienvenido a Pinnacle';

  @override
  String get continueButton => 'Continuar';

  @override
  String get appTitle => 'Seguridad del Turista';

  @override
  String get appTagline => 'Protegiendo cada viaje';

  @override
  String get govBadge => 'SISTEMA OFICIAL DE SEGURIDAD GUBERNAMENTAL';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get loginWelcome =>
      'Bienvenido de nuevo al Sistema de Seguridad del Turista';

  @override
  String get emailAddress => 'Correo electrónico';

  @override
  String get enterEmail => 'Ingresa tu correo';

  @override
  String get password => 'Contraseña';

  @override
  String get enterPassword => 'Ingresa tu contraseña';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get noAccount => '¿No tienes una cuenta? ';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get errorEmptyEmail => 'Por favor ingresa tu correo.';

  @override
  String get errorInvalidEmail => 'Por favor ingresa un correo válido.';

  @override
  String get errorEmptyPassword => 'Por favor ingresa tu contraseña.';

  @override
  String get errorLoginFailed =>
      'Fallo al iniciar sesión. Por favor intenta de nuevo.';

  @override
  String get registerWelcome =>
      'Regístrese para acceder al Sistema de Seguridad';

  @override
  String get fullName => 'Nombre completo';

  @override
  String get enterFullName => 'Ingresa tu nombre completo';

  @override
  String get confirmPassword => 'Confirmar Contraseña';

  @override
  String get enterConfirmPassword => 'Confirma tu contraseña';

  @override
  String get alreadyHaveAccount => '¿Ya tienes una cuenta? ';

  @override
  String get errorEmptyName => 'Por favor ingresa tu nombre completo.';

  @override
  String get errorCreatePassword => 'Por favor crea una contraseña.';

  @override
  String get errorShortPassword =>
      'La contraseña debe tener al menos 8 caracteres.';

  @override
  String get errorPasswordMismatch => 'Las contraseñas no coinciden.';

  @override
  String get errorRegisterFailed =>
      'Fallo el registro. Por favor intenta de nuevo.';

  @override
  String get resetPassword => 'Restablecer contraseña';

  @override
  String get resetPasswordCaption =>
      'Ingresa tu correo y te enviaremos un enlace para restablecer tu contraseña';

  @override
  String get sendResetLink => 'Enviar enlace';

  @override
  String get rememberPassword => '¿Recuerdas tu contraseña? ';
}
