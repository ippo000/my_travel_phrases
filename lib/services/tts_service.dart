import 'package:flutter_tts/flutter_tts.dart';
import 'dart:io' show Platform;

class TtsService {
  late FlutterTts _flutterTts;
  bool _isOfflineReady = false;

  bool get isOfflineReady => _isOfflineReady;

  Future<void> initialize() async {
    _flutterTts = FlutterTts();
    
    try {
      // iOS固有の設定
      if (Platform.isIOS) {
        await _flutterTts.setSharedInstance(true);
        await _flutterTts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [
            IosTextToSpeechAudioCategoryOptions.allowBluetooth,
            IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
            IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          ],
          IosTextToSpeechAudioMode.spokenAudio,
        );
      }

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

      // エンジンの確認
      if (Platform.isIOS) {
        var voices = await _flutterTts.getVoices;
        _isOfflineReady = voices != null && voices.isNotEmpty;
      } else {
        var engines = await _flutterTts.getEngines;
        _isOfflineReady = engines != null && engines.isNotEmpty;
      }
    } catch (e) {
      _isOfflineReady = false;
    }
  }

  Future<void> speak(String text) async {
    if (!_isOfflineReady) {
      throw Exception('オフライン音声機能が利用できません');
    }

    try {
      // iOS用の追加設定
      if (Platform.isIOS) {
        await _flutterTts.awaitSpeakCompletion(true);
      }
      
      await _flutterTts.speak(text);
    } catch (e) {
      throw Exception('音声再生に失敗しました: ${e.toString()}');
    }
  }
}