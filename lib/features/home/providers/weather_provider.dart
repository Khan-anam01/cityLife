import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

// ── Weather data model ─────────────────────────────────
class WeatherData {
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int weatherCode;
  final String condition;
  final String emoji;
  final String cityName;
  final bool isDay;

  const WeatherData({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.weatherCode,
    required this.condition,
    required this.emoji,
    required this.cityName,
    required this.isDay,
  });
}

// ── WMO weather code → human label + emoji ─────────────
// https://open-meteo.com/en/docs#weathervariables
String _conditionFromCode(int code, bool isDay) {
  if (code == 0) return isDay ? 'Clear Sky' : 'Clear Night';
  if (code == 1) return 'Mainly Clear';
  if (code == 2) return 'Partly Cloudy';
  if (code == 3) return 'Overcast';
  if (code <= 49) return 'Foggy';
  if (code <= 59) return 'Drizzle';
  if (code <= 69) return 'Rain';
  if (code <= 79) return 'Snow';
  if (code <= 82) return 'Rain Showers';
  if (code <= 84) return 'Snow Showers';
  if (code <= 99) return 'Thunderstorm';
  return 'Unknown';
}

String _emojiFromCode(int code, bool isDay) {
  if (code == 0) return isDay ? '☀️' : '🌙';
  if (code == 1) return isDay ? '🌤️' : '🌙';
  if (code == 2) return '⛅';
  if (code == 3) return '☁️';
  if (code <= 49) return '🌫️';
  if (code <= 59) return '🌦️';
  if (code <= 69) return '🌧️';
  if (code <= 79) return '❄️';
  if (code <= 82) return '🌧️';
  if (code <= 84) return '🌨️';
  if (code <= 99) return '⛈️';
  return '🌡️';
}

// ── Repository ─────────────────────────────────────────
class WeatherRepository {
  static const _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  Future<WeatherData> fetchWeather() async {
    // 1. Get device location (fall back to Nairobi if denied)
    double lat = -1.2864;
    double lon = 36.8172;
    String cityName = 'Nairobi, Kenya';

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission != LocationPermission.denied &&
            permission != LocationPermission.deniedForever) {
          final pos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low, // low = faster, less battery
          );
          lat = pos.latitude;
          lon = pos.longitude;

          // 2. Reverse geocode to get city name
          try {
            final placemarks = await placemarkFromCoordinates(lat, lon);
            if (placemarks.isNotEmpty) {
              final p = placemarks.first;
              final parts = [
                p.locality ?? p.subAdministrativeArea,
                p.country,
              ].whereType<String>().where((s) => s.isNotEmpty).toList();
              if (parts.isNotEmpty) cityName = parts.join(', ');
            }
          } catch (_) {
            // Geocoding failed — keep default city name
          }
        }
      }
    } catch (_) {
      // Location failed — use Nairobi default
    }

    // 3. Fetch weather from Open-Meteo (no API key required)
    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'latitude': lat.toString(),
      'longitude': lon.toString(),
      'current': [
        'temperature_2m',
        'apparent_temperature',
        'relative_humidity_2m',
        'wind_speed_10m',
        'weather_code',
        'is_day',
      ].join(','),
      'wind_speed_unit': 'kmh',
      'timezone': 'auto',
    });

    final response = await http.get(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('Weather API returned ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final current = json['current'] as Map<String, dynamic>;

    final weatherCode = (current['weather_code'] as num).toInt();
    final isDay = (current['is_day'] as num).toInt() == 1;

    return WeatherData(
      temperature: (current['temperature_2m'] as num).toDouble(),
      feelsLike: (current['apparent_temperature'] as num).toDouble(),
      humidity: (current['relative_humidity_2m'] as num).toInt(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      weatherCode: weatherCode,
      condition: _conditionFromCode(weatherCode, isDay),
      emoji: _emojiFromCode(weatherCode, isDay),
      cityName: cityName,
      isDay: isDay,
    );
  }
}

// ── Riverpod provider ──────────────────────────────────
final weatherProvider = FutureProvider.autoDispose<WeatherData>((ref) async {
  return WeatherRepository().fetchWeather();
});
