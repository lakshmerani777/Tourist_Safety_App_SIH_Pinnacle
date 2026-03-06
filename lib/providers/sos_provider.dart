import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class SOSNotifier extends ChangeNotifier {
  bool _isActive = false;
  int _countdown = 10;
  Timer? _timer;

  bool get isActive => _isActive;
  int get countdown => _countdown;

  void activateSOS() {
    _isActive = true;
    _countdown = 10;
    _startCountdown();
    notifyListeners();
  }

  void cancelSOS() {
    _isActive = false;
    _countdown = 10;
    _timer?.cancel();
    _timer = null;
    notifyListeners();
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        _countdown--;
        notifyListeners();
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
}

final sosProvider = ChangeNotifierProvider<SOSNotifier>((ref) {
  return SOSNotifier();
});
