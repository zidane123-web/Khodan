import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/report_models.dart';
import '../../services/report_export_service.dart';
import '../../services/reports_service.dart';

enum ReportsStatus { initial, loading, success, failure }

enum ReportsRangePreset { threeMonths, sixMonths, twelveMonths }

class ReportsState extends Equatable {
  const ReportsState({
    required this.status,
    required this.preset,
    required this.range,
    this.bundle,
    this.errorMessage,
  });

  final ReportsStatus status;
  final ReportsRangePreset preset;
  final DateTimeRange range;
  final ReportsBundle? bundle;
  final String? errorMessage;

  ReportsState copyWith({
    ReportsStatus? status,
    ReportsRangePreset? preset,
    DateTimeRange? range,
    ReportsBundle? bundle,
    bool clearBundle = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ReportsState(
      status: status ?? this.status,
      preset: preset ?? this.preset,
      range: range ?? this.range,
      bundle: clearBundle ? null : bundle ?? this.bundle,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    preset,
    range,
    bundle,
    errorMessage,
  ];
}

class ReportsCubit extends Cubit<ReportsState> {
  ReportsCubit({
    required ReportsService service,
    required ReportsExportService exportService,
    ReportsRangePreset initialPreset = ReportsRangePreset.sixMonths,
  }) : _service = service,
       _exportService = exportService,
       super(
         ReportsState(
           status: ReportsStatus.initial,
           preset: initialPreset,
           range: _computeRange(initialPreset),
         ),
       );

  final ReportsService _service;
  final ReportsExportService _exportService;

  Future<void> load({required String profileId}) async {
    final DateTimeRange range = state.range;
    emit(state.copyWith(status: ReportsStatus.loading, clearError: true));
    try {
      final ReportsBundle bundle = await _service.load(
        profileId: profileId,
        range: range,
      );
      emit(
        state.copyWith(
          status: ReportsStatus.success,
          bundle: bundle,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: ReportsStatus.failure,
          errorMessage: error.toString(),
          clearBundle: true,
        ),
      );
    }
  }

  Future<void> changePreset({
    required ReportsRangePreset preset,
    required String profileId,
  }) async {
    final DateTimeRange nextRange = _computeRange(preset);
    emit(
      state.copyWith(
        preset: preset,
        range: nextRange,
        status: ReportsStatus.loading,
        clearError: true,
      ),
    );
    try {
      final ReportsBundle bundle = await _service.load(
        profileId: profileId,
        range: nextRange,
      );
      emit(
        state.copyWith(
          status: ReportsStatus.success,
          bundle: bundle,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: ReportsStatus.failure,
          errorMessage: error.toString(),
          clearBundle: true,
        ),
      );
    }
  }

  Future<void> refresh({required String profileId}) async {
    if (state.status == ReportsStatus.loading) {
      return;
    }
    emit(state.copyWith(status: ReportsStatus.loading, clearError: true));
    try {
      final ReportsBundle bundle = await _service.load(
        profileId: profileId,
        range: state.range,
      );
      emit(
        state.copyWith(
          status: ReportsStatus.success,
          bundle: bundle,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: ReportsStatus.failure,
          errorMessage: error.toString(),
          clearBundle: true,
        ),
      );
    }
  }

  Future<void> exportCsv(ReportsTab tab) async {
    final ReportsBundle? bundle = state.bundle;
    if (bundle == null) {
      throw StateError('Aucun rapport charge.');
    }
    await _exportService.exportCsv(
      tab: tab,
      bundle: bundle,
      range: state.range,
    );
  }

  Future<void> exportExcel(ReportsTab tab) async {
    final ReportsBundle? bundle = state.bundle;
    if (bundle == null) {
      throw StateError('Aucun rapport charge.');
    }
    await _exportService.exportExcel(
      tab: tab,
      bundle: bundle,
      range: state.range,
    );
  }

  static DateTimeRange _computeRange(ReportsRangePreset preset) {
    final DateTime now = DateTime.now();
    final int months;
    switch (preset) {
      case ReportsRangePreset.threeMonths:
        months = 3;
        break;
      case ReportsRangePreset.sixMonths:
        months = 6;
        break;
      case ReportsRangePreset.twelveMonths:
        months = 12;
        break;
    }
    final DateTime end = DateTime(now.year, now.month + 1, 0);
    final DateTime start = DateTime(now.year, now.month - (months - 1), 1);
    return DateTimeRange(start: start, end: end);
  }
}
