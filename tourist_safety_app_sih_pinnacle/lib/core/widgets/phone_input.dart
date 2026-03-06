import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class PhoneInput extends StatefulWidget {
  final TextEditingController? controller;
  final String label;
  final ValueChanged<String>? onChanged;
  final ValueChanged<Country>? onCountryChanged;

  const PhoneInput({
    super.key,
    this.controller,
    this.label = 'Phone Number',
    this.onChanged,
    this.onCountryChanged,
  });

  @override
  State<PhoneInput> createState() => _PhoneInputState();
}

class _PhoneInputState extends State<PhoneInput> {
  Country _selectedCountry = Country(
    phoneCode: '91',
    countryCode: 'IN',
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: 'India',
    example: '9123456789',
    displayName: 'India (IN) [+91]',
    displayNameNoCountryCode: 'India (IN)',
    e164Key: '91-IN-0',
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppTypography.caption),
        const SizedBox(height: 8),
        Row(
          children: [
            GestureDetector(
              onTap: _showCountryPicker,
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Text(
                      _selectedCountry.flagEmoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+${_selectedCountry.phoneCode}',
                      style: AppTypography.body,
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down,
                        color: AppColors.textSecondary, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: widget.controller,
                keyboardType: TextInputType.phone,
                onChanged: widget.onChanged,
                style: AppTypography.body,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.card,
                  hintText: 'Phone number',
                  hintStyle: AppTypography.caption,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColors.accentBlue, width: 1.5),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showCountryPicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
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
      onSelect: (Country country) {
        setState(() => _selectedCountry = country);
        widget.onCountryChanged?.call(country);
      },
    );
  }
}
