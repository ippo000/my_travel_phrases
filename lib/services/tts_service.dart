import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  late FlutterTts _flutterTts;
  bool _isOfflineReady = false;

  bool get isOfflineReady => _isOfflineReady;

  Future<void> initialize() async {
    _flutterTts = FlutterTts();
    
    try {
      List<String> preferredLanguages = [
        'en-IE', // アイルランド英語
        'en-GB', // イギリス英語（アイルランドに近い）
        'en-US', // フォールバック
      ];

      bool languageSet = false;
      for (String lang in preferredLanguages) {
        try {
          await _flutterTts.setLanguage(lang);
          languageSet = true;
          break;
        } catch (e) {
          continue;
        }
      }

      if (!languageSet) {
        await _flutterTts.setLanguage('en-US');
      }

      await _flutterTts.setSpeechRate(0.45);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(0.95);
      await _flutterTts.setSharedInstance(true);

      var engines = await _flutterTts.getEngines;
      _isOfflineReady = engines != null && engines.isNotEmpty;
    } catch (e) {
      _isOfflineReady = false;
    }
  }

  Future<void> speak(String text) async {
    if (!_isOfflineReady) {
      throw Exception('オフライン音声機能が利用できません');
    }

    try {
      await _flutterTts.speak(text);
    } catch (e) {
      throw Exception('音声再生に失敗しました');
    }
  }
}