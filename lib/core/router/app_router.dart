import 'package:go_router/go_router.dart';
import '../../screens/splash_screen.dart';
import '../../screens/registration_screen.dart';
import '../../screens/onboarding_screen.dart';
import '../../screens/home_dashboard_screen.dart';
import '../../screens/sos_activated_screen.dart';
import '../../screens/map_view_screen.dart';
import '../../screens/emergency_contacts_screen.dart';
import '../../screens/report_incident_screen.dart';

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
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
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
  ],
);
