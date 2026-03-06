import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/phone_input.dart';
import '../../core/widgets/otp_input.dart';
import '../../core/widgets/safety_button.dart';
import '../../providers/onboarding_provider.dart';

class Step1Phone extends ConsumerStatefulWidget {
  const Step1Phone({super.key});

  @override
  ConsumerState<Step1Phone> createState() => _Step1PhoneState();
}

class _Step1PhoneState extends ConsumerState<Step1Phone> {
  bool _otpSent = false;
  int _resendCountdown = 60;
  Timer? _timer;

  void _sendOTP() {
    setState(() {
      _otpSent = true;
      _resendCountdown = 60;
    });
    _startResendTimer();
  }

  void _startResendTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text('Phone Verification', style: AppTypography.h1),
          const SizedBox(height: 8),
          Text(
            'We\'ll send a verification code via SMS to confirm your phone number for safety alerts.',
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          PhoneInput(
            label: 'Phone Number',
            onChanged: (val) =>
                ref.read(onboardingProvider).setPhoneNumber(val),
          ),
          const SizedBox(height: 24),
          if (!_otpSent)
            SafetyButton(
              text: 'Send Verification Code',
              onPressed: _sendOTP,
            ),
          if (_otpSent) ...[
            const SizedBox(height: 8),
            Text('Enter verification code', style: AppTypography.caption),
            const SizedBox(height: 12),
            OTPInput(
              onCompleted: (code) {
                ref.read(onboardingProvider).setOtpCode(code);
                ref.read(onboardingProvider).setOtpVerified(true);
              },
              onChanged: (code) {
                ref.read(onboardingProvider).setOtpCode(code);
              },
            ),
            const SizedBox(height: 16),
            Center(
              child: _resendCountdown > 0
                  ? Text(
                      'Resend code in ${_resendCountdown}s',
                      style: AppTypography.caption,
                    )
                  : GestureDetector(
                      onTap: _sendOTP,
                      child: Text(
                        'Resend Code',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.accentBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
            ),
          ],
        ],
      ),
    );
  }
}
