import 'package:shared_preferences/shared_preferences.dart';

const _keyAuthFlowRoute = 'auth_flow_route';
const _keyOnboardingStep = 'onboarding_step';
const _keyStep1OtpSent = 'step1_otp_sent';

/// Persists auth flow state so user resumes from the same step (e.g. OTP screen).
class AuthFlowPersistence {
  static Future<void> saveAuthFlowRoute(String route) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAuthFlowRoute, route);
  }

  static Future<String?> getAuthFlowRoute() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAuthFlowRoute);
  }

  static Future<void> saveOnboardingStep(int step) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyOnboardingStep, step);
  }

  static Future<int> getOnboardingStep() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyOnboardingStep) ?? 1;
  }

  static Future<void> saveStep1OtpSent(bool sent) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyStep1OtpSent, sent);
  }

  static Future<bool> getStep1OtpSent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyStep1OtpSent) ?? false;
  }

  static Future<void> clearAuthFlow() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAuthFlowRoute);
    await prefs.remove(_keyOnboardingStep);
    await prefs.remove(_keyStep1OtpSent);
  }
}
