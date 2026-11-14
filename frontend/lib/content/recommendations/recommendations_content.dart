import 'dart:ui' show Locale;

import '../../models/recommendations.dart';
import 'recommendations_en.dart';
import 'recommendations_lt.dart';
import 'recommendations_ru.dart';

/// Recommendations in the app's language. Any language other than
/// Lithuanian or Russian gets English, like the rest of the app.
RecommendationsContent recommendationsFor(Locale locale) {
  switch (locale.languageCode) {
    case 'lt':
      return recommendationsLt;
    case 'ru':
      return recommendationsRu;
    default:
      return recommendationsEn;
  }
}
