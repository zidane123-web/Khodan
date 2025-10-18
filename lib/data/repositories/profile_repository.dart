import 'package:supabase_flutter/supabase_flutter.dart';

import '../local/local_data_sources.dart';
import '../models/profile.dart';
import '../models/sync_action.dart';
import '../services/api_client.dart';
import '../services/offline_sync_manager.dart';

abstract class ProfileRepository {
  Future<Profile> fetch(String profileId);

  Future<Profile> update(Profile profile);
}

class SupabaseProfileRepository implements ProfileRepository {
  SupabaseProfileRepository({ApiExecutor? apiClient})
      : _api = apiClient ?? ApiClient();

  final ApiExecutor _api;

  @override
  Future<Profile> fetch(String profileId) async {
    final Map<String, dynamic>? data = await _api.run(
      (SupabaseClient client) {
        return client
            .from('profiles')
            .select()
            .eq('id', profileId)
            .maybeSingle();
      },
      label: 'profile.fetch',
    );
    if (data == null) {
      throw StateError('Profil $profileId introuvable.');
    }
    return Profile.fromJson(data);
  }

  @override
  Future<Profile> update(Profile profile) async {
    final Map<String, dynamic>? data = await _api.run(
      (SupabaseClient client) {
        return client
            .from('profiles')
            .update(profile.toUpdatePayload())
            .eq('id', profile.id)
            .select()
            .maybeSingle();
      },
      label: 'profile.update',
    );
    if (data == null) {
      throw StateError('Profil ${profile.id} introuvable pour mise à jour.');
    }
    return Profile.fromJson(data);
  }
}

class SyncedProfileRepository implements ProfileRepository {
  SyncedProfileRepository({
    required ProfileRepository remote,
    required LocalProfileDataSource local,
    OfflineSyncManager? offlineManager,
  })  : _remote = remote,
        _local = local,
        _offlineManager = offlineManager ?? OfflineSyncManager.instance {
    _registerHandlers();
  }

  final ProfileRepository _remote;
  final LocalProfileDataSource _local;
  final OfflineSyncManager _offlineManager;
  bool _handlersRegistered = false;

  @override
  Future<Profile> fetch(String profileId) async {
    if (_offlineManager.isOffline.value) {
      final Profile? cached = await _local.fetchProfile(profileId);
      if (cached != null) {
        return cached;
      }
    }

    try {
      final Profile profile = await _remote.fetch(profileId);
      await _local.upsertProfile(profile);
      return profile;
    } catch (error) {
      final Profile? cached = await _local.fetchProfile(profileId);
      if (cached != null) {
        return cached;
      }
      rethrow;
    }
  }

  @override
  Future<Profile> update(Profile profile) async {
    if (_offlineManager.isOffline.value) {
      final Profile? previous = await _local.fetchProfile(profile.id);
      await _local.upsertProfile(profile, syncState: kSyncStatePending);
      await _offlineManager.enqueueAction(
        SyncActionRequest(
          type: SyncActionType.updateProfile,
          rollbackType: previous == null ? null : SyncActionType.updateProfile,
          description: 'Mettre à jour le profil élevage',
          payload: <String, dynamic>{'profile': profile.toJson()},
          rollbackPayload: previous == null
              ? null
              : <String, dynamic>{'profile': previous.toJson()},
          priority: 120,
          execute: () async {
            final Profile updated = await _remote.update(profile);
            await _local.upsertProfile(updated);
          },
        ),
      );
      return profile;
    }

    final Profile updated = await _remote.update(profile);
    await _local.upsertProfile(updated);
    return updated;
  }

  void _registerHandlers() {
    if (_handlersRegistered) {
      return;
    }
    _handlersRegistered = true;

    _offlineManager.registerHandler(
      SyncActionType.updateProfile,
      (QueuedSyncAction action) async {
        final Map<String, dynamic> raw =
            action.payload['profile'] as Map<String, dynamic>;
        final Profile queued = Profile.fromJson(raw);
        final Profile updated = await _remote.update(queued);
        await _local.upsertProfile(updated);
      },
      rollback: (QueuedSyncAction action, Object _) async {
        final Map<String, dynamic>? raw =
            action.rollbackPayload?['profile'] as Map<String, dynamic>?;
        if (raw != null) {
          await _local.upsertProfile(
            Profile.fromJson(raw),
            syncState: kSyncStateSynced,
          );
        }
      },
    );
  }
}

class InMemoryProfileRepository implements ProfileRepository {
  InMemoryProfileRepository();

  final Map<String, Profile> _profiles = <String, Profile>{};

  @override
  Future<Profile> fetch(String profileId) async {
    return _profiles.putIfAbsent(
      profileId,
      () {
        final DateTime now = DateTime.now();
        return Profile(
          id: profileId,
          email: '$profileId@example.com',
          farmName: 'Ferme démo',
          createdAt: now,
          updatedAt: now,
          phone: '+33123456789',
          locale: 'fr_FR',
          timeZone: 'Europe/Paris',
          farmLocation: 'France',
          legalPreferences: const <String, dynamic>{
            'termsAccepted': true,
            'privacyAccepted': true,
            'marketingOptIn': false,
          },
          billingStatus: 'trialing',
        );
      },
    );
  }

  @override
  Future<Profile> update(Profile profile) async {
    _profiles[profile.id] = profile;
    return profile;
  }
}
