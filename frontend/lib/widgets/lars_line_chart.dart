import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../l10n/app_localizations.dart';
import 'package:intl/intl.dart';

enum TimePeriod { weekly, monthly, threeMonths, sixMonths, yearly }

class LarsLineChart extends StatefulWidget {
  const LarsLineChart({super.key});

  @override
  State<LarsLineChart> createState() => LarsLineChartState();
}

class LarsLineChartState extends State<LarsLineChart> {
  TimePeriod _selectedPeriod = TimePeriod.weekly;
  List<FlSpot> _larsData = [];
  List<FlSpot> _stepsData = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isLoadingInProgress = false;
  double _maxSteps = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> refresh() async {
    _isLoadingInProgress = false;
    await _loadData();
  }

  Future<void> _loadData() async {
    if (_isLoadingInProgress) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isLoadingInProgress = true;
    });

    try {
      final api = ApiService();
      final patientCode = await api.getPatientCode();
      
      if (patientCode == null || patientCode.isEmpty) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _larsData = [];
          _stepsData = [];
          _errorMessage = 'No patient code set';
          _isLoadingInProgress = false;
        });
        return;
      }

      // Backend accepts: weekly | monthly | 3months | 6months | yearly.
      final periodStr = switch (_selectedPeriod) {
        TimePeriod.weekly => 'weekly',
        TimePeriod.monthly => 'monthly',
        TimePeriod.threeMonths => '3months',
        TimePeriod.sixMonths => '6months',
        TimePeriod.yearly => 'yearly',
      };
      
      final futures = await Future.wait([
        api.getLarsData(patientCode: patientCode, period: periodStr),
        api.getStepsChartData(patientCode: patientCode, period: periodStr).catchError((_) => {'status': 'ok', 'data': []})
      ]);

      final larsResp = futures[0];
      final stepsResp = futures[1];

      final List<FlSpot> larsSpots = [];
      final List<FlSpot> stepsSpots = [];
      double absoluteMaxSteps = 0;

      if (larsResp['status'] == 'ok' && larsResp['data'] != null) {
        for (var item in larsResp['data']) {
          if (item['score'] != null && item['date'] != null) {
            final date = DateTime.parse(item['date']);
            larsSpots.add(FlSpot(
              date.millisecondsSinceEpoch.toDouble(),
              (item['score'] as num).toDouble(),
            ));
          }
        }
        larsSpots.sort((a, b) => a.x.compareTo(b.x));
      }

      // Use raw daily step counts — no moving average, no aggregation.
      // User preference: show concrete entries in every scale.
      if (stepsResp['status'] == 'ok' && stepsResp['data'] != null) {
        for (var item in stepsResp['data']) {
          if (item['steps'] != null && item['date'] != null) {
            final date = DateTime.parse(item['date']);
            final steps = (item['steps'] as num).toDouble();
            if (steps > absoluteMaxSteps) absoluteMaxSteps = steps;
            stepsSpots.add(FlSpot(date.millisecondsSinceEpoch.toDouble(), steps));
          }
        }
        stepsSpots.sort((a, b) => a.x.compareTo(b.x));
      }

      if (!mounted) return;

      setState(() {
        _larsData = larsSpots;
        _stepsData = stepsSpots;
        // Keep a sane floor so the right-axis labels don't collapse when counts are tiny.
        _maxSteps = absoluteMaxSteps < 1000 ? 1000 : absoluteMaxSteps;
        _isLoading = false;
        _errorMessage = null;
        _isLoadingInProgress = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to fetch LARS data:${e.toString()}';
          _larsData = [];
          _stepsData = [];
          _isLoadingInProgress = false;
        });
      }
    }
  }

  int get _windowDays {
    switch (_selectedPeriod) {
      case TimePeriod.weekly:
        return 7;
      case TimePeriod.monthly:
        return 30;
      case TimePeriod.threeMonths:
        return 90;
      case TimePeriod.sixMonths:
        return 180;
      case TimePeriod.yearly:
        return 365;
    }
  }

  // Anchor the X axis to the full selected window so the chart scale stays
  // consistent even when data is sparse (instead of stretching to fit data).
  double _getMinX() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: _windowDays));
    return start.millisecondsSinceEpoch.toDouble();
  }

  double _getMaxX() {
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day);
    return end.millisecondsSinceEpoch.toDouble();
  }

  double _getMaxY() {
    if (_larsData.isEmpty) return 40.0;
    final maxYFromData = _larsData.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    final padding = (maxYFromData * 0.2).clamp(5.0, 10.0);
    return (maxYFromData + padding).clamp(20.0, 50.0);
  }

  double _getInterval() {
    switch (_selectedPeriod) {
      case TimePeriod.weekly:
        return const Duration(days: 1).inMilliseconds.toDouble();
      case TimePeriod.monthly:
        return const Duration(days: 7).inMilliseconds.toDouble();
      case TimePeriod.threeMonths:
        // ~biweekly ticks fit 6 labels across 90 days
        return const Duration(days: 14).inMilliseconds.toDouble();
      case TimePeriod.sixMonths:
        // ~monthly ticks fit 6 labels across 180 days
        return const Duration(days: 30).inMilliseconds.toDouble();
      case TimePeriod.yearly:
        return const Duration(days: 60).inMilliseconds.toDouble();
    }
  }

  String _formatDate(double ms) {
    final date = DateTime.fromMillisecondsSinceEpoch(ms.toInt());
    switch (_selectedPeriod) {
      case TimePeriod.weekly:
      case TimePeriod.monthly:
      case TimePeriod.threeMonths:
      case TimePeriod.sixMonths:
        return DateFormat('d MMM').format(date);
      case TimePeriod.yearly:
        return DateFormat('MMM yyyy').format(date);
    }
  }

  String _formatStepsData(double yScaled, double maxY) {
    double realSteps = (yScaled / maxY) * _maxSteps;
    if (realSteps >= 1000) {
      return '${(realSteps / 1000).toStringAsFixed(1)}k';
    }
    return realSteps.toInt().toString();
  }

  String _getStepsTranslation(BuildContext context) {
    String lang = Localizations.localeOf(context).languageCode;
    if (lang == 'ru') return 'Шаги';
    if (lang == 'lt') return 'Žingsniai';
    return 'Steps';
  }

  @override
  Widget build(BuildContext context) {
    // A small visual pad on both sides so the first/last point isn't clipped by the Y axis line.
    final pad = (_windowDays * 0.02).clamp(0.5, 3.0);
    final minX = _getMinX() - (pad * const Duration(days: 1).inMilliseconds);
    final maxX = _getMaxX() + (pad * const Duration(days: 1).inMilliseconds);
    final maxY = _getMaxY();
    final intervalX = _getInterval();
    final String stepsLabel = _getStepsTranslation(context);
    final bool hasSteps = _stepsData.isNotEmpty;

    // Project steps onto the shared Y scale (0..maxY) so a single axis can hold both series.
    final scaledStepsData = _stepsData.map((spot) {
      double scaledY = (spot.y / _maxSteps) * maxY;
      return FlSpot(spot.x, scaledY);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8).copyWith(bottom: 16),
          // Use short labels ("3 Mo", "6 Mo", "3 мес.", "3 mėn.", ...) so all 5
          // buttons fit on one line without scrolling on narrow phones.
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPeriodButton(TimePeriod.weekly, AppLocalizations.of(context)!.weekly),
              _buildPeriodButton(TimePeriod.monthly, AppLocalizations.of(context)!.monthly),
              _buildPeriodButton(TimePeriod.threeMonths, AppLocalizations.of(context)!.threeMonths),
              _buildPeriodButton(TimePeriod.sixMonths, AppLocalizations.of(context)!.sixMonths),
              _buildPeriodButton(TimePeriod.yearly, AppLocalizations.of(context)!.yearly),
            ],
          ),
        ),
        
        Padding(
          padding: const EdgeInsets.only(bottom: 16, left: 24, right: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              const Text('LARS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),
              Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.blue.withOpacity(0.5), shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Text(
                stepsLabel, 
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            height: 220,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : (_larsData.isEmpty && _stepsData.isEmpty && _errorMessage != null)
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bar_chart, size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text(
                              _errorMessage == 'No patient code set'
                                  ? AppLocalizations.of(context)!.noPatientCodeSet
                                  : _errorMessage!.startsWith('Failed to fetch LARS data:')
                                      ? AppLocalizations.of(context)!.failedToFetchLarsData(_errorMessage!.substring('Failed to fetch LARS data:'.length).trim())
                                      : _errorMessage!,
                              style: TextStyle(color: Colors.grey[600], fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : (_larsData.isEmpty && _stepsData.isEmpty)
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.bar_chart, size: 48, color: Colors.grey[400]),
                                const SizedBox(height: 8),
                                Text(
                                  AppLocalizations.of(context)!.noDataAvailableYet,
                                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : LineChart(
                            LineChartData(
                              lineTouchData: LineTouchData(
                                touchTooltipData: LineTouchTooltipData(
                                  tooltipBgColor: Colors.black.withOpacity(0.8),
                                  getTooltipItems: (List<LineBarSpot> touchedSpots) {
                                    return touchedSpots.map((LineBarSpot touchedSpot) {
                                      final textStyle = const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      );
                                      bool isStepsLine = scaledStepsData.isNotEmpty && touchedSpot.barIndex == 0;
                                      
                                      if (isStepsLine) {
                                        double realSteps = (touchedSpot.y / maxY) * _maxSteps;
                                        String label = realSteps >= 1000
                                            ? '${(realSteps / 1000).toStringAsFixed(1)}k'
                                            : realSteps.toInt().toString();
                                        return LineTooltipItem('$label $stepsLabel', textStyle);
                                      } else {
                                        return LineTooltipItem('LARS: ${touchedSpot.y.toInt()}', textStyle);
                                      }
                                    }).toList();
                                  },
                                ),
                              ),
                              gridData: FlGridData(show: true, drawVerticalLine: false),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 32,
                                    interval: maxY > 20 ? 10 : 5,
                                    getTitlesWidget: (value, meta) {
                                      if (value == 0) return const SizedBox.shrink();
                                      return Text(value.toInt().toString(), style: const TextStyle(fontSize: 11));
                                    }
                                  ),
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: hasSteps,
                                    reservedSize: hasSteps ? 36 : 0,
                                    interval: maxY > 20 ? 10 : 5,
                                    getTitlesWidget: (value, meta) {
                                      if (!hasSteps) return const SizedBox.shrink();
                                      if (value == 0 || value > maxY) return const SizedBox.shrink();
                                      final label = _formatStepsData(value, maxY);
                                      return Text(label, style: const TextStyle(fontSize: 11, color: Colors.blue));
                                    }
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 28,
                                    interval: intervalX,
                                    getTitlesWidget: (value, meta) {
                                      if (value < minX || value > maxX) return const SizedBox.shrink();
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Text(_formatDate(value), style: const TextStyle(fontSize: 10)),
                                      );
                                    },
                                  ),
                                ),
                                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              borderData: FlBorderData(show: false),
                              minX: minX,
                              maxX: maxX,
                              minY: 0,
                              maxY: maxY,
                              lineBarsData: [
                                if (scaledStepsData.isNotEmpty)
                                  LineChartBarData(
                                    spots: scaledStepsData,
                                    // Avoid curve overshoot when there are many dense daily points.
                                    isCurved: scaledStepsData.length > 1 && scaledStepsData.length < 60,
                                    color: Colors.blue.withOpacity(0.5),
                                    barWidth: 3,
                                    dotData: FlDotData(show: scaledStepsData.length <= 14),
                                    belowBarData: BarAreaData(
                                      show: scaledStepsData.length > 1,
                                      color: Colors.blue.withOpacity(0.15),
                                    ),
                                  ),
                                if (_larsData.isNotEmpty)
                                  LineChartBarData(
                                    spots: _larsData,
                                    isCurved: _larsData.length > 1 && _larsData.length < 60,
                                    color: Colors.black,
                                    barWidth: 3,
                                    dotData: FlDotData(show: _larsData.length <= 20),
                                    belowBarData: BarAreaData(show: false),
                                  ),
                              ],
                            ),
                          ),
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodButton(TimePeriod period, String label) {
    final isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = period;
        });
        _loadData(); 
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}