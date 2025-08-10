import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../services/ai_service.dart';
import 'loading_with_tips.dart';

/// アプリケーション全体で使用するダイアログを管理するクラス。
class Dialogs {
  /// 新しいフレーズを追加するダイアログを表示します。
  static void showAddPhraseDialog({
    required BuildContext context,
    required AiService aiService,
    required Function(Map<String, String>) onPhraseAdded,
  }) {
    showDialog(
      context: context,
      builder: (_) =>
          _AddPhraseDialog(aiService: aiService, onPhraseAdded: onPhraseAdded),
    );
  }

  /// AIとの会話練習用ダイアログを表示します。
  static void showAiChatDialog({
    required BuildContext context,
    required AiService aiService,
  }) {
    showDialog(
      context: context,
      builder: (_) => _AiChatDialog(aiService: aiService),
    );
  }

  /// アプリケーション情報ダイアログを表示します。
  /// このダイアログはシンプルで状態を持たないため、元の実装を維持します。
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

// --- 以下は、このファイル内でのみ使用されるプライベートなWidget ---

/// フレーズ追加ダイアログの本体となるStatefulWidget。
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
    developer.log('AI翻訳開始: "$inputText"', name: 'AddPhraseDialog');
    
    if (inputText.isEmpty) {
      developer.log('入力テキストが空のため翻訳をスキップ', name: 'AddPhraseDialog');
      return;
    }
    
    if (!widget.aiService.isConfigured) {
      developer.log('Gemini APIキーが未設定', name: 'AddPhraseDialog');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gemini APIキーが設定されていません')),
        );
      }
      return;
    }

    setState(() => _isAiLoading = true);
    developer.log('AI翻訳リクエスト送信中...', name: 'AddPhraseDialog');

    try {
      final result = await widget.aiService.translatePhrase(inputText);
      
      if (result != null && result.containsKey('english')) {
        developer.log('AI翻訳成功: ${result.toString()}', name: 'AddPhraseDialog');
        
        if (mounted) {
          _englishController.text = result['english']!.trim();
          developer.log('翻訳結果をフィールドに設定完了', name: 'AddPhraseDialog');
        }
      } else {
        developer.log('AI翻訳結果が無効: $result', name: 'AddPhraseDialog');
        throw Exception('翻訳結果の形式が正しくありません');
      }
    } catch (e) {
      developer.log('AI翻訳エラー: $e', name: 'AddPhraseDialog');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('AI翻訳に失敗しました: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAiLoading = false);
        developer.log('AI翻訳処理完了', name: 'AddPhraseDialog');
      }
    }
  }

  void _submit() {
    final japanese = _japaneseController.text.trim();
    final english = _englishController.text.trim();
    
    developer.log('フレーズ追加試行: 日本語="$japanese", 英語="$english"', name: 'AddPhraseDialog');
    
    // バリデーション
    if (japanese.isEmpty) {
      developer.log('バリデーションエラー: 日本語が空', name: 'AddPhraseDialog');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('日本語を入力してください')),
      );
      return;
    }
    
    if (english.isEmpty) {
      developer.log('バリデーションエラー: 英語が空', name: 'AddPhraseDialog');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('英語を入力してください')),
      );
      return;
    }
    
    try {
      final newPhrase = {
        'japanese': japanese,
        'english': english,
      };
      
      developer.log('フレーズ追加実行: $newPhrase', name: 'AddPhraseDialog');
      widget.onPhraseAdded(newPhrase);
      
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('フレーズを追加しました')),
      );
      
      developer.log('フレーズ追加成功', name: 'AddPhraseDialog');
    } catch (e) {
      developer.log('フレーズ追加エラー: $e', name: 'AddPhraseDialog');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('フレーズの追加に失敗しました: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('新しいフレーズを追加'),
      content: SingleChildScrollView(
        child: Column(
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

            // --- 変更点: AnimatedSwitcherを使用 ---
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: _isAiLoading
                  // --- ローディング中の表示 ---
                  // AnimatedSwitcherがウィジェットの変更を検知するためにKeyが必要
                  ? Flexible(
                      key: const ValueKey('loading'),
                      child: LoadingWithTips(),
                    )
                  // --- 通常時の表示 ---
                  : TextField(
                      // こちらにもKeyが必要
                      key: const ValueKey('field'),
                      controller: _englishController,
                      decoration: const InputDecoration(
                        labelText: '英語',
                        hintText: '例: Hello',
                      ),
                    ),
            ),
          ],
        ),
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

/// AI会話練習ダイアログの本体となるStatefulWidget。
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
    final text = _messageController.text;
    if (text.isEmpty || _isChatLoading) return;

    setState(() {
      _chatHistory.add({'sender': 'user', 'text': text});
      _isChatLoading = true;
    });
    _messageController.clear();
    _scrollToBottom();

    try {
      final response = await widget.aiService.chatWithAi(text);
      if (response != null) {
        setState(() {
          _chatHistory.add({'sender': 'ai', 'text': response});
        });
      }
    } catch (e) {
      setState(() {
        _chatHistory.add({
          'sender': 'ai',
          'text': 'Sorry, I\'m having trouble responding right now.',
        });
      });
    } finally {
      if (mounted) {
        setState(() {
          _isChatLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('🤖 AI会話練習'),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            Expanded(
              child: _chatHistory.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'アイルランド旅行のシチュエーションで会話練習しましょう！',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: _chatHistory.length,
                      itemBuilder: (context, index) {
                        final message = _chatHistory[index];
                        final isUser = message['sender'] == 'user';
                        return Align(
                          alignment: isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 8,
                            ),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(
                                      context,
                                    ).colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              message['text']!,
                              style: TextStyle(
                                color: isUser
                                    ? Theme.of(context).colorScheme.onPrimary
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
            if (_isChatLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: LoadingWithTips(),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'メッセージを入力...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _isChatLoading ? null : _sendMessage,
                  icon: _isChatLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : const Icon(Icons.send),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
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
    );
  }
}
