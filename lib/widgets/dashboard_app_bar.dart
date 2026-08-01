import 'package:flutter/material.dart';

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double blendedReturn;
  final VoidCallback onOpenGoalSolver;

  const DashboardAppBar({super.key, required this.blendedReturn, required this.onOpenGoalSolver});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF181818),
      title: Row(
        children: [
          const Text('Corpus Planner', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFF00E676).withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
            child: Text('Blended CAGR: ${blendedReturn.toStringAsFixed(1)}%', style: const TextStyle(color: Color(0xFF00E676), fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E676), foregroundColor: Colors.black),
            onPressed: onOpenGoalSolver,
            icon: const Icon(Icons.calculate, size: 18),
            label: const Text('Goal Solver', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
