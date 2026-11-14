/// Patient recommendations from the clinical team: nutrition and exercise.
///
/// Pure data, no Flutter imports. One [RecommendationsContent] exists per
/// language (see `lib/content/recommendations/`); all languages share the
/// same ids, order, levels and flags, only the wording differs.
library;

/// How strongly a food advice item applies.
enum RecLevel {
  /// "Rekomenduojama" — good to eat.
  recommended,

  /// "Vengti ar riboti" — avoid or limit.
  limit,

  /// "Atsisakyti" — give up completely.
  avoid,
}

class RecommendationsContent {
  const RecommendationsContent({required this.diet, required this.exercise});

  final DietContent diet;
  final ExerciseContent exercise;
}

/// A short title with optional detail text. Used for the general diet tips,
/// the exercise programme goals and the "bringing foods back" note.
class RecTip {
  const RecTip({required this.id, required this.title, this.detail});

  final String id;
  final String title;
  final String? detail;
}

class DietContent {
  const DietContent({
    required this.title,
    required this.intro,
    required this.generalTitle,
    required this.generalTips,
    required this.groupsTitle,
    required this.groups,
    required this.reintroduction,
  });

  /// Full document title. Kept for fidelity; the screen does not show it.
  final String title;
  final List<String> intro;
  final String generalTitle;
  final List<RecTip> generalTips;
  final String groupsTitle;
  final List<FoodGroup> groups;
  final RecTip reintroduction;
}

class FoodGroup {
  const FoodGroup({
    required this.id,
    required this.title,
    this.subtitle,
    this.intro,
    required this.advice,
  });

  final String id;
  final String title;
  final String? subtitle;
  final String? intro;
  final List<FoodAdvice> advice;
}

class FoodAdvice {
  const FoodAdvice({
    required this.id,
    required this.level,
    required this.text,
    this.note,
  });

  final String id;
  final RecLevel level;

  /// The foods themselves. The level label is shown above, so the text
  /// never repeats "Vengti ar riboti:" and the like.
  final String text;

  /// The reason or condition from the same source sentence.
  final String? note;
}

class ExerciseContent {
  const ExerciseContent({
    required this.title,
    required this.goalsTitle,
    required this.goals,
    required this.sections,
  });

  /// Full document title. Kept for fidelity; the screen does not show it.
  final String title;
  final String goalsTitle;
  final List<RecTip> goals;
  final List<ExerciseSection> sections;
}

class ExerciseSection {
  const ExerciseSection({
    required this.id,
    required this.title,
    this.badge,
    required this.exercises,
  });

  final String id;
  final String title;

  /// Short pill next to the title, e.g. "apie 30 min.".
  final String? badge;
  final List<Exercise> exercises;
}

class Exercise {
  const Exercise({
    required this.id,
    required this.title,
    this.dose = const [],
    required this.steps,
    this.numbered = true,
    this.requiresUnlock = false,
  });

  final String id;
  final String title;

  /// Sets, repetitions, rest or duration, shown as small pills.
  final List<String> dose;

  /// How to do it, one instruction per item.
  final List<String> steps;

  /// Numbered exercises get a 1, 2, 3… badge; the walking card does not.
  final bool numbered;

  /// Kegel exercises: hidden until the patient confirms they learned the
  /// technique with a rehabilitation specialist.
  final bool requiresUnlock;
}
