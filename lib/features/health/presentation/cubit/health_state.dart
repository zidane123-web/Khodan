import 'package:equatable/equatable.dart';

import '../../../../data/models/ailment.dart';
import '../../../../data/models/animal.dart';
import '../../../../data/models/health_record.dart';

class HealthState extends Equatable {
  const HealthState({
    this.isLoading = false,
    this.ailments = const <Ailment>[],
    this.filteredAilments = const <Ailment>[],
    this.records = const <HealthRecord>[],
    this.animals = const <Animal>[],
    this.searchQuery = '',
    this.errorMessage,
  });

  final bool isLoading;
  final List<Ailment> ailments;
  final List<Ailment> filteredAilments;
  final List<HealthRecord> records;
  final List<Animal> animals;
  final String searchQuery;
  final String? errorMessage;

  HealthState copyWith({
    bool? isLoading,
    List<Ailment>? ailments,
    List<Ailment>? filteredAilments,
    List<HealthRecord>? records,
    List<Animal>? animals,
    String? searchQuery,
    String? errorMessage,
  }) {
    return HealthState(
      isLoading: isLoading ?? this.isLoading,
      ailments: ailments ?? this.ailments,
      filteredAilments: filteredAilments ?? this.filteredAilments,
      records: records ?? this.records,
      animals: animals ?? this.animals,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    isLoading,
    ailments,
    filteredAilments,
    records,
    animals,
    searchQuery,
    errorMessage,
  ];
}
