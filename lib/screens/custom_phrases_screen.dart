import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class CustomPhrasesScreen extends StatefulWidget {
  @override
  _CustomPhrasesScreenState createState() => _CustomPhrasesScreenState();
}

class _CustomPhrasesScreenState extends State<CustomPhrasesScreen> {
  List<Map<String, String>> _customPhrases = [];
  final _japaneseController = TextEditingController();
  final _englishController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPhrases();
  }

  // 保存されたフレーズを読み込み
  Future<void> _loadPhrases() async {
    try {
      final phrases = await StorageService.loadUserPhrases();
      setState(() {
        _customPhrases = phrases;
      });
    } catch (e) {
      print('フレーズ読み込みエラー: $e');
    }
  }

  // フレーズを追加して保存
  Future<void> _addPhrase() async {
    if (_japaneseController.text.isEmpty || _englishController.text.isEmpty) {
      return;
    }

    final newPhrase = {
      'japanese': _japaneseController.text,
      'english': _englishController.text,
    };

    setState(() {
      _customPhrases.add(newPhrase);
    });

    // データを永続化
    try {
      await StorageService.saveUserPhrases(_customPhrases);
      _japaneseController.clear();
      _englishController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('フレーズを保存しました')),
      );
    } catch (e) {
      print('保存エラー: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存に失敗しました')),
      );
    }
  }

  // フレーズを削除
  Future<void> _deletePhrase(int index) async {
    setState(() {
      _customPhrases.removeAt(index);
    });
    
    try {
      await StorageService.saveUserPhrases(_customPhrases);
    } catch (e) {
      print('削除エラー: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('マイフレーズ')),
      body: Column(
        children: [
          // フレーズ追加フォーム
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _japaneseController,
                  decoration: InputDecoration(labelText: '日本語'),
                ),
                TextField(
                  controller: _englishController,
                  decoration: InputDecoration(labelText: '英語'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _addPhrase,
                  child: Text('追加'),
                ),
              ],
            ),
          ),
          Divider(),
          // フレーズリスト
          Expanded(
            child: ListView.builder(
              itemCount: _customPhrases.length,
              itemBuilder: (context, index) {
                final phrase = _customPhrases[index];
                return ListTile(
                  title: Text(phrase['japanese'] ?? ''),
                  subtitle: Text(phrase['english'] ?? ''),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deletePhrase(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _japaneseController.dispose();
    _englishController.dispose();
    super.dispose();
  }
}