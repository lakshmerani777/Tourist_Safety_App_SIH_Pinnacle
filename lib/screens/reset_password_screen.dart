import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/widgets/input_field.dart';
import '../core/widgets/safety_button.dart';
import '../l10n/app_localizations.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              right: -30,
              bottom: 100,
              child: Icon(
                Icons.lock_outline,
                size: 200,
                color: AppColors.textSecondary.withValues(alpha: 0.05),
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accentBlue.withValues(alpha: 0.12),
                      ),
                      child: const Icon(
                        Icons.lock_reset,
                        size: 32,
                        color: AppColors.accentBlue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(AppLocalizations.of(context)?.resetPassword ?? 'Reset Password', style: AppTypography.h1),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      AppLocalizations.of(context)?.resetPasswordCaption ?? 'Enter your email and we\'ll send you a link to reset your password',
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
                  const SizedBox(height: 32),
                  SafetyButton(
                    text: AppLocalizations.of(context)?.sendResetLink ?? 'Send reset link',
                    onPressed: () {
                      // TODO: wire to reset-password API
                    },
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: GestureDetector(
                      onTap: () => context.go('/login'),
                      child: RichText(
                        text: TextSpan(
                          text: AppLocalizations.of(context)?.rememberPassword ?? 'Remember your password? ',
                          style: AppTypography.caption,
                          children: [
                            TextSpan(
                              text: AppLocalizations.of(context)?.signIn ?? 'Sign In',
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
