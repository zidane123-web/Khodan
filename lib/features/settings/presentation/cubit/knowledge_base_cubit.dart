import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/local/knowledge_base_cache.dart';
import '../../../../data/models/knowledge_article.dart';
import '../../../../data/repositories/knowledge_base_repository.dart';
import '../../../../data/services/offline_sync_manager.dart';

class KnowledgeBaseState extends Equatable {
  const KnowledgeBaseState({
    this.loading = false,
    this.refreshing = false,
    this.offlineMode = false,
    this.searchQuery = '',
    this.articles = const <KnowledgeArticle>[],
    this.filteredArticles = const <KnowledgeArticle>[],
    this.lastUpdated,
    this.errorMessage,
    this.selectedArticle,
    this.source,
  });

  final bool loading;
  final bool refreshing;
  final bool offlineMode;
  final String searchQuery;
  final List<KnowledgeArticle> articles;
  final List<KnowledgeArticle> filteredArticles;
  final DateTime? lastUpdated;
  final String? errorMessage;
  final KnowledgeArticle? selectedArticle;
  final KnowledgeBaseSource? source;

  KnowledgeBaseState copyWith({
    bool? loading,
    bool? refreshing,
    bool? offlineMode,
    String? searchQuery,
    List<KnowledgeArticle>? articles,
    List<KnowledgeArticle>? filteredArticles,
    DateTime? lastUpdated,
    bool clearError = false,
    String? errorMessage,
    KnowledgeArticle? selectedArticle,
    bool clearSelection = false,
    KnowledgeBaseSource? source,
  }) {
    return KnowledgeBaseState(
      loading: loading ?? this.loading,
      refreshing: refreshing ?? this.refreshing,
      offlineMode: offlineMode ?? this.offlineMode,
      searchQuery: searchQuery ?? this.searchQuery,
      articles: articles ?? this.articles,
      filteredArticles: filteredArticles ?? this.filteredArticles,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      selectedArticle: clearSelection
          ? null
          : selectedArticle ?? this.selectedArticle,
      source: source ?? this.source,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    loading,
    refreshing,
    offlineMode,
    searchQuery,
    articles,
    filteredArticles,
    lastUpdated,
    errorMessage,
    selectedArticle,
    source,
  ];
}

class KnowledgeBaseCubit extends Cubit<KnowledgeBaseState> {
  KnowledgeBaseCubit({
    required KnowledgeBaseRepository repository,
    OfflineSyncManager? offlineManager,
  }) : _repository = repository,
       _offlineManager = offlineManager ?? OfflineSyncManager.instance,
       super(const KnowledgeBaseState());

  final KnowledgeBaseRepository _repository;
  final OfflineSyncManager _offlineManager;
  bool _initialized = false;
  VoidCallback? _offlineListener;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    emit(
      state.copyWith(
        loading: true,
        offlineMode: _offlineManager.isOffline.value,
        clearError: true,
      ),
    );
    _listenToOfflineChanges();

    final CachedKnowledgeBase? cached = await _repository.readCache();
    if (cached != null) {
      emit(
        state.copyWith(
          loading: false,
          refreshing: !_offlineManager.isOffline.value,
          articles: cached.articles,
          filteredArticles: _filterArticles(cached.articles, state.searchQuery),
          lastUpdated: cached.cachedAt,
          source: KnowledgeBaseSource.cache,
        ),
      );
    }

    if (_offlineManager.isOffline.value) {
      emit(state.copyWith(refreshing: false, loading: false));
      return;
    }
    await refresh();
  }

  Future<void> refresh() async {
    if (_offlineManager.isOffline.value) {
      emit(
        state.copyWith(
          offlineMode: true,
          refreshing: false,
          clearError: false,
          errorMessage:
              'Le mode hors-ligne est actif. Reconnectez-vous pour mettre à jour la base.',
        ),
      );
      return;
    }
    emit(
      state.copyWith(refreshing: true, offlineMode: false, clearError: true),
    );
    try {
      final KnowledgeBaseFetchResult result = await _repository
          .fetchRemoteArticles();
      emit(
        state.copyWith(
          loading: false,
          refreshing: false,
          articles: result.articles,
          filteredArticles: _filterArticles(result.articles, state.searchQuery),
          lastUpdated: result.fetchedAt,
          source: result.source,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          refreshing: false,
          loading: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void updateSearch(String query) {
    final String normalized = query.trim();
    emit(
      state.copyWith(
        searchQuery: normalized,
        filteredArticles: _filterArticles(state.articles, normalized),
      ),
    );
  }

  void selectArticle(KnowledgeArticle article) {
    emit(state.copyWith(selectedArticle: article));
  }

  void clearSelection() {
    emit(state.copyWith(clearSelection: true));
  }

  void acknowledgeError() {
    if (state.errorMessage != null) {
      emit(state.copyWith(clearError: true));
    }
  }

  List<KnowledgeArticle> _filterArticles(
    List<KnowledgeArticle> articles,
    String query,
  ) {
    if (query.isEmpty) {
      return articles;
    }
    return articles
        .where((KnowledgeArticle article) => article.matchesQuery(query))
        .toList();
  }

  void _listenToOfflineChanges() {
    _offlineListener ??= () {
      emit(state.copyWith(offlineMode: _offlineManager.isOffline.value));
    };
    _offlineManager.isOffline.addListener(_offlineListener!);
  }

  @override
  Future<void> close() {
    if (_offlineListener != null) {
      _offlineManager.isOffline.removeListener(_offlineListener!);
    }
    return super.close();
  }
}
