import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';
import 'notification_service.dart';

/// A LARS score of 30-42 is major LARS.
const int kMajorLarsScore = 30;

/// Weekly questionnaires in a row with major LARS after which the patient is
/// asked to contact the doctor. Each one covers the past week, so 4 = a month.
const int kMajorLarsWeeks = 4;

/// One weekly LARS questionnaire: its date and total score.
typedef LarsEntry = ({DateTime date, int score});

/// What one look at the weekly scores does with the doctor reminder.
enum LarsReminderStep {
  /// 4 major-LARS weeks in a row that no reminder has counted yet: remind.
  remind,

  /// LARS is not high 4 weeks in a row (any more): withdraw a reminder not
  /// yet read, and count from zero again.
  withdraw,

  /// Still high, but these weeks were already counted for a reminder.
  none,
}

/// The newest weekly scores in a row that are major LARS, counting only
/// questionnaires dated after [after] when given. [entries] are oldest first.
int majorLarsRun(List<LarsEntry> entries, {DateTime? after}) {
  var run = 0;
  for (final entry in entries.reversed) {
    if (entry.score < kMajorLarsScore) break;
    if (after != null && !entry.date.isAfter(after)) break;
    run++;
  }
  return run;
}

/// [lastReminderFor] is the date of the newest questionnaire the previous
/// reminder counted, so the reminder comes again after 4 more high weeks:
/// at week 4, 8, 12... of major LARS.
LarsReminderStep larsReminderStep(
  List<LarsEntry> entries, {
  DateTime? lastReminderFor,
}) {
  if (majorLarsRun(entries) < kMajorLarsWeeks) return LarsReminderStep.withdraw;
  if (majorLarsRun(entries, after: lastReminderFor) < kMajorLarsWeeks) {
    return LarsReminderStep.none;
  }
  return LarsReminderStep.remind;
}

/// 10:00 on the phone's clock: today, or tomorrow when it has passed.
DateTime nextReminderTime(DateTime now) {
  final today = DateTime(now.year, now.month, now.day, 10);
  return now.isBefore(today)
      ? today
      : DateTime(now.year, now.month, now.day + 1, 10);
}

/// Reads the patient's weekly LARS scores of the past year and schedules or
/// withdraws the "contact your doctor" notification.
class LarsReminder {
  static const _lastReminderForKey = 'lars_reminder_last_for_';

  static Future<void> check({
    required String title,
    required String body,
  }) async {
    final api = ApiService();
    final patientCode = await api.getPatientCode();
    if (patientCode == null || patientCode.isEmpty) return;

    final List<LarsEntry> entries;
    try {
      final response = await api.getLarsData(
        patientCode: patientCode,
        period: 'yearly',
      );
      if (response['status'] != 'ok') return;
      entries = [
        for (final row in response['data'] as List)
          if (row['date'] != null && row['score'] != null)
            (
              date: DateTime.parse(row['date'] as String),
              score: row['score'] as int,
            ),
      ]..sort((a, b) => a.date.compareTo(b.date));
    } catch (_) {
      return; // offline: the next app start looks again
    }
    // The server also answers "no scores" when its database is busy; that
    // must not withdraw a reminder.
    if (entries.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final key = '$_lastReminderForKey$patientCode';
    final lastReminderFor = DateTime.tryParse(prefs.getString(key) ?? '');
    final notifications = NotificationService();
    switch (larsReminderStep(entries, lastReminderFor: lastReminderFor)) {
      case LarsReminderStep.remind:
        await notifications.scheduleLarsReminder(
          title: title,
          body: body,
          at: nextReminderTime(DateTime.now()),
        );
        await prefs.setString(key, entries.last.date.toIso8601String());
      case LarsReminderStep.withdraw:
        await notifications.cancelLarsReminder();
        await prefs.remove(key);
      case LarsReminderStep.none:
    }
  }
}
