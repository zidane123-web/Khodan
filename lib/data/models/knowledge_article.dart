import 'package:equatable/equatable.dart';

/// Represents a knowledge base article fetched from Supabase and cached locally.
class KnowledgeArticle extends Equatable {
  const KnowledgeArticle({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.updatedAt,
    this.tags = const <String>[],
    this.category,
  });

  final String id;
  final String title;
  final String summary;
  final String content;
  final DateTime updatedAt;
  final List<String> tags;
  final String? category;

  KnowledgeArticle copyWith({
    String? id,
    String? title,
    String? summary,
    String? content,
    DateTime? updatedAt,
    List<String>? tags,
    String? category,
  }) {
    return KnowledgeArticle(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      content: content ?? this.content,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'summary': summary,
      'content': content,
      'updated_at': updatedAt.toIso8601String(),
      'tags': tags,
      'category': category,
    };
  }

  factory KnowledgeArticle.fromJson(Map<String, dynamic> json) {
    final dynamic rawTags = json['tags'];
    List<String> parsedTags;
    if (rawTags is List<dynamic>) {
      parsedTags = rawTags.whereType<String>().toList();
    } else if (rawTags is String) {
      parsedTags = rawTags
          .split(',')
          .map((String tag) => tag.trim())
          .where((String tag) => tag.isNotEmpty)
          .toList();
    } else {
      parsedTags = const <String>[];
    }

    return KnowledgeArticle(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: (json['summary'] ?? '') as String,
      content: (json['content'] ?? '') as String,
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.now(),
      tags: parsedTags,
      category: json['category'] as String?,
    );
  }

  bool matchesQuery(String query) {
    if (query.isEmpty) {
      return true;
    }
    final String normalizedQuery = query.toLowerCase();
    if (title.toLowerCase().contains(normalizedQuery) ||
        summary.toLowerCase().contains(normalizedQuery)) {
      return true;
    }
    for (final String tag in tags) {
      if (tag.toLowerCase().contains(normalizedQuery)) {
        return true;
      }
    }
    if (category != null &&
        category!.toLowerCase().contains(normalizedQuery)) {
      return true;
    }
    return false;
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        title,
        summary,
        content,
        updatedAt,
        tags,
        category,
      ];
}
