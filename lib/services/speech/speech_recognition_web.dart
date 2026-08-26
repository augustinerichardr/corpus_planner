// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:js' as js;

class PlatformSpeechRecognizer {
  bool get isSupported {
    return js.context.hasProperty('SpeechRecognition') ||
        js.context.hasProperty('webkitSpeechRecognition');
  }

  void _ensureJsBridge() {
    const script = '''
    window.__speechRecInstance = null;
    window.__startSpeechRec = function(lang) {
      try {
        var SpeechRec = window.SpeechRecognition || window.webkitSpeechRecognition;
        if (!SpeechRec) {
          if (window.__speechOnError) window.__speechOnError("SpeechRecognition not supported in this browser. Please use Chrome.");
          return;
        }
        if (window.__speechRecInstance) {
          try { window.__speechRecInstance.abort(); } catch(e){}
        }
        var rec = new SpeechRec();
        window.__speechRecInstance = rec;
        rec.continuous = true;
        rec.interimResults = true;
        rec.lang = lang;

        rec.onresult = function(event) {
          var fullText = "";
          for (var i = 0; i < event.results.length; ++i) {
            fullText += event.results[i][0].transcript;
          }
          var isFinal = event.results[event.results.length - 1].isFinal;
          if (window.__speechOnResult && fullText.trim().length > 0) {
            window.__speechOnResult(fullText.trim(), isFinal);
          }
        };

        rec.onerror = function(event) {
          var err = event.error || "speech_error";
          var msg = "Speech recognition status: " + err;
          if (err === "no-speech") {
            msg = "No voice detected. Please speak closer to your microphone.";
          } else if (err === "not-allowed") {
            msg = "Microphone access denied. Click the lock icon in the Chrome URL bar to allow microphone access.";
          }
          if (window.__speechOnError) window.__speechOnError(msg);
        };

        rec.onend = function() {
          if (window.__speechOnEnd) window.__speechOnEnd();
        };

        rec.start();
      } catch(err) {
        if (window.__speechOnError) window.__speechOnError("Microphone initialization error: " + err.message);
      }
    };

    window.__stopSpeechRec = function() {
      if (window.__speechRecInstance) {
        try { window.__speechRecInstance.stop(); } catch(e){}
      }
    };
    ''';

    if (!js.context.hasProperty('__startSpeechRec')) {
      js.context.callMethod('eval', [script]);
    }
  }

  void startListening({
    required String langCode,
    required Function(String text, bool isFinal) onResult,
    required Function(String error) onError,
    required Function() onEnd,
  }) {
    _ensureJsBridge();
    try {
      js.context['__speechOnResult'] = onResult;
      js.context['__speechOnError'] = onError;
      js.context['__speechOnEnd'] = onEnd;
      js.context.callMethod('__startSpeechRec', [langCode]);
    } catch (e) {
      onError('Error starting microphone listener: $e');
    }
  }

  void stopListening() {
    try {
      if (js.context.hasProperty('__stopSpeechRec')) {
        js.context.callMethod('__stopSpeechRec', []);
      }
    } catch (_) {}
  }
}

PlatformSpeechRecognizer getSpeechRecognizer() => PlatformSpeechRecognizer();
