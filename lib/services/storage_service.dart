import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _customPhrasesKey = 'custom_phrases';
  static const String _favoritesKey = 'favorites';

  // カスタムフレーズを保存
  static Future<void> saveCustomPhrases(List<Map<String, String>> phrases) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(phrases);
    await prefs.setString(_customPhrasesKey, jsonString);
  }

  // カスタムフレーズを読み込み
  static Future<List<Map<String, String>>> loadCustomPhrases() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_customPhrasesKey);
    if (jsonString == null) return [];
    
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.cast<Map<String, dynamic>>()
        .map((item) => Map<String, String>.from(item))
        .toList();
  }

  // お気に入りを保存
  static Future<void> saveFavorites(List<String> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, favorites);
  }

  // お気に入りを読み込み
  static Future<List<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoritesKey) ?? [];
  }
}