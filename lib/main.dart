import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ireland Travel Phrases',
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

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    _initTts();
  }

  void _initTts() async {
    try {
      // オフライン対応の設定
      await flutterTts.setLanguage('en-US'); // より一般的な言語に変更
      await flutterTts.setSpeechRate(0.5);
      await flutterTts.setVolume(1.0);
      await flutterTts.setPitch(1.0);

      // ローカル音声エンジンを優先
      await flutterTts.setSharedInstance(true);

      setState(() {
        isOfflineReady = true;
      });
    } catch (e) {
      // エラーが発生してもアプリは動作する
      setState(() {
        isOfflineReady = false;
      });
    }
  }

  void _speak(String text) async {
    if (!isOfflineReady) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('音声機能が利用できません')));
      return;
    }

    try {
      await flutterTts.speak(text);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('音声再生に失敗しました')));
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
    for (var category in categorizedPhrases.values) {
      for (var phrase in category) {
        if (favorites.contains(phrase['english'])) {
          favoritePhrases.add(phrase);
        }
      }
    }
    return favoritePhrases;
  }

  List<Map<String, String>> _getSearchResults() {
    if (searchQuery.isEmpty) return [];

    List<Map<String, String>> results = [];
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
    return results;
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
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text('アイルランド旅行で使える実用的な英会話フレーズ集です。'),
            SizedBox(height: 8),
            Text('プライバシーポリシー:'),
            Text(
              '本アプリは個人情報を収集しません。すべてのデータはローカルに保存されます。',
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
    final allTabs = ['🔍 検索', '♥ お気に入り', ...categorizedPhrases.keys];

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
