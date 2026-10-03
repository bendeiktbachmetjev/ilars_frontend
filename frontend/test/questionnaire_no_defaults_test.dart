// Questionnaires must not record answers the patient did not choose:
// nothing is pre-selected, and Submit is blocked until every required
// question is answered. These tests never reach the network: with no saved
// patient code, a submit that passes validation stops at the
// "Please set your patient code" message.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lars_app/l10n/app_localizations.dart';
import 'package:lars_app/screens/questionnaires/daily_questionnaire_screen.dart';
import 'package:lars_app/screens/questionnaires/eq5d5l_questionnaire_screen.dart';
import 'package:lars_app/screens/questionnaires/monthly_questionnaire_screen.dart';
import 'package:lars_app/screens/questionnaires/weekly_questionnaire_screen.dart';

const answerAll = 'Please answer all questions';
const passedValidation = 'Please set your patient code in Profile';

Future<void> pumpScreen(WidgetTester tester, Widget screen) async {
  // Tall window so every question is built and tappable without scrolling.
  tester.view.physicalSize = const Size(800, 6000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({});
  await tester.pumpWidget(MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: screen,
  ));
  await tester.pumpAndSettle();
}

Future<void> submit(WidgetTester tester) async {
  await tester.tap(find.text('Submit'));
  await tester.pumpAndSettle();
}

/// Taps the left end of a slider, where its greyed-out thumb sits before the
/// first touch. This must still record the minimum value.
Future<void> tapSliderStart(WidgetTester tester, Finder slider) async {
  final rect = tester.getRect(slider);
  await tester.tapAt(Offset(rect.left + 24, rect.center.dy));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Weekly LARS: nothing pre-selected, empty submit is blocked', (tester) async {
    await pumpScreen(tester, const WeeklyQuestionnaireScreen());

    expect(find.text('—'), findsOneWidget); // total score not shown yet
    await submit(tester);
    expect(find.text(answerAll), findsOneWidget);
    expect(find.text(passedValidation), findsNothing);
  });

  testWidgets('Weekly LARS: all answered gives the standard score and submits', (tester) async {
    await pumpScreen(tester, const WeeklyQuestionnaireScreen());

    await tester.tap(find.text('Yes, at least once per week').at(0)); // flatus: 7
    await tester.tap(find.text('Yes, less than once per week').at(1)); // liquid: 3
    await tester.tap(find.text('Less than once per day (24 hours)')); // frequency: 5
    await tester.pump();
    expect(find.text('—'), findsOneWidget); // still incomplete
    await tester.tap(find.text('No, never').at(2)); // repeat: 0
    await tester.tap(find.text('Yes, at least once per week').at(3)); // urgency: 16
    await tester.pump();
    expect(find.text('31'), findsOneWidget);

    await submit(tester);
    expect(find.text(answerAll), findsNothing);
    expect(find.text(passedValidation), findsOneWidget);
  });

  testWidgets('Daily: required answers blocked when empty; Bristol may be skipped', (tester) async {
    await pumpScreen(tester, const DailyQuestionnaireScreen());

    expect(find.text('—'), findsNWidgets(3)); // bloating, impact, activity sliders
    await submit(tester);
    expect(find.text(answerAll), findsOneWidget);
    ScaffoldMessenger.of(tester.element(find.byType(Scaffold))).clearSnackBars();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Yes').at(0)); // urgency
    await tester.tap(find.text('No').at(1)); // night stools
    await tester.tap(find.text('None')); // leakage
    await tester.tap(find.text('No').at(2)); // incomplete evacuation
    final sliders = find.byType(Slider);
    expect(sliders, findsNWidgets(3));
    await tapSliderStart(tester, sliders.at(0)); // bloating = 0, a real answer
    await tester.tap(sliders.at(1));
    await tester.tap(sliders.at(2));
    await tester.pumpAndSettle();
    expect(find.text('—'), findsNothing);

    await submit(tester); // Bristol left empty on purpose
    expect(find.text(answerAll), findsNothing);
    expect(find.text(passedValidation), findsOneWidget);
  });

  testWidgets('EQ-5D-5L: nothing pre-selected, VAS has no value until touched', (tester) async {
    await pumpScreen(tester, const Eq5d5lQuestionnaireScreen());

    expect(find.text('—'), findsOneWidget); // VAS
    await submit(tester);
    expect(find.text(answerAll), findsOneWidget);
    expect(find.text(passedValidation), findsNothing);
  });

  testWidgets('Monthly: sliders have no value until touched; empty submit is blocked', (tester) async {
    await pumpScreen(tester, const MonthlyQuestionnaireScreen());

    expect(find.text('—'), findsNWidgets(7));
    await submit(tester);
    expect(find.text(answerAll), findsOneWidget);
    ScaffoldMessenger.of(tester.element(find.byType(Scaffold))).clearSnackBars();
    await tester.pumpAndSettle();

    final sliders = find.byType(Slider);
    for (var i = 0; i < 7; i++) {
      await tapSliderStart(tester, sliders.at(i));
    }
    expect(find.text('—'), findsNothing);
    await submit(tester);
    expect(find.text(passedValidation), findsOneWidget);
  });
}
