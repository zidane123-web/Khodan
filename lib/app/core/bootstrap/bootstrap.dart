import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/services/import_export_service.dart';
import '../../../data/services/notification_service.dart';
import '../../../data/services/sync_coordinator.dart';
import '../../core/constants.dart';

class BootstrapResult {
  const BootstrapResult({
    this.supabaseClient,
    this.syncCoordinator,
    required this.notificationService,
    required this.importExportService,
  });

  final SupabaseClient? supabaseClient;
  final SyncCoordinator? syncCoordinator;
  final NotificationService notificationService;
  final ImportExportService importExportService;
}

class AppBootstrap {
  const AppBootstrap._();

  static BootstrapResult? _cached;

  static BootstrapResult get result {
    final BootstrapResult? current = _cached;
    if (current == null) {
      throw StateError('AppBootstrap.ensureInitialized must be called before accessing result.');
    }
    return current;
  }

  static Future<BootstrapResult> ensureInitialized() async {
    if (_cached != null) {
      return _cached!;
    }

    WidgetsFlutterBinding.ensureInitialized();
    final SupabaseClient? client = await _initializeSupabase();
    final SyncCoordinator? syncCoordinator =
        client == null ? null : SyncCoordinator(client: client);
    final NotificationService notificationService = NotificationService();

    await _initializeFirebase(notificationService);

    final ImportExportService importExportService = ImportExportService();

    _cached = BootstrapResult(
      supabaseClient: client,
      syncCoordinator: syncCoordinator,
      notificationService: notificationService,
      importExportService: importExportService,
    );
    return _cached!;
  }

  static Future<SupabaseClient?> _initializeSupabase() async {
    final String supabaseUrl = AppConstants.supabaseUrl;
    final String supabaseAnonKey = AppConstants.supabaseAnonKey;

    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      debugPrint('Supabase credentials are missing. Skipping initialization.');
      return null;
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    return Supabase.instance.client;
  }

  static Future<void> _initializeFirebase(NotificationService notificationService) async {
    try {
      await Firebase.initializeApp();
      await notificationService.initialize();
    } catch (error, stackTrace) {
      debugPrint('Firebase Messaging initialization skipped: ');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
