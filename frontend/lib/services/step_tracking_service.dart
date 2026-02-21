import 'dart:io';
import 'package:health/health.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

/// Reads daily step counts from Apple Health / Health Connect
/// and sends them to the backend.
class StepTrackingService {
  StepTrackingService._();
  static final StepTrackingService instance = StepTrackingService._();

  static const _lastSyncKey = 'steps_last_sync';
  final _health = Health();
  bool _authorized = false;

  /// Request permission to read step data.
  /// Returns true if granted.
  Future<bool> requestPermission() async {
    final types = [HealthDataType.STEPS];
    final permissions = [HealthDataAccess.READ];

    try {
      final ok = await _health.requestAuthorization(types, permissions: permissions);
      _authorized = ok;
      return ok;
    } catch (e) {
      _authorized = false;
      return false;
    }
  }

  /// Fetch steps for the last [days] and send them to the API.
  /// Skips dates already synced (tracks via SharedPreferences).
  Future<void> syncSteps({int days = 7}) async {
    if (!_authorized) {
      final ok = await requestPermission();
      if (!ok) return;
    }

    final api = ApiService();
    final patientCode = await api.getPatientCode();
    if (patientCode == null || patientCode.isEmpty) return;

    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).subtract(Duration(days: days));

    final prefs = await SharedPreferences.getInstance();
    final lastSync = prefs.getString(_lastSyncKey);
    final lastSyncDate = lastSync != null ? DateTime.tryParse(lastSync) : null;

    final entries = <Map<String, dynamic>>[];

    for (var i = 0; i < days; i++) {
      final dayStart = DateTime(start.year, start.month, start.day + i);
      final dayEnd = dayStart.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));

      // Skip already-synced full days (but always re-sync today)
      final isToday = dayStart.year == now.year &&
          dayStart.month == now.month &&
          dayStart.day == now.day;
      if (!isToday && lastSyncDate != null && dayStart.isBefore(lastSyncDate)) {
        continue;
      }

      try {
        final totalSteps = await _health.getTotalStepsInInterval(dayStart, dayEnd);
        if (totalSteps != null && totalSteps > 0) {
          final dateStr =
              '${dayStart.year}-${dayStart.month.toString().padLeft(2, '0')}-${dayStart.day.toString().padLeft(2, '0')}';
          entries.add({
            'step_date': dateStr,
            'step_count': totalSteps,
            'source': Platform.isIOS ? 'apple_health' : 'health_connect',
          });
        }
      } catch (_) {
        // Individual day failure is non-critical
      }
    }

    if (entries.isEmpty) return;

    try {
      await api.sendSteps(patientCode: patientCode, steps: entries);
      await prefs.setString(
          _lastSyncKey, DateTime(now.year, now.month, now.day).toIso8601String());
    } catch (_) {
      // Network failure — will retry next time
    }
  }
}
