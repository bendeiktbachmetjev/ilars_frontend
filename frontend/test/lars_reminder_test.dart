import 'package:flutter_test/flutter_test.dart';
import 'package:lars_app/services/lars_reminder.dart';

/// Weekly questionnaires 7 days apart from 2026-01-05, with these scores.
List<LarsEntry> weeks(List<int> scores) => [
  for (var i = 0; i < scores.length; i++)
    (date: DateTime(2026, 1, 5 + 7 * i), score: scores[i]),
];

/// Plays the weeks one by one as the app sees them, remembering what the
/// check remembers; returns the week numbers (1 = first) that remind.
List<int> remindedWeeks(List<int> scores) {
  final reminded = <int>[];
  DateTime? lastReminderFor;
  for (var n = 1; n <= scores.length; n++) {
    final seen = weeks(scores.sublist(0, n));
    switch (larsReminderStep(seen, lastReminderFor: lastReminderFor)) {
      case LarsReminderStep.remind:
        reminded.add(n);
        lastReminderFor = seen.last.date;
      case LarsReminderStep.withdraw:
        lastReminderFor = null;
      case LarsReminderStep.none:
    }
  }
  return reminded;
}

void main() {
  test('4 weeks of major LARS in a row remind; 3 do not', () {
    expect(larsReminderStep(weeks([32, 35, 31, 30])), LarsReminderStep.remind);
    expect(larsReminderStep(weeks([35, 35, 35])), LarsReminderStep.withdraw);
  });

  test('30 is major LARS, 29 is not', () {
    expect(larsReminderStep(weeks([30, 30, 30, 30])), LarsReminderStep.remind);
    expect(
      larsReminderStep(weeks([30, 30, 30, 29])),
      LarsReminderStep.withdraw,
    );
    expect(
      larsReminderStep(weeks([29, 30, 30, 30])),
      LarsReminderStep.withdraw,
    );
  });

  test('only the newest weeks in a row count', () {
    expect(
      larsReminderStep(weeks([35, 20, 35, 35, 35])),
      LarsReminderStep.withdraw,
    );
    expect(
      larsReminderStep(weeks([35, 20, 35, 35, 35, 35])),
      LarsReminderStep.remind,
    );
  });

  test('while LARS stays high the reminder comes every 4 weeks', () {
    expect(remindedWeeks(List.filled(13, 34)), [4, 8, 12]);
  });

  test('a lower week starts the count again', () {
    //            1   2   3   4   5   6   7   8   9  10
    expect(remindedWeeks([33, 33, 33, 33, 25, 33, 33, 33, 33, 33]), [4, 9]);
  });

  test('after a reminder, the next weeks wait for 4 new high ones', () {
    final seen = weeks([33, 33, 33, 33, 33, 33, 33]);
    expect(
      larsReminderStep(seen, lastReminderFor: seen[3].date),
      LarsReminderStep.none,
    );
    expect(
      larsReminderStep(seen, lastReminderFor: seen[2].date),
      LarsReminderStep.remind,
    );
  });

  test('scores filled with gaps still count as in a row', () {
    final entries = [
      (date: DateTime(2026, 1, 1), score: 36),
      (date: DateTime(2026, 2, 20), score: 36),
      (date: DateTime(2026, 3, 1), score: 36),
      (date: DateTime(2026, 4, 15), score: 36),
    ];
    expect(larsReminderStep(entries), LarsReminderStep.remind);
  });

  test('the reminder comes at 10:00 on the phone clock', () {
    expect(
      nextReminderTime(DateTime(2026, 11, 14, 8, 30)),
      DateTime(2026, 11, 14, 10),
    );
    expect(
      nextReminderTime(DateTime(2026, 11, 14, 10)),
      DateTime(2026, 11, 15, 10),
    );
    expect(
      nextReminderTime(DateTime(2026, 11, 30, 23, 15)),
      DateTime(2026, 12, 1, 10),
    );
  });
}
