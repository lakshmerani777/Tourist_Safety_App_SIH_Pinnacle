import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/widgets/input_field.dart';
import '../core/widgets/safety_button.dart';
import '../providers/api_providers.dart';
import '../providers/user_profile_provider.dart';
import '../services/api_client.dart';
import '../services/auth_flow_persistence.dart';
import '../l10n/app_localizations.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

final _emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onSignIn() async {
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;

    if (email.isEmpty) {
      _showError(AppLocalizations.of(context)?.errorEmptyEmail ?? 'Please enter your email.');
      return;
    }
    if (!_emailRegex.hasMatch(email)) {
      _showError(AppLocalizations.of(context)?.errorInvalidEmail ?? 'Please enter a valid email address.');
      return;
    }
    if (password.isEmpty) {
      _showError(AppLocalizations.of(context)?.errorEmptyPassword ?? 'Please enter your password.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final apiClient = ref.read(apiClientProvider);
      final sessionStorage = ref.read(sessionStorageServiceProvider);
      final response = await apiClient.signIn(email: email, password: password);
      await sessionStorage.saveSessionId(response.sessionId);
      if (!mounted) return;
      ref.read(userProfileProvider).setRegistered(response.fullName, response.email);
      if (!mounted) return;
      await AuthFlowPersistence.saveAuthFlowRoute('/onboarding');
      await AuthFlowPersistence.saveOnboardingStep(1);
      if (!mounted) return;
      context.go('/onboarding');
    } on ApiException catch (e) {
      if (mounted) _showError(e.message);
    } catch (_) {
      if (mounted) _showError(AppLocalizations.of(context)?.errorLoginFailed ?? 'Sign in failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.alertRed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Lock watermark – fixed from top so it doesn't slide when keyboard opens
            Positioned(
              top: 80,
              right: -50,
              child: Icon(
                Icons.lock_outline,
                size: 200,
                color: AppColors.textSecondary.withValues(alpha: 0.05),
              ),
            ),
            SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  // Header
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accentBlue.withValues(alpha: 0.12),
                      ),
                      child: const Icon(
                        Icons.shield,
                        size: 32,
                        color: AppColors.accentBlue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(AppLocalizations.of(context)?.signIn ?? 'Sign In', style: AppTypography.h1),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      AppLocalizations.of(context)?.loginWelcome ?? 'Welcome back to the Tourist Safety System',
                      style: AppTypography.caption,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 40),
                  InputField(
                    label: AppLocalizations.of(context)?.emailAddress ?? 'Email Address',
                    controller: _emailController,
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    hintText: AppLocalizations.of(context)?.enterEmail ?? 'Enter your email',
                  ),
                  const SizedBox(height: 20),
                  InputField(
                    label: AppLocalizations.of(context)?.password ?? 'Password',
                    controller: _passwordController,
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    hintText: AppLocalizations.of(context)?.enterPassword ?? 'Enter your password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => context.go('/reset-password'),
                      child: Text(
                        AppLocalizations.of(context)?.forgotPassword ?? 'Forgot password?',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.accentBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SafetyButton(
                    text: AppLocalizations.of(context)?.signIn ?? 'Sign In',
                    onPressed: _onSignIn,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: GestureDetector(
                      onTap: () => context.go('/register'),
                      child: RichText(
                        text: TextSpan(
                          text: AppLocalizations.of(context)?.noAccount ?? "Don't have an account? ",
                          style: AppTypography.caption,
                          children: [
                            TextSpan(
                              text: AppLocalizations.of(context)?.createAccount ?? 'Create Account',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.accentBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
