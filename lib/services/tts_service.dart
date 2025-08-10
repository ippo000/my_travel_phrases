import 'package:flutter_tts/flutter_tts.dart';
import 'dart:io' show Platform;

class TtsService {
  late FlutterTts _flutterTts;
  bool _isOfflineReady = false;
  String? _currentLanguage;
  List<dynamic>? _availableVoices;

  bool get isOfflineReady => _isOfflineReady;
  String? get currentLanguage => _currentLanguage;
  List<dynamic>? get availableVoices => _availableVoices;

  Future<void> initialize() async {
    _flutterTts = FlutterTts();
    
    try {
      // iOS固有の設定
      if (Platform.isIOS) {
        await _flutterTts.setSharedInstance(true);
        await _flutterTts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playAndRecord,
          [
            IosTextToSpeechAudioCategoryOptions.allowBluetooth,
            IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
            IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
          ],
          IosTextToSpeechAudioMode.spokenAudio,
        );
        await _flutterTts.awaitSpeakCompletion(true);
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
          _currentLanguage = lang;
          languageSet = true;
          break;
        } catch (e) {
          continue;
        }
      }

      if (!languageSet) {
        await _flutterTts.setLanguage('en-US');
        _currentLanguage = 'en-US';
      }

      await _flutterTts.setSpeechRate(0.45);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(0.95);

      // エンジンの確認
      if (Platform.isIOS) {
        _availableVoices = await _flutterTts.getVoices;
        _isOfflineReady = _availableVoices != null && _availableVoices!.isNotEmpty;
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
      // 再生前に停止
      await _flutterTts.stop();
      
      // iOS用の追加設定
      if (Platform.isIOS) {
        await _flutterTts.setVolume(1.0);
        await _flutterTts.setSpeechRate(0.45);
      }
      
      await _flutterTts.speak(text);
    } catch (e) {
      throw Exception('音声再生に失敗しました: ${e.toString()}');
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      // エラーを無視
    }
  }

  // デバッグ用：利用可能な音声を取得
  Future<Map<String, dynamic>> getLanguageInfo() async {
    var voices = await _flutterTts.getVoices;
    var languages = await _flutterTts.getLanguages;
    
    return {
      'currentLanguage': _currentLanguage,
      'availableVoices': voices,
      'availableLanguages': languages,
      'isOfflineReady': _isOfflineReady,
    };
  }

  void dispose() {
    _flutterTts.stop();
  }
}