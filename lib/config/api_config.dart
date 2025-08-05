class ApiConfig {
  // 環境変数からAPIキーを取得（本番環境推奨）
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');
  
  // デバッグ用のフォールバック（開発時のみ使用）
  static const String _debugApiKey = '';
  
  static String get geminiApiKey {
    // 環境変数が設定されている場合はそれを使用
    if (_apiKey.isNotEmpty) {
      return _apiKey;
    }
    
    // デバッグモードでのみフォールバックを使用
    assert(() {
      if (_debugApiKey.isEmpty) {
        throw Exception('Gemini API key not configured. Please set GEMINI_API_KEY environment variable or configure _debugApiKey for development.');
      }
      return true;
    }());
    
    return _debugApiKey;
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