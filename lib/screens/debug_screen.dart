import 'package:flutter/material.dart';
import '../services/tts_service.dart';

class DebugScreen extends StatefulWidget {
  final TtsService ttsService;

  const DebugScreen({super.key, required this.ttsService});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  Map<String, dynamic>? _languageInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLanguageInfo();
  }

  Future<void> _loadLanguageInfo() async {
    try {
      final info = await widget.ttsService.getLanguageInfo();
      setState(() {
        _languageInfo = info;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TTS デバッグ情報'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard('現在の言語', _languageInfo?['currentLanguage'] ?? 'Unknown'),
                  const SizedBox(height: 16),
                  _buildInfoCard('オフライン対応', _languageInfo?['isOfflineReady'].toString() ?? 'Unknown'),
                  const SizedBox(height: 16),
                  _buildLanguagesCard(),
                  const SizedBox(height: 16),
                  _buildVoicesCard(),
                  const SizedBox(height: 16),
                  _buildTestButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguagesCard() {
    final languages = _languageInfo?['availableLanguages'] as List<dynamic>?;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('利用可能な言語', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (languages != null)
              ...languages.map((lang) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      '• $lang ${lang == 'en-IE' ? '← アイルランド英語' : ''}',
                      style: TextStyle(
                        color: lang == 'en-IE' ? Colors.green : null,
                        fontWeight: lang == 'en-IE' ? FontWeight.bold : null,
                      ),
                    ),
                  ))
            else
              const Text('情報を取得できませんでした'),
          ],
        ),
      ),
    );
  }

  Widget _buildVoicesCard() {
    final voices = _languageInfo?['availableVoices'] as List<dynamic>?;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('利用可能な音声', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (voices != null && voices.isNotEmpty)
              ...voices.take(10).map((voice) {
                final voiceMap = voice as Map<String, dynamic>;
                final name = voiceMap['name'] ?? 'Unknown';
                final locale = voiceMap['locale'] ?? 'Unknown';
                final isIrish = locale.toString().contains('en_IE') || locale.toString().contains('en-IE');
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    '• $name ($locale) ${isIrish ? '← アイルランド英語' : ''}',
                    style: TextStyle(
                      color: isIrish ? Colors.green : null,
                      fontWeight: isIrish ? FontWeight.bold : null,
                    ),
                  ),
                );
              })
            else
              const Text('音声情報を取得できませんでした'),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          try {
            await widget.ttsService.speak('Hello from Ireland! Céad míle fáilte!');
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('テスト再生エラー: $e')),
              );
            }
          }
        },
        child: const Text('アイルランド英語テスト再生'),
      ),
    );
  }
}