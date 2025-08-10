import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // 環境変数からAPIキーを取得（本番環境推奨）
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');
  
  static String get geminiApiKey {
    // 環境変数が設定されている場合はそれを使用
    if (_apiKey.isNotEmpty) {
      return _apiKey;
    }
    
    // .envファイルからAPIキーを取得
    final envApiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (envApiKey.isNotEmpty) {
      return envApiKey;
    }
    
    throw Exception('Gemini API key not configured. Please set GEMINI_API_KEY in .env file or as environment variable.');
  }
  
  static bool get isApiKeyConfigured {
    try {
      final key = geminiApiKey;
      return key.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}