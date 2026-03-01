import 'package:flutter/material.dart';
import 'daily_questionnaire_screen.dart';
import 'weekly_questionnaire_screen.dart';
import 'monthly_questionnaire_screen.dart';
import 'eq5d5l_questionnaire_screen.dart';
import '../widgets/lars_line_chart.dart';
import '../services/api_service.dart';
import '../l10n/app_localizations.dart';

// Import LarsLineChartState for GlobalKey
import '../widgets/lars_line_chart.dart' show LarsLineChartState;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, this.onQuestionnaireSubmitted});

  final VoidCallback? onQuestionnaireSubmitted;

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

// Public state class to allow external refresh via GlobalKey
class DashboardScreenState extends State<DashboardScreen> {
  String? _nextQuestionnaireType; // "daily", "weekly", "monthly", "eq5d5l", or null
  bool _isTodayFilled = false;
  bool _isLoadingQuestionnaire = true;
  String? _questionnaireReason;
  String? _errorMessage;
  final GlobalKey<_StatisticsSectionState> _statisticsKey = GlobalKey<_StatisticsSectionState>();
  bool _isLoadingQuestionnaireInProgress = false; // Prevent duplicate requests
  String? _lastKnownPatientCode; // Track patient code to detect changes

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

  // Public method to refresh all data (called when patient code changes)
  Future<void> refreshAllData() async {
    // Reset loading flag to allow new request
    _isLoadingQuestionnaireInProgress = false;
    // Refresh questionnaire and statistics in parallel
    await Future.wait([
      _loadNextQuestionnaire(),
      _statisticsKey.currentState?.refresh() ?? Future.value(),
    ]);
    // Update last known patient code
    final api = ApiService();
    _lastKnownPatientCode = await api.getPatientCode();
  }

  Future<void> _loadNextQuestionnaire() async {
    // Prevent duplicate concurrent requests
    if (_isLoadingQuestionnaireInProgress) {
      return;
    }
    
    setState(() {
      _isLoadingQuestionnaire = true;
      _errorMessage = null;
      _isLoadingQuestionnaireInProgress = true;
    });

    try {
      final api = ApiService();
      final patientCode = await api.getPatientCode();
      
      if (patientCode == null || patientCode.isEmpty) {
        // Error message will be localized when displayed
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
          _questionnaireReason = response['reason'];
          _isLoadingQuestionnaire = false;
          _isLoadingQuestionnaireInProgress = false;
        });
      } else {
        setState(() {
          _nextQuestionnaireType = null;
          _isTodayFilled = false;
          _isLoadingQuestionnaire = false;
          _errorMessage = 'failed_to_load';
          _isLoadingQuestionnaireInProgress = false;
        });
      }
      } catch (e) {
        setState(() {
          _nextQuestionnaireType = null;
          _isTodayFilled = false;
          _isLoadingQuestionnaire = false;
          _errorMessage = 'error_prefix:${e.toString()}';
          _isLoadingQuestionnaireInProgress = false;
        });
      }
  }

  void _openNextQuestionnaire(BuildContext context) async {
    if (_nextQuestionnaireType == null) {
      return;
    }

    Widget screen;
    switch (_nextQuestionnaireType) {
      case 'daily':
        screen = const DailyQuestionnaireScreen();
        break;
      case 'weekly':
        screen = const WeeklyQuestionnaireScreen();
        break;
      case 'monthly':
        screen = const MonthlyQuestionnaireScreen();
        break;
      case 'eq5d5l':
        screen = const Eq5d5lQuestionnaireScreen();
        break;
      default:
        return;
    }

    // Remember which questionnaire type was opened to check after return
    final openedQuestionnaireType = _nextQuestionnaireType;
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );

    // Only reload questionnaire info if questionnaire was submitted (result == true)
    // If user closed with back arrow (result == null), don't reload
    if (result == true) {
      // Questionnaire was submitted successfully
      await _loadNextQuestionnaire();
      // If Weekly (LARS) questionnaire was submitted, refresh chart data
      // Check the type that was opened, not the current _nextQuestionnaireType (which may have changed)
      if (openedQuestionnaireType == 'weekly') {
        _statisticsKey.currentState?.refresh();
      }
      widget.onQuestionnaireSubmitted?.call();
    }
    // If result is null or false, user closed without submitting - do nothing
  }

  String _getQuestionnaireName(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (_nextQuestionnaireType) {
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_errorMessage == 'patient_code_not_set') ...[
              const SizedBox(height: 32),
              _InlineLoginForm(onLoginSuccess: refreshAllData),
            ] else ...[
              StatisticsSection(key: _statisticsKey),
              const SizedBox(height: 32),
              Text(
                AppLocalizations.of(context)!.todaysQuestionnaire,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 16),
              if (_isLoadingQuestionnaire) ...[
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
              ] else if (_errorMessage != null) ...[
                Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[700], size: 28),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage == 'failed_to_load'
                            ? AppLocalizations.of(context)!.failedToLoadQuestionnaireInfo
                            : _errorMessage!.startsWith('error_prefix:')
                                ? AppLocalizations.of(context)!.error(_errorMessage!.substring('error_prefix:'.length))
                                : _errorMessage!,
                        style: TextStyle(
                          color: Colors.red[700],
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              // Removed Retry button - getNextQuestionnaire is only called:
              // 1. On app open (initState)
              // 2. On Save patient code (refreshAllData)
              // 3. On Submit questionnaire (in _openNextQuestionnaire)
            ] else if (_nextQuestionnaireType == null) ...[
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[600], size: 28),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.allQuestionnairesUpToDate,
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ] else if (!_isTodayFilled) ...[
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber[700], size: 28),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getQuestionnaireName(context),
                          style: const TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        if (_questionnaireReason != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            _questionnaireReason!,
                            style: TextStyle(
                              color: Colors.amber[700],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[400],
                    foregroundColor: Colors.black,
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => _openNextQuestionnaire(context),
                  child: Text(AppLocalizations.of(context)!.fillItNow),
                ),
              ),
            ] else ...[
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[600], size: 28),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_getQuestionnaireName(context)} - Completed',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class StatisticsSection extends StatefulWidget {
  const StatisticsSection({super.key});

  @override
  State<StatisticsSection> createState() => _StatisticsSectionState();
}

class _StatisticsSectionState extends State<StatisticsSection> {
  final GlobalKey<LarsLineChartState> _chartKey = GlobalKey<LarsLineChartState>();

  // Public method to refresh chart
  Future<void> refresh() async {
    // Refresh chart only
    await _chartKey.currentState?.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.statistics,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 18),
        LarsLineChart(
          key: _chartKey,
        ),
      ],
    );
  }
}

class _InlineLoginForm extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  
  const _InlineLoginForm({required this.onLoginSuccess, super.key});

  @override
  State<_InlineLoginForm> createState() => _InlineLoginFormState();
}

class _InlineLoginFormState extends State<_InlineLoginForm> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  
  bool _agreedToTerms = false;
  bool _agreedToPromos = false;
  bool _isSubmitting = false;

  Future<void> _submit() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.error('Please enter a patient code'))),
      );
      return;
    }
    
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.error('You must agree to the Terms of Use and Privacy Policy to continue'))),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final api = ApiService();
      
      // 1. Validate the code
      final validateResponse = await api.validatePatientCode(patientCode: code);
      if (validateResponse['status'] != 'ok') {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(validateResponse['detail'] != null 
                ? 'Error: ${validateResponse['detail']}' 
                : 'Invalid patient code'),
            backgroundColor: Colors.red[700],
          ),
        );
        setState(() {
          _isSubmitting = false;
        });
        return;
      }
      
      // 2. Update the profile with email and consents
      final email = _emailController.text.trim();
      await api.updatePatientProfile(
        patientCode: code,
        email: email.isEmpty ? null : email,
        agreedToTerms: _agreedToTerms,
        agreedToPromos: _agreedToPromos,
      );
      
      // 3. Save the code locally
      await api.savePatientCode(code);
      
      // 4. Trigger dashboard reload
      widget.onLoginSuccess();
      
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: ${e.toString()}'),
          backgroundColor: Colors.red[700],
        ),
      );
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.pleaseSetPatientCode,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _codeController,
            decoration: InputDecoration(
              hintText: l10n.enterYourCode,
              border: const OutlineInputBorder(),
              labelText: l10n.patientCode,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Email (Optional)',
              border: OutlineInputBorder(),
              labelText: 'Email Address',
            ),
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            title: const Text('I agree to the Terms of Use and Privacy Policy', style: TextStyle(fontSize: 14)),
            value: _agreedToTerms,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (bool? value) {
              setState(() {
                _agreedToTerms = value ?? false;
              });
            },
          ),
          CheckboxListTile(
            title: const Text('I agree to receive promotional emails (Optional)', style: TextStyle(fontSize: 14)),
            value: _agreedToPromos,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (bool? value) {
              setState(() {
                _agreedToPromos = value ?? false;
              });
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Log In', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}