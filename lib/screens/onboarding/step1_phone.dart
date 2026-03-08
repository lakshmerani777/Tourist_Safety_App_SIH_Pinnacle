import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/phone_input.dart';
import '../../core/widgets/otp_input.dart';
import '../../core/widgets/safety_button.dart';
import '../../providers/onboarding_provider.dart';
import '../../services/auth_flow_persistence.dart';

/// Only this OTP is accepted as valid.
const String _validOtp = '0000';

class Step1Phone extends ConsumerStatefulWidget {
  const Step1Phone({super.key});

  @override
  ConsumerState<Step1Phone> createState() => _Step1PhoneState();
}

class _Step1PhoneState extends ConsumerState<Step1Phone> {
  bool _otpSent = false;
  int _resendCountdown = 60;
  Timer? _timer;
  bool _otpError = false;

  @override
  void initState() {
    super.initState();
    AuthFlowPersistence.getStep1OtpSent().then((sent) {
      if (mounted && sent) {
        setState(() {
          _otpSent = true;
          _resendCountdown = 0;
        });
      }
    });
  }

  void _sendOTP() {
    AuthFlowPersistence.saveStep1OtpSent(true);
    setState(() {
      _otpSent = true;
      _otpError = false;
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
            if (_otpError)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Invalid code. Use 0000 to continue.',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.alertRed,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            OTPInput(
              length: 4,
              onCompleted: (code) {
                ref.read(onboardingProvider).setOtpCode(code);
                final verified = code == _validOtp;
                ref.read(onboardingProvider).setOtpVerified(verified);
                setState(() => _otpError = !verified);
              },
              onChanged: (code) {
                ref.read(onboardingProvider).setOtpCode(code);
                ref.read(onboardingProvider).setOtpVerified(code == _validOtp);
                if (_otpError && code.length == 4) setState(() => _otpError = code != _validOtp);
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
