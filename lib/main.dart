import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/dashboard_screen.dart';
import 'screens/portfolio_manager_screen.dart';
import 'screens/swp_screen.dart';
import 'screens/mutual_funds_screen.dart';
import 'screens/bonds_screen.dart';
import 'screens/loan_arbitrage_screen.dart';
import 'screens/study_screen.dart';
import 'screens/pricing_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CorpusPlannerApp());
}

class CorpusPlannerApp extends StatelessWidget {
  const CorpusPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Corpus Planner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF10B981),
          secondary: Color(0xFF38BDF8),
          surface: Color(0xFF1E293B),
        ),
      ),
      home: const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _selectedIndex = 0;
  bool _isPro = false;
  String _planName = '';

  double? _prefilledInitialLumpSum;
  double? _prefilledMonthlySip;
  double? _prefilledSwpCorpus;
  double? _prefilledArbitrageLoan;

  @override
  void initState() {
    super.initState();
    _checkProStatus();
  }

  /// Checks persistent storage on startup
  Future<void> _checkProStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isPro = prefs.getBool('is_pro_unlocked') ?? false;
      _planName = prefs.getString('pro_plan_name') ?? '';
    });
  }

  /// Opens pricing modal and updates UI immediately if unlocked
  Future<void> _openPricingModal() async {
    final result = await PricingModal.show(context);
    if (result == true) {
      await _checkProStatus();
    }
  }

  void _navigateToPlannerWithNetWorth(double lumpSum, double monthlySip) {
    setState(() {
      _prefilledInitialLumpSum = lumpSum;
      _prefilledMonthlySip = monthlySip;
      _selectedIndex = 0;
    });
  }

  void _navigateToSwpWithCorpus(double terminalCorpus) {
    setState(() {
      _prefilledSwpCorpus = terminalCorpus;
      _selectedIndex = 2;
    });
  }

  void _navigateToArbitrageWithLoan(double loanAmount) {
    setState(() {
      _prefilledArbitrageLoan = loanAmount;
      _selectedIndex = 5;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      DashboardScreen(
        initialLumpSumOverride: _prefilledInitialLumpSum,
        monthlySipOverride: _prefilledMonthlySip,
        onNavigateToStudy: () => setState(() => _selectedIndex = 6),
        onNavigateToSwpWithCorpus: _navigateToSwpWithCorpus,
      ),
      PortfolioManagerScreen(
        onSimulateInPlanner: _navigateToPlannerWithNetWorth,
        onSimulateInArbitrage: _navigateToArbitrageWithLoan,
      ),
      SwpScreen(initialCorpusOverride: _prefilledSwpCorpus),
      const MutualFundsScreen(),
      const BondsScreen(),
      LoanArbitrageScreen(initialLoanOverride: _prefilledArbitrageLoan),
      StudyScreen(
        onNavigateToPlanner: () => setState(() => _selectedIndex = 0),
      ),
    ];

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            backgroundColor: const Color(0xFF1E293B),
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            selectedIconTheme: const IconThemeData(color: Color(0xFF10B981)),
            unselectedIconTheme: const IconThemeData(color: Colors.grey),
            selectedLabelTextStyle: const TextStyle(
              color: Color(0xFF10B981),
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelTextStyle: const TextStyle(
              color: Colors.grey,
              fontSize: 10.5,
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.analytics_outlined),
                selectedIcon: Icon(Icons.analytics),
                label: Text('Planner'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.account_balance_wallet_outlined),
                selectedIcon: Icon(Icons.account_balance_wallet),
                label: Text('Net Worth'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.account_balance_outlined),
                selectedIcon: Icon(Icons.account_balance),
                label: Text('SWP'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.travel_explore_outlined),
                selectedIcon: Icon(Icons.travel_explore),
                label: Text('Funds'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long),
                label: Text('Bonds'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.swap_horizontal_circle_outlined),
                selectedIcon: Icon(Icons.swap_horizontal_circle),
                label: Text('Arbitrage'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.menu_book_outlined),
                selectedIcon: Icon(Icons.menu_book),
                label: Text('Guide'),
              ),
            ],
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _isPro
                      ? Tooltip(
                          message: _planName.isNotEmpty
                              ? '$_planName Active'
                              : 'Pro Active',
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF10B981),
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.verified,
                              color: Color(0xFF10B981),
                              size: 20,
                            ),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(
                            Icons.workspace_premium,
                            color: Color(0xFFF59E0B),
                          ),
                          tooltip: 'Upgrade to Pro',
                          onPressed: _openPricingModal,
                        ),
                ),
              ),
            ),
          ),
          const VerticalDivider(color: Colors.white10, thickness: 1, width: 1),
          Expanded(child: screens[_selectedIndex]),
        ],
      ),
    );
  }
}
