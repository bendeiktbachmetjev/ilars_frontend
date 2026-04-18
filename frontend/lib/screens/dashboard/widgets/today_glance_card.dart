import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/apple_style.dart';

/// Compact "at a glance" strip that sits between the chart and the today's
/// questionnaire card.
///
/// It is a pure visual companion and reads only state already computed on
/// the dashboard — no new API calls.
class TodayGlanceCard extends StatelessWidget {
  const TodayGlanceCard({
    super.key,
    required this.isLoading,
    required this.hasError,
    required this.todayFilled,
  });

  final bool isLoading;
  final bool hasError;
  final bool todayFilled;

  @override
  Widget build(BuildContext context) {
    final Color accent = hasError
        ? AppleStyle.destructive
        : isLoading
            ? AppleStyle.secondaryText
            : todayFilled
                ? AppleStyle.success
                : AppleStyle.accent; // purple for "pending", per design.
    final IconData icon = hasError
        ? Icons.error_outline_rounded
        : isLoading
            ? Icons.hourglass_empty_rounded
            : todayFilled
                ? Icons.check_circle_outline_rounded
                : Icons.schedule_rounded;

    return Container(
      decoration: AppleStyle.cardDecoration(radius: 20),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: accent, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.statistics,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppleStyle.secondaryText,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  todayFilled
                      ? AppLocalizations.of(context)!.allQuestionnairesUpToDate
                      : AppLocalizations.of(context)!.todaysQuestionnaire,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: AppleStyle.primaryText,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
          // Activity pill on the right for visual balance.
          Container(
            width: 36,
            height: 6,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.25),
              borderRadius: BorderRadius.circular(999),
            ),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: todayFilled ? 1.0 : (hasError ? 0.3 : 0.6),
              child: Container(
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
