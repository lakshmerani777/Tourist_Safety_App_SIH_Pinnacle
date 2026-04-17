import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tourist_safety_app_sih_pinnacle/core/theme/app_theme.dart';
import 'package:tourist_safety_app_sih_pinnacle/core/router/app_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tourist_safety_app_sih_pinnacle/l10n/app_localizations.dart';
import 'package:tourist_safety_app_sih_pinnacle/providers/locale_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase init skipped: $e');
  }
  runApp(const ProviderScope(child: TouristSafetyApp()));
}

class TouristSafetyApp extends ConsumerWidget {
  const TouristSafetyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Tourist Safety',
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      locale: currentLocale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LocaleNotifier.supportedLocales,
      routerConfig: appRouter,
    );
  }
}
