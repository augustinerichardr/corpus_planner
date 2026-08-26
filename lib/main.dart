import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'screens/portfolio_manager_screen.dart';
import 'screens/swp_screen.dart';
import 'screens/mutual_fund_explorer_screen.dart';
import 'screens/bonds_screen.dart';
import 'screens/arbitrage_screen.dart';
import 'screens/education_hub_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/pricing_screen.dart';
import 'services/pro_service.dart';
import 'services/settings_service.dart';
import 'widgets/app_drawer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ProService.init();
  await SettingsService().init();
  runApp(const CorpusPlannerApp());
}

class CorpusPlannerApp extends StatelessWidget {
  const CorpusPlannerApp({super.key});

  final List<String> _screenTitles = const [
    'Wealth Planner',
    'Net Worth Portfolio',
    'SWP Simulator',
    'Mutual Funds Screener',
    'Bonds & Fixed Income',
    'Arbitrage Engine',
    'Education Hub',
    'App Settings',
  ];

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService();

    return AnimatedBuilder(
      animation: settings,
      builder: (context, _) {
        return MaterialApp(
          title: 'CorpusIQ Planner',
          debugShowCheckedModeBanner: false,
          themeMode: settings.themeMode,
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0F172A),
            primaryColor: const Color(0xFF10B981),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF10B981),
              secondary: Color(0xFF38BDF8),
              surface: Color(0xFF1E293B),
            ),
            fontFamily: 'Roboto',
          ),
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF8FAFC),
            primaryColor: const Color(0xFF10B981),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF10B981),
              secondary: Color(0xFF0284C7),
              surface: Colors.white,
            ),
            fontFamily: 'Roboto',
          ),
          builder: (context, child) {
            final mediaQueryData = MediaQuery.of(context);
            return MediaQuery(
              data: mediaQueryData.copyWith(
                textScaler: TextScaler.linear(settings.fontScale),
              ),
              child: child!,
            );
          },
          home: MainShellScreen(screenTitles: _screenTitles),
        );
      },
    );
  }
}

class MainShellScreen extends StatefulWidget {
  final List<String> screenTitles;

  const MainShellScreen({super.key, required this.screenTitles});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _selectedIndex = 0;
  int _subTabIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  double? _plannerLumpSumOverride;
  double? _plannerSipOverride;
  double? _swpCorpusOverride;

  void _navigateTo(int primaryIndex, [int? subIndex]) {
    setState(() {
      _selectedIndex = primaryIndex;
      _subTabIndex = subIndex ?? 0;
    });
  }

  void _handleSimulateInPlanner(double lumpSum, double monthlySip) {
    setState(() {
      _plannerLumpSumOverride = lumpSum;
      _plannerSipOverride = monthlySip;
      _selectedIndex = 0;
      _subTabIndex = 0;
    });
  }

  void _handleSimulateInSwp(double terminalCorpus) {
    setState(() {
      _swpCorpusOverride = terminalCorpus;
      _selectedIndex = 2;
      _subTabIndex = 0;
    });
  }

  void _handleSimulateInArbitrage(double _) {
    setState(() {
      _selectedIndex = 5;
      _subTabIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < 700;

    final List<Widget> screens = [
      DashboardScreen(
        initialLumpSumOverride: _plannerLumpSumOverride,
        monthlySipOverride: _plannerSipOverride,
        onNavigateToSwpWithCorpus: _handleSimulateInSwp,
        onNavigateToStudy: () => _navigateTo(6, 0),
      ),
      PortfolioManagerScreen(
        key: ValueKey('portfolio_$_subTabIndex'),
        initialTabIndex: _subTabIndex,
        onSimulateInPlanner: _handleSimulateInPlanner,
        onSimulateInArbitrage: _handleSimulateInArbitrage,
      ),
      SwpScreen(initialCorpusOverride: _swpCorpusOverride),
      ValueListenableBuilder<bool>(
        valueListenable: ProService.isProNotifier,
        builder: (context, isPro, _) => MutualFundExplorerScreen(
          isPaidUser: isPro,
          onAddSipToDashboard: (sipDelta) {
            if (_plannerSipOverride != null) {
              setState(
                () => _plannerSipOverride = (_plannerSipOverride! + sipDelta)
                    .clamp(0, double.infinity),
              );
            }
          },
        ),
      ),
      const BondsScreen(),
      const ArbitrageScreen(),
      EducationHubScreen(
        key: ValueKey('edu_$_subTabIndex'),
        initialTopicIndex: _subTabIndex,
      ),
      const SettingsScreen(),
    ];

    if (isMobile) {
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: isDark
            ? const Color(0xFF0F172A)
            : const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: isDark
              ? const Color(0xFF0F172A)
              : const Color(0xFFFFFFFF),
          elevation: 0.5,
          leading: IconButton(
            icon: Icon(
              Icons.menu_rounded,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          title: Text(
            widget.screenTitles.length > _selectedIndex
                ? widget.screenTitles[_selectedIndex]
                : 'CorpusIQ Pro',
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          actions: [
            ValueListenableBuilder<bool>(
              valueListenable: ProService.isProNotifier,
              builder: (context, isPro, _) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: TextButton.icon(
                    onPressed: () => PricingModal.show(context),
                    icon: Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: isPro
                          ? const Color(0xFF10B981)
                          : const Color(0xFFF59E0B),
                    ),
                    label: Text(
                      isPro ? 'PRO' : 'Upgrade',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isPro
                            ? const Color(0xFF10B981)
                            : const Color(0xFFF59E0B),
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor:
                          (isPro
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFF59E0B))
                              .withValues(alpha: 0.12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        drawer: AppDrawer(
          selectedIndex: _selectedIndex,
          onNavigate: (primaryIndex, [subTabIndex]) {
            _navigateTo(primaryIndex, subTabIndex);
            Navigator.pop(context);
          },
        ),
        body: IndexedStack(index: _selectedIndex, children: screens),
      );
    }

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8FAFC),
      body: Row(
        children: [
          _buildSidebar(isDark),
          VerticalDivider(
            color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
            width: 1,
          ),
          Expanded(
            child: IndexedStack(index: _selectedIndex, children: screens),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(bool isDark) {
    return Container(
      width: 76,
      color: isDark ? const Color(0xFF0F172A) : Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.auto_graph_rounded,
              color: Color(0xFF10B981),
              size: 22,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _navButton(0, Icons.bar_chart_rounded, 'Planner'),
                  _navButton(
                    1,
                    Icons.account_balance_wallet_outlined,
                    'Net Worth',
                  ),
                  _navButton(2, Icons.account_balance_outlined, 'SWP'),
                  _navButton(3, Icons.pie_chart_outline, 'Funds'),
                  _navButton(4, Icons.shield_outlined, 'Bonds'),
                  _navButton(
                    5,
                    Icons.swap_horizontal_circle_outlined,
                    'Arbitrage',
                  ),
                  _navButton(6, Icons.school_outlined, 'Learn'),
                  _navButton(7, Icons.settings_outlined, 'Settings'),
                ],
              ),
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: ProService.isProNotifier,
            builder: (context, isPro, _) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: IconButton(
                  tooltip: isPro ? 'Pro Active' : 'Upgrade to Pro',
                  icon: Icon(
                    Icons.workspace_premium,
                    color: isPro
                        ? const Color(0xFF10B981)
                        : const Color(0xFFF59E0B),
                    size: 26,
                  ),
                  onPressed: () => PricingModal.show(context),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _navButton(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () => _navigateTo(index, 0),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 60,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF38BDF8).withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? const Color(0xFF38BDF8) : Colors.transparent,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFF38BDF8) : Colors.grey,
                size: 20,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF38BDF8) : Colors.grey,
                  fontSize: 9.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
