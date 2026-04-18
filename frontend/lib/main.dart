import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'screens/dashboard/dashboard_screen.dart'
    show DashboardScreen, DashboardScreenState;
import 'screens/profile/profile_screen.dart';
import 'services/api_service.dart';
import 'services/notification_service.dart';
import 'services/step_tracking_service.dart';
import 'theme/apple_style.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'app_brand.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: kAppDisplayName,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('lt'), // Lithuanian
        Locale('ru'), // Russian
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        // Unify the entire chrome (scaffold + app bar + nav bar) with the
        // same iOS-like light surface tone so there are no visible seams
        // between chrome and content.
        scaffoldBackgroundColor: AppleStyle.surface,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  final GlobalKey<DashboardScreenState> _dashboardKey = GlobalKey<DashboardScreenState>();
  final GlobalKey<ProfileScreenState> _profileKey = GlobalKey<ProfileScreenState>();

  late final List<Widget> _screens = [
    DashboardScreen(
      key: _dashboardKey,
      onQuestionnaireSubmitted: () => _scheduleNotification(),
      onPatientCodeChanged: _refreshProfile,
    ),
    ProfileScreen(
      key: _profileKey,
      onPatientCodeChanged: _refreshDashboard,
    ),
  ];

  // Method to refresh dashboard when patient code changes
  void _refreshDashboard() {
    _dashboardKey.currentState?.refreshAllData();
    _checkAndShowHealthDisclosure();
  }

  void _refreshProfile() {
    _profileKey.currentState?.loadProfile();
  }

  Future<void> _checkAndShowHealthDisclosure() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeen = prefs.getBool('has_seen_health_disclosure') ?? false;
    
    if (!hasSeen) {
      if (!mounted) return;
      
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Health Data Access'),
          content: const Text(
            'iLARS collects your daily Steps data from Health Connect. This data is used to visibly track your physical activity alongside your LARS scores on your dashboard, and is shared with your doctor to help comprehensively monitor your recovery and health.'
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('I Understand'),
            ),
          ],
        ),
      );
      
      await prefs.setBool('has_seen_health_disclosure', true);
    }
    
    // ignore: unawaited_futures
    StepTrackingService.instance.syncSteps();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initial check on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowHealthDisclosure();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _scheduleNotification();
      _checkAndShowHealthDisclosure();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleNotification();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// Only remind if backend says there is a questionnaire due today and not yet filled.
  /// Works the same whether user fills from app or browser.
  Future<bool> _shouldRemindToday() async {
    final api = ApiService();
    final patientCode = await api.getPatientCode();
    if (patientCode == null || patientCode.isEmpty) return false;
    try {
      final response = await api.getNextQuestionnaire(patientCode: patientCode);
      if (response['status'] != 'ok') return false;
      final questionnaireType = response['questionnaire_type'];
      final isTodayFilled = response['is_today_filled'] as bool? ?? false;
      return questionnaireType != null && !isTodayFilled;
    } catch (_) {
      return false;
    }
  }

  Future<void> _scheduleNotification() async {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;

    final notificationService = NotificationService();
    await notificationService.scheduleDailyNotification(
      title: l10n.notificationTitle,
      body: l10n.notificationBody,
      shouldRemind: _shouldRemindToday(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppleStyle.surface,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppleStyle.surface,
        surfaceTintColor: AppleStyle.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 56,
        title: ShaderMask(
          shaderCallback: (Rect bounds) {
            return AppleStyle.brandGradient.createShader(bounds);
          },
          child: Text(
            AppLocalizations.of(context)!.appTitle,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 0.6,
            ),
          ),
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: _CompactNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

/// Compact custom bottom navigation bar. Same surface tone as the rest of
/// the chrome, noticeably shorter than the default [BottomNavigationBar],
/// and uses the brand gradient on the selected icon.
class _CompactNavBar extends StatelessWidget {
  const _CompactNavBar({
    required this.selectedIndex,
    required this.onTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: const BoxDecoration(
        color: AppleStyle.surface,
        border: Border(
          top: BorderSide(color: Color(0xFFE5E5EA), width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 54,
          child: Row(
            children: [
              Expanded(
                child: _CompactNavItem(
                  icon: Icons.grid_view_rounded,
                  label: l10n.dashboard,
                  selected: selectedIndex == 0,
                  onTap: () => onTap(0),
                ),
              ),
              Expanded(
                child: _CompactNavItem(
                  icon: Icons.person_rounded,
                  label: l10n.profile,
                  selected: selectedIndex == 1,
                  onTap: () => onTap(1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactNavItem extends StatelessWidget {
  const _CompactNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            selected
                ? ShaderMask(
                    shaderCallback: (bounds) =>
                        AppleStyle.brandGradient.createShader(bounds),
                    child: Icon(icon, color: Colors.white, size: 22),
                  )
                : Icon(icon, color: const Color(0xFF9CA3AF), size: 22),
            const SizedBox(height: 2),
            selected
                ? ShaderMask(
                    shaderCallback: (bounds) =>
                        AppleStyle.brandGradient.createShader(bounds),
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        color: Colors.white,
                        letterSpacing: -0.1,
                      ),
                    ),
                  )
                : Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      color: Color(0xFF9CA3AF),
                      letterSpacing: -0.1,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
