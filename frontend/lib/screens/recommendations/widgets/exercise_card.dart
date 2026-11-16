import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/recommendations.dart';
import '../../../theme/apple_style.dart';
import '../../dashboard/widgets/pill_button.dart';
import 'badges.dart';
import 'exercise_animation.dart';
import 'fold_card.dart';
import 'motion.dart';

/// One exercise as an accordion card: dose pills on the face, steps inside.
///
/// A [locked] card (the Kegel exercises) shows why it is locked and an
/// Unlock button instead of the dose and steps.
class ExerciseCard extends StatefulWidget {
  const ExerciseCard({
    super.key,
    required this.exercise,
    this.number,
    this.locked = false,
    this.onUnlocked,
  });

  final Exercise exercise;

  /// Badge number; null for the walking card, which shows a walking icon
  /// and starts open.
  final int? number;
  final bool locked;

  /// Called when the patient confirms they learned the technique.
  final VoidCallback? onUnlocked;

  @override
  State<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard> {
  late bool _expanded = widget.number == null;

  // From unlocking until the next fold, the lock text stays the folded body,
  // so it cross-fades into the steps.
  bool _justUnlocked = false;

  void _toggle() {
    HapticFeedback.selectionClick();
    setState(() {
      _expanded = !_expanded;
      _justUnlocked = false;
    });
  }

  Future<void> _askToUnlock() async {
    final l10n = AppLocalizations.of(context)!;
    final bool? learned = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppleStyle.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(
          l10n.recKegelDialogTitle,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppleStyle.primaryText,
            letterSpacing: -0.3,
            height: 1.3,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: AppleStyle.secondaryText,
            ),
            child: Text(
              l10n.recKegelDialogNo,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppleStyle.accent),
            child: Text(
              l10n.recKegelDialogYes,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    if (learned != true || !mounted) return;
    HapticFeedback.lightImpact();
    widget.onUnlocked?.call();
    setState(() {
      _expanded = true;
      _justUnlocked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final exercise = widget.exercise;
    final bool locked = widget.locked;
    return FoldCard(
      expanded: !locked && _expanded,
      onToggle: locked ? null : _toggle,
      trailing: locked
          ? const Icon(
              Icons.lock_rounded,
              key: ValueKey('locked'),
              size: 20,
              color: AppleStyle.secondaryText,
            )
          : null,
      header: BadgeRow(
        badge: widget.number == null
            ? const IconBadge(icon: Icons.directions_walk_rounded)
            : NumberBadge(number: widget.number!),
        title: Text(
          exercise.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppleStyle.primaryText,
            letterSpacing: -0.2,
          ),
        ),
        // Animated so the pills slide in smoothly when the card unlocks.
        below: AnimatedSize(
          duration: motionDuration(context, 240),
          curve: Curves.easeInOutCubic,
          alignment: Alignment.topLeft,
          child: locked || exercise.dose.isEmpty
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final dose in exercise.dose)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppleStyle.inputFill,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            dose,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppleStyle.primaryText,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
        ),
      ),
      folded: locked || _justUnlocked ? _lockedBody(l10n) : null,
      // Nothing of the exercise is built while it is locked.
      body: locked ? const SizedBox.shrink() : _steps(context),
    );
  }

  Widget _lockedBody(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.recKegelLockedBody,
            style: const TextStyle(
              fontSize: 14.5,
              color: AppleStyle.secondaryText,
              height: 1.42,
            ),
          ),
          const SizedBox(height: 14),
          // PillButton has a fixed height: cap the text size so the label
          // still fits at the largest iOS text sizes.
          MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.6,
            child: PillButton(
              label: l10n.recKegelUnlock,
              icon: Icons.lock_open_rounded,
              style: PillButtonStyle.secondary,
              height: 46,
              onPressed: _askToUnlock,
            ),
          ),
        ],
      ),
    );
  }

  Widget _steps(BuildContext context) {
    // Centres each dot on the first line of its step at any text size.
    final double dotTop =
        (MediaQuery.textScalerOf(context).scale(15) * 1.42 - 6) / 2;
    final ExerciseScene? scene = exerciseScenes[widget.exercise.id];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        if (scene != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: ExerciseAnimation(scene: scene, playing: _expanded),
          ),
        for (final step in widget.exercise.steps)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 6,
                height: 6,
                margin: EdgeInsets.only(top: dotTop),
                decoration: const BoxDecoration(
                  color: AppleStyle.accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  step,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppleStyle.primaryText,
                    height: 1.42,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
