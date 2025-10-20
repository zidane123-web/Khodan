import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:khodan/app/core/logging/diagnostics_service.dart';
import 'package:khodan/data/services/offline_sync_manager.dart';
import 'package:khodan/features/settings/presentation/cubit/diagnostics_cubit.dart';

class _MockDiagnosticsService extends Mock implements DiagnosticsService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PackageInfo.setMockInitialValues(
    appName: 'Khodan',
    packageName: 'com.example.khodan',
    version: '1.0.0',
    buildNumber: '1',
    buildSignature: 'test',
  );

  setUpAll(() {
    registerFallbackValue(<String>[]);
  });

  group('DiagnosticsCubit', () {
    late DiagnosticsCubit cubit;
    late _MockDiagnosticsService service;
    late ValueNotifier<List<DiagnosticsEntry>> entriesNotifier;
    bool detailedLogging = false;

    setUp(() {
      service = _MockDiagnosticsService();
      entriesNotifier =
          ValueNotifier<List<DiagnosticsEntry>>(<DiagnosticsEntry>[
            DiagnosticsEntry(
              timestamp: DateTime(2024, 1, 10, 8, 30),
              message: 'Sync completed',
              level: 'info',
              source: 'sync',
              details: 'All ok',
            ),
          ]);

      detailedLogging = false;

      when(service.initialize).thenAnswer((_) async {});
      when(
        () => service.detailedLoggingEnabled,
      ).thenAnswer((_) => detailedLogging);
      when(() => service.entries).thenAnswer((_) => entriesNotifier.value);
      when(() => service.entriesListenable).thenReturn(entriesNotifier);
      when(
        () => service.exportToFile(headerLines: any(named: 'headerLines')),
      ).thenAnswer((_) async => 'logs.txt');
      when(() => service.clear()).thenAnswer((_) async {
        entriesNotifier.value = <DiagnosticsEntry>[];
      });
      when(() => service.setDetailedLogging(any())).thenAnswer((invocation) async {
        detailedLogging = invocation.positionalArguments.first as bool;
        entriesNotifier.notifyListeners();
      });

      final OfflineSyncManager offline = OfflineSyncManager.instance;
      offline.isOffline.value = false;
      offline.pendingActions.value = 2;

      cubit = DiagnosticsCubit(service: service, offlineManager: offline);
    });

    tearDown(() async {
      await cubit.close();
    });

    test('initialise les diagnostics et charge les entrées', () async {
      await cubit.initialize();

      expect(cubit.state.loading, isFalse);
      expect(cubit.state.entries, entriesNotifier.value);
      expect(cubit.state.detailedLogging, detailedLogging);
      expect(cubit.state.deviceDiagnostics, isNotNull);
      expect(cubit.state.deviceDiagnostics?.pendingActions, 2);
      verify(service.initialize).called(1);
    });

    test('active la journalisation détaillée', () async {
      await cubit.initialize();

      await cubit.toggleDetailedLogging(true);

      expect(detailedLogging, isTrue);
      expect(cubit.state.detailedLogging, isTrue);
      verify(() => service.setDetailedLogging(true)).called(1);
    });

    test('exporte les journaux et renvoie le chemin du fichier', () async {
      await cubit.initialize();

      final String? path = await cubit.exportLogs();

      expect(path, 'logs.txt');
      expect(cubit.state.exportPath, 'logs.txt');
      verify(
        () => service.exportToFile(headerLines: any(named: 'headerLines')),
      ).called(1);
    });
  });
}
