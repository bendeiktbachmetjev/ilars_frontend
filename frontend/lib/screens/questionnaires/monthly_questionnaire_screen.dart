import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/apple_style.dart';

class MonthlyQuestionnaireScreen extends StatefulWidget {
  /// When non-null, the screen opens in "edit" mode and pre-fills its state
  /// from the map. Keys match the backend column names for monthly_entries.
  final Map<String, dynamic>? initialData;

  const MonthlyQuestionnaireScreen({super.key, this.initialData});

  @override
  State<MonthlyQuestionnaireScreen> createState() => _MonthlyQuestionnaireScreenState();
}

class _MonthlyQuestionnaireScreenState extends State<MonthlyQuestionnaireScreen> {
  // null = not answered yet. Nothing is pre-selected, so an untouched
  // slider can never be saved as a real answer.
  int? avoidTravel;
  int? avoidSocial;
  int? embarrassed;
  int? worryNotice;
  int? depressed;
  int? control;
  int? satisfaction;
  bool showMissing = false;

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;
    if (d != null) {
      avoidTravel = (d['avoid_travel'] as num?)?.toInt();
      avoidSocial = (d['avoid_social'] as num?)?.toInt();
      embarrassed = (d['embarrassed'] as num?)?.toInt();
      worryNotice = (d['worry_notice'] as num?)?.toInt();
      depressed = (d['depressed'] as num?)?.toInt();
      control = (d['control'] as num?)?.toInt();
      satisfaction = (d['satisfaction'] as num?)?.toInt();
    }
  }

  final TextStyle labelStyle = const TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
  final Color activeColor = Colors.black;

  /// [value] is null until the patient touches the slider: the thumb then sits
  /// at [min] greyed out and "—" is shown. A tap where the thumb already is
  /// only fires onChangeStart, so it is used to record that first answer too.
  Widget _buildLikertSlider({
    required String label,
    required int? value,
    required int min,
    required int max,
    required void Function(int) onChanged,
  }) {
    final color = value == null ? Colors.grey[400] : activeColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: labelStyle.copyWith(color: showMissing && value == null ? Colors.red : null),
              ),
            ),
            Text(value?.toString() ?? '—', style: labelStyle),
          ],
        ),
        Row(
          children: [
            Text('$min', style: const TextStyle(fontSize: 14)),
            Expanded(
              child: Slider(
                value: (value ?? min).toDouble(),
                min: min.toDouble(),
                max: max.toDouble(),
                divisions: max - min,
                label: value?.toString(),
                onChangeStart: value == null ? (v) => onChanged(v.round()) : null,
                onChanged: (v) => onChanged(v.round()),
                activeColor: color,
                thumbColor: color,
              ),
            ),
            Text('$max', style: const TextStyle(fontSize: 14)),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppleStyle.surface,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.monthlyQualityOfLife),
        centerTitle: true,
        backgroundColor: AppleStyle.surface,
        surfaceTintColor: AppleStyle.surface,
        scrolledUnderElevation: 0,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    const SizedBox(height: 12),
                    _buildLikertSlider(
                      label: AppLocalizations.of(context)!.avoidTraveling,
                      value: avoidTravel,
                      min: 1,
                      max: 4,
                      onChanged: (v) => setState(() => avoidTravel = v),
                    ),
                    const SizedBox(height: 24),
                    _buildLikertSlider(
                      label: AppLocalizations.of(context)!.avoidSocialActivities,
                      value: avoidSocial,
                      min: 1,
                      max: 4,
                      onChanged: (v) => setState(() => avoidSocial = v),
                    ),
                    const SizedBox(height: 24),
                    _buildLikertSlider(
                      label: AppLocalizations.of(context)!.feelEmbarrassed,
                      value: embarrassed,
                      min: 1,
                      max: 4,
                      onChanged: (v) => setState(() => embarrassed = v),
                    ),
                    const SizedBox(height: 24),
                    _buildLikertSlider(
                      label: AppLocalizations.of(context)!.worryOthersNotice,
                      value: worryNotice,
                      min: 1,
                      max: 4,
                      onChanged: (v) => setState(() => worryNotice = v),
                    ),
                    const SizedBox(height: 24),
                    _buildLikertSlider(
                      label: AppLocalizations.of(context)!.feelDepressed,
                      value: depressed,
                      min: 1,
                      max: 4,
                      onChanged: (v) => setState(() => depressed = v),
                    ),
                    const SizedBox(height: 24),
                    _buildLikertSlider(
                      label: AppLocalizations.of(context)!.feelInControl,
                      value: control,
                      min: 0,
                      max: 10,
                      onChanged: (v) => setState(() => control = v),
                    ),
                    const SizedBox(height: 24),
                    _buildLikertSlider(
                      label: AppLocalizations.of(context)!.overallSatisfaction,
                      value: satisfaction,
                      min: 0,
                      max: 10,
                      onChanged: (v) => setState(() => satisfaction = v),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24.0, bottom: 8),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF3A8DFF), Color(0xFF8F5CFF)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        if (avoidTravel == null ||
                            avoidSocial == null ||
                            embarrassed == null ||
                            worryNotice == null ||
                            depressed == null ||
                            control == null ||
                            satisfaction == null) {
                          setState(() => showMissing = true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(AppLocalizations.of(context)!.answerAllQuestions)),
                          );
                          return;
                        }
                        final api = ApiService();
                        final code = await api.getPatientCode();
                        if (code == null || code.isEmpty) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(AppLocalizations.of(context)!.pleaseSetPatientCode)),
                          );
                          return;
                        }

                        final overall = ((control! + satisfaction!) / 2).round();
                        final raw = {
                          'avoid_travel': avoidTravel,
                          'avoid_social': avoidSocial,
                          'embarrassed': embarrassed,
                          'worry_notice': worryNotice,
                          'depressed': depressed,
                          'control': control,
                          'satisfaction': satisfaction,
                        };

                        try {
                          final resp = await api.sendMonthly(
                            patientCode: code,
                            qolScore: overall,
                            rawData: raw,
                          );
                          if (resp.statusCode >= 200 && resp.statusCode < 300) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(AppLocalizations.of(context)!.submittedSuccessfully)),
                            );
                            // Return true to indicate successful submission, so dashboard can refresh chart
                            Navigator.of(context).pop(true);
                          } else {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(AppLocalizations.of(context)!.submitFailed(resp.statusCode))),
                            );
                          }
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(AppLocalizations.of(context)!.error(e.toString()))),
                          );
                        }
                      },
                      child: Text(AppLocalizations.of(context)!.submit),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 