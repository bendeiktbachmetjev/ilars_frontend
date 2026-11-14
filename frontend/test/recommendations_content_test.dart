// The English and Russian recommendations must have exactly the Lithuanian
// structure (same ids, order, levels, flags and list lengths), with real
// translated text in every field.

import 'package:flutter_test/flutter_test.dart';

import 'package:lars_app/content/recommendations/recommendations_en.dart';
import 'package:lars_app/content/recommendations/recommendations_lt.dart';
import 'package:lars_app/content/recommendations/recommendations_ru.dart';
import 'package:lars_app/models/recommendations.dart';

/// The content without its wording: one line per item.
List<String> shapeOf(RecommendationsContent c) {
  final d = c.diet;
  final e = c.exercise;
  return [
    'diet.intro:${d.intro.length}',
    for (final t in d.generalTips) 'tip:${t.id}:${t.detail != null}',
    for (final g in d.groups) ...[
      'group:${g.id}:${g.subtitle != null}:${g.intro != null}',
      for (final a in g.advice) 'advice:${a.id}:${a.level.name}:${a.note != null}',
    ],
    'reintro:${d.reintroduction.id}:${d.reintroduction.detail != null}',
    for (final t in e.goals) 'goal:${t.id}:${t.detail != null}',
    for (final s in e.sections) ...[
      'section:${s.id}:${s.badge != null}',
      for (final x in s.exercises)
        'exercise:${x.id}:${x.numbered}:${x.requiresUnlock}:'
            '${x.dose.length}:${x.steps.length}',
    ],
  ];
}

/// Every text the content holds.
List<String> textsOf(RecommendationsContent c) {
  final d = c.diet;
  final e = c.exercise;
  List<String> tip(RecTip t) => [t.title, if (t.detail != null) t.detail!];
  return [
    d.title,
    ...d.intro,
    d.generalTitle,
    for (final t in d.generalTips) ...tip(t),
    d.groupsTitle,
    for (final g in d.groups) ...[
      g.title,
      if (g.subtitle != null) g.subtitle!,
      if (g.intro != null) g.intro!,
      for (final a in g.advice) ...[a.text, if (a.note != null) a.note!],
    ],
    ...tip(d.reintroduction),
    e.title,
    e.goalsTitle,
    for (final t in e.goals) ...tip(t),
    for (final s in e.sections) ...[
      s.title,
      if (s.badge != null) s.badge!,
      for (final x in s.exercises) ...[x.title, ...x.dose, ...x.steps],
    ],
  ];
}

final lithuanianLetters = RegExp('[ąčęėįšųūžĄČĘĖĮŠŲŪŽ]');

void main() {
  const translations = {'en': recommendationsEn, 'ru': recommendationsRu};

  test('Lithuanian ids are unique', () {
    final ids = shapeOf(recommendationsLt).map((line) => line.split(':')[1]);
    expect(ids.toSet().length, ids.length);
  });

  group('same structure as Lithuanian', () {
    translations.forEach((code, content) {
      test(code, () => expect(shapeOf(content), shapeOf(recommendationsLt)));
    });
  });

  test('no empty texts', () {
    for (final content in [recommendationsLt, ...translations.values]) {
      for (final text in textsOf(content)) {
        expect(text.trim(), isNotEmpty);
      }
    }
  });

  group('translated', () {
    translations.forEach((code, content) {
      test(code, () {
        expect(content.diet.title, isNot(recommendationsLt.diet.title));
        expect(content.exercise.title, isNot(recommendationsLt.exercise.title));
        final leftovers =
            textsOf(content).where(lithuanianLetters.hasMatch).toList();
        expect(leftovers, isEmpty, reason: 'Lithuanian text left in $code');
      });
    });
  });
}
