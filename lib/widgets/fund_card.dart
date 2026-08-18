import 'package:flutter/material.dart';
import '../models/mutual_fund_model.dart';

class FundCard extends StatelessWidget {
  final MutualFundScheme scheme;
  final String? return5Y;
  final VoidCallback onTap;

  const FundCard({
    super.key,
    required this.scheme,
    this.return5Y,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final house = scheme.schemeName.split(' ').first;

    return Card(
      color: const Color(0xFF1E293B),
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: scheme.isAdded ? const Color(0xFF10B981) : Colors.white10,
          width: scheme.isAdded ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: scheme.isAdded
                    ? const Color(0xFF10B981).withOpacity(0.2)
                    : const Color(0xFF334155),
                child: Text(
                  house.substring(0, house.length > 3 ? 3 : house.length),
                  style: TextStyle(
                    color: scheme.isAdded
                        ? const Color(0xFF10B981)
                        : Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scheme.schemeName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF334155),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            scheme.category,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        if (return5Y != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '5Y: $return5Y',
                            style: const TextStyle(
                              color: Color(0xFF10B981),
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                scheme.isAdded ? Icons.check_circle : Icons.add_circle,
                color: const Color(0xFF10B981),
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
