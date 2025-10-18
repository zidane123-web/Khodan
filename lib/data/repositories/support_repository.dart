import '../models/support_request.dart';
import '../models/sync_action.dart';
import '../services/api_client.dart';
import '../services/offline_sync_manager.dart';

abstract class SupportRepository {
  Future<void> submit(SupportRequest request);
}

class SupabaseSupportRepository implements SupportRepository {
  SupabaseSupportRepository({ApiExecutor? apiClient})
      : _api = apiClient ?? ApiClient();

  final ApiExecutor _api;

  @override
  Future<void> submit(SupportRequest request) async {
    await _api.run(
      (client) => client.from('support_requests').insert(
        request.toJson(),
      ),
      label: 'support.create',
    );
  }
}

class SyncedSupportRepository implements SupportRepository {
  SyncedSupportRepository({
    required SupportRepository remote,
    OfflineSyncManager? offlineManager,
  })  : _remote = remote,
        _offlineManager = offlineManager ?? OfflineSyncManager.instance {
    _registerHandler();
  }

  final SupportRepository _remote;
  final OfflineSyncManager _offlineManager;
  bool _handlerRegistered = false;

  @override
  Future<void> submit(SupportRequest request) async {
    if (_offlineManager.isOffline.value) {
      await _offlineManager.enqueueAction(
        SyncActionRequest(
          type: SyncActionType.createSupportRequest,
          description: 'Ticket support "${request.subject}"',
          payload: <String, dynamic>{'support': request.toJson()},
          priority: 40,
          execute: () async {
            await _remote.submit(request);
          },
        ),
      );
      return;
    }
    await _remote.submit(request);
  }

  void _registerHandler() {
    if (_handlerRegistered) {
      return;
    }
    _handlerRegistered = true;

    _offlineManager.registerHandler(
      SyncActionType.createSupportRequest,
      (QueuedSyncAction action) async {
        final Map<String, dynamic> raw =
            action.payload['support'] as Map<String, dynamic>;
        await _remote.submit(SupportRequest.fromJson(raw));
      },
    );
  }
}

class InMemorySupportRepository implements SupportRepository {
  InMemorySupportRepository();

  final List<SupportRequest> submitted = <SupportRequest>[];

  @override
  Future<void> submit(SupportRequest request) async {
    submitted.add(request);
  }
}
