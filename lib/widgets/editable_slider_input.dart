import 'package:flutter/material.dart';

class EditableSliderInput extends StatefulWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final String unit;
  final bool isPrefix;
  final bool isDecimal;
  final ValueChanged<double> onChanged;

  const EditableSliderInput({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    this.isPrefix = false,
    this.isDecimal = false,
    required this.onChanged,
  });

  @override
  State<EditableSliderInput> createState() => _EditableSliderInputState();
}

class _EditableSliderInputState extends State<EditableSliderInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formatValue(widget.value));
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _controller.text = _formatValue(widget.value);
      }
    });
  }

  String _formatValue(double val) {
    if (widget.isDecimal) {
      return val.toStringAsFixed(1);
    }
    return val.toInt().toString();
  }

  @override
  void didUpdateWidget(covariant EditableSliderInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focusNode.hasFocus && (widget.value != oldWidget.value)) {
      _controller.text = _formatValue(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextSubmitted(String str) {
    final parsed = double.tryParse(str.replaceAll(RegExp(r'[^0-9.]'), ''));
    if (parsed != null) {
      final clamped = parsed.clamp(widget.min, widget.max);
      widget.onChanged(clamped);
      _controller.text = _formatValue(clamped);
    } else {
      _controller.text = _formatValue(widget.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.label,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Container(
                width: 125,
                height: 28,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: const Color(0xFF10B981).withOpacity(0.5),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (widget.isPrefix)
                      Text(
                        widget.unit,
                        style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: widget.isDecimal,
                        ),
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                        ),
                        onChanged: (str) {
                          final parsed = double.tryParse(
                            str.replaceAll(RegExp(r'[^0-9.]'), ''),
                          );
                          if (parsed != null) {
                            widget.onChanged(
                              parsed.clamp(widget.min, widget.max),
                            );
                          }
                        },
                        onSubmitted: _onTextSubmitted,
                      ),
                    ),
                    if (!widget.isPrefix && widget.unit.isNotEmpty)
                      Text(
                        ' ${widget.unit}',
                        style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF10B981),
              inactiveTrackColor: Colors.white12,
              thumbColor: const Color(0xFF10B981),
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: Slider(
              value: widget.value.clamp(widget.min, widget.max),
              min: widget.min,
              max: widget.max,
              onChanged: (v) {
                widget.onChanged(v);
                _controller.text = _formatValue(v);
              },
            ),
          ),
        ],
      ),
    );
  }
}
