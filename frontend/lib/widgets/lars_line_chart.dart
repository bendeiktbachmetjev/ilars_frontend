import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../l10n/app_localizations.dart';
import 'package:intl/intl.dart';

enum TimePeriod { weekly, monthly, yearly }

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

      final periodStr = _selectedPeriod == TimePeriod.weekly 
          ? 'weekly' 
          : _selectedPeriod == TimePeriod.monthly 
              ? 'monthly' 
              : 'yearly';
      
      final futures = await Future.wait([
        api.getLarsData(patientCode: patientCode, period: periodStr),
        api.getStepsChartData(patientCode: patientCode, period: periodStr).catchError((_) => {'status': 'ok', 'data': []})
      ]);

      final larsResp = futures[0];
      final stepsResp = futures[1];

      List<FlSpot> larsSpots = [];
      List<Map<String, dynamic>> rawSteps = [];
      
      if (larsResp['status'] == 'ok' && larsResp['data'] != null) {
        for (var item in larsResp['data']) {
          if (item['score'] != null && item['date'] != null) {
            final date = DateTime.parse(item['date']);
            larsSpots.add(FlSpot(date.millisecondsSinceEpoch.toDouble(), (item['score'] as num).toDouble()));
          }
        }
      }

      if (stepsResp['status'] == 'ok' && stepsResp['data'] != null) {
        for (var item in stepsResp['data']) {
          if (item['steps'] != null && item['date'] != null) {
            final date = DateTime.parse(item['date']);
            rawSteps.add({
              'date': date,
              'steps': (item['steps'] as num).toDouble()
            });
          }
        }
      }

      // Calculate moving average for steps
      List<FlSpot> stepsSpots = [];
      double absoluteMaxSteps = 0;
      
      if (rawSteps.isNotEmpty) {
        rawSteps.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
        
        int windowSize = _selectedPeriod == TimePeriod.yearly ? 30 : 7;
        
        for (int i = 0; i < rawSteps.length; i++) {
          double sum = 0;
          int count = 0;
          for (int j = i >= windowSize ? i - windowSize + 1 : 0; j <= i; j++) {
            sum += rawSteps[j]['steps'] as double;
            count++;
          }
          double avg = sum / count;
          if (avg > absoluteMaxSteps) absoluteMaxSteps = avg;
          stepsSpots.add(FlSpot((rawSteps[i]['date'] as DateTime).millisecondsSinceEpoch.toDouble(), avg));
        }
      }

      if (!mounted) return;
      
      setState(() {
        _larsData = larsSpots;
        _stepsData = stepsSpots;
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

  double _getMinX() {
    double minX = double.infinity;
    if (_larsData.isNotEmpty) {
      minX = _larsData.map((s) => s.x).reduce((a, b) => a < b ? a : b);
    }
    if (_stepsData.isNotEmpty) {
      double minS = _stepsData.map((s) => s.x).reduce((a, b) => a < b ? a : b);
      if (minS < minX) minX = minS;
    }
    
    if (minX == double.infinity) {
      return DateTime.now().subtract(const Duration(days: 35)).millisecondsSinceEpoch.toDouble();
    }
    return minX; 
  }

  double _getMaxX() {
    double maxX = -double.infinity;
    if (_larsData.isNotEmpty) {
      maxX = _larsData.map((s) => s.x).reduce((a, b) => a > b ? a : b);
    }
    if (_stepsData.isNotEmpty) {
      double maxS = _stepsData.map((s) => s.x).reduce((a, b) => a > b ? a : b);
      if (maxS > maxX) maxX = maxS;
    }
    
    if (maxX == -double.infinity) {
      return DateTime.now().millisecondsSinceEpoch.toDouble();
    }
    return maxX;
  }

  double _getMaxY() {
    if (_larsData.isEmpty) return 40.0;
    final maxYFromData = _larsData.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    final padding = (maxYFromData * 0.2).clamp(5.0, 10.0);
    return (maxYFromData + padding).clamp(20.0, 50.0);
  }

  double _getInterval(double minX, double maxX) {
    double distance = maxX - minX;
    if (distance <= const Duration(days: 7).inMilliseconds) {
      return const Duration(days: 1).inMilliseconds.toDouble();
    } else if (distance <= const Duration(days: 35).inMilliseconds) {
      return const Duration(days: 7).inMilliseconds.toDouble();
    } else if (distance <= const Duration(days: 180).inMilliseconds) {
      return const Duration(days: 30).inMilliseconds.toDouble();
    }
    return const Duration(days: 365).inMilliseconds.toDouble();
  }

  String _formatDate(double ms) {
    final date = DateTime.fromMillisecondsSinceEpoch(ms.toInt());
    switch (_selectedPeriod) {
      case TimePeriod.weekly:
      case TimePeriod.monthly:
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
    final minX = _getMinX() - const Duration(days: 2).inMilliseconds; // Pad beginning
    final maxX = _getMaxX() + const Duration(days: 2).inMilliseconds; // Pad end
    final maxY = _getMaxY();
    final intervalX = _getInterval(minX, maxX);
    final String stepsLabel = _getStepsTranslation(context);
    
    // Scale steps data to fit into Lars Y scale
    final scaledStepsData = _stepsData.map((spot) {
      double scaledY = (spot.y / _maxSteps) * maxY;
      return FlSpot(spot.x, scaledY);
    }).toList();

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPeriodButton(TimePeriod.weekly, AppLocalizations.of(context)!.weekly),
              const SizedBox(width: 8),
              _buildPeriodButton(TimePeriod.monthly, AppLocalizations.of(context)!.monthly),
              const SizedBox(width: 8),
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
                                    showTitles: true,
                                    reservedSize: 36,
                                    interval: maxY > 20 ? 10 : 5,
                                    getTitlesWidget: (value, meta) {
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
                                    isCurved: scaledStepsData.length > 1,
                                    color: Colors.blue.withOpacity(0.5),
                                    barWidth: 3,
                                    dotData: FlDotData(show: scaledStepsData.length <= 1),
                                    belowBarData: BarAreaData(
                                      show: scaledStepsData.length > 1,
                                      color: Colors.blue.withOpacity(0.15),
                                    ),
                                  ),
                                if (_larsData.isNotEmpty)
                                  LineChartBarData(
                                    spots: _larsData,
                                    isCurved: _larsData.length > 1,
                                    color: Colors.black,
                                    barWidth: 3,
                                    dotData: FlDotData(show: _larsData.length <= 10),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}