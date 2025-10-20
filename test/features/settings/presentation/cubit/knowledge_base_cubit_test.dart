import 'package:flutter_test/flutter_test.dart';

import 'package:khodan/data/local/knowledge_base_cache.dart';
import 'package:khodan/data/models/knowledge_article.dart';
import 'package:khodan/data/repositories/knowledge_base_repository.dart';
import 'package:khodan/data/services/offline_sync_manager.dart';
import 'package:khodan/features/settings/presentation/cubit/knowledge_base_cubit.dart';

class _FakeKnowledgeBaseRepository implements KnowledgeBaseRepository {
  _FakeKnowledgeBaseRepository({
    required this.cachedArticles,
    required this.remoteArticles,
  });

  final List<KnowledgeArticle> cachedArticles;
  final List<KnowledgeArticle> remoteArticles;
  int remoteCalls = 0;

  @override
  Future<CachedKnowledgeBase?> readCache() async {
    return CachedKnowledgeBase(
      articles: cachedArticles,
      cachedAt: DateTime(2024, 1, 5),
    );
  }

  @override
  Future<KnowledgeBaseFetchResult> fetchRemoteArticles() async {
    remoteCalls += 1;
    return KnowledgeBaseFetchResult(
      articles: remoteArticles,
      source: KnowledgeBaseSource.remote,
      fetchedAt: DateTime(2024, 1, 10),
    );
  }

  @override
  Future<KnowledgeArticle?> findCachedArticle(String id) async {
    for (final KnowledgeArticle article in cachedArticles) {
      if (article.id == id) {
        return article;
      }
    }
    for (final KnowledgeArticle article in remoteArticles) {
      if (article.id == id) {
        return article;
      }
    }
    return null;
  }
}

void main() {
  final OfflineSyncManager offlineManager = OfflineSyncManager.instance;

  setUp(() {
    offlineManager.isOffline.value = false;
  });

  group('KnowledgeBaseCubit', () {
    late _FakeKnowledgeBaseRepository repository;
    late KnowledgeBaseCubit cubit;

    final List<KnowledgeArticle> cached = <KnowledgeArticle>[
      KnowledgeArticle(
        id: 'cached-a',
        title: 'Planifier la ration journalière',
        summary: 'Comprendre les besoins journaliers.',
        content: 'Contenu cached',
        updatedAt: DateTime(2023, 12, 31),
      ),
    ];

    final List<KnowledgeArticle> remote = <KnowledgeArticle>[
      KnowledgeArticle(
        id: 'remote-a',
        title: 'Suivi vétérinaire',
        summary: 'Enregistrer tous les soins.',
        content: 'Contenu remote',
        updatedAt: DateTime(2024, 1, 10),
      ),
      KnowledgeArticle(
        id: 'remote-b',
        title: 'Synchronisation hors ligne',
        summary: 'Comprendre la mise à jour des données.',
        content: 'Contenu remote 2',
        updatedAt: DateTime(2024, 1, 9),
      ),
    ];

    setUp(() {
      repository = _FakeKnowledgeBaseRepository(
        cachedArticles: cached,
        remoteArticles: remote,
      );
      cubit = KnowledgeBaseCubit(
        repository: repository,
        offlineManager: offlineManager,
      );
    });

    tearDown(() async {
      await cubit.close();
    });

    test(
      'initialise les articles depuis le cache puis depuis le distant',
      () async {
        await cubit.initialize();

        expect(cubit.state.loading, isFalse);
        expect(cubit.state.refreshing, isFalse);
        expect(cubit.state.articles, remote);
        expect(cubit.state.filteredArticles, remote);
        expect(cubit.state.offlineMode, isFalse);
        expect(repository.remoteCalls, 1);
      },
    );

    test('filtre les articles selon la recherche', () async {
      await cubit.initialize();

      cubit.updateSearch('synchronisation');

      expect(cubit.state.filteredArticles.length, 1);
      expect(cubit.state.filteredArticles.first.id, 'remote-b');
    });

    test(
      'affiche un message hors-ligne quand le mode hors-ligne est actif',
      () async {
        await cubit.initialize();
        offlineManager.isOffline.value = true;

        await cubit.refresh();

        expect(cubit.state.offlineMode, isTrue);
        expect(cubit.state.refreshing, isFalse);
        expect(cubit.state.errorMessage, isNotNull);
        expect(repository.remoteCalls, 1);
      },
    );
  });
}
