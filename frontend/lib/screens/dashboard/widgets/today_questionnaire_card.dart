import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/apple_style.dart';
import 'pill_button.dart';
import 'status_row.dart';

/// Bottom card on the dashboard that holds the state of today's questionnaire
/// and its primary CTA.
///
/// Pure presentation widget: all business logic (deciding which branch to
/// show, opening a questionnaire, editing today's answers) stays inside the
/// dashboard state. This widget only maps already-computed state into the
/// corresponding UI.
class TodayQuestionnaireCard extends StatelessWidget {
  const TodayQuestionnaireCard({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required this.nextQuestionnaireType,
    required this.isTodayFilled,
    required this.todayFilledType,
    required this.questionnaireReason,
    required this.nextQuestionnaireName,
    required this.todayFilledQuestionnaireName,
    required this.onFillNow,
    required this.onEditToday,
  });

  final bool isLoading;
  final String? errorMessage;
  final String? nextQuestionnaireType;
  final bool isTodayFilled;
  final String? todayFilledType;
  final String? questionnaireReason;
  final String nextQuestionnaireName;
  final String todayFilledQuestionnaireName;
  final VoidCallback onFillNow;
  final VoidCallback onEditToday;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    Widget content;

    if (isLoading) {
      content = const Padding(
        padding: EdgeInsets.symmetric(vertical: 18),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (errorMessage != null) {
      content = StatusRow(
        icon: Icons.error_outline_rounded,
        iconColor: AppleStyle.destructive,
        tintColor: AppleStyle.destructive,
        title: errorMessage == 'failed_to_load'
            ? l10n.failedToLoadQuestionnaireInfo
            : errorMessage!.startsWith('error_prefix:')
                ? l10n.error(errorMessage!.substring('error_prefix:'.length))
                : errorMessage!,
      );
    } else if (todayFilledType != null) {
      // Completed today + edit affordance.
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StatusRow(
            icon: Icons.check_circle_rounded,
            iconColor: AppleStyle.success,
            tintColor: AppleStyle.success,
            // Keep the literal word to avoid introducing a new l10n key.
            title: '$todayFilledQuestionnaireName · Completed',
          ),
          const SizedBox(height: 12),
          PillButton(
            label: l10n.editTodaysAnswers,
            icon: Icons.edit_outlined,
            onPressed: onEditToday,
            style: PillButtonStyle.secondary,
          ),
        ],
      );
    } else if (nextQuestionnaireType == null) {
      content = StatusRow(
        icon: Icons.check_circle_rounded,
        iconColor: AppleStyle.success,
        tintColor: AppleStyle.success,
        title: l10n.allQuestionnairesUpToDate,
      );
    } else if (!isTodayFilled) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StatusRow(
            icon: Icons.bolt_rounded,
            iconColor: AppleStyle.accent,
            tintColor: AppleStyle.primaryText,
            title: nextQuestionnaireName,
            subtitle: questionnaireReason,
          ),
          const SizedBox(height: 14),
          PillButton(
            label: l10n.fillItNow,
            icon: Icons.arrow_forward_rounded,
            onPressed: onFillNow,
            style: PillButtonStyle.primary,
          ),
        ],
      );
    } else {
      // Fallback: is_today_filled=true but no type was provided by the server.
      content = StatusRow(
        icon: Icons.check_circle_rounded,
        iconColor: AppleStyle.success,
        tintColor: AppleStyle.success,
        title: l10n.allQuestionnairesUpToDate,
      );
    }

    return Container(
      decoration: AppleStyle.cardDecoration(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.todaysQuestionnaire,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppleStyle.primaryText,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }
}
