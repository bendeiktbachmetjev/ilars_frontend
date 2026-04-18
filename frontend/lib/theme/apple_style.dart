import 'package:flutter/material.dart';

/// Shared Apple-style visual constants used across the dashboard, profile
/// and questionnaire screens. Centralising the palette here keeps the look
/// consistent and makes it easy to tweak without touching any screen logic.
class AppleStyle {
  AppleStyle._();

  // ---- Surfaces -----------------------------------------------------------
  /// Main app background. All top-level surfaces (scaffold, app bar, nav
  /// bar, screen bodies) use this tone so there are no visible "white vs
  /// grey" seams between chrome and content.
  static const Color surface = Color(0xFFF5F5F7);

  /// Elevated card fill — pops against [surface] thanks to a subtle shadow.
  static const Color card = Colors.white;

  /// Filled-input / soft-neutral fill used for text fields and secondary
  /// pill buttons.
  static const Color inputFill = Color(0xFFF2F2F7);

  // ---- Text ---------------------------------------------------------------
  static const Color primaryText = Color(0xFF111111);
  static const Color secondaryText = Color(0xFF6B7280);

  // ---- Semantic colors ----------------------------------------------------
  static const Color success = Color(0xFF34C759);
  static const Color destructive = Color(0xFFFF3B30);

  // ---- Brand / accent -----------------------------------------------------
  /// Brand gradient endpoints (used for the iLARS wordmark and primary CTAs).
  static const Color gradientStart = Color(0xFF3A8DFF);
  static const Color gradientEnd = Color(0xFF8F5CFF);

  /// Purple accent used for neutral / primary iconography. Matches the end
  /// of the brand gradient so icons feel at home next to the iLARS logo.
  static const Color accent = Color(0xFF8F5CFF);

  static const LinearGradient brandGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ---- Elevation ----------------------------------------------------------
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static BoxDecoration cardDecoration({Color? color, double radius = 22}) {
    return BoxDecoration(
      color: color ?? card,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: cardShadow,
    );
  }

  // ---- Inputs -------------------------------------------------------------
  /// Rounded filled text-field decoration with a gradient-tinted focus ring.
  static InputDecoration appleInputDecoration(String hint, {String? label}) {
    return InputDecoration(
      hintText: hint,
      labelText: label,
      filled: true,
      fillColor: inputFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: gradientStart, width: 1.4),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}
