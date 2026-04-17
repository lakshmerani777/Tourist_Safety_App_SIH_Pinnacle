import 'package:go_router/go_router.dart';
import 'package:tourist_safety_app_sih_pinnacle/screens/splash_screen.dart';
import 'package:tourist_safety_app_sih_pinnacle/screens/registration_screen.dart';
import 'package:tourist_safety_app_sih_pinnacle/screens/login_screen.dart';
import 'package:tourist_safety_app_sih_pinnacle/screens/reset_password_screen.dart';
import 'package:tourist_safety_app_sih_pinnacle/screens/onboarding_screen.dart';
import 'package:tourist_safety_app_sih_pinnacle/screens/home_dashboard_screen.dart';
import 'package:tourist_safety_app_sih_pinnacle/screens/sos_activated_screen.dart';
import 'package:tourist_safety_app_sih_pinnacle/screens/map_view_screen.dart';
import 'package:tourist_safety_app_sih_pinnacle/screens/emergency_contacts_screen.dart';
import 'package:tourist_safety_app_sih_pinnacle/screens/report_incident_screen.dart';
import 'package:tourist_safety_app_sih_pinnacle/screens/alerts_screen.dart';
import 'package:tourist_safety_app_sih_pinnacle/screens/profile_screen.dart';
import 'package:tourist_safety_app_sih_pinnacle/screens/police_dashboard_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegistrationScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/reset-password',
      builder: (context, state) => const ResetPasswordScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) {
        final extra = state.extra;
        final restoreStep = extra is Map ? extra['restoreStep'] as int? : null;
        return OnboardingScreen(restoreStep: restoreStep);
      },
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeDashboardScreen(),
    ),
    GoRoute(
      path: '/sos',
      builder: (context, state) => const SOSActivatedScreen(),
    ),
    GoRoute(
      path: '/map',
      builder: (context, state) => const MapViewScreen(),
    ),
    GoRoute(
      path: '/emergency',
      builder: (context, state) => const EmergencyContactsScreen(),
    ),
    GoRoute(
      path: '/report',
      builder: (context, state) => const ReportIncidentScreen(),
    ),
    GoRoute(
      path: '/alerts',
      builder: (context, state) => const AlertsScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/police-dashboard',
      builder: (context, state) => const PoliceDashboardLoginScreen(),
    ),
  ],
);
