import 'speech_recognition_stub.dart'
    if (dart.library.html) 'speech_recognition_web.dart';

class SpeechRecognitionService {
  final PlatformSpeechRecognizer _recognizer = getSpeechRecognizer();

  bool get isSupported => _recognizer.isSupported;

  void startListening({
    required String langCode,
    required Function(String text, bool isFinal) onResult,
    required Function(String error) onError,
    required Function() onEnd,
  }) {
    _recognizer.startListening(
      langCode: langCode,
      onResult: onResult,
      onError: onError,
      onEnd: onEnd,
    );
  }

  void stopListening() {
    _recognizer.stopListening();
  }
}
