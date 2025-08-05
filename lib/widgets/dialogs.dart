import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import 'loading_with_tips.dart';

class Dialogs {
  static void showAddPhraseDialog({
    required BuildContext context,
    required AiService aiService,
    required Function(Map<String, String>) onPhraseAdded,
  }) {
    final japaneseController = TextEditingController();
    final englishController = TextEditingController();
    final pronunciationController = TextEditingController();
    bool isAiLoading = false;

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
                            if (japaneseController.text.isEmpty) return;

                            if (!aiService.isConfigured) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Gemini APIキーが設定されていません')),
                              );
                              return;
                            }

                            setDialogState(() {
                              isAiLoading = true;
                            });

                            try {
                              final result = await aiService.translatePhrase(japaneseController.text);
                              if (result != null) {
                                englishController.text = result['english']!;
                                pronunciationController.text = result['pronunciation']!;
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('AI翻訳に失敗しました: $e')),
                              );
                            } finally {
                              setDialogState(() {
                                isAiLoading = false;
                              });
                            }
                          },
                    tooltip: 'AI翻訳',
                  ),
                ),
              ),
              if (isAiLoading) ...[
                const SizedBox(height: 16),
                const LoadingWithTips(),
              ],
              if (!isAiLoading) ...[
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
                  onPhraseAdded({
                    'japanese': japaneseController.text,
                    'english': englishController.text,
                    'pronunciation': pronunciationController.text,
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('フレーズを追加しました')),
                  );
                }
              },
              child: const Text('追加'),
            ),
          ],
        ),
      ),
    );
  }

  static void showAiChatDialog({
    required BuildContext context,
    required AiService aiService,
  }) {
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
                        onSubmitted: (text) => _sendMessage(text, messageController, chatHistory, setChatState, aiService, isChatLoading),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: isChatLoading
                          ? null
                          : () => _sendMessage(messageController.text, messageController, chatHistory, setChatState, aiService, isChatLoading),
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
                if (isChatLoading) ...[
                  const SizedBox(height: 16),
                  const LoadingWithTips(),
                ],
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

  static Future<void> _sendMessage(
    String text,
    TextEditingController messageController,
    List<Map<String, String>> chatHistory,
    StateSetter setChatState,
    AiService aiService,
    bool isChatLoading,
  ) async {
    if (text.isNotEmpty && !isChatLoading) {
      setChatState(() {
        chatHistory.add({'sender': 'user', 'text': text});
        isChatLoading = true;
      });
      messageController.clear();

      try {
        final response = await aiService.chatWithAi(text);
        if (response != null) {
          setChatState(() {
            chatHistory.add({'sender': 'ai', 'text': response});
          });
        }
      } catch (e) {
        setChatState(() {
          chatHistory.add({
            'sender': 'ai',
            'text': 'Sorry, I\'m having trouble responding right now.',
          });
        });
      } finally {
        setChatState(() {
          isChatLoading = false;
        });
      }
    }
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
}