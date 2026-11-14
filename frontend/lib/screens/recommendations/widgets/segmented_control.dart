import 'package:flutter/material.dart';
import '../../../theme/apple_style.dart';

/// iOS-style segmented control pinned above the recommendation pages. The
/// white thumb follows [controller] live, so it slides along with a swipe.
class SegmentedControl extends StatelessWidget {
  const SegmentedControl({
    super.key,
    required this.controller,
    required this.segments,
    required this.onSelected,
  });

  final PageController controller;

  /// Icon and label of each segment, in page order.
  final List<(IconData, String)> segments;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        // Clamped so the iOS overscroll bounce cannot push the thumb out.
        final double page =
            ((controller.hasClients ? controller.page : null) ??
                    controller.initialPage.toDouble())
                .clamp(0.0, segments.length - 1.0);
        final int selected = page.round();
        return Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: AppleStyle.track,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Align(
                  alignment: Alignment(-1 + 2 * page / (segments.length - 1), 0),
                  child: FractionallySizedBox(
                    widthFactor: 1 / segments.length,
                    heightFactor: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(11),
                        boxShadow: AppleStyle.cardShadow,
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  for (final (i, (icon, label)) in segments.indexed)
                    Expanded(
                      child: _Segment(
                        icon: icon,
                        label: label,
                        selected: i == selected,
                        onTap: () => onSelected(i),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = selected ? Colors.white : AppleStyle.secondaryText;
    final Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          maxLines: 1,
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 38),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: selected
                    ? ShaderMask(
                        shaderCallback: (bounds) =>
                            AppleStyle.brandGradient.createShader(bounds),
                        child: content,
                      )
                    : content,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
