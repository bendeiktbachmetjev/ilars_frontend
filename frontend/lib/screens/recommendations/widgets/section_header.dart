import 'package:flutter/material.dart';
import '../../../theme/apple_style.dart';

/// Title above a group of cards, with an optional pill (e.g. "about 30 min").
/// Carries its own spacing: 24 px above, 10 px below.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.badge});

  final String title;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 24, 4, 10),
      // A Wrap lets the pill drop under the title at large text sizes.
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Semantics(
            header: true,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppleStyle.primaryText,
                letterSpacing: -0.4,
              ),
            ),
          ),
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppleStyle.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                badge!,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppleStyle.accent,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
