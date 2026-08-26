import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../services/speech/speech_recognition_service.dart';

class VoiceFeedbackDialog extends StatefulWidget {
  const VoiceFeedbackDialog({super.key});

  @override
  State<VoiceFeedbackDialog> createState() => _VoiceFeedbackDialogState();
}

class _VoiceFeedbackDialogState extends State<VoiceFeedbackDialog> {
  final _msgCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _speech = SpeechRecognitionService();
  bool _isRec = false;
  bool _isSending = false;
  Timer? _timer;
  int _sec = 0;

  void _toggleVoice() {
    if (_isRec) {
      _timer?.cancel();
      _speech.stopListening();
      setState(() => _isRec = false);
    } else {
      setState(() {
        _isRec = true;
        _sec = 0;
      });
      _timer = Timer.periodic(
        const Duration(seconds: 1),
        (_) => mounted ? setState(() => _sec++) : null,
      );
      _speech.startListening(
        langCode: 'en-IN',
        onResult: (res, _) =>
            mounted ? setState(() => _msgCtrl.text = res) : null,
        onError: (_) {
          _timer?.cancel();
          if (mounted) setState(() => _isRec = false);
        },
        onEnd: () {
          _timer?.cancel();
          if (mounted) setState(() => _isRec = false);
        },
      );
    }
  }

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    final msg = _msgCtrl.text.trim();
    if (msg.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email and feedback message.'),
        ),
      );
      return;
    }
    setState(() => _isSending = true);
    try {
      final res = await http.post(
        Uri.parse('https://formspree.io/f/xrpzjppr'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'message': msg}),
      );
      if (res.statusCode >= 200 && res.statusCode < 300 && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Feedback dispatched!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        return;
      }
    } catch (_) {}
    final mail = Uri.parse(
      'mailto:ganymedeearth24@gmail.com?subject=Feedback&body=${Uri.encodeComponent(msg)}',
    );
    if (await canLaunchUrl(mail)) await launchUrl(mail);
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _speech.stopListening();
    _msgCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: const Text(
        'Voice & Text Feedback',
        style: TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _toggleVoice,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _isRec
                      ? const Color(0xFFEF4444).withValues(alpha: 0.2)
                      : const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isRec ? Colors.redAccent : const Color(0xFF38BDF8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isRec ? Icons.stop_circle : Icons.mic,
                      color:
                          _isRec ? Colors.redAccent : const Color(0xFF38BDF8),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isRec
                          ? 'Listening ($_sec s)... Tap Stop'
                          : 'Tap to Speak (Voice Input)',
                      style: TextStyle(
                        color:
                            _isRec ? Colors.redAccent : const Color(0xFF38BDF8),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _msgCtrl,
              maxLines: 3,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: const InputDecoration(
                hintText: 'Speech transcript or message...',
                hintStyle: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                filled: true,
                fillColor: Color(0xFF0F172A),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: const InputDecoration(
                hintText: 'Your email for direct reply',
                hintStyle: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                filled: true,
                fillColor: Color(0xFF0F172A),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSending ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.black,
          ),
          child: _isSending
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Send'),
        ),
      ],
    );
  }
}
