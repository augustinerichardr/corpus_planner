import 'package:flutter/material.dart';
import '../financial_engine.dart';

class ProjectionTable extends StatelessWidget {
  final List<GrowthProjection> results;
  final String Function(double) formatCurrency;
  final VoidCallback onExportCsv;

  const ProjectionTable({super.key, required this.results, required this.formatCurrency, required this.onExportCsv});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Yearly Projection Schedule', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF00E676), side: const BorderSide(color: Color(0xFF00E676))),
                onPressed: onExportCsv,
                icon: const Icon(Icons.download, size: 16),
                label: const Text('Export CSV'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Year')),
                    DataColumn(label: Text('Monthly SIP')),
                    DataColumn(label: Text('Total Invested')),
                    DataColumn(label: Text('Equity MF')),
                    DataColumn(label: Text('Bonds/Debt')),
                    DataColumn(label: Text('Total Corpus')),
                    DataColumn(label: Text('Real Value')),
                  ],
                  rows: results.map((r) => DataRow(cells: [
                    DataCell(Text('Y${r.year}')),
                    DataCell(Text(formatCurrency(r.monthlySip))),
                    DataCell(Text(formatCurrency(r.totalInvested))),
                    DataCell(Text(formatCurrency(r.equityValue))),
                    DataCell(Text(formatCurrency(r.debtValue))),
                    DataCell(Text(formatCurrency(r.corpusValue), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00E676)))),
                    DataCell(Text(formatCurrency(r.realValue))),
                  ])).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
