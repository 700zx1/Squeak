import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  static final FlutterTts _flutterTts = FlutterTts();
  static bool _listenersInitialized = false;

  static Future<void> speak(String text) async {
    if (!_listenersInitialized) {
      _flutterTts.setStartHandler(() {
        print('TTS: Speech started');
      });
      _flutterTts.setCompletionHandler(() {
        print('TTS: Speech completed');
      });
      _flutterTts.setErrorHandler((msg) {
        print('TTS: Error: ' + msg);
      });
      _listenersInitialized = true;
    }
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(_speechRate);
    // Limit text length for TTS debug
    final limitedText = text.length > 500 ? text.substring(0, 500) : text;
    print('TTS: Speaking text (length: \\${limitedText.length}):');
    print(limitedText);
    await _flutterTts.speak(limitedText);
  }

  static double _speechRate = 0.5;
  static String _voice = "default";
  static String _engine = "default";

  static Future<void> setSpeed(double speed) async {
    _speechRate = speed;
    await _flutterTts.setSpeechRate(speed);
  }

  static Future<void> setVoice(String voice) async {
    _voice = voice;
    await _flutterTts.setVoice({"name": voice, "locale": "en-US"});
  }

  static Future<void> setEngine(String engine) async {
    _engine = engine;
    await _flutterTts.setEngine(engine);
  }

  static Future<List<dynamic>> getAvailableVoices() async {
    return await _flutterTts.getVoices;
  }

  static Future<List<dynamic>> getAvailableEngines() async {
    return await _flutterTts.getEngines;
  }

  static Future<void> stop() async {
    await _flutterTts.stop();
  }

  static Future<void> pause() async {
    await _flutterTts.pause();
  }
}
