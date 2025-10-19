import 'package:supabase_flutter/supabase_flutter.dart';

import '../local/knowledge_base_cache.dart';
import '../models/knowledge_article.dart';
import '../services/api_client.dart';

enum KnowledgeBaseSource {
  remote,
  cache,
}

class KnowledgeBaseFetchResult {
  const KnowledgeBaseFetchResult({
    required this.articles,
    required this.source,
    this.fetchedAt,
  });

  final List<KnowledgeArticle> articles;
  final KnowledgeBaseSource source;
  final DateTime? fetchedAt;
}

abstract class KnowledgeBaseRepository {
  Future<CachedKnowledgeBase?> readCache();

  Future<KnowledgeArticle?> findCachedArticle(String id);

  Future<KnowledgeBaseFetchResult> fetchRemoteArticles();
}

class SupabaseKnowledgeBaseRepository implements KnowledgeBaseRepository {
  SupabaseKnowledgeBaseRepository({
    required ApiExecutor apiClient,
    KnowledgeBaseCache? cache,
    this.tableName = 'knowledge_articles',
  })  : _apiClient = apiClient,
        _cache = cache ?? KnowledgeBaseCache();

  final ApiExecutor _apiClient;
  final KnowledgeBaseCache _cache;
  final String tableName;

  @override
  Future<CachedKnowledgeBase?> readCache() {
    return _cache.read();
  }

  @override
  Future<KnowledgeArticle?> findCachedArticle(String id) async {
    final CachedKnowledgeBase? cached = await readCache();
    if (cached == null) {
      return null;
    }
    for (final KnowledgeArticle article in cached.articles) {
      if (article.id == id) {
        return article;
      }
    }
    return null;
  }

  @override
  Future<KnowledgeBaseFetchResult> fetchRemoteArticles() async {
    final List<dynamic> response = await _apiClient.run(
      (SupabaseClient client) => client
          .from(tableName)
          .select('id, title, summary, content, tags, category, updated_at')
          .order('updated_at', ascending: false),
      label: 'knowledge_base.fetch_all',
    );
    final DateTime fetchedAt = DateTime.now();
    final List<KnowledgeArticle> articles = response
        .whereType<Map<String, dynamic>>()
        .map(KnowledgeArticle.fromJson)
        .toList();
    await _cache.save(articles, timestamp: fetchedAt);
    return KnowledgeBaseFetchResult(
      articles: articles,
      source: KnowledgeBaseSource.remote,
      fetchedAt: fetchedAt,
    );
  }
}

class InMemoryKnowledgeBaseRepository implements KnowledgeBaseRepository {
  InMemoryKnowledgeBaseRepository({
    List<KnowledgeArticle>? seed,
    KnowledgeBaseCache? cache,
  })  : _articles = seed ?? _defaultArticles,
        _cache = cache ?? KnowledgeBaseCache();

  List<KnowledgeArticle> _articles;
  final KnowledgeBaseCache _cache;

  static final List<KnowledgeArticle> _defaultArticles =
      <KnowledgeArticle>[
    KnowledgeArticle(
      id: 'kb-feed-planification',
      title: 'Planifier la ration journalière',
      summary:
          'Comprendre comment calculer et enregistrer les rations journalières pour chaque lot.',
      content: '''
## Objectifs de la planification

- Garantir un apport suffisant en énergie et en protéines.
- Adapter les rations selon l'âge et le stade de lactation.

### Étapes clés

1. Ouvrez l'écran **Stocks & Alimentation**.
2. Sélectionnez le lot cible puis appuyez sur **Planifier une ration**.
3. Renseignez les ingrédients et quantités.
4. Validez pour enregistrer la ration.

> Astuce : Les valeurs nutritives sont automatiquement proposées selon vos stocks disponibles.
''',
      tags: <String>['Alimentation', 'Production laitière'],
      updatedAt: DateTime.now(),
      category: 'Nutrition',
    ),
    KnowledgeArticle(
      id: 'kb-sante-suivi',
      title: 'Suivre les interventions vétérinaires',
      summary:
          'Enregistrez les traitements et vaccinations pour bénéficier des rappels automatiques.',
      content: '''
## Pourquoi enregistrer les soins ?

- Garder une trace centralisée.
- Préparer vos audits sanitaires.
- Recevoir des rappels avant échéance.

### Comment procéder

1. Rendez-vous dans **�?vènements > Soins**.
2. Appuyez sur **Ajouter un soin** et sélectionnez l'animal concerné.
3. Décrivez l'intervention, la posologie et la durée.

Les rappels s'afficheront directement sur le tableau de bord.
''',
      tags: <String>['Santé', 'Alertes'],
      updatedAt: DateTime.now(),
      category: 'Sanitaire',
    ),
    KnowledgeArticle(
      id: 'kb-synchro',
      title: 'Comprendre la synchronisation hors-ligne',
      summary:
          'Découvrez comment l’application gère vos données en mode déconnecté et comment forcer la synchronisation.',
      content: '''
### Mode hors-ligne

Lorsque vous activez le mode hors-ligne, toutes les modifications sont stockées localement.

### Forcer la synchronisation

1. Ouvrez **Paramètres > Mode hors-ligne**.
2. Appuyez sur **Synchroniser** pour envoyer les actions en attente.

Les journaux de synchronisation sont disponibles dans **Paramètres > Journaux & diagnostics**.
''',
      tags: <String>['Synchronisation'],
      updatedAt: DateTime.now(),
      category: 'Support',
    ),
  ];

  void seed(List<KnowledgeArticle> articles) {
    _articles = List<KnowledgeArticle>.unmodifiable(articles);
  }

  @override
  Future<CachedKnowledgeBase?> readCache() {
    return _cache.read();
  }

  @override
  Future<KnowledgeArticle?> findCachedArticle(String id) async {
    final CachedKnowledgeBase? cached = await readCache();
    if (cached == null) {
      return null;
    }
    for (final KnowledgeArticle article in cached.articles) {
      if (article.id == id) {
        return article;
      }
    }
    return null;
  }

  @override
  Future<KnowledgeBaseFetchResult> fetchRemoteArticles() async {
    final DateTime fetchedAt = DateTime.now();
    await _cache.save(_articles, timestamp: fetchedAt);
    return KnowledgeBaseFetchResult(
      articles: List<KnowledgeArticle>.from(_articles),
      source: KnowledgeBaseSource.remote,
      fetchedAt: fetchedAt,
    );
  }
}
