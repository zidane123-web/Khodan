import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/knowledge_article.dart';

class CachedKnowledgeBase {
  const CachedKnowledgeBase({
    required this.articles,
    required this.cachedAt,
  });

  final List<KnowledgeArticle> articles;
  final DateTime cachedAt;
}

/// Persists the knowledge base payload locally so it can be browsed offline.
class KnowledgeBaseCache {
  KnowledgeBaseCache({SharedPreferences? preferences})
      : _preferences = preferences;

  static const String _articlesKey = 'knowledge_base_articles_v1';
  static const String _timestampKey = 'knowledge_base_cached_at_v1';

  SharedPreferences? _preferences;

  Future<CachedKnowledgeBase?> read() async {
    await _ensurePreferences();
    final SharedPreferences prefs = _preferences!;
    final String? rawArticles = prefs.getString(_articlesKey);
    if (rawArticles == null || rawArticles.isEmpty) {
      return null;
    }
    try {
      final List<dynamic> decoded = jsonDecode(rawArticles) as List<dynamic>;
      final List<KnowledgeArticle> articles = decoded
          .whereType<Map<String, dynamic>>()
          .map(KnowledgeArticle.fromJson)
          .toList();
      final String? rawTimestamp = prefs.getString(_timestampKey);
      final DateTime cachedAt = DateTime.tryParse(rawTimestamp ?? '') ??
          (articles.isNotEmpty ? articles.first.updatedAt : DateTime.now());
      return CachedKnowledgeBase(
        articles: articles,
        cachedAt: cachedAt,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> save(
    List<KnowledgeArticle> articles, {
    DateTime? timestamp,
  }) async {
    await _ensurePreferences();
    final SharedPreferences prefs = _preferences!;
    final String payload = jsonEncode(
      articles.map((KnowledgeArticle article) => article.toJson()).toList(),
    );
    await prefs.setString(_articlesKey, payload);
    await prefs.setString(
      _timestampKey,
      (timestamp ?? DateTime.now()).toIso8601String(),
    );
  }

  Future<void> clear() async {
    await _ensurePreferences();
    final SharedPreferences prefs = _preferences!;
    await prefs.remove(_articlesKey);
    await prefs.remove(_timestampKey);
  }

  Future<void> _ensurePreferences() async {
    _preferences ??= await SharedPreferences.getInstance();
  }
}
