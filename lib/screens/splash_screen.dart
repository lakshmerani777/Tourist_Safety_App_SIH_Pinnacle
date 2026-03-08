import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../services/auth_flow_persistence.dart';
import '../services/maps_config_service.dart';
import '../services/session_storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _animController.forward();

    // Fetch Maps API key from backend and apply on iOS (runs in parallel with splash delay)
    MapsConfigService().fetchAndApplyMapsApiKey();

    Future.delayed(const Duration(milliseconds: 2500), () async {
      if (!mounted) return;
      final sessionId = await SessionStorageService().getSessionId();
      final savedRoute = await AuthFlowPersistence.getAuthFlowRoute();
      final onboardingStep = await AuthFlowPersistence.getOnboardingStep();

      if (!mounted) return;
      if (savedRoute == '/onboarding') {
        context.go('/onboarding', extra: {'restoreStep': onboardingStep});
        return;
      }
      if (sessionId != null && sessionId.isNotEmpty) {
        context.go('/home');
        return;
      }
      context.go('/register');
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),
                  // Shield icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accentBlue.withValues(alpha: 0.12),
                    ),
                    child: const Icon(
                      Icons.shield,
                      size: 56,
                      color: AppColors.accentBlue,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // App Name
                  Text('Tourist Safety', style: AppTypography.h1),
                  const SizedBox(height: 8),
                  // Tagline
                  Text(
                    'Protecting every journey',
                    style: AppTypography.caption,
                  ),
                  const Spacer(flex: 3),
                  // Government badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      'OFFICIAL GOVERNMENT SAFETY SYSTEM',
                      style: AppTypography.caption.copyWith(
                        fontSize: 10,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
