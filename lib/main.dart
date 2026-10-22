import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './services/hive_database_service.dart';
import './theme.dart';
import './onboarding/onboarding_page.dart';
import './pages/summary_page.dart';
import './pages/pc_management_page.dart';
import './pages/support_inventory_page.dart';
import './pages/repair_log_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi Hive Community Edition (Hive CE) dengan 3 Box: 'pc_box', 'support_box', 'log_box'
  await HiveDatabaseService.instance.init();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LTrack',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.dark(
          primary: mint,
          surface: card,
        ),
        bottomAppBarTheme: const BottomAppBarThemeData(
          color: Colors.transparent,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      home: const OnboardingGate(),
    ),
  );
}

/// Gate yang menentukan layar pertama: Onboarding jika belum pernah dilihat,
/// kemudian Shell (layar utama). Status disimpan ke SharedPreferences.
class OnboardingGate extends StatefulWidget {
  const OnboardingGate({super.key});

  @override
  State<OnboardingGate> createState() => _OnboardingGateState();
}

class _OnboardingGateState extends State<OnboardingGate> {
  bool _seen = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _seen = prefs.getBool('ltrack_onboarding_seen') ?? false;
      _loading = false;
    });
  }

  Future<void> _complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ltrack_onboarding_seen', true);
    if (!mounted) return;
    setState(() => _seen = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: bg,
        body: Center(child: CircularProgressIndicator(color: mint)),
      );
    }
    if (_seen) return const Shell();
    return OnboardingPage(onCompleted: _complete);
  }
}

class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _activeTab = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      SummaryPage(navigateTo: (index) => setState(() => _activeTab = index)),
      const PCManagementPage(),
      const SupportInventoryPage(),
      const RepairLogPage(),
    ];

    const icons = [
      Icons.dashboard_rounded,
      Icons.desktop_windows_rounded,
      Icons.devices_other_rounded,
      Icons.build_circle_rounded,
    ];

    const labels = [
      'Beranda',
      'PC Lab',
      'Pendukung',
      'Log Servis',
    ];

    return Scaffold(
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 320),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.02),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: KeyedSubtree(key: ValueKey(_activeTab), child: pages[_activeTab]),
        ),
      ),
      bottomNavigationBar: Material(
        color: Colors.transparent,
        elevation: 0,
        child: SafeArea(
          child: Container(
            height: 58,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.all(5),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xFF131915),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: a(mint, 0.22), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(120),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: mint.withAlpha(15),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),

            child: LayoutBuilder(
              builder: (context, box) {
                final slot = box.maxWidth / 4;
                const size = 44.0;

                return Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // Sliding pill indikator :v
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 340),
                      curve: Curves.easeOutCubic,
                      left: _activeTab * slot + (slot - size) / 2,
                      top: 1,
                      child: Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: a(mint, 0.16),
                          border: Border.all(color: mint, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: mint.withAlpha(50),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        for (var k = 0; k < 4; k++)
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => setState(() => _activeTab = k),
                              child: Tooltip(
                                message: labels[k],
                                child: Center(
                                  child: AnimatedScale(
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeOutCubic,
                                    scale: _activeTab == k ? 1.15 : 1.0,
                                    child: Icon(
                                      icons[k],
                                      size: 22,
                                      color: _activeTab == k ? mint : Colors.white38,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
