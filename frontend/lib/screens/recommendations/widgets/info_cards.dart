import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/recommendations.dart';
import '../../../theme/apple_style.dart';
import 'badges.dart';
import 'motion.dart';

const _titleStyle = TextStyle(
  fontSize: 15.5,
  fontWeight: FontWeight.w600,
  color: AppleStyle.primaryText,
  height: 1.3,
);

const _detailStyle = TextStyle(
  fontSize: 14.5,
  color: AppleStyle.secondaryText,
  height: 1.42,
);

Widget _tipRow(Widget badge, RecTip tip) {
  return BadgeRow(
    badge: badge,
    title: Text(tip.title, style: _titleStyle),
    below: tip.detail == null
        ? null
        : Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(tip.detail!, style: _detailStyle),
          ),
  );
}

/// Opening card of the nutrition page: the first paragraph clamped to three
/// lines, with "Read more" unfolding the whole introduction.
class IntroCard extends StatefulWidget {
  const IntroCard({super.key, required this.paragraphs});

  final List<String> paragraphs;

  @override
  State<IntroCard> createState() => _IntroCardState();
}

class _IntroCardState extends State<IntroCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const bodyStyle = TextStyle(
      fontSize: 15,
      color: AppleStyle.secondaryText,
      height: 1.42,
    );
    return Container(
      decoration: AppleStyle.cardDecoration(),
      // Less at the bottom: the 44 px tall button brings its own air.
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              gradient: AppleStyle.brandGradient,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 14),
          AnimatedSize(
            duration: motionDuration(context, 240),
            curve: Curves.easeInOutCubic,
            alignment: Alignment.topLeft,
            // Full width in both states, so only the height animates.
            child: SizedBox(
              width: double.infinity,
              child: _expanded
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 8,
                      children: [
                        for (final paragraph in widget.paragraphs)
                          Text(paragraph, style: bodyStyle),
                      ],
                    )
                  : Text(
                      widget.paragraphs.first,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: bodyStyle,
                    ),
            ),
          ),
          Semantics(
            expanded: _expanded,
            child: TextButton(
              onPressed: () => setState(() => _expanded = !_expanded),
              style: TextButton.styleFrom(
                foregroundColor: AppleStyle.accent,
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 44),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                _expanded ? l10n.recShowLess : l10n.recReadMore,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A tip with its title and detail always visible: the numbered nutrition
/// tips, and the closing note on bringing foods back.
class TipCard extends StatelessWidget {
  const TipCard({super.key, required this.badge, required this.tip});

  final Widget badge;
  final RecTip tip;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppleStyle.cardDecoration(radius: 20),
      padding: const EdgeInsets.all(16),
      child: _tipRow(badge, tip),
    );
  }
}

/// The exercise programme's goals, at the top of the movement page.
class GoalsCard extends StatelessWidget {
  const GoalsCard({super.key, required this.title, required this.goals});

  final String title;
  final List<RecTip> goals;

  @override
  Widget build(BuildContext context) {
    final Widget flag = Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppleStyle.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.flag_rounded, size: 18, color: AppleStyle.accent),
    );
    return Container(
      decoration: AppleStyle.cardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppleStyle.primaryText,
              letterSpacing: -0.3,
            ),
          ),
          for (final goal in goals) _tipRow(flag, goal),
        ],
      ),
    );
  }
}
