import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class CountrySelect extends StatelessWidget {
  final String label;
  final Country? selectedCountry;
  final ValueChanged<Country> onSelect;

  const CountrySelect({
    super.key,
    required this.label,
    this.selectedCountry,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.caption),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showPicker(context),
          child: Container(
            width: double.infinity,
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                if (selectedCountry != null) ...[
                  Text(selectedCountry!.flagEmoji,
                      style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selectedCountry!.name,
                      style: AppTypography.body,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: Text(
                      'Select country',
                      style: AppTypography.caption,
                    ),
                  ),
                ],
                const Icon(Icons.keyboard_arrow_down,
                    color: AppColors.textSecondary, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showPicker(BuildContext context) {
    showCountryPicker(
      context: context,
      countryListTheme: CountryListThemeData(
        backgroundColor: AppColors.card,
        textStyle: AppTypography.body,
        searchTextStyle: AppTypography.body,
        bottomSheetHeight: MediaQuery.of(context).size.height * 0.7,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        inputDecoration: InputDecoration(
          hintText: 'Search country',
          hintStyle: AppTypography.caption,
          prefixIcon:
              const Icon(Icons.search, color: AppColors.textSecondary),
          filled: true,
          fillColor: AppColors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
        ),
      ),
      onSelect: onSelect,
    );
  }
}
