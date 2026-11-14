import 'package:flutter/material.dart';
import '../../../theme/apple_style.dart';

/// Brand-gradient square with a white number, for tips and exercises.
/// Grows with very large text instead of clipping the digit.
class NumberBadge extends StatelessWidget {
  const NumberBadge({super.key, required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: AppleStyle.brandGradient,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$number',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// 38×38 tinted square holding an icon, as on the dashboard cards.
class IconBadge extends StatelessWidget {
  const IconBadge({
    super.key,
    required this.icon,
    this.color = AppleStyle.accent,
  });

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: color, size: 19),
    );
  }
}

/// In a baseline-aligned row, centres [child] on the first line of the title
/// beside it, at every text size. An empty line of title-sized text, centred
/// on the child, gives it that baseline; an icon's own sits at its bottom.
class TitleLineCentered extends StatelessWidget {
  const TitleLineCentered({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        const Text('', style: TextStyle(fontSize: 15.5, height: 1.3)),
      ],
    );
  }
}

/// A badge beside a title, with optional content under the title. The badge
/// stays centred on the title's first line.
class BadgeRow extends StatelessWidget {
  const BadgeRow({
    super.key,
    required this.badge,
    required this.title,
    this.below,
  });

  final Widget badge;
  final Widget title;
  final Widget? below;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        TitleLineCentered(child: badge),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [title, if (below != null) below!],
          ),
        ),
      ],
    );
  }
}
