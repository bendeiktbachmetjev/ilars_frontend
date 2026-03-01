import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../l10n/app_localizations.dart';

class MonthlyQuestionnaireScreen extends StatefulWidget {
  const MonthlyQuestionnaireScreen({super.key});

  @override
  State<MonthlyQuestionnaireScreen> createState() => _MonthlyQuestionnaireScreenState();
}

class _MonthlyQuestionnaireScreenState extends State<MonthlyQuestionnaireScreen> {
  int avoidTravel = 1;
  int avoidSocial = 1;
  int embarrassed = 1;
  int worryNotice = 1;
  int depressed = 1;
  int control = 0;
  int satisfaction = 0;

  final TextStyle labelStyle = const TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
  final Color activeColor = Colors.black;

  Widget _buildLikertSlider({
    required String label,
    required double value,
    required int min,
    required int max,
    required void Function(double) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle),
        Row(
          children: [
            Text('$min', style: const TextStyle(fontSize: 14)),
            Expanded(
              child: Slider(
                value: value,
                min: min.toDouble(),
                max: max.toDouble(),
                divisions: max - min,
                label: value.round().toString(),
                onChanged: onChanged,
                activeColor: activeColor,
                thumbColor: activeColor,
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
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.monthlyQualityOfLife),
        centerTitle: true,
        backgroundColor: Colors.white,
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
                      value: avoidTravel.toDouble(),
                      min: 1,
                      max: 4,
                      onChanged: (v) => setState(() => avoidTravel = v.round()),
                    ),
                    const SizedBox(height: 24),
                    _buildLikertSlider(
                      label: AppLocalizations.of(context)!.avoidSocialActivities,
                      value: avoidSocial.toDouble(),
                      min: 1,
                      max: 4,
                      onChanged: (v) => setState(() => avoidSocial = v.round()),
                    ),
                    const SizedBox(height: 24),
                    _buildLikertSlider(
                      label: AppLocalizations.of(context)!.feelEmbarrassed,
                      value: embarrassed.toDouble(),
                      min: 1,
                      max: 4,
                      onChanged: (v) => setState(() => embarrassed = v.round()),
                    ),
                    const SizedBox(height: 24),
                    _buildLikertSlider(
                      label: AppLocalizations.of(context)!.worryOthersNotice,
                      value: worryNotice.toDouble(),
                      min: 1,
                      max: 4,
                      onChanged: (v) => setState(() => worryNotice = v.round()),
                    ),
                    const SizedBox(height: 24),
                    _buildLikertSlider(
                      label: AppLocalizations.of(context)!.feelDepressed,
                      value: depressed.toDouble(),
                      min: 1,
                      max: 4,
                      onChanged: (v) => setState(() => depressed = v.round()),
                    ),
                    const SizedBox(height: 24),
                    _buildLikertSlider(
                      label: AppLocalizations.of(context)!.feelInControl,
                      value: control.toDouble(),
                      min: 0,
                      max: 10,
                      onChanged: (v) => setState(() => control = v.round()),
                    ),
                    const SizedBox(height: 24),
                    _buildLikertSlider(
                      label: AppLocalizations.of(context)!.overallSatisfaction,
                      value: satisfaction.toDouble(),
                      min: 0,
                      max: 10,
                      onChanged: (v) => setState(() => satisfaction = v.round()),
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
                        final api = ApiService();
                        final code = await api.getPatientCode();
                        if (code == null || code.isEmpty) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(AppLocalizations.of(context)!.pleaseSetPatientCode)),
                          );
                          return;
                        }

                        final overall = ((control + satisfaction) / 2).round();
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