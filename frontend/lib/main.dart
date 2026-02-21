import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'screens/dashboard_screen.dart' show DashboardScreen, DashboardScreenState;
import 'screens/profile_screen.dart';
import 'services/api_service.dart';
import 'services/notification_service.dart';
import 'services/step_tracking_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  runApp(const MyApp());

  // Background step sync (non-blocking)
  _initStepTracking();
}

Future<void> _initStepTracking() async {
  try {
    final stepService = StepTrackingService.instance;
    final granted = await stepService.requestPermission();
    if (granted) {
      await stepService.syncSteps(days: 7);
    }
  } catch (_) {
    // Non-critical — app works without step data
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iLARS',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('lt'), // Lithuanian
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
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

  late final List<Widget> _screens = [
    DashboardScreen(
      key: _dashboardKey,
      onQuestionnaireSubmitted: () => _scheduleNotification(),
    ),
    ProfileScreen(onPatientCodeChanged: _refreshDashboard),
  ];

  // Method to refresh dashboard when patient code changes
  void _refreshDashboard() {
    _dashboardKey.currentState?.refreshAllData();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
      StepTrackingService.instance.syncSteps(days: 3);
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
      shouldRemind: _shouldRemindToday,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        title: ShaderMask(
          shaderCallback: (Rect bounds) {
            return const LinearGradient(
              colors: [Color(0xFF3A8DFF), Color(0xFF8F5CFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          child: Text(
            AppLocalizations.of(context)!.appTitle,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: GradientIconLabel(
              icon: Icons.dashboard,
              label: AppLocalizations.of(context)!.dashboard,
              selected: _selectedIndex == 0,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: GradientIconLabel(
              icon: Icons.person,
              label: AppLocalizations.of(context)!.profile,
              selected: _selectedIndex == 1,
            ),
            label: '',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class GradientIconLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  const GradientIconLabel({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = const LinearGradient(
      colors: [Color(0xFF3A8DFF), Color(0xFF8F5CFF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        selected
            ? ShaderMask(
                shaderCallback: (Rect bounds) {
                  return gradient.createShader(bounds);
                },
                child: Icon(
                  icon,
                  color: Colors.white,
                ),
              )
            : Icon(
                icon,
                color: Colors.grey,
              ),
        const SizedBox(height: 2),
        selected
            ? ShaderMask(
                shaderCallback: (Rect bounds) {
                  return gradient.createShader(bounds);
                },
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
      ],
    );
  }
}