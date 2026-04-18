import 'package:flutter/material.dart';
import '../../../theme/apple_style.dart';

/// iOS-style list row: rounded icon badge + label + chevron.
class ProfileListTile extends StatelessWidget {
  const ProfileListTile({
    super.key,
    required this.leadingIcon,
    required this.label,
    required this.onTap,
  });

  final IconData leadingIcon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppleStyle.accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(
                leadingIcon,
                size: 17,
                color: AppleStyle.accent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppleStyle.primaryText,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppleStyle.secondaryText,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
