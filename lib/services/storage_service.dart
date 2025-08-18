import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _userPhrasesKey = 'user_phrases';
  static const String _favoritesKey = 'favorites';

  static Future<List<Map<String, String>>> loadUserPhrases() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_userPhrasesKey);
    if (jsonString == null) return [];
    
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((item) => Map<String, String>.from(item)).toList();
  }

  static Future<void> saveUserPhrases(List<Map<String, String>> phrases) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(phrases);
    await prefs.setString(_userPhrasesKey, jsonString);
  }

  static Future<Set<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_favoritesKey) ?? [];
    return favorites.toSet();
  }

  static Future<void> saveFavorites(Set<String> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, favorites.toList());
  }
}