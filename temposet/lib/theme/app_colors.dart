import 'package:flutter/material.dart';

/// TempoSet Color Palette — extracted from Stitch design system.
class AppColors {
  AppColors._();

  // ── Primary ──
  static const Color primary = Color(0xFF25D1F4);

  // ── Backgrounds ──
  static const Color backgroundDark = Color(0xFF101F22);
  static const Color surface = Color(0xFF1A2F33);
  static const Color navBackground = Color(0xFF0A1518);
  static const Color iconBackground = Color(0xFF1E3E43);

  // ── Text ──
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF94A3B8); // slate-400
  static const Color textTertiary = Color(0xFF64748B); // slate-500

  // ── Accent variations ──
  static const Color primaryMuted = Color(0x1A25D1F4);  // 10% opacity
  static const Color primaryGlow = Color(0x3325D1F4);   // 20% opacity
  static const Color primarySubtle = Color(0x0D25D1F4);  // 5% opacity

  // ── Functional ──
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);

  // ── Borders ──
  static Color borderSubtle = primary.withValues(alpha: 0.1);
  static Color borderMedium = primary.withValues(alpha: 0.2);
  static Color borderStrong = primary.withValues(alpha: 0.5);
}
