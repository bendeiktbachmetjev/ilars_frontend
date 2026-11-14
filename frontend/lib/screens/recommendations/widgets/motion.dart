import 'package:flutter/material.dart';

/// Animation length for the recommendations screen. With reduced motion it
/// shrinks to a single frame, so changes land without visible movement (not
/// zero: [AnimatedSize] asserts on a zero duration).
Duration motionDuration(BuildContext context, int milliseconds) {
  return Duration(
    milliseconds: MediaQuery.disableAnimationsOf(context) ? 1 : milliseconds,
  );
}

/// Fades a list item in while it rises 12 px into place. Items are staggered
/// by [index]; only the first six move, the rest start below the fold.
class EntranceStagger extends StatelessWidget {
  const EntranceStagger({
    super.key,
    required this.animation,
    required this.index,
    required this.child,
  });

  final Animation<double> animation;
  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Same widget structure in every case, so a change of the reduced-motion
    // setting never rebuilds the child from scratch.
    final Animation<double> t =
        index < 6 && !MediaQuery.disableAnimationsOf(context)
            ? animation.drive(CurveTween(
                curve: Interval(
                  index * 0.08,
                  index * 0.08 + 0.5,
                  curve: Curves.easeOutCubic,
                ),
              ))
            : kAlwaysCompleteAnimation;
    return FadeTransition(
      opacity: t,
      child: AnimatedBuilder(
        animation: t,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, 12 * (1 - t.value)),
          child: child,
        ),
        child: child,
      ),
    );
  }
}
