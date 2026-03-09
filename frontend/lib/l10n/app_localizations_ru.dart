// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'ABBA LARS';

  @override
  String get appName => 'ABBA LARS';

  @override
  String get dashboard => 'Дашборд';

  @override
  String get profile => 'Профиль';

  @override
  String get statistics => 'Статистика';

  @override
  String get weekly => 'Еженедельно';

  @override
  String get monthly => 'Ежемесячно';

  @override
  String get yearly => 'Ежегодно';

  @override
  String get todaysQuestionnaire => 'Опросник на сегодня';

  @override
  String get dailyQuestionnaire => 'Ежедневный опросник';

  @override
  String get weeklyQuestionnaire => 'Еженедельный опросник (LARS)';

  @override
  String get monthlyQuestionnaire => 'Ежемесячный опросник';

  @override
  String get qualityOfLifeQuestionnaire => 'Опросник качества жизни (EQ-5D-5L)';

  @override
  String get noQuestionnaireNeeded => 'Опросник не требуется';

  @override
  String get allQuestionnairesUpToDate => 'Все опросники заполнены';

  @override
  String get fillItNow => 'Заполнить сейчас';

  @override
  String get pleaseSetPatientCode =>
      'Пожалуйста, введите код пациента в Профиле';

  @override
  String get failedToLoadQuestionnaireInfo =>
      'Не удалось загрузить информацию об опроснике';

  @override
  String get retry => 'Повторить';

  @override
  String get completeWeeklyQuestionnairesToSeeStatistics =>
      'Заполняйте еженедельные опросники, чтобы увидеть статистику LARS';

  @override
  String get completeMoreWeeklyQuestionnaires =>
      'Заполняйте больше еженедельных опросников, чтобы увидеть тенденции';

  @override
  String get ilarsPatient => 'Пациент ABBA LARS';

  @override
  String get noPatientCode => 'Код пациента не задан';

  @override
  String code(String code) {
    return 'Код: $code';
  }

  @override
  String get patientCode => 'Код пациента';

  @override
  String get enterYourCode => 'Введите ваш код';

  @override
  String get save => 'Сохранить';

  @override
  String get logout => 'Выйти';

  @override
  String get patientCodeSaved => 'Код пациента сохранен';

  @override
  String get patientCodeCleared => 'Код пациента очищен';

  @override
  String get dailySymptoms => 'Ежедневные симптомы';

  @override
  String get stoolPerDay => 'Стул/день';

  @override
  String get padsUsed => 'Использовано прокладок';

  @override
  String get urgent => 'Позывы';

  @override
  String get nightStools => 'Ночной стул';

  @override
  String get yes => 'Да';

  @override
  String get no => 'Нет';

  @override
  String get stoolLeakage => 'Подтекание стула';

  @override
  String get none => 'Нет';

  @override
  String get liquid => 'Жидкий';

  @override
  String get solid => 'Твердый';

  @override
  String get incompleteEvacuation => 'Неполное опорожнение';

  @override
  String get bloating => 'Вздутие';

  @override
  String get impactOnLife => 'Влияние на жизнь';

  @override
  String get whatDidYouConsumeToday => 'Что вы сегодня ели?';

  @override
  String get whatDidYouDrinkToday => 'Что вы пили';

  @override
  String quantity(String unit) {
    return 'Количество ($unit):';
  }

  @override
  String get stoolConsistency => 'Консистенция стула';

  @override
  String get submit => 'Отправить';

  @override
  String get submittedSuccessfully => 'Успешно отправлено';

  @override
  String submitFailed(int statusCode) {
    return 'Сбой отправки: $statusCode';
  }

  @override
  String error(String error) {
    return 'Ошибка: $error';
  }

  @override
  String get larsScoreQuestionnaire => 'Опросник LARS';

  @override
  String get flatusControlQuestion =>
      'Случалось ли вам не контролировать газы?';

  @override
  String get liquidStoolLeakageQuestion =>
      'Было ли у вас случайное подтекание жидкого стула?';

  @override
  String get bowelFrequencyQuestion =>
      'Как часто вы ходите в туалет по большому?';

  @override
  String get repeatBowelOpeningQuestion =>
      'Приходилось ли вам снова идти в туалет менее чем через час?';

  @override
  String get urgencyToToiletQuestion =>
      'Бывало ли у вас такое сильное желание сходить в туалет, что приходилось бежать?';

  @override
  String get totalScore => 'Общий балл:';

  @override
  String get noNever => 'Нет, никогда';

  @override
  String get yesLessThanOncePerWeek => 'Да, реже одного раза в неделю';

  @override
  String get yesAtLeastOncePerWeek => 'Да, не менее одного раза в неделю';

  @override
  String get moreThan7TimesPerDay => 'Чаще 7 раз в день (24 часа)';

  @override
  String timesPerDay(String min, String max) {
    return '$min-$max раз в день (24 часа)';
  }

  @override
  String get lessThanOncePerDay => 'Реже одного раза в день (24 часа)';

  @override
  String get monthlyQualityOfLife => 'Качество жизни за месяц';

  @override
  String get avoidTraveling => 'Я избегаю поездок из-за проблем с кишечником';

  @override
  String get avoidSocialActivities => 'Я избегаю социальных мероприятий';

  @override
  String get feelEmbarrassed => 'Я стесняюсь своего состояния';

  @override
  String get worryOthersNotice => 'Я боюсь, что другие заметят мои симптомы';

  @override
  String get feelDepressed =>
      'Я чувствую себя подавленным из-за работы кишечника';

  @override
  String get feelInControl => 'Я чувствую, что контролирую симптомы кишечника';

  @override
  String get overallSatisfaction => 'Общая удовлетворенность работой кишечника';

  @override
  String get eq5d5lQuestionnaire => 'Опросник EQ-5D-5L';

  @override
  String get mobility => '1. ПОДВИЖНОСТЬ';

  @override
  String get selfCare => '2. УХОД ЗА СОБОЙ';

  @override
  String get usualActivities => 'ПРИВЫЧНАЯ ДЕЯТЕЛЬНОСТЬ';

  @override
  String get usualActivitiesDescription =>
      'ПРИВЫЧНАЯ ДЕЯТЕЛЬНОСТЬ\n(например: учеба, работа, работа по дому, семейная жизнь или досуг)';

  @override
  String get painDiscomfort => 'БОЛЬ / КОМФОРТ';

  @override
  String get anxietyDepression => 'ТРЕВОГА / ДЕПРЕССИЯ';

  @override
  String get noProblemsWalking => 'Я не испытываю трудностей при ходьбе';

  @override
  String get slightProblemsWalking =>
      'Я испытываю небольшие трудности при ходьбе';

  @override
  String get moderateProblemsWalking =>
      'Я испытываю умеренные трудности при ходьбе';

  @override
  String get severeProblemsWalking =>
      'Я испытываю выраженные трудности при ходьбе';

  @override
  String get unableToWalk => 'Я не могу ходить';

  @override
  String get noProblemsWashing =>
      'Я не испытываю трудностей при умывании или одевании';

  @override
  String get slightProblemsWashing =>
      'Я испытываю небольшие трудности при умывании или одевании';

  @override
  String get moderateProblemsWashing =>
      'Я испытываю умеренные трудности при умывании или одевании';

  @override
  String get severeProblemsWashing =>
      'Я испытываю выраженные трудности при умывании или одевании';

  @override
  String get unableToWash => 'Я не могу сам(а) мыться или одеваться';

  @override
  String get noProblemsUsualActivities =>
      'Я не испытываю трудностей в выполнении моей повседневной деятельности';

  @override
  String get slightProblemsUsualActivities =>
      'Я испытываю небольшие трудности в выполнении моей повседневной деятельности';

  @override
  String get moderateProblemsUsualActivities =>
      'Я испытываю умеренные трудности в выполнении моей повседневной деятельности';

  @override
  String get severeProblemsUsualActivities =>
      'Я испытываю сильные трудности в выполнении моей повседневной деятельности';

  @override
  String get unableToDoUsualActivities =>
      'Я не могу заниматься моей повседневной деятельностью';

  @override
  String get noPainDiscomfort => 'Я не испытываю боли или дискомфорта';

  @override
  String get slightPainDiscomfort => 'Я испытываю слабую боль или дискомфорт';

  @override
  String get moderatePainDiscomfort =>
      'Я испытываю умеренную боль или дискомфорт';

  @override
  String get severePainDiscomfort => 'Я испытываю сильную боль или дискомфорт';

  @override
  String get extremePainDiscomfort =>
      'Я испытываю невыносимую боль или дискомфорт';

  @override
  String get notAnxiousDepressed => 'Я не испытываю ни тревоги, ни депрессии';

  @override
  String get slightlyAnxiousDepressed =>
      'Я испытываю легкую тревогу или депрессию';

  @override
  String get moderatelyAnxiousDepressed =>
      'Я испытываю умеренную тревогу или депрессию';

  @override
  String get severelyAnxiousDepressed =>
      'Я испытываю явную тревогу или депрессию';

  @override
  String get extremelyAnxiousDepressed =>
      'Я испытываю крайнюю тревогу или депрессию';

  @override
  String get noPatientCodeSet => 'Код пациента не задан';

  @override
  String failedToFetchLarsData(String error) {
    return 'Не удалось получить данные LARS: $error';
  }

  @override
  String get noDataAvailableYet => 'Данных пока нет';

  @override
  String get foodVegetablesAllTypes => 'Овощи (любые)';

  @override
  String get foodVegetablesExamples =>
      'Капуста, брокколи, морковь, цветная капуста, цукини, шпинат';

  @override
  String get foodRootVegetables => 'Корнеплоды';

  @override
  String get foodRootVegetablesExamples =>
      'Картофель в мундире, морковь, корнеплоды';

  @override
  String get foodWholeGrains => 'Цельнозерновые продукты';

  @override
  String get foodWholeGrainsExamples => 'Овсянка, гречка, бурый рис, киноа';

  @override
  String get foodWholeGrainBread => 'Цельнозерновой хлеб';

  @override
  String get foodWholeGrainBreadExamples =>
      'Черный хлеб, хлеб из цельного зерна';

  @override
  String get foodNutsAndSeeds => 'Орехи и семена';

  @override
  String get foodNutsAndSeedsExamples => 'Орехи, семечки, семена льна, чиа';

  @override
  String get foodLegumes => 'Бобовые';

  @override
  String get foodLegumesExamples =>
      'Фасоль (любая), чечевица, горох (в т.ч. супы)';

  @override
  String get foodFruitsWithSkin => 'Фрукты с кожурой';

  @override
  String get foodFruitsWithSkinExamples =>
      'Яблоки, груши, сливы, абрикосы (если съедена кожура)';

  @override
  String get foodBerriesAny => 'Ягоды (любые)';

  @override
  String get foodBerriesExamples =>
      'Малина, клубника, черника, смородина, ежевика';

  @override
  String get foodSoftFruitsWithoutSkin => 'Мягкие фрукты без кожуры';

  @override
  String get foodSoftFruitsExamples => 'Бананы, дыня, арбуз, манго';

  @override
  String get foodMuesliAndBranCereals => 'Мюсли и хлопья с отрубями';

  @override
  String get foodMuesliExamples => 'Хлопья без сахара, гранола';

  @override
  String get drinkWater => 'Вода';

  @override
  String get drinkWaterExamples =>
      'Обычная вода, минеральная вода, фильтрованная вода';

  @override
  String get drinkCoffee => 'Кофе';

  @override
  String get drinkCoffeeExamples => 'Эспрессо, капучино, американо, латте';

  @override
  String get drinkTea => 'Чай';

  @override
  String get drinkTeaExamples =>
      'Черный чай, зеленый чай, травяной чай, ромашковый чай';

  @override
  String get drinkAlcohol => 'Алкоголь';

  @override
  String get drinkAlcoholExamples => 'Пиво, вино, водка, коктейли';

  @override
  String get drinkCarbonatedDrinks => 'Газированные напитки';

  @override
  String get drinkCarbonatedExamples =>
      'Кола, спрайт, фанта, газированная вода';

  @override
  String get drinkJuices => 'Соки';

  @override
  String get drinkJuicesExamples =>
      'Апельсиновый сок, яблочный сок, виноградный сок, смузи';

  @override
  String get drinkDairyDrinks => 'Молочные напитки';

  @override
  String get drinkDairyExamples => 'Молоко, кефир, йогурт, молочные коктейли';

  @override
  String get drinkEnergyDrinks => 'Энергетические напитки';

  @override
  String get drinkEnergyExamples => 'Red Bull, Monster, энергетики в шотах';

  @override
  String get unitServings => 'порции';

  @override
  String get unitSlices => 'ломтики';

  @override
  String get unitHandfuls => 'горсти';

  @override
  String get unitPieces => 'шт';

  @override
  String get unitGlasses => 'стаканы';

  @override
  String get unitCups => 'чашки';

  @override
  String get unitDrinks => 'напитки';

  @override
  String get unitCans => 'банки';

  @override
  String get notificationTitle => 'Время заполнить опросник';

  @override
  String get notificationBody => 'Не забудьте заполнить сегодняшний опросник';

  @override
  String get healthTodayTitle => 'ВАШЕ ЗДОРОВЬЕ СЕГОДНЯ';

  @override
  String get healthTodayDescription =>
      'Мы хотели бы узнать, насколько хорошо или плохо Ваше здоровье СЕГОДНЯ. Эта шкала пронумерована от 0 до 100. 100 означает наилучшее состояние здоровья, которое вы можете представить. 0 означает наихудшее состояние здоровья, которое вы можете представить.';

  @override
  String get yourHealthTodayIs => 'ВАШЕ ЗДОРОВЬЕ СЕГОДНЯ =';

  @override
  String get termsOfUse => 'Условия использования';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get termsOfUseComingSoon =>
      'Скоро: здесь будет текст Условий использования.';

  @override
  String get privacyPolicyComingSoon =>
      'Скоро: здесь будет текст Политики конфиденциальности.';

  @override
  String get dailyWarning =>
      'Обратите внимание: этот опросник относится к тому, как вы себя чувствуете СЕГОДНЯ.';

  @override
  String get weeklyWarning =>
      'Обратите внимание: этот опросник относится к вашему состоянию за ПРОШЛУЮ НЕДЕЛЮ.';

  @override
  String get emailOptional => 'Email (Необязательно)';

  @override
  String get emailAddress => 'Адрес электронной почты';

  @override
  String get agreeToTerms =>
      'Я согласен с Условиями использования и Политикой конфиденциальности';

  @override
  String get agreeToPromos =>
      'Я согласен получать рекламные письма (Необязательно)';

  @override
  String get logIn => 'Войти';

  @override
  String get unsubscribePromos => 'Отписаться от рекламных писем';

  @override
  String get subscribePromos => 'Подписаться на рекламные письма';

  @override
  String get unsubscribed => 'Подписка успешно отменена';

  @override
  String get subscribed => 'Подписка успешно оформлена';
}
