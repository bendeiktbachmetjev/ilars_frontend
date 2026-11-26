// Store pictures of the real app screens, drawn with invented data.
//
//   cd frontend   (the Flutter app folder)
//   python3 store/pictures/make_fixture.py            # only to change the data
//   flutter test tool/store_captures_test.dart
//
// Writes store/pictures/raw/{en,lt}/*.png, each 1320 x 2868 (iPhone 17 Pro
// Max: 440 x 956 points at 3x, safe area 62 top / 34 bottom). The status-bar
// zone is left as the app paints it; the clock and icons are added later.
//
// No server and no device: every request the screens make is answered from
// store/pictures/fixtures/patient.json (an invented patient), and the plugins
// (step data, notifications, saved settings) are stubbed. Any request the
// fixtures do not know fails the test, so nothing can silently show an error.
//
// Fonts: Roboto from the Flutter SDK stands in for the phone's system font,
// plus the Material Icons font and Apple Color Emoji (macOS) for the food and
// drink pictures.

// This file lives in tool/, so the analyzer does not see it as a test.
// ignore_for_file: invalid_use_of_visible_for_testing_member, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lars_app/l10n/app_localizations.dart';
import 'package:lars_app/main.dart';
import 'package:lars_app/screens/questionnaires/daily_questionnaire_screen.dart';
import 'package:lars_app/screens/questionnaires/weekly_questionnaire_screen.dart';

const _out = 'store/pictures/raw';
final _fixture = jsonDecode(
  File('store/pictures/fixtures/patient.json').readAsStringSync(),
) as Map<String, dynamic>;

const _emojiFamily = 'Apple Color Emoji';
final _shotKey = GlobalKey();
final List<String> _unknownRequests = [];

// ---- Fonts -----------------------------------------------------------------

Future<void> _loadFonts() async {
  final root = Platform.environment['FLUTTER_ROOT'] ??
      File(Platform.resolvedExecutable).parent.parent.parent.parent.parent
          .parent.path;
  final dir = '$root/bin/cache/artifacts/material_fonts';
  const weights = [
    'Thin', 'Light', 'Regular', 'Medium', 'Bold', 'Black', //
    'Italic', 'MediumItalic', 'BoldItalic',
  ];
  ByteData read(String path) =>
      ByteData.sublistView(File(path).readAsBytesSync());

  // Material on iOS asks for CupertinoSystemText / CupertinoSystemDisplay
  // (the phone's own font); Roboto stands in for it under every name.
  // Text that names no family at all is handled in _systemFontForUnnamed.
  for (final family in [
    'Roboto',
    'CupertinoSystemText',
    'CupertinoSystemDisplay',
  ]) {
    final loader = FontLoader(family);
    for (final w in weights) {
      loader.addFont(Future.value(read('$dir/Roboto-$w.ttf')));
    }
    await loader.load();
  }
  await (FontLoader('MaterialIcons')
        ..addFont(Future.value(read('$dir/MaterialIcons-Regular.otf'))))
      .load();
  const emoji = '/System/Library/Fonts/Apple Color Emoji.ttc';
  // (registered as _emojiFamily)
  if (File(emoji).existsSync()) {
    await (FontLoader(_emojiFamily)
          ..addFont(Future.value(read(emoji))))
        .load();
  }
}

// ---- Faked server ----------------------------------------------------------

String _day(int daysAgo) {
  final now = DateTime.now();
  final d = DateTime(now.year, now.month, now.day - daysAgo);
  return '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}

int _windowDays(String? period) => switch (period) {
      'weekly' => 7,
      'monthly' => 30,
      '3months' => 90,
      '6months' => 180,
      _ => 365,
    };

Future<http.Response> _server(http.Request request) async {
  final path = request.url.path;
  final code = request.headers['X-Patient-Code'] ??
      request.headers['x-patient-code'];
  Map<String, dynamic>? body;

  if (code != _fixture['patient_code']) {
    _unknownRequests.add('$path (patient code "$code")');
    return http.Response('{"status":"error"}', 401);
  }
  final window = _windowDays(request.url.queryParameters['period']);
  switch (path) {
    case '/getNextQuestionnaire':
      body = Map<String, dynamic>.from(_fixture['next_questionnaire'] as Map);
    case '/getLarsData':
      body = {
        'status': 'ok',
        'data': [
          for (final w in _fixture['weekly_lars'] as List)
            if ((w['days_ago'] as int) <= window)
              {'date': _day(w['days_ago'] as int), 'score': w['score']},
        ],
      };
    case '/getStepsChartData':
      body = {
        'status': 'ok',
        'data': [
          for (final s in _fixture['steps'] as List)
            if ((s['days_ago'] as int) <= window)
              {'date': _day(s['days_ago'] as int), 'steps': s['steps']},
        ],
      };
    case '/getStepsSyncInfo':
      // Already synced up to yesterday: the app reads no step data.
      body = {'status': 'ok', 'start_date': _day(0)};
    case '/getPatientProfile':
      body = {
        'status': 'ok',
        'email': null,
        'agreed_to_terms': true,
        'agreed_to_promos': false,
      };
  }
  if (body == null) {
    _unknownRequests.add('${request.method} ${request.url}');
    return http.Response('{"status":"error"}', 404);
  }
  return http.Response(jsonEncode(body), 200,
      headers: {'content-type': 'application/json'});
}

// ---- Faked device ----------------------------------------------------------

void _stubPlugins() {
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  // Apple Health / Health Connect: permission given; no reads happen because
  // the faked server says steps are already synced.
  messenger.setMockMethodCallHandler(
      const MethodChannel('flutter_health'), (call) async {
    if (call.method == 'requestAuthorization' ||
        call.method == 'hasPermissions') {
      return true;
    }
    return null;
  });
  // Local notifications: accept everything.
  messenger.setMockMethodCallHandler(
      const MethodChannel('dexterous.com/flutter/local_notifications'),
      (call) async => null);
  // Haptics and other system calls.
  messenger.setMockMethodCallHandler(SystemChannels.platform,
      (call) async => null);
}

// ---- Phone -----------------------------------------------------------------

void _phone(WidgetTester tester, Locale locale) {
  tester.view.physicalSize = const Size(1320, 2868);
  tester.view.devicePixelRatio = 3.0;
  const insets = FakeViewPadding(top: 62 * 3, bottom: 34 * 3);
  tester.view.padding = insets;
  tester.view.viewPadding = insets;
  tester.platformDispatcher.localesTestValue = [locale];
  tester.platformDispatcher.localeTestValue = locale;
  tester.platformDispatcher.textScaleFactorTestValue = 1.0;
  tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearAllTestValues);
}

/// Frames without pumpAndSettle: the exercise pictures loop forever.
Future<void> _frames(WidgetTester tester, [int ms = 1200]) async {
  for (var t = 0; t < ms; t += 50) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

/// Lets the faked server's answers arrive (they are real futures).
Future<void> _settleData(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.runAsync(() => Future<void>.delayed(
          const Duration(milliseconds: 20),
        ));
    await _frames(tester, 200);
  }
}

/// A text style that names no font family (e.g. the Submit buttons' own
/// textStyle) gets the system font on a phone, but the test's box font here,
/// and no loaded font can replace that default. So, just before a picture,
/// such texts are given the stand-in system font directly on their render
/// objects. In the same way the phone's emoji font is named as a fallback
/// (the food and drink pictures), which the phone also does on its own.
/// Nothing in the app changes.
Future<void> _systemFontForUnnamed(WidgetTester tester) async {
  var changed = false;
  void visit(RenderObject node) {
    if (node is RenderParagraph) {
      final span = node.text;
      final style = span.style;
      final needsFamily = style?.fontFamily == null;
      final needsEmoji = !(style?.fontFamilyFallback?.contains(_emojiFamily) ??
              false) &&
          span.toPlainText().runes.any((r) => r >= 0x2600);
      if (span is TextSpan && (needsFamily || needsEmoji)) {
        node.text = TextSpan(
          text: span.text,
          children: span.children,
          style: (style ?? const TextStyle()).copyWith(
            fontFamily: style?.fontFamily ?? 'CupertinoSystemText',
            fontFamilyFallback: needsEmoji ? const [_emojiFamily] : null,
          ),
          recognizer: span.recognizer,
          semanticsLabel: span.semanticsLabel,
          locale: span.locale,
          spellOut: span.spellOut,
        );
        changed = true;
      }
    }
    node.visitChildren(visit);
  }

  visit(_shotKey.currentContext!.findRenderObject()!);
  if (changed) await tester.pump(); // layout + paint only, no rebuild
}

Future<void> _save(WidgetTester tester, String lang, String name) async {
  await _systemFontForUnnamed(tester);
  expect(find.byType(CircularProgressIndicator), findsNothing,
      reason: '$name: a loading spinner is still showing');
  expect(_unknownRequests, isEmpty,
      reason: '$name: requests the fixtures do not answer');
  final exception = tester.takeException();
  expect(exception, isNull, reason: '$name: $exception');
  await tester.runAsync(() async {
    final boundary = _shotKey.currentContext!.findRenderObject()!
        as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3.0);
    expect(image.width, 1320);
    expect(image.height, 2868);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    File('$_out/$lang/$name.png')
      ..createSync(recursive: true)
      ..writeAsBytesSync(data!.buffer.asUint8List());
  });
}

Future<void> _tapText(WidgetTester tester, String text, {int index = 0}) async {
  final f = find.text(text);
  await tester.ensureVisible(f.at(index));
  await _frames(tester, 400);
  await tester.tap(f.at(index));
  await _frames(tester, 600);
}

/// Scrolls [text] to the top of its list, [offset] points below the top.
Future<void> _scrollToTop(WidgetTester tester, String text,
    {double offset = 0, Finder? within}) async {
  // Lists build lazily: step down until the text exists.
  if (within != null) {
    final list = tester.state<ScrollableState>(find
        .descendant(of: within, matching: find.byType(Scrollable))
        .first);
    while (find.text(text).evaluate().isEmpty &&
        list.position.pixels < list.position.maxScrollExtent) {
      list.position.jumpTo(list.position.pixels + 300);
      await tester.pump();
    }
  }
  final element = tester.element(find.text(text).first);
  final scrollable = Scrollable.of(element);
  final box = element.findRenderObject()! as RenderBox;
  final viewport = scrollable.context.findRenderObject()! as RenderBox;
  final dy = box.localToGlobal(Offset.zero).dy -
      viewport.localToGlobal(Offset.zero).dy;
  final position = scrollable.position;
  position.jumpTo((position.pixels + dy - offset)
      .clamp(position.minScrollExtent, position.maxScrollExtent));
  await _frames(tester, 400);
}

// ---- The run ---------------------------------------------------------------

Future<void> _capture(WidgetTester tester, Locale locale) async {
  final lang = locale.languageCode;
  final l10n = lookupAppLocalizations(locale);
  _phone(tester, locale);
  _unknownRequests.clear();
  SharedPreferences.setMockInitialValues({
    'patient_code': _fixture['patient_code'] as String,
    'has_seen_health_disclosure': true,
  });

  await tester.pumpWidget(RepaintBoundary(key: _shotKey, child: const MyApp()));
  await _settleData(tester);

  // 1. Dashboard: the chart over three months (weekly LARS + daily steps).
  await _tapText(tester, l10n.threeMonths);
  await _settleData(tester);
  await _save(tester, lang, 'dashboard');

  final navigator = tester.state<NavigatorState>(find.byType(Navigator).first);

  // 2. Daily form, partly filled in with mild values.
  final daily = Map<String, dynamic>.from(_fixture['daily_in_progress'] as Map);
  navigator.push(MaterialPageRoute(
      builder: (_) => DailyQuestionnaireScreen(initialData: daily)));
  await _frames(tester, 1000);
  await _save(tester, lang, 'daily');
  navigator.pop();
  await _frames(tester, 1000);

  // 4. Food and drink part of the same form, a few items chosen.
  navigator.push(MaterialPageRoute(
      builder: (_) => DailyQuestionnaireScreen(initialData: {
            ...daily,
            ...Map<String, dynamic>.from(_fixture['food_in_progress'] as Map),
          })));
  await _frames(tester, 1000);
  await _scrollToTop(tester, l10n.whatDidYouConsumeToday,
      offset: 4, within: find.byType(DailyQuestionnaireScreen));
  // The Bristol stool pictures must stay out of the picture.
  final bristol = find.text(l10n.stoolConsistency);
  final screenBottom = tester.view.physicalSize.height / 3;
  if (bristol.evaluate().isNotEmpty) {
    expect(tester.getTopLeft(bristol).dy, greaterThan(screenBottom),
        reason: 'Bristol scale would be visible');
  }
  await _save(tester, lang, 'food');
  navigator.pop();
  await _frames(tester, 1000);

  // 3. Weekly LARS, the first two questions answered (gas: "yes, less than
  // once a week"; liquid leakage: "no, never"), the rest still open.
  navigator.push(MaterialPageRoute(
      builder: (_) => const WeeklyQuestionnaireScreen(initialData: {
            'flatus_control': 1,
            'liquid_stool_leakage': 0,
          })));
  await _frames(tester, 1000);
  await _save(tester, lang, 'weekly-lars');
  navigator.pop();
  await _frames(tester, 1000);

  // 5. Recommendations, Diet.
  await _tapText(tester, l10n.recommendations);
  await _frames(tester, 1500);
  await _save(tester, lang, 'recommendations-diet');

  // 6. Recommendations, Exercise: goals, the walking card open with its
  // figure (it opens by itself), the training cards folded below.
  await _tapText(tester, l10n.recSegmentExercise);
  await _frames(tester, 1500);
  await _frames(tester, 1900); // the walker mid-step
  await _save(tester, lang, 'recommendations-exercise');

  // 7. Profile: patient code and settings only (no e-mail saved).
  await _tapText(tester, l10n.profile);
  await _settleData(tester);
  await _save(tester, lang, 'profile');

  // Leave nothing running.
  await tester.pumpWidget(const SizedBox());
  await _frames(tester, 200);
}

void main() {
  setUpAll(() async {
    await _loadFonts();
    _stubPlugins();
  });

  for (final locale in const [Locale('en'), Locale('lt')]) {
    testWidgets('store pictures ${locale.languageCode}', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      debugDisableShadows = false;
      WidgetsApp.debugAllowBannerOverride = false;
      try {
        await http.runWithClient(
          () => _capture(tester, locale),
          () => MockClient(_server),
        );
      } finally {
        debugDefaultTargetPlatformOverride = null;
        debugDisableShadows = true;
        WidgetsApp.debugAllowBannerOverride = true;
      }
    });
  }
}
