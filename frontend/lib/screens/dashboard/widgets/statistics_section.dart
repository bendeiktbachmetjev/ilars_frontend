import 'package:flutter/material.dart';
import '../../../widgets/lars_line_chart.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/apple_style.dart';

/// "Statistics" card: section title + LARS/steps chart.
///
/// State is made public so [DashboardScreenState] can poke it via a
/// `GlobalKey<StatisticsSectionState>` to trigger a chart refresh after a
/// questionnaire is submitted or the patient code changes.
class StatisticsSection extends StatefulWidget {
  const StatisticsSection({super.key});

  @override
  State<StatisticsSection> createState() => StatisticsSectionState();
}

class StatisticsSectionState extends State<StatisticsSection> {
  final GlobalKey<LarsLineChartState> _chartKey =
      GlobalKey<LarsLineChartState>();

  Future<void> refresh() async {
    await _chartKey.currentState?.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: Text(
            AppLocalizations.of(context)!.statistics,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: AppleStyle.primaryText,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.left,
          ),
        ),
        LarsLineChart(key: _chartKey),
      ],
    );
  }
}
