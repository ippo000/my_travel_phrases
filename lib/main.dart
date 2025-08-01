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
      title: 'アイルランド旅行英会話',
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

  final List<Map<String, String>> phrases = const [
    {'japanese': 'こんにちは', 'english': 'Hello', 'pronunciation': 'ハロー'},
    {'japanese': 'ありがとう', 'english': 'Thank you', 'pronunciation': 'サンキュー'},
    {
      'japanese': 'すみません',
      'english': 'Excuse me',
      'pronunciation': 'エクスキューズ ミー',
    },
    {
      'japanese': 'いくらですか？',
      'english': 'How much is it?',
      'pronunciation': 'ハウ マッチ イズ イット',
    },
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
      'japanese': 'トイレはどこですか？',
      'english': 'Where is the toilet?',
      'pronunciation': 'ウェア イズ ザ トイレット',
    },
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
      'japanese': 'ダブリン城はどこですか？',
      'english': 'Where is Dublin Castle?',
      'pronunciation': 'ウェア イズ ダブリン キャッスル',
    },
    {
      'japanese': 'チェックインお願いします',
      'english': 'Check in, please',
      'pronunciation': 'チェック イン プリーズ',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🍀 アイルランド旅行英会話'),
        backgroundColor: const Color(0xFF228B22),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: phrases.length,
        itemBuilder: (context, index) {
          final phrase = phrases[index];
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
        },
      ),
    );
  }
}
