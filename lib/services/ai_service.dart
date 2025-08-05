import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/api_config.dart';

class AiService {
  late GenerativeModel _geminiModel;

  void initialize() {
    try {
      if (ApiConfig.isApiKeyConfigured) {
        _geminiModel = GenerativeModel(
          model: 'gemini-2.5-flash',
          apiKey: ApiConfig.geminiApiKey,
          generationConfig: GenerationConfig(
            responseMimeType: 'application/json',
          ),
        );
      }
    } catch (e) {
      print('AI Service initialization failed: $e');
    }
  }

  bool get isConfigured => ApiConfig.isApiKeyConfigured;

  Future<Map<String, String>?> translatePhrase(String japaneseText) async {
    if (!isConfigured) {
      throw Exception('Gemini APIキーが設定されていません');
    }

    try {
      final prompt =
          '''
日本語のフレーズ「$japaneseText」をアイルランド旅行で使える自然な英語に翻訳してください。
アイルランドで使われる表現や方言を含めて、自然で実用的な翻訳をお願いします。

以下のJSON形式で回答してください：
{
  "english": "英語翻訳",
  "pronunciation": "カタカナ発音"
}
''';

      final content = [Content.text(prompt)];
      final response = await _geminiModel.generateContent(content);

      if (response.text != null) {
        print('AI Translation Response: ${response.text}');
        final jsonData = jsonDecode(response.text!);
        return {
          'english': jsonData['english'] as String,
          'pronunciation': jsonData['pronunciation'] as String,
        };
      }
      throw Exception('AI翻訳の応答を解析できませんでした');
    } catch (e) {
      throw Exception('AI翻訳に失敗しました: $e');
    }
  }

  Future<String?> chatWithAi(String userMessage) async {
    if (!isConfigured) return null;

    final prompt =
        '''
あなたはアイルランドのフレンドリーな現地人です。日本人旅行者と英語で会話してください。
アイルランドの文化や観光地、食べ物などを紹介しながら、自然で友好的な会話をしてください。
旅行者のメッセージ: "$userMessage"

英語で答えてください。150文字以内でお願いします。
''';

    final content = [Content.text(prompt)];
    final response = await _geminiModel.generateContent(content);

    if (response.text != null) {
      print('AI Chat Response: ${response.text}');
    }
    return response.text;
  }
}
