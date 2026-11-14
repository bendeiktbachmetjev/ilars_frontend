import 'package:flutter/material.dart';
import '../../../theme/apple_style.dart';
import 'badges.dart';
import 'motion.dart';

/// White card whose tappable header folds a body open and closed. Shared by
/// the food-group and exercise cards.
class FoldCard extends StatelessWidget {
  const FoldCard({
    super.key,
    required this.header,
    required this.body,
    required this.expanded,
    required this.onToggle,
    this.trailing,
    this.folded,
  });

  /// Everything left of the chevron.
  final Widget header;
  final Widget body;
  final bool expanded;

  /// Null leaves the header inert.
  final VoidCallback? onToggle;

  /// Replaces the chevron. A change pops in with a scale, so each variant
  /// needs its own key.
  final Widget? trailing;

  /// Shown under the header while folded; nothing by default.
  final Widget? folded;

  @override
  Widget build(BuildContext context) {
    final Duration fold = motionDuration(context, 240);
    return DecoratedBox(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(22)),
        boxShadow: AppleStyle.cardShadow,
      ),
      child: Material(
        color: AppleStyle.card,
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              button: onToggle != null,
              expanded: onToggle == null ? null : expanded,
              child: InkWell(
                onTap: onToggle,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 64),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    // Baseline alignment keeps the chevron level with the
                    // title's first line, however tall the header grows.
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Expanded(child: header),
                        const SizedBox(width: 8),
                        TitleLineCentered(
                          child: SizedBox(
                            width: 24,
                            child: AnimatedSwitcher(
                              duration: motionDuration(context, 320),
                              transitionBuilder: (child, animation) =>
                                  ScaleTransition(
                                    scale: animation.drive(
                                      CurveTween(curve: Curves.easeOutBack),
                                    ),
                                    child: child,
                                  ),
                              child: trailing ??
                                  AnimatedRotation(
                                    turns: expanded ? 0.5 : 0,
                                    duration: fold,
                                    curve: Curves.easeInOutCubic,
                                    child: const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 24,
                                      color: AppleStyle.secondaryText,
                                    ),
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            AnimatedCrossFade(
              duration: fold,
              sizeCurve: Curves.easeInOutCubic,
              crossFadeState: expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: folded ?? const SizedBox(width: double.infinity),
              secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Divider(
                      height: 0.5,
                      thickness: 0.5,
                      color: AppleStyle.track,
                    ),
                    const SizedBox(height: 14),
                    body,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
