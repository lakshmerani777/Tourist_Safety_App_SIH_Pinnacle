import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tourist_safety_app_sih_pinnacle/core/theme/app_theme.dart';
import 'package:tourist_safety_app_sih_pinnacle/core/router/app_router.dart';

void main() {
  runApp(const ProviderScope(child: TouristSafetyApp()));
}

class TouristSafetyApp extends StatelessWidget {
  const TouristSafetyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Tourist Safety',
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: appRouter,
    );
  }
}
