import 'package:flutter/material.dart';
import '../models/education_models.dart';
import '../data/education/investment_basics_data.dart';
import '../data/education/mutual_funds_data.dart';
import '../data/education/bonds_data.dart';
import '../data/education/arbitrage_data.dart';
import '../data/education/getting_started_data.dart';
import '../data/education/tax_codes_data.dart';
import '../data/education/govt_savings_data.dart';
import '../widgets/dashboard_app_bar.dart';
import '../widgets/regulatory_disclaimer.dart';

class EducationHubScreen extends StatefulWidget {
  final int initialTopicIndex;

  const EducationHubScreen({
    super.key,
    this.initialTopicIndex = 0,
  });

  @override
  State<EducationHubScreen> createState() => _EducationHubScreenState();
}

class _EducationHubScreenState extends State<EducationHubScreen> {
  late int _selectedCategoryIndex;
  int _selectedCardIndex = 0;
  bool _showMobileDetail = false;
  final ScrollController _mobileChipController = ScrollController();

  final List<EduCategoryTree> _categories = [
    investmentBasicsCategory, // 0: Investment Fundamentals
    mutualFundsCategory, // 1: Mutual Funds
    bondsCategory, // 2: Bonds & Fixed Income
    arbitrageCategory, // 3: Arbitrage & Cash Parking
    gettingStartedCategory, // 4: How to Start Investing
    taxCodesCategory, // 5: Income Tax Act Codes
    govtSavingsCategory, // 6: Govt Small Savings (India)
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategoryIndex =
        widget.initialTopicIndex.clamp(0, _categories.length - 1);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToActiveChip());
  }

  @override
  void didUpdateWidget(covariant EducationHubScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTopicIndex != oldWidget.initialTopicIndex) {
      setState(() {
        _selectedCategoryIndex =
            widget.initialTopicIndex.clamp(0, _categories.length - 1);
        _selectedCardIndex = 0;
        _showMobileDetail = false;
      });
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _scrollToActiveChip());
    }
  }

  void _scrollToActiveChip() {
    if (_mobileChipController.hasClients) {
      final double targetOffset = (_selectedCategoryIndex * 150.0).clamp(
        0.0,
        _mobileChipController.position.maxScrollExtent,
      );
      _mobileChipController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _mobileChipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeCategory = _categories[_selectedCategoryIndex];
    final allNodes = activeCategory.allNodes;
    if (_selectedCardIndex >= allNodes.length) {
      _selectedCardIndex = 0;
    }
    final activeNode =
        allNodes.isNotEmpty ? allNodes[_selectedCardIndex] : null;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: const DashboardAppBar(
        title: 'Financial Knowledge & Decision Tree',
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 850;

            return Column(
              children: [
                // Top Navigation Bar (Wrapping grid on Web, Scrollable capsule rail on Mobile)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 16 : 8,
                    vertical: 8,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E293B),
                    border: Border(
                      bottom: BorderSide(color: Color(0xFF334155)),
                    ),
                  ),
                  child: isDesktop
                      ? _buildDesktopCategoryWrap()
                      : _buildMobileScrollableRail(),
                ),

                // Master-Detail Hierarchy Content
                Expanded(
                  child: isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 360,
                              child: _buildHierarchicalTreeList(activeCategory,
                                  isDesktop: true),
                            ),
                            const VerticalDivider(
                                color: Colors.white10, width: 1),
                            Expanded(
                              child: activeNode != null
                                  ? _buildDirectiveDeepDive(
                                      activeNode, activeCategory.color)
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        )
                      : _showMobileDetail && activeNode != null
                          ? Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  color: const Color(0xFF1E293B),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.arrow_back,
                                            color: Color(0xFF10B981), size: 20),
                                        onPressed: () => setState(
                                            () => _showMobileDetail = false),
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          activeNode.title,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                    child: _buildDirectiveDeepDive(
                                        activeNode, activeCategory.color)),
                              ],
                            )
                          : _buildHierarchicalTreeList(activeCategory,
                              isDesktop: false),
                ),
                const RegulatoryDisclaimer(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDesktopCategoryWrap() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: List.generate(_categories.length, (i) {
        final cat = _categories[i];
        final isSel = _selectedCategoryIndex == i;
        return ChoiceChip(
          avatar: Icon(
            cat.icon,
            size: 13,
            color: isSel ? Colors.black : cat.color,
          ),
          label: Text(
            cat.title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
              color: isSel ? Colors.black : Colors.white70,
            ),
          ),
          selected: isSel,
          selectedColor: cat.color,
          backgroundColor: const Color(0xFF0F172A),
          side: BorderSide(
            color: isSel ? cat.color : const Color(0xFF334155),
          ),
          showCheckmark: false,
          onSelected: (_) => setState(() {
            _selectedCategoryIndex = i;
            _selectedCardIndex = 0;
            _showMobileDetail = false;
          }),
        );
      }),
    );
  }

  Widget _buildMobileScrollableRail() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        controller: _mobileChipController,
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final cat = _categories[i];
          final isSel = _selectedCategoryIndex == i;
          return ChoiceChip(
            avatar: Icon(
              cat.icon,
              size: 14,
              color: isSel ? Colors.black : cat.color,
            ),
            label: Text(
              cat.title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                color: isSel ? Colors.black : Colors.white70,
              ),
            ),
            selected: isSel,
            selectedColor: cat.color,
            backgroundColor: const Color(0xFF0F172A),
            side: BorderSide(
              color: isSel ? cat.color : const Color(0xFF334155),
            ),
            showCheckmark: false,
            onSelected: (_) => setState(() {
              _selectedCategoryIndex = i;
              _selectedCardIndex = 0;
              _showMobileDetail = false;
              _scrollToActiveChip();
            }),
          );
        },
      ),
    );
  }

  Widget _buildHierarchicalTreeList(EduCategoryTree category,
      {required bool isDesktop}) {
    int globalIndex = 0;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: category.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: category.color.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.touch_app_outlined, size: 15, color: category.color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isDesktop
                      ? 'Select any topic below to inspect directives, math & tax codes'
                      : 'Tap any topic below to view in-depth directives & projections',
                  style: TextStyle(
                    color: category.color,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Native Collapsible Accordions for Sub-Groups
        for (final group in category.subGroups)
          Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
              listTileTheme: const ListTileThemeData(
                minVerticalPadding: 0,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 4, vertical: 0),
              ),
            ),
            child: ExpansionTile(
              initiallyExpanded: true,
              iconColor: Colors.white70,
              collapsedIconColor: Colors.white54,
              title: Row(
                children: [
                  Icon(group.icon, size: 14, color: category.color),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      group.groupName,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: category.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      group.groupTag,
                      style: TextStyle(
                          color: category.color,
                          fontSize: 8.5,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              childrenPadding: const EdgeInsets.only(bottom: 8),
              children: [
                for (final node in group.nodes) ...[
                  _buildLeafCard(node, globalIndex++, category.color,
                      isDesktop: isDesktop),
                  const SizedBox(height: 6),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildLeafCard(EduLeafNode node, int flatIndex, Color accentColor,
      {required bool isDesktop}) {
    final isSelected = isDesktop && _selectedCardIndex == flatIndex;

    return InkWell(
      onTap: () => setState(() {
        _selectedCardIndex = flatIndex;
        if (!isDesktop) _showMobileDetail = true;
      }),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F2E3B) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? accentColor : const Color(0xFF334155),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    node.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    node.badge,
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              node.rateOrRule,
              style: const TextStyle(
                color: Color(0xFF38BDF8),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              node.shortSummary,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 10.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  isDesktop ? 'View Directives →' : 'Tap to expand →',
                  style: TextStyle(
                    color: isSelected ? accentColor : const Color(0xFF64748B),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectiveDeepDive(EduLeafNode node, Color accentColor) {
    final bulletItems = node.deepExplanation
        .split('\n\n')
        .where((s) => s.trim().isNotEmpty)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  node.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  node.taxSection,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Rule Directive
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: accentColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              node.rateOrRule,
              style: TextStyle(
                color: accentColor,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                fontSize: 11.5,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Collapsible Accordion 1: Illustrative Outlay & Maturity Projection
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF064E3B).withValues(alpha: 0.35),
                    const Color(0xFF1E293B),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.4)),
              ),
              child: ExpansionTile(
                initiallyExpanded: true,
                tilePadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                leading: const Icon(Icons.calculate_outlined,
                    color: Color(0xFF10B981), size: 18),
                title: const Text(
                  'Illustrative Outlay & Maturity Projection',
                  style: TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
                childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Sample Outlay: ${node.sampleInvestment}',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 10.5)),
                      Text('Lock-in / Tenure: ${node.sampleTenure}',
                          style: const TextStyle(
                              color: Color(0xFF38BDF8),
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Expected Maturity / Return: ${node.sampleMaturityValue}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          // Key Metrics Row
          Row(
            children: [
              for (final metric in node.metrics)
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          metric['label']!,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 9,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            metric['val']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Collapsible Accordion 2: Operational Directives & Statutory Rules
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: ExpansionTile(
                initiallyExpanded: true,
                tilePadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                leading: const Icon(Icons.description_outlined,
                    color: Color(0xFF38BDF8), size: 18),
                title: const Text(
                  'Directives, Regulatory Notes & Operational Framework',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
                childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                children: [
                  for (final item in bulletItems)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildRichBulletItem(item),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRichBulletItem(String rawText) {
    final cleanText = rawText.replaceFirst('•', '').replaceAll('*', '').trim();
    final colonIndex = cleanText.indexOf(':');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6, right: 8),
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            color: Color(0xFF38BDF8),
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: (colonIndex != -1)
              ? RichText(
                  text: TextSpan(
                    style: const TextStyle(
                        color: Color(0xFF94A3B8), fontSize: 11.5, height: 1.45),
                    children: [
                      TextSpan(
                        text: '${cleanText.substring(0, colonIndex + 1)} ',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                          text: cleanText.substring(colonIndex + 1).trim()),
                    ],
                  ),
                )
              : Text(
                  cleanText,
                  style: const TextStyle(
                      color: Color(0xFF94A3B8), fontSize: 11.5, height: 1.45),
                ),
        ),
      ],
    );
  }
}
