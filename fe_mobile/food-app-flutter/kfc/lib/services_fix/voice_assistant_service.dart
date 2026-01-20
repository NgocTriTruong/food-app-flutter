import 'package:speech_to_text/speech_to_text.dart' as stt;

typedef VoiceCallback = void Function(String recognizedText);

class VoiceAssistantService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _available = false;

  Future<bool> init() async {
    _available = await _speech.initialize();
    return _available;
  }

  bool get isAvailable => _available;

  void listen(VoiceCallback onResult) async {
    if (!_available) {
      await init();
    }
    if (!_available) return;

    _speech.listen(onResult: (result) {
      if (result.finalResult) {
        onResult(result.recognizedWords);
      }
    }, listenFor: Duration(seconds: 10), pauseFor: Duration(seconds: 3));
  }

  void stop() {
    if (_speech.isListening) _speech.stop();
  }
}
