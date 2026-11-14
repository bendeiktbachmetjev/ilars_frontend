import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/recommendations.dart';
import '../../../theme/apple_style.dart';
import 'badges.dart';
import 'fold_card.dart';

const _groupIcons = <String, IconData>{
  'meat': Icons.set_meal_rounded,
  'grains': Icons.bakery_dining_rounded,
  'produce': Icons.eco_rounded,
  'dairy': Icons.local_drink_rounded,
  'fats': Icons.opacity_rounded,
  'drinks': Icons.local_cafe_rounded,
  'sugar': Icons.cake_rounded,
  'fatty': Icons.fastfood_rounded,
};

extension on RecLevel {
  /// Item bars and the label pill's fill.
  Color get color => switch (this) {
        RecLevel.recommended => AppleStyle.success,
        RecLevel.limit => AppleStyle.warning,
        RecLevel.avoid => AppleStyle.destructive,
      };

  /// Label text and icon, dark enough to read on the light fill.
  Color get textColor => switch (this) {
        RecLevel.recommended => AppleStyle.successText,
        RecLevel.limit => AppleStyle.warningText,
        RecLevel.avoid => AppleStyle.destructiveText,
      };

  IconData get icon => switch (this) {
        RecLevel.recommended => Icons.check_circle_rounded,
        RecLevel.limit => Icons.remove_circle_rounded,
        RecLevel.avoid => Icons.cancel_rounded,
      };

  String label(AppLocalizations l10n) => switch (this) {
        RecLevel.recommended => l10n.recLevelRecommended,
        RecLevel.limit => l10n.recLevelLimit,
        RecLevel.avoid => l10n.recLevelAvoid,
      };
}

/// One food group as an accordion card; open, it lists the advice under
/// level labels.
class FoodGroupCard extends StatefulWidget {
  const FoodGroupCard({super.key, required this.group});

  final FoodGroup group;

  @override
  State<FoodGroupCard> createState() => _FoodGroupCardState();
}

class _FoodGroupCardState extends State<FoodGroupCard> {
  bool _expanded = false;

  void _toggle() {
    HapticFeedback.selectionClick();
    setState(() => _expanded = !_expanded);
  }

  @override
  Widget build(BuildContext context) {
    final group = widget.group;

    // Each run of consecutive advice with the same level gets one label.
    final runs = <List<FoodAdvice>>[];
    for (final advice in group.advice) {
      if (runs.isEmpty || runs.last.first.level != advice.level) {
        runs.add([advice]);
      } else {
        runs.last.add(advice);
      }
    }

    return FoldCard(
      expanded: _expanded,
      onToggle: _toggle,
      header: Row(
        children: [
          IconBadge(icon: _groupIcons[group.id] ?? Icons.restaurant_rounded),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppleStyle.primaryText,
                    letterSpacing: -0.2,
                  ),
                ),
                if (group.subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    group.subtitle!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppleStyle.secondaryText,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          if (group.intro != null)
            Text(
              group.intro!,
              style: const TextStyle(
                fontSize: 14.5,
                color: AppleStyle.secondaryText,
                height: 1.42,
              ),
            ),
          for (final run in runs) _LevelBlock(advice: run),
        ],
      ),
    );
  }
}

/// A level label pill, then the advice items under it.
class _LevelBlock extends StatelessWidget {
  const _LevelBlock({required this.advice});

  /// Consecutive advice items that share one level.
  final List<FoodAdvice> advice;

  @override
  Widget build(BuildContext context) {
    final level = advice.first.level;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: level.color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(level.icon, size: 15, color: level.textColor),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  level.label(AppLocalizations.of(context)!),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: level.textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Column(
          spacing: 10,
          children: [
            for (final item in advice)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 3,
                      decoration: BoxDecoration(
                        color: level.color.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.text,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppleStyle.primaryText,
                              height: 1.4,
                            ),
                          ),
                          if (item.note != null) ...[
                            const SizedBox(height: 3),
                            Text(
                              item.note!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppleStyle.secondaryText,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}
