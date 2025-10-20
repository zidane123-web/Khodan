import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/knowledge_article.dart';
import '../../../../data/repositories/knowledge_base_repository.dart';
import '../../../../data/services/offline_sync_manager.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/knowledge_base_cubit.dart';

class SettingsKnowledgeBaseScreen extends StatelessWidget {
  const SettingsKnowledgeBaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final KnowledgeBaseRepository repository = context
        .read<KnowledgeBaseRepository>();
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

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  DateFormat _buildDateFormat(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    return DateFormat.yMMMMd(locale.toLanguageTag()).add_Hm();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final DateFormat dateFormat = _buildDateFormat(context);
    return BlocConsumer<KnowledgeBaseCubit, KnowledgeBaseState>(
      listener: (BuildContext context, KnowledgeBaseState state) {
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
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
            title: Text(l10n.knowledgeBaseTitle),
            actions: <Widget>[
              IconButton(
                tooltip: l10n.knowledgeBaseRefresh,
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
                    if (state.offlineMode) const _OfflineBanner(),
                    _buildHeader(context, state, l10n, dateFormat),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () =>
                            context.read<KnowledgeBaseCubit>().refresh(),
                        child: _buildArticleList(
                          context,
                          state,
                          l10n,
                          dateFormat,
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    KnowledgeBaseState state,
    AppLocalizations l10n,
    DateFormat dateFormat,
  ) {
    final ThemeData theme = Theme.of(context);
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
              hintText: l10n.knowledgeBaseSearchHint,
              suffixIcon: state.searchQuery.isEmpty
                  ? null
                  : IconButton(
                      tooltip: l10n.commonClear,
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
                  l10n.knowledgeBaseCount(state.filteredArticles.length),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              if (state.lastUpdated != null)
                Text(
                  l10n.knowledgeBaseUpdatedAt(
                    dateFormat.format(state.lastUpdated!.toLocal()),
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArticleList(
    BuildContext context,
    KnowledgeBaseState state,
    AppLocalizations l10n,
    DateFormat dateFormat,
  ) {
    if (state.filteredArticles.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: <Widget>[
          const SizedBox(height: 96),
          Icon(
            Icons.menu_book_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.knowledgeBaseEmpty,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.knowledgeBaseEmptyHelp,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
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
          onTap: () =>
              context.read<KnowledgeBaseCubit>().selectArticle(article),
          dateFormat: dateFormat,
          l10n: l10n,
        );
      },
    );
  }

  Future<void> _showArticleViewer(
    BuildContext context,
    KnowledgeArticle article,
  ) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final DateFormat dateFormat = _buildDateFormat(context);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.9,
          minChildSize: 0.5,
          builder: (BuildContext context, ScrollController controller) {
            final ThemeData theme = Theme.of(context);
            return Column(
              children: <Widget>[
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  title: Text(article.title, style: theme.textTheme.titleLarge),
                  subtitle: Text(
                    l10n.knowledgeBaseLastUpdate(
                      dateFormat.format(article.updatedAt.toLocal()),
                    ),
                  ),
                  trailing: IconButton(
                    tooltip: MaterialLocalizations.of(context).closeButtonLabel,
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
                    styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)),
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
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: <Widget>[
          const Icon(Icons.cloud_off_outlined),
          const SizedBox(width: 12),
          Expanded(child: Text(l10n.knowledgeBaseOfflineBanner)),
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
    required this.l10n,
  });

  final KnowledgeArticle article;
  final VoidCallback onTap;
  final DateFormat dateFormat;
  final AppLocalizations l10n;

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
              Text(article.title, style: theme.textTheme.titleMedium),
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
                l10n.knowledgeBaseLastUpdate(
                  dateFormat.format(article.updatedAt.toLocal()),
                ),
                style: theme.textTheme.labelMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
