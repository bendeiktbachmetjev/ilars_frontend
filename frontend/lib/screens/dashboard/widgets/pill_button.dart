import 'package:flutter/material.dart';
import '../../../theme/apple_style.dart';

/// Visual variants for [PillButton].
enum PillButtonStyle {
  /// Brand gradient fill. Use for the primary action on a screen/card.
  primary,

  /// Soft neutral fill. Use for secondary actions (edit, logout, cancel).
  secondary,

  /// Soft neutral fill with destructive red text + icon (unsubscribe, etc).
  destructive,
}

/// Full-width rounded button shared across dashboard and profile screens.
class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.style,
    this.icon,
    this.height,
  });

  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final PillButtonStyle style;
  final double? height;

  @override
  Widget build(BuildContext context) {
    if (style == PillButtonStyle.primary) {
      return SizedBox(
        width: double.infinity,
        height: height ?? 52,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: AppleStyle.brandGradient,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x263A8DFF),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: InkWell(
              onTap: onPressed,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  if (icon != null) ...[
                    const SizedBox(width: 8),
                    Icon(icon, color: Colors.white, size: 18),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }

    // secondary / destructive share the same soft neutral pill, differing
    // only in foreground tint.
    final Color fg = style == PillButtonStyle.destructive
        ? AppleStyle.destructive
        : AppleStyle.accent;
    final Color labelFg = style == PillButtonStyle.destructive
        ? AppleStyle.destructive
        : AppleStyle.primaryText;

    return SizedBox(
      width: double.infinity,
      height: height ?? 46,
      child: TextButton.icon(
        style: TextButton.styleFrom(
          backgroundColor: AppleStyle.inputFill,
          foregroundColor: labelFg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18),
        ),
        onPressed: onPressed,
        icon: Icon(icon ?? Icons.edit_outlined, size: 17, color: fg),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
            color: labelFg,
          ),
        ),
      ),
    );
  }
}
