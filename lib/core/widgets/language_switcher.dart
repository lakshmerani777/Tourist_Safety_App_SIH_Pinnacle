import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tourist_safety_app_sih_pinnacle/providers/locale_provider.dart';
import 'package:tourist_safety_app_sih_pinnacle/core/theme/app_colors.dart';
import 'package:tourist_safety_app_sih_pinnacle/core/theme/app_typography.dart';

class LanguageSwitcher extends ConsumerWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);

    return DropdownButtonHideUnderline(
      child: DropdownButton<Locale>(
        value: currentLocale,
        icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
        dropdownColor: AppColors.card,
        style: AppTypography.body.copyWith(color: AppColors.textPrimary, fontSize: 14),
        onChanged: (Locale? newLocale) {
          if (newLocale != null) {
            ref.read(localeProvider.notifier).setLocale(newLocale);
          }
        },
        items: LocaleNotifier.supportedLocales.map((Locale locale) {
          return DropdownMenuItem<Locale>(
            value: locale,
            child: Text(
              LocaleNotifier.localeNames[locale.languageCode] ?? locale.languageCode,
            ),
          );
        }).toList(),
      ),
    );
  }
}
