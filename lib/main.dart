import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'screens/retirement_screen.dart';
import 'screens/study_screen.dart';

void main() {
  runApp(const CorpusPlannerApp());
}

class CorpusPlannerApp extends StatelessWidget {
  const CorpusPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Corpus Planner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E676),
          secondary: Color(0xFF29B6F6),
          surface: Color(0xFF1E1E1E),
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

  final List<Widget> _screens = const [
    DashboardScreen(),
    RetirementScreen(),
    StudyScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth >= 850;

        if (isDesktop) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
                  labelType: NavigationRailLabelType.all,
                  backgroundColor: const Color(0xFF181818),
                  selectedIconTheme: const IconThemeData(color: Color(0xFF00E676)),
                  selectedLabelTextStyle: const TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 12),
                  unselectedLabelTextStyle: const TextStyle(color: Colors.white54, fontSize: 11),
                  destinations: const [
                    NavigationRailDestination(icon: Icon(Icons.analytics_outlined), selectedIcon: Icon(Icons.analytics), label: Text('Planner')),
                    NavigationRailDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: Text('SWP')),
                    NavigationRailDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: Text('Guide')),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1, color: Colors.white10),
                Expanded(child: IndexedStack(index: _selectedIndex, children: _screens)),
              ],
            ),
          );
        }

        return Scaffold(
          body: IndexedStack(index: _selectedIndex, children: _screens),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.analytics_outlined), selectedIcon: Icon(Icons.analytics, color: Color(0xFF00E676)), label: 'Planner'),
              NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet, color: Color(0xFF00E676)), label: 'SWP'),
              NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book, color: Color(0xFF00E676)), label: 'Guide'),
            ],
          ),
        );
      },
    );
  }
}
