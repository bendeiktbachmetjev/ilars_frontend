// The Recommendations tab must fit a small phone at large text in every
// language, keep its pages' state when switching, and keep the Kegel
// exercises hidden until the logged-in patient confirms they learned the
// technique. Texts come from the content files, so the tests survive new
// translations.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lars_app/content/recommendations/recommendations_content.dart';
import 'package:lars_app/l10n/app_localizations.dart';
import 'package:lars_app/main.dart';
import 'package:lars_app/screens/recommendations/recommendations_screen.dart';
import 'package:lars_app/screens/recommendations/widgets/motion.dart';

const kegelKey = 'rec_kegel_unlocked_for';
const codeKey = 'patient_code'; // where ApiService keeps the logged-in code

Future<void> pumpScreen(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
  Map<String, Object> prefs = const {},
  bool reduceMotion = false,
}) async {
  tester.view.physicalSize = const Size(375, 667);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues(prefs);
  await tester.pumpWidget(MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(1.3),
        disableAnimations: reduceMotion,
      ),
      child: child!,
    ),
    home: const RecommendationsScreen(),
  ));
  if (!reduceMotion) await tester.pumpAndSettle();
}

/// On screen and not hidden inside a folded card.
Finder shown(String text) => find.text(text).hitTestable();

Future<void> scrollTo(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text));
  await tester.pumpAndSettle();
}

Future<void> expectShown(WidgetTester tester, String text) async {
  await scrollTo(tester, text);
  expect(shown(text), findsOneWidget);
}

Future<void> tapText(WidgetTester tester, String text) async {
  await scrollTo(tester, text);
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the tab sits between Dashboard and Profile, label fitting',
      (tester) async {
    // Wide window, large text: the label must shrink into its third. At
    // phone width the existing Dashboard and Profile screens overflow in the
    // wide test font, so this test cannot use 375 px.
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.textScaleFactorTestValue = 1.7;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    SharedPreferences.setMockInitialValues({'has_seen_health_disclosure': true});
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final label = tester.getRect(find.text('Recommendations'));
    expect(tester.getCenter(find.text('Dashboard')).dx, lessThan(label.left));
    expect(tester.getCenter(find.text('Profile')).dx, greaterThan(label.right));
    expect(label.left, greaterThanOrEqualTo(800 / 3));
    expect(label.right, lessThanOrEqualTo(800 * 2 / 3));
    expect(label.bottom, lessThanOrEqualTo(600));

    // Opening the tab replays the entrance; tapping it again does not.
    double entrance() => tester
        .widget<EntranceStagger>(find.byType(EntranceStagger).first)
        .animation
        .value;
    await tester.tap(find.text('Recommendations'));
    await tester.pump();
    expect(entrance(), 0);
    await tester.pumpAndSettle();
    expect(entrance(), 1);
    expect(shown('Nutrition'), findsOneWidget);
    await tester.tap(find.text('Recommendations'));
    await tester.pump();
    expect(entrance(), 1);
    expect(tester.takeException(), isNull);
  });

  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets('everything opened fits at 1.3x text: ${locale.languageCode}',
        (tester) async {
      await pumpScreen(tester, locale: locale);
      final l10n = lookupAppLocalizations(locale);
      final content = recommendationsFor(locale);
      final diet = content.diet;

      // Nutrition: the whole introduction and every food group.
      await tapText(tester, l10n.recReadMore);
      await expectShown(tester, diet.intro.last);
      for (final group in diet.groups) {
        await tapText(tester, group.title);
        await expectShown(tester, group.advice.first.text);
      }
      await expectShown(tester, diet.reintroduction.detail!);
      expect(tester.takeException(), isNull);

      // Movement, reached by swiping: every exercise, unlocking Kegel.
      await tester.fling(find.byType(PageView), const Offset(-300, 0), 1000);
      await tester.pumpAndSettle();
      expect(shown(content.exercise.goalsTitle), findsOneWidget);
      final exercises =
          content.exercise.sections.expand((section) => section.exercises);
      for (final exercise in exercises) {
        if (exercise.requiresUnlock) {
          await tapText(tester, l10n.recKegelUnlock);
          await tester.tap(find.text(l10n.recKegelDialogYes));
          await tester.pumpAndSettle();
        } else if (exercise.numbered) {
          await tapText(tester, exercise.title);
        } // else: the walking card starts open.
        await expectShown(tester, exercise.steps.first);
      }
      await expectShown(tester, exercises.last.steps.last);
      expect(tester.takeException(), isNull);

      // Back by tapping the segment: scroll position and open cards stayed.
      await tester.tap(find.text(l10n.recSegmentDiet));
      await tester.pumpAndSettle();
      expect(shown(diet.reintroduction.detail!), findsOneWidget);
      expect(find.text(l10n.recShowLess, skipOffstage: false), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('with reduced motion nothing animates', (tester) async {
    await pumpScreen(tester, reduceMotion: true);
    final content = recommendationsFor(const Locale('en'));
    final firstCardOpacity = tester
        .widget<FadeTransition>(find.descendant(
          of: find.byType(EntranceStagger).first,
          matching: find.byType(FadeTransition),
        ))
        .opacity;
    expect(firstCardOpacity.value, 1); // no entrance fade

    // Every change is done by the next frame.
    Future<void> nextFrame() async {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
    }

    await tester.tap(find.text('Read more'));
    await nextFrame();
    expect(find.text('Show less'), findsOneWidget);
    await tester.tap(find.text('Movement'));
    await nextFrame();
    expect(shown(content.exercise.goalsTitle), findsOneWidget);
    final walk = content.exercise.sections
        .expand((section) => section.exercises)
        .firstWhere((exercise) => !exercise.numbered);
    await scrollTo(tester, walk.title);
    expect(shown(walk.steps.first), findsOneWidget);
    await tester.tap(find.text(walk.title));
    await nextFrame();
    expect(shown(walk.steps.first), findsNothing);
    await tester.tap(find.text(walk.title));
    await nextFrame();
    expect(shown(walk.steps.first), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  group('Kegel exercises', () {
    final kegel = recommendationsFor(const Locale('en'))
        .exercise
        .sections
        .expand((section) => section.exercises)
        .singleWhere((exercise) => exercise.requiresUnlock);
    // Anywhere in the tree, even hidden.
    final built = find.text(kegel.steps.first, skipOffstage: false);

    Future<void> openKegel(
        WidgetTester tester, Map<String, Object> prefs) async {
      await pumpScreen(tester, prefs: prefs);
      await tester.tap(find.text('Movement'));
      await tester.pumpAndSettle();
      await scrollTo(tester, kegel.title);
    }

    Future<void> answerUnlock(WidgetTester tester, String answer) async {
      await tapText(tester, 'Unlock');
      expect(
        find.text('Did you learn the correct technique in the PMR department?'),
        findsOneWidget,
      );
      await tester.tap(find.text(answer));
      await tester.pumpAndSettle();
    }

    testWidgets('are locked at first, and "Not yet" keeps them locked',
        (tester) async {
      await openKegel(tester, {});
      expect(built, findsNothing);
      expect(find.text(kegel.dose.first, skipOffstage: false), findsNothing);

      await answerUnlock(tester, 'Not yet');
      expect(built, findsNothing);
      expect(shown('Unlock'), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(kegelKey), isNull);
    });

    testWidgets('"Yes, I did" shows them and remembers the patient',
        (tester) async {
      await openKegel(tester, {codeKey: 'A'});
      await answerUnlock(tester, 'Yes, I did');
      await expectShown(tester, kegel.dose.first);
      await expectShown(tester, kegel.steps.first);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(kegelKey), 'A');
      expect(tester.takeException(), isNull);
    });

    testWidgets('stay unlocked for the patient who confirmed', (tester) async {
      await openKegel(tester, {codeKey: 'A', kegelKey: 'A'});
      expect(find.text('Unlock', skipOffstage: false), findsNothing);
      await expectShown(tester, kegel.dose.first);
      expect(shown(kegel.steps.first), findsNothing); // folded like the rest

      await tapText(tester, kegel.title);
      await expectShown(tester, kegel.steps.first);
    });

    testWidgets('lock again when another patient logs in', (tester) async {
      await openKegel(tester, {codeKey: 'A', kegelKey: 'A'});
      expect(find.text('Unlock', skipOffstage: false), findsNothing);

      // Patient B logs in on another tab; opening this tab re-checks.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(codeKey, 'B');
      tester
          .state<RecommendationsScreenState>(find.byType(RecommendationsScreen))
          .playEntrance();
      await tester.pumpAndSettle();
      await expectShown(tester, 'Unlock');
      expect(built, findsNothing);
    });
  });
}
