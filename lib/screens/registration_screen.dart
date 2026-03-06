import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/widgets/input_field.dart';
import '../core/widgets/safety_button.dart';
import '../providers/user_profile_provider.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Lock watermark
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
                    child: Text('Create Account', style: AppTypography.h1),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Register to access the Tourist Safety System',
                      style: AppTypography.caption,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 40),
                  InputField(
                    label: 'Full Name',
                    controller: _nameController,
                    prefixIcon: Icons.person_outline,
                    hintText: 'Enter your full name',
                  ),
                  const SizedBox(height: 20),
                  InputField(
                    label: 'Email Address',
                    controller: _emailController,
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    hintText: 'Enter your email',
                  ),
                  const SizedBox(height: 20),
                  InputField(
                    label: 'Password',
                    controller: _passwordController,
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    hintText: 'Create a password',
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
                  const SizedBox(height: 20),
                  InputField(
                    label: 'Confirm Password',
                    controller: _confirmPasswordController,
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscureConfirm,
                    hintText: 'Confirm your password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SafetyButton(
                    text: 'Create Account',
                    onPressed: () {
                      ref.read(userProfileProvider).setRegistered(
                            _nameController.text,
                            _emailController.text,
                          );
                      context.go('/onboarding');
                    },
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        // Sign in flow — placeholder
                      },
                      child: RichText(
                        text: TextSpan(
                          text: 'Already have an account? ',
                          style: AppTypography.caption,
                          children: [
                            TextSpan(
                              text: 'Sign In',
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
