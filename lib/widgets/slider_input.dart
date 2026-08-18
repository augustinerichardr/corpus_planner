import 'package:flutter/material.dart';
import '../utils/formatters.dart';

class SliderInput extends StatefulWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String displayValue;
  final ValueChanged<double> onChanged;
  final bool isCurrency;
  final String currencySymbol;
  final String countryCode;

  const SliderInput({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.displayValue,
    required this.onChanged,
    this.isCurrency = false,
    this.currencySymbol = '₹',
    this.countryCode = 'IN',
  });

  @override
  State<SliderInput> createState() => _SliderInputState();
}

class _SliderInputState extends State<SliderInput> {
  late TextEditingController _textController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: _formatValue(widget.value));

    // When the user clicks away (unfocuses), reformat and clamp the value cleanly
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _applyValue(_textController.text);
      }
    });
  }

  @override
  void didUpdateWidget(covariant SliderInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 🎯 Only overwrite controller text if the user IS NOT actively typing in this field
    if (oldWidget.value != widget.value && !_focusNode.hasFocus) {
      _textController.text = _formatValue(widget.value);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _formatValue(double val) {
    if (val == 0) return '0';
    return val % 1 == 0 ? val.toInt().toString() : val.toStringAsFixed(1);
  }

  void _applyValue(String textVal) {
    if (textVal.trim().isEmpty) {
      widget.onChanged(0);
      _textController.text = '0';
      return;
    }
    double? parsed = double.tryParse(textVal);
    if (parsed != null) {
      double clamped = parsed.clamp(widget.min, widget.max);
      widget.onChanged(clamped);
      _textController.text = _formatValue(clamped);
    } else {
      _textController.text = _formatValue(widget.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedMin = widget.isCurrency
        ? formatCompactCurrency(
            widget.min,
            symbol: widget.currencySymbol,
            countryCode: widget.countryCode,
          )
        : '${_formatValue(widget.min)}${widget.label.contains('%') ? '%' : ''}';

    String formattedMax = widget.isCurrency
        ? formatCompactCurrency(
            widget.max,
            symbol: widget.currencySymbol,
            countryCode: widget.countryCode,
          )
        : '${_formatValue(widget.max)}${widget.label.contains('%') ? '%' : ''}';

    String rangeHint = 'Range: $formattedMin to $formattedMax';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  rangeHint,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 130,
            height: 38,
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: const TextStyle(
                color: Color(0xFF10B981),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                prefixText: widget.isCurrency
                    ? '${widget.currencySymbol} '
                    : '',
                prefixStyle: const TextStyle(
                  color: Color(0xFF10B981),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                filled: true,
                fillColor: const Color(0xFF262626),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Color(0xFF10B981)),
                ),
              ),
              onSubmitted: _applyValue,
              onChanged: (val) {
                // 🎯 Live updates state while user types valid figures
                if (val.isEmpty) {
                  widget.onChanged(0);
                  return;
                }
                double? parsed = double.tryParse(val);
                if (parsed != null &&
                    parsed >= widget.min &&
                    parsed <= widget.max) {
                  widget.onChanged(parsed);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
