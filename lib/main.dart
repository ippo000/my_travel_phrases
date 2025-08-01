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
      title: '旅行英会話',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
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

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    _initTts();
  }

  void _initTts() async {
    await flutterTts.setLanguage('en-US');
    await flutterTts.setSpeechRate(0.5);
  }

  void _speak(String text) async {
    await flutterTts.speak(text);
  }

  final List<Map<String, String>> phrases = const [
    {'japanese': 'こんにちは', 'english': 'Hello', 'pronunciation': 'ハロー'},
    {'japanese': 'ありがとう', 'english': 'Thank you', 'pronunciation': 'サンキュー'},
    {
      'japanese': 'いくらですか？',
      'english': 'How much is it?',
      'pronunciation': 'ハウ マッチ イズ イット',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('旅行英会話'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        itemCount: phrases.length,
        itemBuilder: (context, index) {
          final phrase = phrases[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
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
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          phrase['english']!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          phrase['pronunciation']!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _speak(phrase['english']!),
                    icon: const Icon(Icons.play_arrow),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
