import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String recognizedText = "";

  SpeechService() {
    _speech = stt.SpeechToText();
  }

  Future<void> startListening(Function(String) onResult) async {
    bool available = await _speech.initialize();
    if (available) {
      _isListening = true;
      _speech.listen(onResult: (result) {
        recognizedText = result.recognizedWords;
        onResult(recognizedText);
      });
    }
  }

  void stopListening() {
    _speech.stop();
    _isListening = false;
  }
}
