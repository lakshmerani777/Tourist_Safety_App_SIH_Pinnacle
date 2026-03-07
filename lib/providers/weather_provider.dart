import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class WeatherData {
  final double temperature;
  final double windSpeed;
  final int weatherCode;

  WeatherData({
    required this.temperature,
    required this.windSpeed,
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
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=$lat&longitude=$lng'
        '&current=temperature_2m,weather_code,wind_speed_10m',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final current = json['current'];
        _weather = WeatherData(
          temperature: (current['temperature_2m'] as num).toDouble(),
          windSpeed: (current['wind_speed_10m'] as num).toDouble(),
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
