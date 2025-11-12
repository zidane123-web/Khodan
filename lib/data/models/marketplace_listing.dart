import 'package:equatable/equatable.dart';

enum MarketplaceListingStatus {
  draft('draft'),
  published('published'),
  paused('paused'),
  expired('expired'),
  sold('sold'),
  withdrawn('withdrawn');

  const MarketplaceListingStatus(this.key);
  final String key;

  static MarketplaceListingStatus fromKey(String? raw) {
    return MarketplaceListingStatus.values.firstWhere(
      (MarketplaceListingStatus status) => status.key == raw,
      orElse: () => MarketplaceListingStatus.draft,
    );
  }
}

class MarketplaceListing extends Equatable {
  const MarketplaceListing({
    required this.id,
    required this.profileId,
    required this.title,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.animalId,
    this.contactId,
    this.feeTransactionId,
    this.description,
    this.price,
    this.currency = 'XOF',
    this.isNegotiable = false,
    this.mediaUrls = const <String>[],
    this.tags = const <String>[],
    this.visibility = 'public',
    this.publishedAt,
    this.expiresAt,
    this.archivedAt,
  });

  factory MarketplaceListing.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? media = json['media_urls'] as List<dynamic>?;
    final List<dynamic>? tags = json['tags'] as List<dynamic>?;
    return MarketplaceListing(
      id: json['id'] as String,
      profileId: json['profile_id'] as String,
      title: json['title'] as String? ?? '',
      status: MarketplaceListingStatus.fromKey(json['status'] as String?),
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updated_at']) ?? DateTime.now(),
      animalId: json['animal_id'] as String?,
      contactId: json['contact_id'] as String?,
      feeTransactionId: json['fee_transaction_id'] as String?,
      description: json['description'] as String?,
      price: _parseDouble(json['price']),
      currency: json['currency'] as String? ?? 'XOF',
      isNegotiable: json['is_negotiable'] as bool? ?? false,
      mediaUrls: media != null
          ? media.whereType<String>().toList(growable: false)
          : const <String>[],
      tags: tags != null
          ? tags.whereType<String>().toList(growable: false)
          : const <String>[],
      visibility: json['visibility'] as String? ?? 'public',
      publishedAt: _parseDate(json['published_at']),
      expiresAt: _parseDate(json['expires_at']),
      archivedAt: _parseDate(json['archived_at']),
    );
  }

  final String id;
  final String profileId;
  final String title;
  final MarketplaceListingStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? animalId;
  final String? contactId;
  final String? feeTransactionId;
  final String? description;
  final double? price;
  final String currency;
  final bool isNegotiable;
  final List<String> mediaUrls;
  final List<String> tags;
  final String visibility;
  final DateTime? publishedAt;
  final DateTime? expiresAt;
  final DateTime? archivedAt;

  MarketplaceListing copyWith({
    MarketplaceListingStatus? status,
    DateTime? publishedAt,
    DateTime? expiresAt,
    DateTime? archivedAt,
  }) {
    return MarketplaceListing(
      id: id,
      profileId: profileId,
      title: title,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      animalId: animalId,
      contactId: contactId,
      feeTransactionId: feeTransactionId,
      description: description,
      price: price,
      currency: currency,
      isNegotiable: isNegotiable,
      mediaUrls: mediaUrls,
      tags: tags,
      visibility: visibility,
      publishedAt: publishedAt ?? this.publishedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }

  Map<String, dynamic> toInsertPayload() {
    return <String, dynamic>{
      'profile_id': profileId,
      'animal_id': animalId,
      'contact_id': contactId,
      'title': title,
      'description': description,
      'price': price,
      'currency': currency,
      'is_negotiable': isNegotiable,
      'media_urls': mediaUrls,
      'tags': tags,
      'status': status.key,
      'visibility': visibility,
      'published_at': publishedAt?.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'fee_transaction_id': feeTransactionId,
    };
  }

  static double? _parseDouble(dynamic raw) {
    if (raw == null) {
      return null;
    }
    if (raw is num) {
      return raw.toDouble();
    }
    if (raw is String && raw.isNotEmpty) {
      return double.tryParse(raw);
    }
    return null;
  }

  static DateTime? _parseDate(dynamic input) {
    if (input == null) {
      return null;
    }
    if (input is DateTime) {
      return input;
    }
    if (input is String && input.isNotEmpty) {
      return DateTime.tryParse(input);
    }
    return null;
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        profileId,
        title,
        status,
        createdAt,
        updatedAt,
        animalId,
        contactId,
        feeTransactionId,
        description,
        price,
        currency,
        isNegotiable,
        mediaUrls,
        tags,
        visibility,
        publishedAt,
        expiresAt,
        archivedAt,
      ];
}

class MarketplaceListingDraft {
  const MarketplaceListingDraft({
    required this.title,
    this.animalId,
    this.contactId,
    this.description,
    this.price,
    this.currency = 'XOF',
    this.isNegotiable = false,
    this.mediaUrls = const <String>[],
    this.tags = const <String>[],
    this.visibility = 'public',
    this.expiresAt,
    this.feeTransactionId,
  });

  final String title;
  final String? animalId;
  final String? contactId;
  final String? description;
  final double? price;
  final String currency;
  final bool isNegotiable;
  final List<String> mediaUrls;
  final List<String> tags;
  final String visibility;
  final DateTime? expiresAt;
  final String? feeTransactionId;
}
