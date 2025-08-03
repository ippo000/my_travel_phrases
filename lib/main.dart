import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'config/api_config.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ireland Travel Phrases (Irish Accent)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          brightness: Brightness.light,
        ),
        cardTheme: CardTheme.of(context).copyWith(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      ),
      home: const TravelPhrasesPage(),
    );
  }
}

class TravelPhrasesPage extends StatefulWidget {
  const TravelPhrasesPage({super.key});

  @override
  State<TravelPhrasesPage> createState() => _TravelPhrasesPageState();
}

class _TravelPhrasesPageState extends State<TravelPhrasesPage> {
  late FlutterTts flutterTts;
  bool isOfflineReady = false;
  Set<String> favorites = {};
  String searchQuery = '';
  List<Map<String, String>> userPhrases = [];
  late GenerativeModel geminiModel;
  bool isAiLoading = false;
  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    _initTts();
    _initGemini();
  }

  void _initGemini() {
    if (ApiConfig.isApiKeyConfigured) {
      geminiModel = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: ApiConfig.geminiApiKey,
      );
    }
  }

  void _initTts() async {
    try {
      // アイルランド英語の設定を試行
      List<String> preferredLanguages = [
        'en-IE', // アイルランド英語
        'en-GB', // イギリス英語（アイルランドに近い）
        'en-US', // フォールバック
      ];

      bool languageSet = false;
      for (String lang in preferredLanguages) {
        try {
          await flutterTts.setLanguage(lang);
          languageSet = true;
          break;
        } catch (e) {
          continue;
        }
      }

      if (!languageSet) {
        await flutterTts.setLanguage('en-US');
      }

      await flutterTts.setSpeechRate(0.45); // アイルランドなまりに合わせて少し遅く
      await flutterTts.setVolume(1.0);
      await flutterTts.setPitch(0.95); // 少し低めのピッチ

      // オフライン音声エンジンを優先
      await flutterTts.setSharedInstance(true);

      // オフライン音声の確認
      var engines = await flutterTts.getEngines;
      if (engines != null && engines.isNotEmpty) {
        // 利用可能なエンジンがある場合はオフライン対応
        setState(() {
          isOfflineReady = true;
        });
      } else {
        setState(() {
          isOfflineReady = false;
        });
      }
    } catch (e) {
      // エラーが発生してもアプリは動作する
      setState(() {
        isOfflineReady = false;
      });
    }
  }

  void _speak(String text) async {
    if (!isOfflineReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('オフライン音声機能が利用できません。デバイスの音声設定を確認してください。'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    try {
      await flutterTts.speak(text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('音声再生に失敗しました。アイルランド英語音声がインストールされていない可能性があります。'),
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  void _toggleFavorite(String phraseKey) {
    setState(() {
      if (favorites.contains(phraseKey)) {
        favorites.remove(phraseKey);
      } else {
        favorites.add(phraseKey);
      }
    });
  }

  List<Map<String, String>> _getFavoritePhrases() {
    List<Map<String, String>> favoritePhrases = [];
    // 既存のフレーズからお気に入りを取得
    for (var category in categorizedPhrases.values) {
      for (var phrase in category) {
        if (favorites.contains(phrase['english'])) {
          favoritePhrases.add(phrase);
        }
      }
    }
    // ユーザー追加フレーズからお気に入りを取得
    for (var phrase in userPhrases) {
      if (favorites.contains(phrase['english'])) {
        favoritePhrases.add(phrase);
      }
    }
    return favoritePhrases;
  }

  List<Map<String, String>> _getSearchResults() {
    if (searchQuery.isEmpty) return [];

    List<Map<String, String>> results = [];
    // 既存のフレーズを検索
    for (var category in categorizedPhrases.values) {
      for (var phrase in category) {
        if (phrase['japanese']!.contains(searchQuery) ||
            phrase['english']!.toLowerCase().contains(
              searchQuery.toLowerCase(),
            ) ||
            phrase['pronunciation']!.contains(searchQuery)) {
          results.add(phrase);
        }
      }
    }
    // ユーザー追加フレーズを検索
    for (var phrase in userPhrases) {
      if (phrase['japanese']!.contains(searchQuery) ||
          phrase['english']!.toLowerCase().contains(
            searchQuery.toLowerCase(),
          ) ||
          phrase['pronunciation']!.contains(searchQuery)) {
        results.add(phrase);
      }
    }
    return results;
  }

  Future<void> _translateWithAI(
    TextEditingController japaneseController,
    TextEditingController englishController,
    TextEditingController pronunciationController,
  ) async {
    if (japaneseController.text.isEmpty) return;

    if (!ApiConfig.isApiKeyConfigured) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gemini APIキーが設定されていません')));
      return;
    }

    setState(() {
      isAiLoading = true;
    });

    try {
      final prompt =
          '''
日本語のフレーズ「${japaneseController.text}」をアイルランド旅行で使える自然な英語に翻訳してください。
以下の形式で回答してください：
English: [英語翻訳]
Pronunciation: [カタカナ発音]

アイルランドで使われる表現や方言を含めて、自然で実用的な翻訳をお願いします。
''';

      final content = [Content.text(prompt)];
      final response = await geminiModel.generateContent(content);

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
          englishController.text = english;
          pronunciationController.text = pronunciation;
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('AI翻訳に失敗しました: $e')));
    } finally {
      setState(() {
        isAiLoading = false;
      });
    }
  }

  void _showAddPhraseDialog() {
    final japaneseController = TextEditingController();
    final englishController = TextEditingController();
    final pronunciationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('新しいフレーズを追加'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: japaneseController,
                decoration: InputDecoration(
                  labelText: '日本語',
                  hintText: '例: こんにちは',
                  suffixIcon: IconButton(
                    icon: isAiLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome),
                    onPressed: isAiLoading
                        ? null
                        : () async {
                            await _translateWithAI(
                              japaneseController,
                              englishController,
                              pronunciationController,
                            );
                            setDialogState(() {});
                          },
                    tooltip: 'AI翻訳',
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: englishController,
                decoration: const InputDecoration(
                  labelText: '英語',
                  hintText: '例: Hello',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: pronunciationController,
                decoration: const InputDecoration(
                  labelText: '発音（カタカナ）',
                  hintText: '例: ハロー',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                if (japaneseController.text.isNotEmpty &&
                    englishController.text.isNotEmpty &&
                    pronunciationController.text.isNotEmpty) {
                  setState(() {
                    userPhrases.add({
                      'japanese': japaneseController.text,
                      'english': englishController.text,
                      'pronunciation': pronunciationController.text,
                    });
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('フレーズを追加しました')));
                }
              },
              child: const Text('追加'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAiChatDialog() {
    final messageController = TextEditingController();
    List<Map<String, String>> chatHistory = [];
    bool isChatLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setChatState) => AlertDialog(
          title: const Text('🤖 AI会話練習'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: Column(
              children: [
                Expanded(
                  child: chatHistory.isEmpty
                      ? const Center(
                          child: Text('アイルランド旅行のシチュエーションで会話練習しましょう！'),
                        )
                      : ListView.builder(
                          itemCount: chatHistory.length,
                          itemBuilder: (context, index) {
                            final message = chatHistory[index];
                            final isUser = message['sender'] == 'user';
                            return Align(
                              alignment: isUser
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isUser
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(
                                          context,
                                        ).colorScheme.surfaceVariant,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  message['text']!,
                                  style: TextStyle(
                                    color: isUser
                                        ? Theme.of(
                                            context,
                                          ).colorScheme.onPrimary
                                        : Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: messageController,
                        decoration: const InputDecoration(
                          hintText: 'メッセージを入力...',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (text) async {
                          if (text.isNotEmpty && !isChatLoading) {
                            setChatState(() {
                              chatHistory.add({'sender': 'user', 'text': text});
                              isChatLoading = true;
                            });
                            messageController.clear();

                            try {
                              final prompt =
                                  '''
あなたはアイルランドのフレンドリーな現地人です。日本人旅行者と英語で会話してください。
アイルランドの文化や観光地、食べ物などを紹介しながら、自然で友好的な会話をしてください。
旅行者のメッセージ: "$text"

英語で答えてください。150文字以内でお願いします。
''';

                              final content = [Content.text(prompt)];
                              final response = await geminiModel
                                  .generateContent(content);

                              if (response.text != null) {
                                setChatState(() {
                                  chatHistory.add({
                                    'sender': 'ai',
                                    'text': response.text!,
                                  });
                                });
                              }
                            } catch (e) {
                              setChatState(() {
                                chatHistory.add({
                                  'sender': 'ai',
                                  'text':
                                      'Sorry, I\'m having trouble responding right now.',
                                });
                              });
                            } finally {
                              setChatState(() {
                                isChatLoading = false;
                              });
                            }
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: isChatLoading
                          ? null
                          : () async {
                              final text = messageController.text;
                              if (text.isNotEmpty) {
                                messageController.clear();
                                setChatState(() {
                                  chatHistory.add({
                                    'sender': 'user',
                                    'text': text,
                                  });
                                  isChatLoading = true;
                                });

                                // 同じロジックを実行
                              }
                            },
                      icon: isChatLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('閉じる'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ireland Travel Phrases'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.2.0'),
            SizedBox(height: 8),
            Text('アイルランド旅行で使える実用的な英会話フレーズ集です。'),
            SizedBox(height: 8),
            Text('🇮🇪 アイルランドなまりの音声に対応（オフライン対応）'),
            SizedBox(height: 8),
            Text('🤖 Gemini AIで翻訳・会話練習機能'),
            SizedBox(height: 8),
            Text('プライバシーポリシー:'),
            Text(
              '本アプリは個人情報を収集しません。AI機能はインターネット接続が必要です。',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  final Map<String, List<Map<String, String>>> categorizedPhrases = {
    '自然な会話・挨拶': [
      {
        'japanese': '調子はどう？',
        'english': 'How are you getting on?',
        'pronunciation': 'ハウ アー ユー ゲッティング オン',
      },
      {
        'japanese': 'お疲れ様でした',
        'english': 'Cheers for that!',
        'pronunciation': 'チアーズ フォー ザット',
      },
      {
        'japanese': '本当にありがとう',
        'english': 'I really appreciate it',
        'pronunciation': 'アイ リアリー アプリシエイト イット',
      },
      {
        'japanese': 'お気遣いありがとう',
        'english': 'That\'s very kind of you',
        'pronunciation': 'ザッツ ベリー カインド オブ ユー',
      },
      {
        'japanese': 'すみません、お時間いただけますか？',
        'english': 'Sorry to bother you, could I have a moment?',
        'pronunciation': 'ソーリー トゥ ボザー ユー クッド アイ ハブ ア モーメント',
      },
      {
        'japanese': 'また今度お会いしましょう',
        'english': 'Let\'s catch up soon',
        'pronunciation': 'レッツ キャッチ アップ スーン',
      },
      {
        'japanese': '楽しい時間をありがとう',
        'english': 'Thanks for a lovely time',
        'pronunciation': 'サンクス フォー ア ラブリー タイム',
      },
      {
        'japanese': 'お先に失礼します',
        'english': 'I\'ll head off now',
        'pronunciation': 'アイル ヘッド オフ ナウ',
      },
    ],
    'パブ・レストラン': [
      {
        'japanese': 'パブはどこですか？',
        'english': 'Where is the pub?',
        'pronunciation': 'ウェア イズ ザ パブ',
      },
      {
        'japanese': 'ギネスを1杯ください',
        'english': 'One pint of Guinness, please',
        'pronunciation': 'ワン パイント オブ ギネス プリーズ',
      },
      {
        'japanese': 'ビールを2杯ください',
        'english': 'Two beers, please',
        'pronunciation': 'トゥー ビアズ プリーズ',
      },
      {
        'japanese': 'ウイスキーをください',
        'english': 'Whiskey, please',
        'pronunciation': 'ウイスキー プリーズ',
      },
      {
        'japanese': 'メニューをください',
        'english': 'Menu, please',
        'pronunciation': 'メニュー プリーズ',
      },
      {
        'japanese': 'おすすめは何ですか？',
        'english': 'What do you recommend?',
        'pronunciation': 'ワット ドゥ ユー レコメンド',
      },
      {
        'japanese': 'フィッシュアンドチップスください',
        'english': 'Fish and chips, please',
        'pronunciation': 'フィッシュ アンド チップス プリーズ',
      },
      {
        'japanese': 'アイリッシュシチューください',
        'english': 'Irish stew, please',
        'pronunciation': 'アイリッシュ スチュー プリーズ',
      },
      {
        'japanese': 'ベジタリアン料理はありますか？',
        'english': 'Do you have vegetarian food?',
        'pronunciation': 'ドゥ ユー ハブ ベジタリアン フード',
      },
      {
        'japanese': 'お会計お願いします',
        'english': 'Check, please',
        'pronunciation': 'チェック プリーズ',
      },
      {
        'japanese': 'いくらですか？',
        'english': 'How much is it?',
        'pronunciation': 'ハウ マッチ イズ イット',
      },
      {
        'japanese': 'カードで支払いできますか？',
        'english': 'Can I pay by card?',
        'pronunciation': 'キャン アイ ペイ バイ カード',
      },
      {
        'japanese': 'チップを含めてください',
        'english': 'Please include the tip',
        'pronunciation': 'プリーズ インクルード ザ チップ',
      },
    ],
    '観光': [
      {
        'japanese': 'ダブリン城はどこですか？',
        'english': 'Where is Dublin Castle?',
        'pronunciation': 'ウェア イズ ダブリン キャッスル',
      },
      {
        'japanese': 'トリニティカレッジはどこですか？',
        'english': 'Where is Trinity College?',
        'pronunciation': 'ウェア イズ トリニティ カレッジ',
      },
      {
        'japanese': 'チェックインお願いします',
        'english': 'Check in, please',
        'pronunciation': 'チェック イン プリーズ',
      },
      {
        'japanese': 'チェックアウトお願いします',
        'english': 'Check out, please',
        'pronunciation': 'チェック アウト プリーズ',
      },
      {
        'japanese': '部屋の鍵をください',
        'english': 'Room key, please',
        'pronunciation': 'ルーム キー プリーズ',
      },
      {
        'japanese': 'WiFiのパスワードは？',
        'english': 'What is the WiFi password?',
        'pronunciation': 'ワット イズ ザ ワイファイ パスワード',
      },
      {
        'japanese': 'トイレはどこですか？',
        'english': 'Where is the toilet?',
        'pronunciation': 'ウェア イズ ザ トイレット',
      },
      {
        'japanese': '駅はどこですか？',
        'english': 'Where is the station?',
        'pronunciation': 'ウェア イズ ザ ステーション',
      },
      {
        'japanese': '写真を撮ってください',
        'english': 'Take a photo, please',
        'pronunciation': 'テイク ア フォト プリーズ',
      },
      {
        'japanese': '入場料はいくらですか？',
        'english': 'How much is the entrance fee?',
        'pronunciation': 'ハウ マッチ イズ ジ エントランス フィー',
      },
      {
        'japanese': 'ガイドツアーはありますか？',
        'english': 'Do you have guided tours?',
        'pronunciation': 'ドゥ ユー ハブ ガイデッド ツアーズ',
      },
      {
        'japanese': '何時に開いていますか？',
        'english': 'What time do you open?',
        'pronunciation': 'ワット タイム ドゥ ユー オープン',
      },
    ],
    '交通・移動': [
      {
        'japanese': 'バス停はどこですか？',
        'english': 'Where is the bus stop?',
        'pronunciation': 'ウェア イズ ザ バス ストップ',
      },
      {
        'japanese': '空港までお願いします',
        'english': 'To the airport, please',
        'pronunciation': 'トゥ ジ エアポート プリーズ',
      },
      {
        'japanese': 'タクシーを呼んでください',
        'english': 'Please call a taxi',
        'pronunciation': 'プリーズ コール ア タクシー',
      },
      {
        'japanese': 'いくらかかりますか？',
        'english': 'How much does it cost?',
        'pronunciation': 'ハウ マッチ ダズ イット コスト',
      },
      {
        'japanese': 'ここで停めてください',
        'english': 'Please stop here',
        'pronunciation': 'プリーズ ストップ ヒア',
      },
      {
        'japanese': '電車のチケットをください',
        'english': 'Train ticket, please',
        'pronunciation': 'トレイン チケット プリーズ',
      },
      {
        'japanese': '何番ホームですか？',
        'english': 'Which platform?',
        'pronunciation': 'ウィッチ プラットフォーム',
      },
      {
        'japanese': '次の電車はいつですか？',
        'english': 'When is the next train?',
        'pronunciation': 'ウェン イズ ザ ネクスト トレイン',
      },
    ],
    'ショッピング': [
      {
        'japanese': 'いくらですか？',
        'english': 'How much is this?',
        'pronunciation': 'ハウ マッチ イズ ジス',
      },
      {
        'japanese': '安くしてください',
        'english': 'Can you make it cheaper?',
        'pronunciation': 'キャン ユー メイク イット チーパー',
      },
      {
        'japanese': 'これをください',
        'english': 'I will take this',
        'pronunciation': 'アイ ウィル テイク ジス',
      },
      {
        'japanese': '試着できますか？',
        'english': 'Can I try this on?',
        'pronunciation': 'キャン アイ トライ ジス オン',
      },
      {
        'japanese': '他の色はありますか？',
        'english': 'Do you have other colors?',
        'pronunciation': 'ドゥ ユー ハブ アザー カラーズ',
      },
      {
        'japanese': 'レシートをください',
        'english': 'Receipt, please',
        'pronunciation': 'レシート プリーズ',
      },
      {
        'japanese': '返品できますか？',
        'english': 'Can I return this?',
        'pronunciation': 'キャン アイ リターン ジス',
      },
      {
        'japanese': '免税手続きできますか？',
        'english': 'Can I get tax-free?',
        'pronunciation': 'キャン アイ ゲット タックス フリー',
      },
    ],
    '緊急時': [
      {
        'japanese': '道に迷いました',
        'english': 'I am lost',
        'pronunciation': 'アイ アム ロスト',
      },
      {
        'japanese': '助けてください',
        'english': 'Can you help me?',
        'pronunciation': 'キャン ユー ヘルプ ミー',
      },
      {
        'japanese': '英語が話せません',
        'english': 'I do not speak English well',
        'pronunciation': 'アイ ドゥ ノット スピーク イングリッシュ ウェル',
      },
      {
        'japanese': '病院はどこですか？',
        'english': 'Where is the hospital?',
        'pronunciation': 'ウェア イズ ザ ホスピタル',
      },
      {
        'japanese': '警察を呼んでください',
        'english': 'Please call the police',
        'pronunciation': 'プリーズ コール ザ ポリース',
      },
      {
        'japanese': '救急車を呼んでください',
        'english': 'Please call an ambulance',
        'pronunciation': 'プリーズ コール アン アンビュランス',
      },
      {
        'japanese': '日本領事館はどこですか？',
        'english': 'Where is the Japanese embassy?',
        'pronunciation': 'ウェア イズ ザ ジャパニーズ エンバシー',
      },
      {
        'japanese': 'パスポートを紛失しました',
        'english': 'I lost my passport',
        'pronunciation': 'アイ ロスト マイ パスポート',
      },
      {
        'japanese': '盗難にあいました',
        'english': 'I was robbed',
        'pronunciation': 'アイ ワズ ロブド',
      },
    ],
  };

  Widget _buildPhraseCard(Map<String, String> phrase) {
    final isFavorite = favorites.contains(phrase['english']);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    phrase['japanese']!,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    phrase['english']!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    phrase['pronunciation']!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton.filled(
                  onPressed: () => _toggleFavorite(phrase['english']!),
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: isFavorite
                        ? Theme.of(context).colorScheme.errorContainer
                        : Theme.of(context).colorScheme.surfaceVariant,
                    foregroundColor: isFavorite
                        ? Theme.of(context).colorScheme.onErrorContainer
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: isOfflineReady
                      ? () => _speak(phrase['english']!)
                      : null,
                  icon: Icon(
                    isOfflineReady ? Icons.play_arrow : Icons.offline_bolt,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: isOfflineReady
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceVariant,
                    foregroundColor: isOfflineReady
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allTabs = [
      '🔍 検索',
      '♥ お気に入り',
      '➕ マイフレーズ',
      ...categorizedPhrases.keys,
    ];

    return DefaultTabController(
      length: allTabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '🍀 Ireland Travel Phrases',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          actions: [
            IconButton.outlined(
              icon: const Icon(Icons.smart_toy),
              onPressed: _showAiChatDialog,
              tooltip: 'AI会話練習',
            ),
            const SizedBox(width: 8),
            IconButton.outlined(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showAboutDialog(context),
            ),
          ],
          backgroundColor: const Color(0xFF228B22),
          foregroundColor: Colors.white,
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: allTabs
                .map(
                  (category) => Tab(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        category,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddPhraseDialog,
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          child: const Icon(Icons.add),
        ),
        body: TabBarView(
          children: [
            // 検索タブ
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SearchBar(
                    hintText: 'フレーズを検索...',
                    leading: const Icon(Icons.search),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    elevation: MaterialStateProperty.all(2),
                  ),
                ),
                Expanded(
                  child: searchQuery.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search,
                                size: 64,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'キーワードを入力してフレーズを検索してください',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : _getSearchResults().isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '検索結果がありません',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _getSearchResults().length,
                          itemBuilder: (context, index) {
                            return _buildPhraseCard(_getSearchResults()[index]);
                          },
                        ),
                ),
              ],
            ),
            // お気に入りタブ
            _getFavoritePhrases().isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite_border,
                            size: 64,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'お気に入りのフレーズがありません',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '♥ボタンでフレーズを追加してください',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _getFavoritePhrases().length,
                    itemBuilder: (context, index) {
                      return _buildPhraseCard(_getFavoritePhrases()[index]);
                    },
                  ),
            // マイフレーズタブ
            userPhrases.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            size: 64,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'オリジナルフレーズがありません',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '右下の＋ボタンでフレーズを追加してください',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: userPhrases.length,
                    itemBuilder: (context, index) {
                      return _buildPhraseCard(userPhrases[index]);
                    },
                  ),
            // カテゴリタブ
            ...categorizedPhrases.values.map((phrases) {
              return ListView.builder(
                itemCount: phrases.length,
                itemBuilder: (context, index) =>
                    _buildPhraseCard(phrases[index]),
              );
            }),
          ],
        ),
      ),
    );
  }
}
