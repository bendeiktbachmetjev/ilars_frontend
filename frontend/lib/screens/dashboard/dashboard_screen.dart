import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/api_service.dart';
import '../../theme/apple_style.dart';
import '../questionnaires/daily_questionnaire_screen.dart';
import '../questionnaires/eq5d5l_questionnaire_screen.dart';
import '../questionnaires/monthly_questionnaire_screen.dart';
import '../questionnaires/weekly_questionnaire_screen.dart';
import 'widgets/inline_login_form.dart';
import 'widgets/statistics_section.dart';
import 'widgets/today_glance_card.dart';
import 'widgets/today_questionnaire_card.dart';

/// Dashboard root. Owns all state and controllers; defers presentation to
/// small widgets in the `widgets/` folder so this file stays focused on
/// loading, refreshing and navigation logic.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    this.onQuestionnaireSubmitted,
    this.onPatientCodeChanged,
  });

  final VoidCallback? onQuestionnaireSubmitted;
  final VoidCallback? onPatientCodeChanged;

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

/// Public state — exposed so `main.dart` can call [refreshAllData] through a
/// `GlobalKey<DashboardScreenState>`.
class DashboardScreenState extends State<DashboardScreen> {
  // "daily", "weekly", "monthly", "eq5d5l", or null
  String? _nextQuestionnaireType;
  bool _isTodayFilled = false;

  // Which type was already filled today (if any). Used to offer an
  // "Edit today's answers" button that re-opens the same questionnaire
  // pre-filled with today's saved values.
  String? _todayFilledType;
  bool _isLoadingQuestionnaire = true;
  String? _questionnaireReason;
  String? _errorMessage;

  final GlobalKey<StatisticsSectionState> _statisticsKey =
      GlobalKey<StatisticsSectionState>();

  bool _isLoadingQuestionnaireInProgress = false;
  String? _lastKnownPatientCode;

  @override
  void initState() {
    super.initState();
    _loadNextQuestionnaire();
    _loadInitialPatientCode();
  }

  Future<void> _loadInitialPatientCode() async {
    final api = ApiService();
    _lastKnownPatientCode = await api.getPatientCode();
  }

  Future<void> refreshAllData() async {
    // Reset loading flag to allow a new request.
    _isLoadingQuestionnaireInProgress = false;
    // Refresh questionnaire and statistics in parallel.
    await Future.wait([
      _loadNextQuestionnaire(),
      _statisticsKey.currentState?.refresh() ?? Future.value(),
    ]);
    final api = ApiService();
    _lastKnownPatientCode = await api.getPatientCode();

    widget.onPatientCodeChanged?.call();
  }

  Future<void> _loadNextQuestionnaire() async {
    if (_isLoadingQuestionnaireInProgress) return;

    setState(() {
      _isLoadingQuestionnaire = true;
      _errorMessage = null;
      _isLoadingQuestionnaireInProgress = true;
    });

    try {
      final api = ApiService();
      final patientCode = await api.getPatientCode();

      if (patientCode == null || patientCode.isEmpty) {
        setState(() {
          _nextQuestionnaireType = null;
          _isTodayFilled = false;
          _isLoadingQuestionnaire = false;
          _errorMessage = 'patient_code_not_set';
        });
        return;
      }

      final response = await api.getNextQuestionnaire(patientCode: patientCode);

      if (response['status'] == 'ok') {
        setState(() {
          _nextQuestionnaireType = response['questionnaire_type'];
          _isTodayFilled = response['is_today_filled'] ?? false;
          _todayFilledType = response['today_filled_type'] as String?;
          _questionnaireReason = response['reason'];
          _isLoadingQuestionnaire = false;
          _isLoadingQuestionnaireInProgress = false;
        });
      } else {
        setState(() {
          _nextQuestionnaireType = null;
          _isTodayFilled = false;
          _todayFilledType = null;
          _isLoadingQuestionnaire = false;
          _errorMessage = 'failed_to_load';
          _isLoadingQuestionnaireInProgress = false;
        });
      }
    } catch (e) {
      setState(() {
        _nextQuestionnaireType = null;
        _isTodayFilled = false;
        _todayFilledType = null;
        _isLoadingQuestionnaire = false;
        _errorMessage = 'error_prefix:${e.toString()}';
        _isLoadingQuestionnaireInProgress = false;
      });
    }
  }

  void _openNextQuestionnaire(BuildContext context) async {
    if (_nextQuestionnaireType == null) return;
    await _openQuestionnaire(context, _nextQuestionnaireType!,
        initialData: null);
  }

  /// Re-open the questionnaire the patient already filled today, with the
  /// form pre-filled from the server so they can correct a mistake.
  Future<void> _editTodayQuestionnaire(BuildContext context) async {
    final type = _todayFilledType;
    if (type == null) return;

    final l10n = AppLocalizations.of(context)!;
    final api = ApiService();
    final code = await api.getPatientCode();
    if (code == null || code.isEmpty) return;

    Map<String, dynamic>? initialData;
    try {
      initialData = await api.getTodayEntry(patientCode: code, type: type);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.error(e.toString()))),
      );
      return;
    }

    if (!context.mounted) return;
    await _openQuestionnaire(context, type, initialData: initialData);
  }

  Future<void> _openQuestionnaire(
    BuildContext context,
    String type, {
    required Map<String, dynamic>? initialData,
  }) async {
    Widget screen;
    switch (type) {
      case 'daily':
        screen = DailyQuestionnaireScreen(initialData: initialData);
        break;
      case 'weekly':
        screen = WeeklyQuestionnaireScreen(initialData: initialData);
        break;
      case 'monthly':
        screen = MonthlyQuestionnaireScreen(initialData: initialData);
        break;
      case 'eq5d5l':
        screen = Eq5d5lQuestionnaireScreen(initialData: initialData);
        break;
      default:
        return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );

    // Only reload if the questionnaire was actually submitted (result == true).
    if (result == true) {
      await _loadNextQuestionnaire();
      // Weekly (LARS) submissions move the chart, so refresh statistics too.
      if (type == 'weekly') {
        _statisticsKey.currentState?.refresh();
      }
      widget.onQuestionnaireSubmitted?.call();
    }
  }

  String _questionnaireNameFor(BuildContext context, String? type) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case 'daily':
        return l10n.dailyQuestionnaire;
      case 'weekly':
        return l10n.weeklyQuestionnaire;
      case 'monthly':
        return l10n.monthlyQuestionnaire;
      case 'eq5d5l':
        return l10n.qualityOfLifeQuestionnaire;
      default:
        return l10n.noQuestionnaireNeeded;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Material (instead of Container) so the surface color fills the full
    // IndexedStack viewport even when scroll content is shorter than screen.
    return Material(
      color: AppleStyle.surface,
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: _errorMessage == 'patient_code_not_set'
              ? Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: InlineLoginForm(onLoginSuccess: refreshAllData),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Statistics block: chart lives inside a rounded card.
                    Container(
                      decoration: AppleStyle.cardDecoration(),
                      padding: const EdgeInsets.fromLTRB(4, 18, 4, 14),
                      child: StatisticsSection(key: _statisticsKey),
                    ),
                    const SizedBox(height: 14),
                    // Secondary "at a glance" strip — reads only state the
                    // dashboard already holds, no extra API calls.
                    TodayGlanceCard(
                      isLoading: _isLoadingQuestionnaire,
                      hasError: _errorMessage != null,
                      todayFilled:
                          _todayFilledType != null || _isTodayFilled,
                    ),
                    const SizedBox(height: 14),
                    // Anchored at the bottom of the scroll content.
                    TodayQuestionnaireCard(
                      isLoading: _isLoadingQuestionnaire,
                      errorMessage: _errorMessage,
                      nextQuestionnaireType: _nextQuestionnaireType,
                      isTodayFilled: _isTodayFilled,
                      todayFilledType: _todayFilledType,
                      questionnaireReason: _questionnaireReason,
                      nextQuestionnaireName:
                          _questionnaireNameFor(context, _nextQuestionnaireType),
                      todayFilledQuestionnaireName:
                          _questionnaireNameFor(context, _todayFilledType),
                      onFillNow: () => _openNextQuestionnaire(context),
                      onEditToday: () => _editTodayQuestionnaire(context),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
