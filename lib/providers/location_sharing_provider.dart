import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:latlong2/latlong.dart';

class LocationSharingState {
  final bool sharingWithAuthorities;
  final bool sharingWithFamily;
  final String? sessionId;
  final String? shareableLink;
  final DateTime? sharingStartedAt;

  const LocationSharingState({
    this.sharingWithAuthorities = false,
    this.sharingWithFamily = false,
    this.sessionId,
    this.shareableLink,
    this.sharingStartedAt,
  });

  LocationSharingState copyWith({
    bool? sharingWithAuthorities,
    bool? sharingWithFamily,
    String? sessionId,
    String? shareableLink,
    DateTime? sharingStartedAt,
  }) {
    return LocationSharingState(
      sharingWithAuthorities: sharingWithAuthorities ?? this.sharingWithAuthorities,
      sharingWithFamily: sharingWithFamily ?? this.sharingWithFamily,
      sessionId: sessionId ?? this.sessionId,
      shareableLink: shareableLink ?? this.shareableLink,
      sharingStartedAt: sharingStartedAt ?? this.sharingStartedAt,
    );
  }

  /// True if either sharing mode is active
  bool get isSharing => sharingWithAuthorities || sharingWithFamily;
}

class LocationSharingNotifier extends ChangeNotifier {
  LocationSharingState _state = const LocationSharingState();
  LocationSharingState get state => _state;

  static const _baseUrl = 'https://lakshmerani777.github.io/Tourist_Safety_App_SIH_Pinnacle/share_location_page.html';

  LocationSharingNotifier() {
    _loadPersistedState();
  }

  Future<void> _loadPersistedState() async {
    final prefs = await SharedPreferences.getInstance();
    final withAuth = prefs.getBool('sharing_authorities') ?? false;
    final withFam = prefs.getBool('sharing_family') ?? false;
    final sid = prefs.getString('sharing_session_id');
    final link = prefs.getString('sharing_link');

    _state = LocationSharingState(
      sharingWithAuthorities: withAuth,
      sharingWithFamily: withFam,
      sessionId: sid,
      shareableLink: link,
      sharingStartedAt: (withAuth || withFam) ? DateTime.now() : null,
    );
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sharing_authorities', _state.sharingWithAuthorities);
    await prefs.setBool('sharing_family', _state.sharingWithFamily);
    if (_state.sessionId != null) {
      await prefs.setString('sharing_session_id', _state.sessionId!);
    }
    if (_state.shareableLink != null) {
      await prefs.setString('sharing_link', _state.shareableLink!);
    }
  }

  void toggleAuthoritiesSharing(LatLng position, String name) {
    final newValue = !_state.sharingWithAuthorities;
    final sessionId = newValue
        ? (_state.sessionId ?? const Uuid().v4())
        : _state.sessionId;

    _state = _state.copyWith(
      sharingWithAuthorities: newValue,
      sessionId: sessionId,
      sharingStartedAt: newValue ? DateTime.now() : _state.sharingStartedAt,
    );

    // Rebuild the link if family sharing is also on
    if (_state.sharingWithFamily) {
      _rebuildLink(position, name);
    }

    _persist();
    notifyListeners();
  }

  void toggleFamilySharing(LatLng position, String name) {
    final newValue = !_state.sharingWithFamily;
    final sessionId = _state.sessionId ?? const Uuid().v4();

    if (newValue) {
      final link = _buildLink(position, name, sessionId);
      _state = _state.copyWith(
        sharingWithFamily: true,
        sessionId: sessionId,
        shareableLink: link,
        sharingStartedAt: DateTime.now(),
      );
    } else {
      _state = LocationSharingState(
        sharingWithAuthorities: _state.sharingWithAuthorities,
        sharingWithFamily: false,
        sessionId: _state.sessionId,
        shareableLink: null,
        sharingStartedAt: _state.sharingStartedAt,
      );
    }

    _persist();
    notifyListeners();
  }

  /// Regenerate link when position updates while sharing is active
  void updateSharedPosition(LatLng position, String name) {
    if (!_state.sharingWithFamily) return;
    _rebuildLink(position, name);
    notifyListeners();
  }

  void _rebuildLink(LatLng position, String name) {
    if (_state.sessionId == null) return;
    final link = _buildLink(position, name, _state.sessionId!);
    _state = _state.copyWith(shareableLink: link);
    _persist();
  }

  String _buildLink(LatLng pos, String name, String sessionId) {
    final encodedName = Uri.encodeComponent(name);
    return '$_baseUrl?lat=${pos.latitude}&lng=${pos.longitude}&name=$encodedName&session=$sessionId';
  }

  void stopAllSharing() {
    _state = const LocationSharingState();
    _persist();
    notifyListeners();
  }
}

final locationSharingProvider = ChangeNotifierProvider<LocationSharingNotifier>((ref) {
  return LocationSharingNotifier();
});
