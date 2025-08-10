import 'dart:convert';
import 'dart:developer' as developer;
import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/api_config.dart';

class AiService {
  late GenerativeModel _geminiModel;

  void initialize() {
    try {
      developer.log('AI Service 初期化開始', name: 'AiService');
      
      if (ApiConfig.isApiKeyConfigured) {
        _geminiModel = GenerativeModel(
          model: 'gemini-2.5-flash',
          apiKey: ApiConfig.geminiApiKey,
          generationConfig: GenerationConfig(
            responseMimeType: 'application/json',
          ),
        );
        developer.log('Geminiモデル初期化成功', name: 'AiService');
      } else {
        developer.log('APIキーが設定されていません', name: 'AiService');
      }
    } catch (e) {
      developer.log('AI Service 初期化失敗: $e', name: 'AiService');
    }
  }

  bool get isConfigured => ApiConfig.isApiKeyConfigured;

  Future<Map<String, String>?> translatePhrase(String japaneseText) async {
    developer.log('翻訳リクエスト: "$japaneseText"', name: 'AiService');
    
    if (!isConfigured) {
      developer.log('APIキー未設定エラー', name: 'AiService');
      throw Exception('Gemini APIキーが設定されていません');
    }

    try {
      final prompt = '''
日本語のフレーズ「$japaneseText」をアイルランド旅行で使える自然な英語に翻訳してください。
アイルランドで使われる表現や方言を含めて、自然で実用的な翻訳をお願いします。

以下のJSON形式で回答してください：
{
  "english": "英語翻訳",
  "pronunciation": "カタカナ発音"
}
''';

      developer.log('プロンプト送信中...', name: 'AiService');
      final content = [Content.text(prompt)];
      final response = await _geminiModel.generateContent(content);

      if (response.text != null && response.text!.isNotEmpty) {
        developer.log('AIレスポンス受信: ${response.text}', name: 'AiService');
        
        try {
          // JSONパース前のテキストクリーニング
          String cleanedText = response.text!.trim();
          if (cleanedText.startsWith('```json')) {
            cleanedText = cleanedText.replaceFirst('```json', '').replaceFirst('```', '').trim();
          }
          
          final jsonData = jsonDecode(cleanedText);
          
          if (jsonData is Map<String, dynamic> && 
              jsonData.containsKey('english') && 
              jsonData.containsKey('pronunciation')) {
            
            final result = {
              'english': (jsonData['english'] as String).trim(),
              'pronunciation': (jsonData['pronunciation'] as String).trim(),
            };
            
            developer.log('翻訳成功: $result', name: 'AiService');
            return result;
          } else {
            developer.log('JSONフォーマットエラー: 必要なフィールドがありません', name: 'AiService');
            throw Exception('翻訳結果の形式が正しくありません');
          }
        } catch (jsonError) {
          developer.log('JSONパースエラー: $jsonError', name: 'AiService');
          throw Exception('AIの応答を解析できませんでした: $jsonError');
        }
      } else {
        developer.log('AIレスポンスが空', name: 'AiService');
        throw Exception('AIからの応答がありませんでした');
      }
    } catch (e) {
      developer.log('翻訳エラー: $e', name: 'AiService');
      throw Exception('AI翻訳に失敗しました: $e');
    }
  }

  Future<String?> chatWithAi(String userMessage) async {
    developer.log('チャットリクエスト: "$userMessage"', name: 'AiService');
    
    if (!isConfigured) {
      developer.log('チャット: APIキー未設定', name: 'AiService');
      return null;
    }

    try {
      final prompt = '''
あなたはアイルランドのフレンドリーな現地人です。日本人旅行者と英語で会話してください。
アイルランドの文化や観光地、食べ物などを紹介しながら、自然で友好的な会話をしてください。
旅行者のメッセージ: "$userMessage"

英語で答えてください。150文字以内でお願いします。
''';

      developer.log('チャットプロンプト送信中...', name: 'AiService');
      final content = [Content.text(prompt)];
      final response = await _geminiModel.generateContent(content);

      if (response.text != null && response.text!.isNotEmpty) {
        developer.log('チャットレスポンス: ${response.text}', name: 'AiService');
        return response.text!.trim();
      } else {
        developer.log('チャットレスポンスが空', name: 'AiService');
        return null;
      }
    } catch (e) {
      developer.log('チャットエラー: $e', name: 'AiService');
      return null;
    }
  }
}
