import 'package:equatable/equatable.dart';

/// Simple data container used to preconfigure the animal list with
/// contextual filters coming from other parts of the application.
class AnimalQuickFilter extends Equatable {
  const AnimalQuickFilter({
    required this.label,
    this.sex,
    this.statusQuery,
    this.includeIds,
  });

  final String label;
  final String? sex;
  final String? statusQuery;
  final Set<String>? includeIds;

  @override
  List<Object?> get props => <Object?>[label, sex, statusQuery, includeIds];
}
