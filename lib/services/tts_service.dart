import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  static final FlutterTts _flutterTts = FlutterTts();
  static bool _listenersInitialized = false;

  static Future<void> speak(String text) async {
    if (!_listenersInitialized) {
      _flutterTts.setStartHandler(() {
        print('TTS: Speech started');
      });
      _flutterTts.setCompletionHandler(() async {
        print('TTS: Speech completed');
        // Speak the next chunk, if any
        if (_ttsChunks.isNotEmpty) {
          final next = _ttsChunks.removeAt(0);
          print('TTS: Speaking next chunk (${next.length} chars)');
          await _flutterTts.speak(next);
        }
      });
      _flutterTts.setErrorHandler((msg) {
        print('TTS: Error: ' + msg);
      });
      _listenersInitialized = true;
    }
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(_speechRate);
    // Split text into chunks of ~400 chars, preferring sentence boundaries
    _ttsChunks = _splitIntoChunks(text, 400);
    if (_ttsChunks.isNotEmpty) {
      final first = _ttsChunks.removeAt(0);
      print('TTS: Speaking first chunk (${first.length} chars)');
      await _flutterTts.speak(first);
    }
  }

  static List<String> _ttsChunks = [];

  static List<String> _splitIntoChunks(String text, int maxLen) {
    final List<String> chunks = [];
    String remaining = text.trim();
    final sentenceReg = RegExp(r'(?<=[.!?])\s+');
    while (remaining.isNotEmpty) {
      if (remaining.length <= maxLen) {
        chunks.add(remaining);
        break;
      }
      // Try to find the last sentence boundary within maxLen
      final sub = remaining.substring(0, maxLen);
      final matches = sentenceReg.allMatches(sub).toList();
      int splitIdx = -1;
      if (matches.isNotEmpty) {
        splitIdx = matches.last.end;
      } else {
        // No sentence boundary, split at maxLen
        splitIdx = maxLen;
      }
      chunks.add(remaining.substring(0, splitIdx).trim());
      remaining = remaining.substring(splitIdx).trim();
    }
    return chunks;
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
