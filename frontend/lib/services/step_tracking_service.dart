import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'api_service.dart';

/// Reads daily step counts from Apple Health / Health Connect
/// and sends them to the backend.
///
/// Sync range is determined by the backend (GET /getStepsSyncInfo),
/// so there is no local cache to manage.
class StepTrackingService {
  StepTrackingService._();
  static final StepTrackingService instance = StepTrackingService._();

  final _health = Health();
  bool _authorized = false;

  Future<bool> requestPermission() async {
    final types = [HealthDataType.STEPS];
    final permissions = [HealthDataAccess.READ];

    try {
      debugPrint('[Steps] Requesting HealthKit authorization...');
      final ok = await _health.requestAuthorization(types, permissions: permissions);
      _authorized = ok;
      debugPrint('[Steps] Authorization result: $ok');
      return ok;
    } catch (e) {
      debugPrint('[Steps] Authorization error: $e');
      _authorized = false;
      return false;
    }
  }

  /// Sync steps from the backend-determined start date up to yesterday.
  Future<void> syncSteps() async {
    debugPrint('[Steps] syncSteps called (authorized=$_authorized)');

    if (!_authorized) {
      final ok = await requestPermission();
      if (!ok) {
        debugPrint('[Steps] Not authorized — aborting sync');
        return;
      }
    }

    final api = ApiService();
    final patientCode = await api.getPatientCode();
    if (patientCode == null || patientCode.isEmpty) {
      debugPrint('[Steps] No patient code — aborting sync');
      return;
    }
    debugPrint('[Steps] Patient code: $patientCode');

    // Ask backend for the start date
    final DateTime startDate;
    try {
      final syncInfo = await api.getStepsSyncInfo(patientCode: patientCode);
      final raw = syncInfo['start_date'] as String?;
      if (raw == null) {
        debugPrint('[Steps] Backend returned no start_date — aborting');
        return;
      }
      startDate = DateTime.parse(raw);
      debugPrint('[Steps] Backend says sync from: $raw');
    } catch (e) {
      debugPrint('[Steps] Failed to get sync info: $e');
      return;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (!startDate.isBefore(today)) {
      debugPrint('[Steps] Already up to date (start=$startDate >= today=$today)');
      return;
    }

    debugPrint('[Steps] Range: $startDate → $yesterday');

    final entries = <Map<String, dynamic>>[];
    var current = startDate;

    while (!current.isAfter(yesterday)) {
      final dayEnd = current.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));

      try {
        final totalSteps = await _health.getTotalStepsInInterval(current, dayEnd);
        debugPrint('[Steps] $current → $totalSteps steps');
        if (totalSteps != null && totalSteps > 0) {
          final dateStr =
              '${current.year}-${current.month.toString().padLeft(2, '0')}-${current.day.toString().padLeft(2, '0')}';
          entries.add({
            'step_date': dateStr,
            'step_count': totalSteps,
          });
        }
      } catch (e) {
        debugPrint('[Steps] Error reading day $current: $e');
      }

      current = current.add(const Duration(days: 1));
    }

    debugPrint('[Steps] Collected ${entries.length} day(s) with step data');
    if (entries.isEmpty) {
      debugPrint('[Steps] No step data to send — done');
      return;
    }

    try {
      debugPrint('[Steps] Sending ${entries.length} entries to backend...');
      final response = await api.sendSteps(patientCode: patientCode, steps: entries);
      debugPrint('[Steps] Backend response: ${response.statusCode} ${response.body}');
    } catch (e) {
      debugPrint('[Steps] Send error: $e');
    }
  }
}
