import 'package:flutter/material.dart';

class EduCategoryTree {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<EduSubGroup> subGroups;

  const EduCategoryTree({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.subGroups,
  });

  /// Flat list of all leaf nodes for search & linear iteration
  List<EduLeafNode> get allNodes => subGroups.expand((g) => g.nodes).toList();
}

class EduSubGroup {
  final String groupName;
  final String groupTag;
  final IconData icon;
  final List<EduLeafNode> nodes;

  const EduSubGroup({
    required this.groupName,
    required this.groupTag,
    required this.icon,
    required this.nodes,
  });
}

class EduLeafNode {
  final String title;
  final String badge;
  final String rateOrRule;
  final String taxSection;
  final String lockIn;
  final String shortSummary;
  final String deepExplanation;
  final String sampleInvestment;
  final String sampleTenure;
  final String sampleExpectedReturn;
  final String sampleMaturityValue;
  final List<Map<String, String>> metrics;

  const EduLeafNode({
    required this.title,
    required this.badge,
    required this.rateOrRule,
    required this.taxSection,
    required this.lockIn,
    required this.shortSummary,
    required this.deepExplanation,
    required this.sampleInvestment,
    required this.sampleTenure,
    required this.sampleExpectedReturn,
    required this.sampleMaturityValue,
    required this.metrics,
  });
}
