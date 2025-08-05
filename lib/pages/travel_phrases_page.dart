import 'package:flutter/material.dart';
import '../data/phrases_data.dart';
import '../services/ai_service.dart';
import '../services/tts_service.dart';
import '../widgets/phrase_card.dart';
import '../widgets/dialogs.dart';
import '../widgets/tab_views.dart';

class TravelPhrasesPage extends StatefulWidget {
  const TravelPhrasesPage({super.key});

  @override
  State<TravelPhrasesPage> createState() => _TravelPhrasesPageState();
}

class _TravelPhrasesPageState extends State<TravelPhrasesPage> {
  final TtsService _ttsService = TtsService();
  final AiService _aiService = AiService();
  
  Set<String> favorites = {};
  String searchQuery = '';
  List<Map<String, String>> userPhrases = [];

  @override
  void initState() {
    super.initState();
    _ttsService.initialize();
    _aiService.initialize();
  }

  void _speak(String text) async {
    try {
      await _ttsService.speak(text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void _toggleFavorite(String phraseKey) {
    setState(() {
      if (favorites.contains(phraseKey)) {
        favorites.remove(phraseKey);
      } else {
        favorites.add(phraseKey);
      }
    });
  }

  List<Map<String, String>> _getFavoritePhrases() {
    List<Map<String, String>> favoritePhrases = [];
    for (var category in categorizedPhrases.values) {
      for (var phrase in category) {
        if (favorites.contains(phrase['english'])) {
          favoritePhrases.add(phrase);
        }
      }
    }
    for (var phrase in userPhrases) {
      if (favorites.contains(phrase['english'])) {
        favoritePhrases.add(phrase);
      }
    }
    return favoritePhrases;
  }

  List<Map<String, String>> _getSearchResults() {
    if (searchQuery.isEmpty) return [];

    List<Map<String, String>> results = [];
    for (var category in categorizedPhrases.values) {
      for (var phrase in category) {
        if (phrase['japanese']!.contains(searchQuery) ||
            phrase['english']!.toLowerCase().contains(searchQuery.toLowerCase()) ||
            phrase['pronunciation']!.contains(searchQuery)) {
          results.add(phrase);
        }
      }
    }
    for (var phrase in userPhrases) {
      if (phrase['japanese']!.contains(searchQuery) ||
          phrase['english']!.toLowerCase().contains(searchQuery.toLowerCase()) ||
          phrase['pronunciation']!.contains(searchQuery)) {
        results.add(phrase);
      }
    }
    return results;
  }

  Widget _buildPhraseCard(Map<String, String> phrase) {
    return PhraseCard(
      phrase: phrase,
      isFavorite: favorites.contains(phrase['english']),
      isOfflineReady: _ttsService.isOfflineReady,
      onFavoriteToggle: () => _toggleFavorite(phrase['english']!),
      onSpeak: () => _speak(phrase['english']!),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allTabs = [
      '🔍 検索',
      '♥ お気に入り',
      '➕ マイフレーズ',
      ...categorizedPhrases.keys,
    ];

    return DefaultTabController(
      length: allTabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '🍀 Ireland Travel Phrases',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          actions: [
            IconButton.outlined(
              icon: const Icon(Icons.smart_toy),
              onPressed: () => Dialogs.showAiChatDialog(
                context: context,
                aiService: _aiService,
              ),
              tooltip: 'AI会話練習',
            ),
            const SizedBox(width: 8),
            IconButton.outlined(
              icon: const Icon(Icons.info_outline),
              onPressed: () => Dialogs.showAboutDialog(context),
            ),
          ],
          backgroundColor: const Color(0xFF228B22),
          foregroundColor: Colors.white,
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: allTabs
                .map(
                  (category) => Tab(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        category,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Dialogs.showAddPhraseDialog(
            context: context,
            aiService: _aiService,
            onPhraseAdded: (phrase) {
              setState(() {
                userPhrases.add(phrase);
              });
            },
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          child: const Icon(Icons.add),
        ),
        body: TabBarView(
          children: [
            TabViews.buildSearchTab(
              searchQuery: searchQuery,
              onSearchChanged: (value) => setState(() => searchQuery = value),
              searchResults: _getSearchResults(),
              buildPhraseCard: _buildPhraseCard,
            ),
            TabViews.buildFavoritesTab(
              favorites: _getFavoritePhrases(),
              buildPhraseCard: _buildPhraseCard,
            ),
            TabViews.buildUserPhrasesTab(
              userPhrases: userPhrases,
              buildPhraseCard: _buildPhraseCard,
            ),
            ...categorizedPhrases.values.map((phrases) {
              return TabViews.buildCategoryTab(
                phrases: phrases,
                buildPhraseCard: _buildPhraseCard,
              );
            }),
          ],
        ),
      ),
    );
  }
}