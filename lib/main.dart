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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF228B22),
          foregroundColor: Colors.white,
        ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('音声機能が利用できません')),
      );
      return;
    }
    
    try {
      await flutterTts.speak(text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('音声再生に失敗しました')),
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
            phrase['english']!.toLowerCase().contains(searchQuery.toLowerCase()) ||
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
            Text('本アプリは個人情報を収集しません。すべてのデータはローカルに保存されます。', style: TextStyle(fontSize: 12)),
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
    '挨拶': [
      {'japanese': 'こんにちは', 'english': 'Hello', 'pronunciation': 'ハロー'},
      {'japanese': 'ありがとう', 'english': 'Thank you', 'pronunciation': 'サンキュー'},
      {'japanese': 'すみません', 'english': 'Excuse me', 'pronunciation': 'エクスキューズ ミー'},
      {'japanese': 'さようなら', 'english': 'Goodbye', 'pronunciation': 'グッドバイ'},
    ],
    '食事・パブ': [
      {'japanese': 'パブはどこですか？', 'english': 'Where is the pub?', 'pronunciation': 'ウェア イズ ザ パブ'},
      {'japanese': 'ギネスを1杯ください', 'english': 'One pint of Guinness, please', 'pronunciation': 'ワン パイント オブ ギネス プリーズ'},
      {'japanese': 'メニューをください', 'english': 'Menu, please', 'pronunciation': 'メニュー プリーズ'},
      {'japanese': 'お会計お願いします', 'english': 'Check, please', 'pronunciation': 'チェック プリーズ'},
      {'japanese': 'いくらですか？', 'english': 'How much is it?', 'pronunciation': 'ハウ マッチ イズ イット'},
    ],
    '観光': [
      {'japanese': 'ダブリン城はどこですか？', 'english': 'Where is Dublin Castle?', 'pronunciation': 'ウェア イズ ダブリン キャッスル'},
      {'japanese': 'チェックインお願いします', 'english': 'Check in, please', 'pronunciation': 'チェック イン プリーズ'},
      {'japanese': 'トイレはどこですか？', 'english': 'Where is the toilet?', 'pronunciation': 'ウェア イズ ザ トイレット'},
      {'japanese': '写真を撮ってください', 'english': 'Take a photo, please', 'pronunciation': 'テイク ア フォト プリーズ'},
    ],
    '緊急時': [
      {'japanese': '道に迷いました', 'english': 'I am lost', 'pronunciation': 'アイ アム ロスト'},
      {'japanese': '助けてください', 'english': 'Can you help me?', 'pronunciation': 'キャン ユー ヘルプ ミー'},
      {'japanese': '英語が話せません', 'english': 'I do not speak English well', 'pronunciation': 'アイ ドゥ ノット スピーク イングリッシュ ウェル'},
      {'japanese': '病院はどこですか？', 'english': 'Where is the hospital?', 'pronunciation': 'ウェア イズ ザ ホスピタル'},
    ],
  };

  Widget _buildPhraseCard(Map<String, String> phrase) {
    final isFavorite = favorites.contains(phrase['english']);
    return Card(
      margin: const EdgeInsets.all(8.0),
      color: Colors.green[50],
      elevation: 3,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green[200]!, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      phrase['japanese']!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 46, 125, 50),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      phrase['english']!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color.fromARGB(255, 56, 142, 60),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      phrase['pronunciation']!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color.fromARGB(255, 117, 117, 117),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _toggleFavorite(phrase['english']!),
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.grey,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: isOfflineReady ? Colors.green[700] : Colors.grey[400],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  onPressed: isOfflineReady ? () => _speak(phrase['english']!) : null,
                  icon: Icon(
                    isOfflineReady ? Icons.play_arrow : Icons.offline_bolt,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
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
          title: const Text('🍀 Ireland Travel Phrases'),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showAboutDialog(context),
            ),
          ],
          backgroundColor: const Color(0xFF228B22),
          foregroundColor: Colors.white,
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: allTabs.map((category) => Tab(text: category)).toList(),
          ),
        ),
        body: TabBarView(
          children: [
            // 検索タブ
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'フレーズを検索...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.green[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.green[700]!, width: 2),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: searchQuery.isEmpty
                      ? const Center(
                          child: Text(
                            'キーワードを入力してフレーズを検索してください',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        )
                      : _getSearchResults().isEmpty
                          ? const Center(
                              child: Text(
                                '検索結果がありません',
                                style: TextStyle(color: Colors.grey, fontSize: 16),
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
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'お気に入りのフレーズがありません\n♥ボタンでフレーズを追加してください',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 16),
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
                itemBuilder: (context, index) => _buildPhraseCard(phrases[index]),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
