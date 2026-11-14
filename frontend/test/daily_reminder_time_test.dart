import 'package:flutter_test/flutter_test.dart';
import 'package:lars_app/services/notification_service.dart';
import 'package:timezone/timezone.dart' as tz;

void main() {
  test('before 19:00 the reminder is today at 19:00', () {
    expect(
      nextDailyReminderTime(DateTime(2026, 11, 14, 8, 30)),
      DateTime(2026, 11, 14, 19),
    );
  });

  test('after 19:00 the reminder is tomorrow at 19:00', () {
    expect(
      nextDailyReminderTime(DateTime(2026, 11, 14, 21, 5)),
      DateTime(2026, 11, 15, 19),
    );
    expect(
      nextDailyReminderTime(DateTime(2026, 11, 30, 23, 59)),
      DateTime(2026, 12, 1, 19),
    );
  });

  test('19:00 stays 19:00 across the summer-time change', () {
    // Lithuania moves the clock on the last Sunday of March and October.
    expect(
      nextDailyReminderTime(DateTime(2027, 3, 27, 20)),
      DateTime(2027, 3, 28, 19),
    );
    expect(
      nextDailyReminderTime(DateTime(2026, 10, 24, 20)),
      DateTime(2026, 10, 25, 19),
    );
  });

  test(
    'the scheduled moment is 19:00 on the phone, whatever its time zone',
    () {
      // The notification plugin gets the time as a UTC moment; it must be the
      // same moment as 19:00 on this machine's clock (run the tests with TZ=
      // set to other zones to check them too).
      final local = nextDailyReminderTime(DateTime.now());
      final scheduled = tz.TZDateTime.from(local, tz.UTC);
      expect(scheduled.isAtSameMomentAs(local), isTrue);
      final onThePhone = DateTime.fromMillisecondsSinceEpoch(
        scheduled.millisecondsSinceEpoch,
      );
      expect(onThePhone.hour, 19);
    },
  );
}
