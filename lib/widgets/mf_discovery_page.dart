import 'package:flutter/material.dart';
import '../models/mutual_fund_model.dart';
import '../services/mf_service.dart';

class MFDiscoveryPage extends StatefulWidget {
  final Function(MutualFundScheme, double monthlySip) onAddInvestment;

  const MFDiscoveryPage({super.key, required this.onAddInvestment});

  @override
  State<MFDiscoveryPage> createState() => _MFDiscoveryPageState();
}

class _MFDiscoveryPageState extends State<MFDiscoveryPage> {
  final TextEditingController _searchController = TextEditingController();
  List<MutualFundScheme> _searchResults = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    setState(() => _isLoading = true);

    try {
      final results = await MFService.searchFunds(query);
      if (!mounted) return;
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error searching funds: $e')));
    }
  }

  void _showAddDialog(MutualFundScheme fund) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    await MFService.getFundDetails(fund);
    if (!mounted) return;
    Navigator.of(context).pop();

    final sipController = TextEditingController(text: "5000");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(
          fund.schemeName,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Latest NAV: ₹${fund.nav ?? "N/A"} (${fund.date ?? ""})',
              style: const TextStyle(color: Colors.greenAccent),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: sipController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Monthly SIP Amount (₹)',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.greenAccent),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent,
            ),
            onPressed: () {
              final sip = double.tryParse(sipController.text) ?? 0.0;
              widget.onAddInvestment(fund, sip);
              Navigator.pop(ctx);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Added ${fund.schemeName} to Planner!')),
              );
            },
            child: const Text(
              'Add to Assets',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Mutual Fund Explorer'),
        backgroundColor: const Color(0xFF1E293B),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search Index, Flexi Cap, Small Cap funds...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.greenAccent),
                  onPressed: _performSearch,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (ctx, index) {
                    final item = _searchResults[index];
                    return Card(
                      color: const Color(0xFF1E293B),
                      child: ListTile(
                        title: Text(
                          item.schemeName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          'Scheme Code: ${item.schemeCode}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.add_circle,
                            color: Colors.greenAccent,
                          ),
                          onPressed: () => _showAddDialog(item),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
