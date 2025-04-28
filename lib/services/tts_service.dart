import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  static final FlutterTts _flutterTts = FlutterTts();

  static Future<void> speak(String text) async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(_speechRate);
    await _flutterTts.speak(text);
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
