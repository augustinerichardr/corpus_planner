class PlatformSpeechRecognizer {
  bool get isSupported => false;

  void startListening({
    required String langCode,
    required Function(String text, bool isFinal) onResult,
    required Function(String error) onError,
    required Function() onEnd,
  }) {
    onError('Speech recognition is not supported on this platform.');
  }

  void stopListening() {}
}

PlatformSpeechRecognizer getSpeechRecognizer() => PlatformSpeechRecognizer();
