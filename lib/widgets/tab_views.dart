import 'package:flutter/material.dart';
import 'phrase_card.dart';

class TabViews {
  static Widget buildSearchTab({
    required String searchQuery,
    required Function(String) onSearchChanged,
    required List<Map<String, String>> searchResults,
    required Widget Function(Map<String, String>) buildPhraseCard,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SearchBar(
            hintText: 'フレーズを検索...',
            leading: const Icon(Icons.search),
            onChanged: onSearchChanged,
            elevation: MaterialStateProperty.all(2),
          ),
        ),
        Expanded(
          child: searchQuery.isEmpty
              ? _buildEmptyState(
                  icon: Icons.search,
                  title: 'キーワードを入力してフレーズを検索してください',
                )
              : searchResults.isEmpty
              ? _buildEmptyState(
                  icon: Icons.search_off,
                  title: '検索結果がありません',
                )
              : ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) => buildPhraseCard(searchResults[index]),
                ),
        ),
      ],
    );
  }

  static Widget buildFavoritesTab({
    required List<Map<String, String>> favorites,
    required Widget Function(Map<String, String>) buildPhraseCard,
  }) {
    return favorites.isEmpty
        ? _buildEmptyState(
            icon: Icons.favorite_border,
            title: 'お気に入りのフレーズがありません',
            subtitle: '♥ボタンでフレーズを追加してください',
          )
        : ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) => buildPhraseCard(favorites[index]),
          );
  }

  static Widget buildUserPhrasesTab({
    required List<Map<String, String>> userPhrases,
    required Widget Function(Map<String, String>) buildPhraseCard,
  }) {
    return userPhrases.isEmpty
        ? _buildEmptyState(
            icon: Icons.add_circle_outline,
            title: 'オリジナルフレーズがありません',
            subtitle: '右下の＋ボタンでフレーズを追加してください',
          )
        : ListView.builder(
            itemCount: userPhrases.length,
            itemBuilder: (context, index) => buildPhraseCard(userPhrases[index]),
          );
  }

  static Widget buildCategoryTab({
    required List<Map<String, String>> phrases,
    required Widget Function(Map<String, String>) buildPhraseCard,
  }) {
    return ListView.builder(
      itemCount: phrases.length,
      itemBuilder: (context, index) => buildPhraseCard(phrases[index]),
    );
  }

  static Widget _buildEmptyState({
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    return Builder(
      builder: (context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 64,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}