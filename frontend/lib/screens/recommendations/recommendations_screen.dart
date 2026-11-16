import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../content/recommendations/recommendations_content.dart';
import '../../l10n/app_localizations.dart';
import '../../models/recommendations.dart';
import '../../services/api_service.dart';
import '../../theme/apple_style.dart';
import 'widgets/badges.dart';
import 'widgets/exercise_card.dart';
import 'widgets/food_group_card.dart';
import 'widgets/info_cards.dart';
import 'widgets/motion.dart';
import 'widgets/section_header.dart';
import 'widgets/segmented_control.dart';

/// Patient code that confirmed learning the Kegel technique ('' when nobody
/// was logged in).
const _kegelUnlockedForKey = 'rec_kegel_unlocked_for';

/// The clinical team's nutrition and exercise advice: two swipeable pages
/// under a pinned segmented control.
class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => RecommendationsScreenState();
}

/// Public state — exposed so `main.dart` can call [playEntrance] through a
/// `GlobalKey<RecommendationsScreenState>`.
class RecommendationsScreenState extends State<RecommendationsScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _page = 0;
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );
  bool _kegelUnlocked = false;

  @override
  void initState() {
    super.initState();
    _loadKegelUnlocked();
    _entrance.forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    _pageController.dispose();
    super.dispose();
  }

  /// Replays the staggered entrance of the cards on the visible page. Also
  /// re-checks the Kegel unlock, as the patient code may have changed on
  /// another tab.
  void playEntrance() {
    _entrance.forward(from: 0);
    _loadKegelUnlocked();
  }

  /// The Kegel card unlocks on the patient's own confirmation, stored on the
  /// device with their patient code, so the next patient on a shared phone
  /// starts locked. A backend flag can replace this later.
  Future<void> _loadKegelUnlocked() async {
    final prefs = await SharedPreferences.getInstance();
    final code = await ApiService().getPatientCode() ?? '';
    final unlocked = prefs.getString(_kegelUnlockedForKey) == code;
    if (!mounted || unlocked == _kegelUnlocked) return;
    setState(() => _kegelUnlocked = unlocked);
  }

  Future<void> _unlockKegel() async {
    setState(() => _kegelUnlocked = true);
    final code = await ApiService().getPatientCode() ?? '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kegelUnlockedForKey, code);
  }

  void _showPage(int index) {
    if (MediaQuery.disableAnimationsOf(context)) {
      _pageController.jumpToPage(index);
    } else {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  List<Widget> _dietItems(DietContent diet) {
    return [
      IntroCard(paragraphs: diet.intro),
      SectionHeader(title: diet.generalTitle),
      for (final (i, tip) in diet.generalTips.indexed)
        TipCard(badge: NumberBadge(number: i + 1), tip: tip),
      SectionHeader(title: diet.groupsTitle),
      for (final group in diet.groups) FoodGroupCard(group: group),
      TipCard(
        badge: const IconBadge(
          icon: Icons.restart_alt_rounded,
          color: AppleStyle.gradientStart,
        ),
        tip: diet.reintroduction,
      ),
    ];
  }

  List<Widget> _exerciseItems(ExerciseContent exercise) {
    return [
      GoalsCard(title: exercise.goalsTitle, goals: exercise.goals),
      for (final section in exercise.sections) ...[
        SectionHeader(title: section.title, badge: section.badge),
        ..._exerciseCards(section.exercises),
      ],
    ];
  }

  /// Numbering restarts in each section and skips the walking card.
  Iterable<Widget> _exerciseCards(List<Exercise> exercises) sync* {
    var number = 0;
    for (final exercise in exercises) {
      yield ExerciseCard(
        exercise: exercise,
        number: exercise.numbered ? ++number : null,
        locked: exercise.requiresUnlock && !_kegelUnlocked,
        onUnlocked: _unlockKegel,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final content = recommendationsFor(Localizations.localeOf(context));
    return Material(
      color: AppleStyle.surface,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: SegmentedControl(
                controller: _pageController,
                segments: [
                  (Icons.restaurant_rounded, l10n.recSegmentDiet),
                  (Icons.directions_walk_rounded, l10n.recSegmentExercise),
                ],
                onSelected: _showPage,
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  HapticFeedback.selectionClick();
                  setState(() => _page = page);
                },
                // The page out of view keeps its state but stops its
                // exercise animations.
                children: [
                  TickerMode(
                    enabled: _page == 0,
                    child: _Page(
                      entrance: _entrance,
                      items: _dietItems(content.diet),
                    ),
                  ),
                  TickerMode(
                    enabled: _page == 1,
                    child: _Page(
                      entrance: _entrance,
                      items: _exerciseItems(content.exercise),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One segment's list. Kept alive so its scroll position and open cards
/// survive a switch to the other segment.
class _Page extends StatefulWidget {
  const _Page({required this.entrance, required this.items});

  final Animation<double> entrance;
  final List<Widget> items;

  @override
  State<_Page> createState() => _PageState();
}

class _PageState extends State<_Page> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final items = widget.items;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, item) in items.indexed)
            EntranceStagger(
              animation: widget.entrance,
              index: i,
              child: Padding(
                // 12 px between cards; section headers carry their own
                // spacing.
                padding: EdgeInsets.only(
                  top: i == 0 ||
                          item is SectionHeader ||
                          items[i - 1] is SectionHeader
                      ? 0
                      : 12,
                ),
                child: item,
              ),
            ),
        ],
      ),
    );
  }
}
