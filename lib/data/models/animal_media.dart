import 'package:equatable/equatable.dart';

class AnimalMedia extends Equatable {
  const AnimalMedia({
    required this.id,
    required this.profileId,
    required this.animalId,
    required this.storagePath,
    required this.createdAt,
    required this.updatedAt,
    this.signedUrl,
    this.signedUrlExpiresAt,
    this.localPath,
    this.bytesSize,
    this.width,
    this.height,
    this.syncState = 'synced',
    this.isCover = false,
  });

  final String id;
  final String profileId;
  final String animalId;
  final String storagePath;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? signedUrl;
  final DateTime? signedUrlExpiresAt;
  final String? localPath;
  final int? bytesSize;
  final int? width;
  final int? height;
  final String syncState;
  final bool isCover;

  bool get hasValidSignedUrl {
    if (signedUrl == null) {
      return false;
    }
    if (signedUrlExpiresAt == null) {
      return true;
    }
    return signedUrlExpiresAt!.isAfter(DateTime.now());
  }

  AnimalMedia copyWith({
    String? id,
    String? profileId,
    String? animalId,
    String? storagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? signedUrl,
    bool clearSignedUrl = false,
    DateTime? signedUrlExpiresAt,
    bool clearSignedExpiry = false,
    String? localPath,
    bool clearLocalPath = false,
    int? bytesSize,
    bool clearBytesSize = false,
    int? width,
    bool clearWidth = false,
    int? height,
    bool clearHeight = false,
    String? syncState,
    bool? isCover,
  }) {
    return AnimalMedia(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      animalId: animalId ?? this.animalId,
      storagePath: storagePath ?? this.storagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      signedUrl: clearSignedUrl ? null : signedUrl ?? this.signedUrl,
      signedUrlExpiresAt: clearSignedExpiry
          ? null
          : signedUrlExpiresAt ?? this.signedUrlExpiresAt,
      localPath: clearLocalPath ? null : localPath ?? this.localPath,
      bytesSize: clearBytesSize ? null : bytesSize ?? this.bytesSize,
      width: clearWidth ? null : width ?? this.width,
      height: clearHeight ? null : height ?? this.height,
      syncState: syncState ?? this.syncState,
      isCover: isCover ?? this.isCover,
    );
  }

  factory AnimalMedia.fromJson(Map<String, dynamic> json) {
    return AnimalMedia(
      id: json['id'] as String,
      profileId: json['profile_id'] as String,
      animalId: json['animal_id'] as String,
      storagePath: json['storage_path'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      signedUrl: json['signed_url'] as String?,
      signedUrlExpiresAt: json['signed_url_expires_at'] != null
          ? DateTime.parse(json['signed_url_expires_at'] as String)
          : null,
      localPath: json['local_path'] as String?,
      bytesSize: json['bytes_size'] as int?,
      width: json['width'] as int?,
      height: json['height'] as int?,
      syncState: json['sync_state'] as String? ?? 'synced',
      isCover: json['is_cover'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'profile_id': profileId,
      'animal_id': animalId,
      'storage_path': storagePath,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'signed_url': signedUrl,
      'signed_url_expires_at': signedUrlExpiresAt?.toIso8601String(),
      'local_path': localPath,
      'bytes_size': bytesSize,
      'width': width,
      'height': height,
      'sync_state': syncState,
      'is_cover': isCover,
    };
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        profileId,
        animalId,
        storagePath,
        createdAt,
        updatedAt,
        signedUrl,
        signedUrlExpiresAt,
        localPath,
        bytesSize,
        width,
        height,
        syncState,
        isCover,
      ];
}
