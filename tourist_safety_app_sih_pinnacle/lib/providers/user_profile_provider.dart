import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class UserProfile {
  final String fullName;
  final String email;
  final bool isRegistered;
  final bool isOnboarded;

  const UserProfile({
    this.fullName = '',
    this.email = '',
    this.isRegistered = false,
    this.isOnboarded = false,
  });

  UserProfile copyWith({
    String? fullName,
    String? email,
    bool? isRegistered,
    bool? isOnboarded,
  }) {
    return UserProfile(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      isRegistered: isRegistered ?? this.isRegistered,
      isOnboarded: isOnboarded ?? this.isOnboarded,
    );
  }
}

class UserProfileNotifier extends ChangeNotifier {
  UserProfile _profile = const UserProfile();

  UserProfile get profile => _profile;

  void setRegistered(String fullName, String email) {
    _profile = _profile.copyWith(
      fullName: fullName,
      email: email,
      isRegistered: true,
    );
    notifyListeners();
  }

  void setOnboarded() {
    _profile = _profile.copyWith(isOnboarded: true);
    notifyListeners();
  }

  void reset() {
    _profile = const UserProfile();
    notifyListeners();
  }
}

final userProfileProvider = ChangeNotifierProvider<UserProfileNotifier>((ref) {
  return UserProfileNotifier();
});
