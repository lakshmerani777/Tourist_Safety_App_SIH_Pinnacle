import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class WeatherData {
  final double temperature;
  final int aqi;
  final int weatherCode;

  WeatherData({
    required this.temperature,
    required this.aqi,
    required this.weatherCode,
  });

  String get description => _weatherCodeToDescription(weatherCode);
  IconData get icon => _weatherCodeToIcon(weatherCode);

  static String _weatherCodeToDescription(int code) {
    if (code == 0) return 'Clear Sky';
    if (code <= 3) return 'Partly Cloudy';
    if (code <= 48) return 'Foggy';
    if (code <= 57) return 'Drizzle';
    if (code <= 67) return 'Rain';
    if (code <= 77) return 'Snow';
    if (code <= 82) return 'Rain Showers';
    if (code <= 86) return 'Snow Showers';
    if (code >= 95) return 'Thunderstorm';
    return 'Unknown';
  }

  static IconData _weatherCodeToIcon(int code) {
    if (code == 0) return Icons.wb_sunny;
    if (code <= 3) return Icons.cloud;
    if (code <= 48) return Icons.foggy;
    if (code <= 67) return Icons.grain;
    if (code <= 77) return Icons.ac_unit;
    if (code <= 86) return Icons.cloudy_snowing;
    if (code >= 95) return Icons.thunderstorm;
    return Icons.cloud;
  }

  String get aqiLabel {
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy (SG)';
    if (aqi <= 200) return 'Unhealthy';
    if (aqi <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }

  Color get aqiColor {
    if (aqi <= 50) return const Color(0xFF34C759);
    if (aqi <= 100) return const Color(0xFFFF9F0A);
    if (aqi <= 150) return const Color(0xFFFF6B35);
    if (aqi <= 200) return const Color(0xFFFF3B3B);
    if (aqi <= 300) return const Color(0xFF8B3FD9);
    return const Color(0xFF7E0023);
  }
}

class WeatherNotifier extends ChangeNotifier {
  WeatherData? _weather;
  bool _isLoading = false;

  WeatherData? get weather => _weather;
  bool get isLoading => _isLoading;

  Future<void> fetchWeather(double lat, double lng) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Fetch weather
      final weatherUrl = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=$lat&longitude=$lng'
        '&current=temperature_2m,weather_code',
      );
      // Fetch AQI
      final aqiUrl = Uri.parse(
        'https://air-quality-api.open-meteo.com/v1/air-quality'
        '?latitude=$lat&longitude=$lng'
        '&current=us_aqi',
      );

      final responses = await Future.wait([
        http.get(weatherUrl),
        http.get(aqiUrl),
      ]);

      if (responses[0].statusCode == 200 && responses[1].statusCode == 200) {
        final weatherJson = jsonDecode(responses[0].body);
        final aqiJson = jsonDecode(responses[1].body);
        final current = weatherJson['current'];
        final aqiCurrent = aqiJson['current'];
        _weather = WeatherData(
          temperature: (current['temperature_2m'] as num).toDouble(),
          aqi: (aqiCurrent['us_aqi'] as num).toInt(),
          weatherCode: (current['weather_code'] as num).toInt(),
        );
      }
    } catch (_) {
      // Silently fail — weather is non-critical
    }

    _isLoading = false;
    notifyListeners();
  }
}

final weatherProvider = ChangeNotifierProvider<WeatherNotifier>((ref) {
  final notifier = WeatherNotifier();
  // Fetch for default location (Bandra West)
  notifier.fetchWeather(19.062641, 72.830899);
  return notifier;
});
