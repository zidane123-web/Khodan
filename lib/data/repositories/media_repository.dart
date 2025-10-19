import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../local/local_data_sources.dart';
import '../models/animal_media.dart';
import '../models/sync_action.dart';
import '../services/api_client.dart';
import '../services/offline_sync_manager.dart';

abstract class MediaRepository {
  Future<List<AnimalMedia>> fetchAnimalGallery({
    required String profileId,
    required String animalId,
    bool forceRemote = false,
  });

  Future<AnimalMedia> uploadAnimalPhoto({
    required String profileId,
    required String animalId,
    required String filePath,
  });

  Future<void> deleteAnimalPhoto({
    required String profileId,
    required String animalId,
    required String mediaId,
  });

  Future<AnimalMedia> refreshSignedUrl(
    AnimalMedia media, {
    Duration ttl = const Duration(hours: 1),
  });
}

class InMemoryMediaRepository implements MediaRepository {
  InMemoryMediaRepository();

  final Map<String, List<AnimalMedia>> _storage = <String, List<AnimalMedia>>{};

  String _key(String profileId, String animalId) => '$profileId::$animalId';

  @override
  Future<List<AnimalMedia>> fetchAnimalGallery({
    required String profileId,
    required String animalId,
    bool forceRemote = false,
  }) async {
    final List<AnimalMedia> assets = List<AnimalMedia>.from(
      _storage[_key(profileId, animalId)] ?? const <AnimalMedia>[],
    );
    assets.sort(
      (AnimalMedia a, AnimalMedia b) => b.createdAt.compareTo(a.createdAt),
    );
    return assets;
  }

  @override
  Future<AnimalMedia> uploadAnimalPhoto({
    required String profileId,
    required String animalId,
    required String filePath,
  }) async {
    final File file = File(filePath);
    if (!file.existsSync()) {
      throw StateError('Image file not found at $filePath');
    }
    final Uint8List bytes = await file.readAsBytes();
    final img.Image? decoded = img.decodeImage(bytes);
    final DateTime now = DateTime.now();
    final AnimalMedia asset = AnimalMedia(
      id: 'local-${now.microsecondsSinceEpoch}',
      profileId: profileId,
      animalId: animalId,
      storagePath: file.uri.pathSegments.last,
      createdAt: now,
      updatedAt: now,
      localPath: file.path,
      bytesSize: bytes.length,
      width: decoded?.width,
      height: decoded?.height,
      syncState: kSyncStateSynced,
      signedUrl: file.uri.toString(),
    );
    final String key = _key(profileId, animalId);
    final List<AnimalMedia> existing = List<AnimalMedia>.from(
      _storage[key] ?? const <AnimalMedia>[],
    );
    existing
      ..add(asset)
      ..sort(
        (AnimalMedia a, AnimalMedia b) => b.createdAt.compareTo(a.createdAt),
      );
    _storage[key] = existing;
    return asset;
  }

  @override
  Future<void> deleteAnimalPhoto({
    required String profileId,
    required String animalId,
    required String mediaId,
  }) async {
    final String key = _key(profileId, animalId);
    final List<AnimalMedia> existing = List<AnimalMedia>.from(
      _storage[key] ?? const <AnimalMedia>[],
    );
    existing.removeWhere((AnimalMedia asset) => asset.id == mediaId);
    _storage[key] = existing;
  }

  @override
  Future<AnimalMedia> refreshSignedUrl(
    AnimalMedia media, {
    Duration ttl = const Duration(hours: 1),
  }) async {
    return media;
  }
}

class SupabaseMediaRepository {
  SupabaseMediaRepository({
    ApiExecutor? apiClient,
    String bucket = 'animal-media',
    Duration signedUrlTtl = const Duration(hours: 1),
  }) : _api = apiClient ?? ApiClient(),
       _bucket = bucket,
       _signedUrlTtl = signedUrlTtl;

  final ApiExecutor _api;
  final String _bucket;
  final Duration _signedUrlTtl;

  Future<List<AnimalMedia>> fetchAnimalGallery({
    required String profileId,
    required String animalId,
  }) async {
    final String folder = _folder(profileId, animalId);
    final List<FileObject> files = await _api.run(
      (SupabaseClient client) =>
          client.storage.from(_bucket).list(path: folder),
      label: 'media.list',
    );
    if (files.isEmpty) {
      return const <AnimalMedia>[];
    }

    final List<String> paths = files
        .map((FileObject file) => '$folder/${file.name}')
        .toList(growable: false);
    final List<SignedUrl> signedUrls = await _api.run(
      (SupabaseClient client) => client.storage
          .from(_bucket)
          .createSignedUrls(paths, _signedUrlTtl.inSeconds),
      label: 'media.sign',
    );
    final Map<String, SignedUrl> signedByPath = <String, SignedUrl>{
      for (final SignedUrl url in signedUrls) url.path: url,
    };
    final DateTime expiry = DateTime.now().add(_signedUrlTtl);
    return files
        .map((FileObject file) {
          final String storagePath = '$folder/${file.name}';
          final SignedUrl? signed = signedByPath[storagePath];
          final DateTime createdAt = file.createdAt != null
              ? DateTime.tryParse(file.createdAt!) ?? DateTime.now()
              : DateTime.now();
          final DateTime updatedAt = file.updatedAt != null
              ? DateTime.tryParse(file.updatedAt!) ?? createdAt
              : createdAt;

          return AnimalMedia(
            id: storagePath,
            profileId: profileId,
            animalId: animalId,
            storagePath: storagePath,
            createdAt: createdAt,
            updatedAt: updatedAt,
            signedUrl: signed?.signedUrl,
            signedUrlExpiresAt: signed == null ? null : expiry,
            bytesSize: file.metadata?['size'] as int?,
            syncState: kSyncStateSynced,
          );
        })
        .toList(growable: false);
  }

  Future<AnimalMedia> uploadBinary({
    required String profileId,
    required String animalId,
    required String storagePath,
    required Uint8List bytes,
    required int width,
    required int height,
    required int sizeBytes,
  }) async {
    await _api.run<void>(
      (SupabaseClient client) => client.storage
          .from(_bucket)
          .uploadBinary(
            storagePath,
            bytes,
            fileOptions: const FileOptions(
              upsert: false,
              contentType: 'image/jpeg',
              cacheControl: '3600',
            ),
          ),
      label: 'media.upload',
    );
    final List<SignedUrl> signedUrls = await _api.run(
      (SupabaseClient client) => client.storage.from(_bucket).createSignedUrls(
        <String>[storagePath],
        _signedUrlTtl.inSeconds,
      ),
      label: 'media.sign.upload',
    );
    final SignedUrl? signed = signedUrls.isEmpty ? null : signedUrls.first;
    final DateTime now = DateTime.now();
    return AnimalMedia(
      id: storagePath,
      profileId: profileId,
      animalId: animalId,
      storagePath: storagePath,
      createdAt: now,
      updatedAt: now,
      signedUrl: signed?.signedUrl,
      signedUrlExpiresAt: signed == null ? null : now.add(_signedUrlTtl),
      width: width,
      height: height,
      bytesSize: sizeBytes,
      syncState: kSyncStateSynced,
    );
  }

  Future<void> delete({required String storagePath}) {
    return _api.run(
      (SupabaseClient client) =>
          client.storage.from(_bucket).remove(<String>[storagePath]),
      label: 'media.delete',
    );
  }

  Future<AnimalMedia> refreshSignedUrl(
    AnimalMedia media, {
    Duration? ttl,
  }) async {
    final Duration lifetime = ttl ?? _signedUrlTtl;
    final List<SignedUrl> signedUrls = await _api.run(
      (SupabaseClient client) => client.storage.from(_bucket).createSignedUrls(
        <String>[media.storagePath],
        lifetime.inSeconds,
      ),
      label: 'media.sign.refresh',
    );
    final SignedUrl? signed = signedUrls.isEmpty ? null : signedUrls.first;
    return media.copyWith(
      signedUrl: signed?.signedUrl,
      signedUrlExpiresAt: signed == null ? null : DateTime.now().add(lifetime),
    );
  }

  static String _folder(String profileId, String animalId) =>
      'profiles/$profileId/animals/$animalId';
}

class SyncedMediaRepository implements MediaRepository {
  SyncedMediaRepository({
    required SupabaseMediaRepository remote,
    required LocalAnimalMediaDataSource local,
    OfflineSyncManager? offlineManager,
  }) : _remote = remote,
       _local = local,
       _offlineManager = offlineManager ?? OfflineSyncManager.instance {
    _registerHandlers();
  }

  final SupabaseMediaRepository _remote;
  final LocalAnimalMediaDataSource _local;
  final OfflineSyncManager _offlineManager;
  final Uuid _uuid = const Uuid();

  Directory? _cacheDir;

  static bool _handlersRegistered = false;

  @override
  Future<List<AnimalMedia>> fetchAnimalGallery({
    required String profileId,
    required String animalId,
    bool forceRemote = false,
  }) async {
    if (_offlineManager.isOffline.value && !forceRemote) {
      return _local.fetchByAnimal(profileId: profileId, animalId: animalId);
    }

    try {
      final List<AnimalMedia> remoteAssets = await _remote.fetchAnimalGallery(
        profileId: profileId,
        animalId: animalId,
      );
      final List<AnimalMedia> localAssets = await _local.fetchByAnimal(
        profileId: profileId,
        animalId: animalId,
      );
      final Map<String, AnimalMedia> localById = <String, AnimalMedia>{
        for (final AnimalMedia asset in localAssets) asset.id: asset,
      };
      final Set<String> remoteIds = remoteAssets
          .map((AnimalMedia asset) => asset.id)
          .toSet();

      final List<AnimalMedia> merged = remoteAssets.map((AnimalMedia asset) {
        final AnimalMedia? local = localById[asset.id];
        if (local == null) {
          return asset;
        }
        return asset.copyWith(
          localPath: local.localPath,
          bytesSize: local.bytesSize ?? asset.bytesSize,
          width: local.width ?? asset.width,
          height: local.height ?? asset.height,
        );
      }).toList();

      for (final AnimalMedia local in localAssets) {
        if (!remoteIds.contains(local.id) &&
            local.syncState == kSyncStatePending) {
          merged.add(local);
        }
      }

      await _local.replaceMedia(
        merged,
        profileId: profileId,
        animalId: animalId,
      );
      merged.sort(
        (AnimalMedia a, AnimalMedia b) => b.createdAt.compareTo(a.createdAt),
      );
      return merged;
    } catch (error) {
      final List<AnimalMedia> cached = await _local.fetchByAnimal(
        profileId: profileId,
        animalId: animalId,
      );
      if (cached.isNotEmpty) {
        return cached;
      }
      rethrow;
    }
  }

  @override
  Future<AnimalMedia> uploadAnimalPhoto({
    required String profileId,
    required String animalId,
    required String filePath,
  }) async {
    final _PreparedUpload prepared = await _prepareUpload(
      profileId: profileId,
      animalId: animalId,
      filePath: filePath,
    );

    if (_offlineManager.isOffline.value) {
      final AnimalMedia pending = prepared.asset.copyWith(
        syncState: kSyncStatePending,
      );
      await _local.upsertMedia(pending, syncState: kSyncStatePending);
      await _offlineManager.enqueueAction(
        SyncActionRequest(
          type: SyncActionType.uploadAnimalMedia,
          rollbackType: SyncActionType.deleteAnimalMedia,
          description: 'Upload ${p.basename(pending.storagePath)}',
          payload: <String, dynamic>{'asset': pending.toJson()},
          rollbackPayload: <String, dynamic>{'asset': pending.toJson()},
          priority: 110,
        ),
      );
      return pending;
    }

    final AnimalMedia uploaded = await _performUpload(prepared.asset);
    return uploaded;
  }

  @override
  Future<void> deleteAnimalPhoto({
    required String profileId,
    required String animalId,
    required String mediaId,
  }) async {
    final AnimalMedia? asset = await _local.fetchById(mediaId);
    if (asset == null) {
      return;
    }

    if (_offlineManager.isOffline.value) {
      await _local.delete(mediaId);
      await _deleteLocalFile(asset.localPath);
      await _offlineManager.enqueueAction(
        SyncActionRequest(
          type: SyncActionType.deleteAnimalMedia,
          description: 'Delete ${p.basename(asset.storagePath)}',
          payload: <String, dynamic>{'asset': asset.toJson()},
          rollbackPayload: <String, dynamic>{'asset': asset.toJson()},
          priority: 90,
        ),
      );
      return;
    }

    await _local.delete(mediaId);
    try {
      await _remote.delete(storagePath: asset.storagePath);
      await _deleteLocalFile(asset.localPath);
    } catch (error) {
      await _local.upsertMedia(asset);
      rethrow;
    }
  }

  @override
  Future<AnimalMedia> refreshSignedUrl(
    AnimalMedia media, {
    Duration ttl = const Duration(hours: 1),
  }) async {
    if (_offlineManager.isOffline.value) {
      return media;
    }
    final AnimalMedia refreshed = await _remote.refreshSignedUrl(
      media,
      ttl: ttl,
    );
    await _local.upsertMedia(refreshed);
    return refreshed;
  }

  Future<AnimalMedia> _performUpload(AnimalMedia asset) async {
    final String? localPath = asset.localPath;
    if (localPath == null) {
      throw StateError('Missing local path for ${asset.storagePath}');
    }
    final File file = File(localPath);
    if (!await file.exists()) {
      throw StateError('Local cache missing for ${asset.storagePath}');
    }
    final Uint8List bytes = await file.readAsBytes();

    final AnimalMedia remoteAsset = await _remote.uploadBinary(
      profileId: asset.profileId,
      animalId: asset.animalId,
      storagePath: asset.storagePath,
      bytes: bytes,
      width: asset.width ?? 0,
      height: asset.height ?? 0,
      sizeBytes: bytes.length,
    );

    final AnimalMedia merged = remoteAsset.copyWith(
      localPath: asset.localPath,
      width: asset.width ?? remoteAsset.width,
      height: asset.height ?? remoteAsset.height,
      bytesSize: asset.bytesSize ?? remoteAsset.bytesSize,
      syncState: kSyncStateSynced,
    );
    await _local.upsertMedia(merged);
    return merged;
  }

  Future<_PreparedUpload> _prepareUpload({
    required String profileId,
    required String animalId,
    required String filePath,
  }) async {
    final File source = File(filePath);
    if (!await source.exists()) {
      throw StateError('Image not found at $filePath');
    }
    final Uint8List rawBytes = await source.readAsBytes();
    final img.Image? decoded = img.decodeImage(rawBytes);
    if (decoded == null) {
      throw StateError('Unsupported image format for $filePath');
    }

    final img.Image oriented = img.bakeOrientation(decoded);
    final img.Image resized = _resizeIfNeeded(oriented);
    final Uint8List encoded = Uint8List.fromList(
      img.encodeJpg(resized, quality: 85),
    );

    final Directory targetDir = await _ensureCacheDir(profileId, animalId);
    final String filename = '${_uuid.v4()}.jpg';
    final File targetFile = File(p.join(targetDir.path, filename));
    await targetFile.writeAsBytes(encoded, flush: true);

    final String storagePath =
        '${SupabaseMediaRepository._folder(profileId, animalId)}/$filename';
    final DateTime now = DateTime.now();

    final AnimalMedia asset = AnimalMedia(
      id: storagePath,
      profileId: profileId,
      animalId: animalId,
      storagePath: storagePath,
      createdAt: now,
      updatedAt: now,
      localPath: targetFile.path,
      width: resized.width,
      height: resized.height,
      bytesSize: encoded.length,
      syncState: kSyncStateSynced,
    );
    return _PreparedUpload(asset: asset);
  }

  Future<Directory> _ensureCacheDir(String profileId, String animalId) async {
    _cacheDir ??= await getApplicationDocumentsDirectory();
    final Directory base = _cacheDir!;
    final Directory dir = Directory(
      p.join(base.path, 'animal_media', profileId, animalId),
    );
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static img.Image _resizeIfNeeded(img.Image image) {
    const int maxDimension = 1600;
    final int longestSide = image.width > image.height
        ? image.width
        : image.height;
    if (longestSide <= maxDimension) {
      return image;
    }
    final double ratio = maxDimension / longestSide;
    final int width = (image.width * ratio).round();
    final int height = (image.height * ratio).round();
    return img.copyResize(
      image,
      width: width,
      height: height,
      interpolation: img.Interpolation.cubic,
    );
  }

  Future<void> _deleteLocalFile(String? path) async {
    if (path == null || path.isEmpty) {
      return;
    }
    try {
      final File file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // ignore IO errors silently
    }
  }

  void _registerHandlers() {
    if (_handlersRegistered) {
      return;
    }
    _handlersRegistered = true;

    _offlineManager.registerHandler(
      SyncActionType.uploadAnimalMedia,
      (QueuedSyncAction action) async {
        final Map<String, dynamic> raw =
            action.payload['asset'] as Map<String, dynamic>;
        final AnimalMedia asset = AnimalMedia.fromJson(raw);
        await _performUpload(asset);
      },
      rollback: (QueuedSyncAction action, Object _) async {
        final Map<String, dynamic>? raw =
            action.rollbackPayload?['asset'] as Map<String, dynamic>?;
        if (raw != null) {
          final AnimalMedia asset = AnimalMedia.fromJson(raw);
          await _local.delete(asset.id);
        }
      },
    );

    _offlineManager.registerHandler(
      SyncActionType.deleteAnimalMedia,
      (QueuedSyncAction action) async {
        final Map<String, dynamic> raw =
            action.payload['asset'] as Map<String, dynamic>;
        final AnimalMedia asset = AnimalMedia.fromJson(raw);
        await _remote.delete(storagePath: asset.storagePath);
        await _deleteLocalFile(asset.localPath);
      },
      rollback: (QueuedSyncAction action, Object _) async {
        final Map<String, dynamic>? raw =
            action.rollbackPayload?['asset'] as Map<String, dynamic>?;
        if (raw != null) {
          final AnimalMedia asset = AnimalMedia.fromJson(raw);
          await _local.upsertMedia(asset);
        }
      },
    );
  }
}

class _PreparedUpload {
  _PreparedUpload({required this.asset});

  final AnimalMedia asset;
}
