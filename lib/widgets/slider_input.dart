import 'package:flutter/material.dart';

class SliderInput extends StatelessWidget {
  final String label, displayValue;
  final double value, min, max;
  final int divisions;
  final ValueChanged<double> onChanged;

  const SliderInput({
    super.key, required this.label, required this.value, required this.min,
    required this.max, required this.divisions, required this.displayValue, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, color: Colors.white70)),
            Text(displayValue, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF00E676))),
          ],
        ),
        Slider(value: value, min: min, max: max, divisions: divisions, activeColor: const Color(0xFF00E676), onChanged: onChanged),
      ],
    );
  }
}
