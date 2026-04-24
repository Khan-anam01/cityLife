import 'package:flutter/material.dart';

/// City Life Design System — Color Palette
/// Theme: Urban Modern — deep navy authority with electric teal energy
abstract class AppColors {
  // ── Brand Primary ──────────────────────────────────────
  static const Color primary = Color(0xFF0A2540); // Deep Navy
  static const Color primaryLight = Color(0xFF1A3F6F); // Navy Light
  static const Color primaryDark = Color(0xFF061828); // Navy Dark

  // ── Accent ─────────────────────────────────────────────
  static const Color accent = Color(0xFF00D4AA); // Electric Teal
  static const Color accentLight = Color(0xFF4DFFDC); // Teal Light
  static const Color accentDark = Color(0xFF009E7E); // Teal Dark

  // ── Secondary Accent ───────────────────────────────────
  static const Color amber = Color(0xFFFFB547); // Warm Amber (events)
  static const Color coral = Color(0xFFFF6B6B); // Coral (alerts/sos)
  static const Color lavender = Color(0xFF8B7CF6); // Lavender (social)
  static const Color sky = Color(0xFF38BDF8); // Sky Blue (map)

  // ── Neutrals ───────────────────────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF6F8FB); // Off-white bg
  static const Color surface = Color(0xFFFFFFFF); // Card surface
  static const Color border = Color(0xFFE2E8F0); // Subtle border
  static const Color divider = Color(0xFFF1F5F9); // Divider line

  // ── Text ───────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF0A2540); // Main text
  static const Color textSecondary = Color(0xFF64748B); // Muted text
  static const Color textTertiary = Color(0xFF94A3B8); // Placeholder
  static const Color textInverse = Color(0xFFFFFFFF); // Text on dark

  // ── Dark Theme ─────────────────────────────────────────
  static const Color darkBackground = Color(0xFF061828);
  static const Color darkSurface = Color(0xFF0D2137);
  static const Color darkSurfaceElevated = Color(0xFF152E48);
  static const Color darkBorder = Color(0xFF1E3A52);
  static const Color darkTextPrimary = Color(0xFFE8F4FF); // ← bright white-blue
  static const Color darkTextSecondary = Color(0xFFAAC8E0); // ← soft light blue

  // ── Semantic ───────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFFFB547);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF38BDF8);

  // ── Module Colors (for icons & cards) ─────────────────
  static const Color moduleHospital = Color(0xFFFF6B6B);
  static const Color moduleSchool = Color(0xFF38BDF8);
  static const Color moduleRestaurant = Color(0xFFFFB547);
  static const Color modulePolice = Color(0xFF0A2540);
  static const Color moduleTransport = Color(0xFF8B7CF6);
  static const Color moduleJobs = Color(0xFF00D4AA);
  static const Color moduleEvents = Color(0xFFFFB547);
  static const Color moduleNews = Color(0xFF38BDF8);
  static const Color moduleSocial = Color(0xFF8B7CF6);
  static const Color moduleReport = Color(0xFFFF6B6B);
  static const Color moduleEmergency = Color(0xFFEF4444);

  // ── Gradients ──────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentLight],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primary, Color(0xFF0D4F8C)],
  );

  static const LinearGradient cardOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Color(0xCC0A2540)],
  );
}
