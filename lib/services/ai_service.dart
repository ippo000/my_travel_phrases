import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/api_config.dart';

class AiService {
  late GenerativeModel _geminiModel;

  void initialize() {
    if (ApiConfig.isApiKeyConfigured) {
      _geminiModel = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: ApiConfig.geminiApiKey,
      );
    }
  }

  bool get isConfigured => ApiConfig.isApiKeyConfigured;

  Future<Map<String, String>?> translatePhrase(String japaneseText) async {
    if (!isConfigured) return null;

    final prompt = '''
日本語のフレーズ「$japaneseText」をアイルランド旅行で使える自然な英語に翻訳してください。
以下の形式で回答してください：
English: [英語翻訳]
Pronunciation: [カタカナ発音]

アイルランドで使われる表現や方言を含めて、自然で実用的な翻訳をお願いします。
''';

    final content = [Content.text(prompt)];
    final response = await _geminiModel.generateContent(content);

    if (response.text != null) {
      final lines = response.text!.split('\n');
      String english = '';
      String pronunciation = '';

      for (String line in lines) {
        if (line.startsWith('English:')) {
          english = line.replaceFirst('English:', '').trim();
        } else if (line.startsWith('Pronunciation:')) {
          pronunciation = line.replaceFirst('Pronunciation:', '').trim();
        }
      }

      if (english.isNotEmpty && pronunciation.isNotEmpty) {
        return {'english': english, 'pronunciation': pronunciation};
      }
    }
    return null;
  }

  Future<String?> chatWithAi(String userMessage) async {
    if (!isConfigured) return null;

    final prompt = '''
あなたはアイルランドのフレンドリーな現地人です。日本人旅行者と英語で会話してください。
アイルランドの文化や観光地、食べ物などを紹介しながら、自然で友好的な会話をしてください。
旅行者のメッセージ: "$userMessage"

英語で答えてください。150文字以内でお願いします。
''';

    final content = [Content.text(prompt)];
    final response = await _geminiModel.generateContent(content);

    return response.text;
  }
}