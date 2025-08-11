import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import 'loading_with_tips.dart';

class Dialogs {
  static void showAddPhraseDialog({
    required BuildContext context,
    required AiService aiService,
    required Function(Map<String, String>) onPhraseAdded,
  }) {
    showDialog(
      context: context,
      builder: (_) => _AddPhraseDialog(aiService: aiService, onPhraseAdded: onPhraseAdded),
    );
  }

  static void showAiChatDialog({
    required BuildContext context,
    required AiService aiService,
  }) {
    showDialog(
      context: context,
      builder: (_) => _AiChatDialog(aiService: aiService),
    );
  }

  static void showAboutDialog(BuildContext context) {
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
            SizedBox(height: 16),
            Text('🇮🇪 アイルランドなまりの音声に対応（オフライン対応）'),
            SizedBox(height: 8),
            Text('🤖 Gemini AIで翻訳・会話練習機能'),
            SizedBox(height: 16),
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
}

class _AddPhraseDialog extends StatefulWidget {
  const _AddPhraseDialog({
    required this.aiService,
    required this.onPhraseAdded,
  });

  final AiService aiService;
  final Function(Map<String, String>) onPhraseAdded;

  @override
  State<_AddPhraseDialog> createState() => _AddPhraseDialogState();
}

class _AddPhraseDialogState extends State<_AddPhraseDialog> {
  final _japaneseController = TextEditingController();
  final _englishController = TextEditingController();
  bool _isAiLoading = false;

  @override
  void dispose() {
    _japaneseController.dispose();
    _englishController.dispose();
    super.dispose();
  }

  Future<void> _handleAiTranslate() async {
    final inputText = _japaneseController.text.trim();
    if (inputText.isEmpty || !widget.aiService.isConfigured) {
      _showSnackBar(inputText.isEmpty 
        ? '日本語を入力してください' 
        : 'Gemini APIキーが設定されていません');
      return;
    }

    setState(() => _isAiLoading = true);
    try {
      final result = await widget.aiService.translatePhrase(inputText);
      if (mounted && result != null && result.containsKey('english')) {
        _englishController.text = result['english']!.trim();
      }
    } catch (e) {
      if (mounted) _showSnackBar('AI翻訳に失敗しました');
    } finally {
      if (mounted) setState(() => _isAiLoading = false);
    }
  }

  void _submit() {
    final japanese = _japaneseController.text.trim();
    final english = _englishController.text.trim();
    
    if (japanese.isEmpty || english.isEmpty) {
      _showSnackBar(japanese.isEmpty ? '日本語を入力してください' : '英語を入力してください');
      return;
    }
    
    widget.onPhraseAdded({'japanese': japanese, 'english': english});
    Navigator.of(context).pop();
    _showSnackBar('フレーズを追加しました');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('新しいフレーズを追加'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _japaneseController,
            enabled: !_isAiLoading,
            decoration: InputDecoration(
              labelText: '日本語',
              hintText: '例: こんにちは',
              suffixIcon: _isAiLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : IconButton(
                      icon: const Icon(Icons.auto_awesome),
                      onPressed: _handleAiTranslate,
                      tooltip: 'AI翻訳',
                    ),
            ),
            onSubmitted: (_) => _isAiLoading ? null : _handleAiTranslate(),
          ),
          const SizedBox(height: 16),
          if (_isAiLoading)
            const LoadingWithTips()
          else
            TextField(
              controller: _englishController,
              decoration: const InputDecoration(
                labelText: '英語',
                hintText: '例: Hello',
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isAiLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        TextButton(
          onPressed: _isAiLoading ? null : _submit,
          child: const Text('追加'),
        ),
      ],
    );
  }
}

class _AiChatDialog extends StatefulWidget {
  const _AiChatDialog({required this.aiService});

  final AiService aiService;

  @override
  State<_AiChatDialog> createState() => _AiChatDialogState();
}

class _AiChatDialogState extends State<_AiChatDialog> {
  final _messageController = TextEditingController();
  final List<Map<String, String>> _chatHistory = [];
  bool _isChatLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isChatLoading) return;

    setState(() {
      _chatHistory.add({'sender': 'user', 'text': text});
      _isChatLoading = true;
    });
    _messageController.clear();
    _scrollToBottom();

    try {
      final response = await widget.aiService.chatWithAi(text);
      if (mounted) {
        setState(() {
          _chatHistory.add({
            'sender': 'ai', 
            'text': response ?? 'エラーが発生しました'
          });
          _isChatLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _chatHistory.add({
            'sender': 'ai', 
            'text': 'エラーが発生しました'
          });
          _isChatLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            AppBar(
              title: const Text('🤖 AI会話練習'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _chatHistory.length + (_isChatLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _chatHistory.length && _isChatLoading) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(width: 8),
                          Text('AIが考えています...'),
                        ],
                      ),
                    );
                  }
                  
                  final message = _chatHistory[index];
                  final isUser = message['sender'] == 'user';
                  
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isUser 
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        message['text']!,
                        style: TextStyle(
                          color: isUser 
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      enabled: !_isChatLoading,
                      decoration: const InputDecoration(
                        hintText: 'メッセージを入力...',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _isChatLoading ? null : _sendMessage,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}