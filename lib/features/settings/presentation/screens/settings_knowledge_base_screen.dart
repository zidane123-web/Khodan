import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/knowledge_article.dart';
import '../../../../data/repositories/knowledge_base_repository.dart';
import '../../../../data/services/offline_sync_manager.dart';
import '../cubit/knowledge_base_cubit.dart';

class SettingsKnowledgeBaseScreen extends StatelessWidget {
  const SettingsKnowledgeBaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final KnowledgeBaseRepository repository =
        context.read<KnowledgeBaseRepository>();
    return BlocProvider<KnowledgeBaseCubit>(
      create: (BuildContext context) => KnowledgeBaseCubit(
        repository: repository,
        offlineManager: OfflineSyncManager.instance,
      )..initialize(),
      child: const _KnowledgeBaseView(),
    );
  }
}

class _KnowledgeBaseView extends StatefulWidget {
  const _KnowledgeBaseView();

  @override
  State<_KnowledgeBaseView> createState() => _KnowledgeBaseViewState();
}

class _KnowledgeBaseViewState extends State<_KnowledgeBaseView> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late final DateFormat _dateFormat;

  @override
  void initState() {
    super.initState();
    _dateFormat = DateFormat.yMMMMd('fr_FR').add_Hm();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<KnowledgeBaseCubit, KnowledgeBaseState>(
      listener: (BuildContext context, KnowledgeBaseState state) {
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
          context.read<KnowledgeBaseCubit>().acknowledgeError();
        }
        if (state.selectedArticle != null) {
          _showArticleViewer(context, state.selectedArticle!);
          context.read<KnowledgeBaseCubit>().clearSelection();
        }
      },
      builder: (BuildContext context, KnowledgeBaseState state) {
        final bool showLoader =
            state.loading && state.articles.isEmpty && !state.refreshing;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Base de connaissances'),
            actions: <Widget>[
              IconButton(
                tooltip: 'Rafraîchir',
                onPressed: state.refreshing
                    ? null
                    : () => context.read<KnowledgeBaseCubit>().refresh(),
                icon: state.refreshing
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh_outlined),
              ),
            ],
          ),
          body: showLoader
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: <Widget>[
                    if (state.offlineMode)
                      const _OfflineBanner(),
                    _buildHeader(context, state),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () =>
                            context.read<KnowledgeBaseCubit>().refresh(),
                        child: _buildArticleList(state),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, KnowledgeBaseState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onChanged: context.read<KnowledgeBaseCubit>().updateSearch,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Rechercher dans les guides, FAQ, mots-clés...',
              suffixIcon: state.searchQuery.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Effacer',
                      onPressed: () {
                        _searchController.clear();
                        context.read<KnowledgeBaseCubit>().updateSearch('');
                        _searchFocusNode.requestFocus();
                      },
                      icon: const Icon(Icons.close),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  state.filteredArticles.isEmpty
                      ? 'Aucun article trouvé'
                      : '${state.filteredArticles.length} article(s)',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              if (state.lastUpdated != null)
                Text(
                  'Mis à jour ${_dateFormat.format(state.lastUpdated!.toLocal())}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Theme.of(context).hintColor),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArticleList(KnowledgeBaseState state) {
    if (state.filteredArticles.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const <Widget>[
          SizedBox(height: 96),
          Center(
            child: Icon(Icons.menu_book_outlined, size: 48, color: Colors.grey),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Nous n’avons trouvé aucun article pour votre recherche.\n'
              'Essayez avec d’autres mots-clés ou contactez le support.',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: state.filteredArticles.length,
      itemBuilder: (BuildContext context, int index) {
        final KnowledgeArticle article = state.filteredArticles[index];
        return _KnowledgeArticleTile(
          article: article,
          onTap: () => context.read<KnowledgeBaseCubit>().selectArticle(article),
          dateFormat: _dateFormat,
        );
      },
    );
  }

  Future<void> _showArticleViewer(
    BuildContext context,
    KnowledgeArticle article,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.9,
          minChildSize: 0.5,
          builder: (BuildContext context, ScrollController controller) {
            return Column(
              children: <Widget>[
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(
                    article.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  subtitle: Text(
                    _dateFormat.format(article.updatedAt.toLocal()),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),
                const Divider(height: 0),
                Expanded(
                  child: Markdown(
                    controller: controller,
                    data: article.content,
                    padding: const EdgeInsets.all(16),
                    styleSheet: MarkdownStyleSheet.fromTheme(
                      Theme.of(context),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: const <Widget>[
          Icon(Icons.cloud_off_outlined),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Mode hors-ligne actif : les articles affichés proviennent du cache local.',
            ),
          ),
        ],
      ),
    );
  }
}

class _KnowledgeArticleTile extends StatelessWidget {
  const _KnowledgeArticleTile({
    required this.article,
    required this.onTap,
    required this.dateFormat,
  });

  final KnowledgeArticle article;
  final VoidCallback onTap;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                article.title,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                article.summary,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: -8,
                children: <Widget>[
                  if (article.category != null &&
                      article.category!.trim().isNotEmpty)
                    Chip(
                      avatar: const Icon(Icons.folder_open, size: 16),
                      label: Text(article.category!),
                    ),
                  ...article.tags.map(
                    (String tag) => Chip(
                      label: Text(tag),
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Dernière mise à jour : ${dateFormat.format(article.updatedAt.toLocal())}',
                style: theme.textTheme.labelMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
