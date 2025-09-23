import 'dart:math' as math;

import '../../../data/models/animal.dart';

class GenealogyAnalysis {
  const GenealogyAnalysis({
    required this.generations,
    this.inbreedingCoefficient,
    this.ancestorOccurrences = const <String, int>{},
  });

  final List<List<Animal?>> generations;
  final double? inbreedingCoefficient;
  final Map<String, int> ancestorOccurrences;

  bool get hasRisk =>
      (inbreedingCoefficient ?? 0) >= 0.0625 ||
      ancestorOccurrences.values.any((int count) => count > 1);
}

class GenealogyAnalyzer {
  GenealogyAnalyzer(this.animalsById);

  final Map<String, Animal> animalsById;
  final Map<String, double> _inbreedingMemo = <String, double>{};

  GenealogyAnalysis analyze(String animalId, {int depth = 3}) {
    final List<List<Animal?>> generations = _buildGenerations(animalId, depth);
    final double? coefficient = _computeAnimalInbreeding(animalId);
    final Map<String, int> occurrences = _countOccurrences(generations);
    return GenealogyAnalysis(
      generations: generations,
      inbreedingCoefficient: coefficient,
      ancestorOccurrences: occurrences,
    );
  }

  double computePairCoefficient(String? firstId, String? secondId,
      {int maxDepth = 5, Set<String>? pedigreeStack}) {
    if (firstId == null || secondId == null) {
      return 0;
    }
    final Map<String, List<int>> ancestorsA =
        _ancestorPaths(firstId, maxDepth: maxDepth);
    final Map<String, List<int>> ancestorsB =
        _ancestorPaths(secondId, maxDepth: maxDepth);

    double coefficient = 0;
    final Set<String> common = ancestorsA.keys
        .toSet()
        .intersection(ancestorsB.keys.toSet());
    for (final String ancestorId in common) {
      final double ancestorInbreeding =
          _computeInbreedingForAncestor(
        ancestorId,
        maxDepth: maxDepth,
        stack: <String>{...pedigreeStack ?? <String>{}},
      );
      for (final int depthA in ancestorsA[ancestorId]!) {
        for (final int depthB in ancestorsB[ancestorId]!) {
          coefficient += math.pow(0.5, depthA + depthB + 1) *
              (1 + ancestorInbreeding);
        }
      }
    }

    return coefficient;
  }

  double? _computeAnimalInbreeding(String animalId) {
    final Animal? animal = animalsById[animalId];
    if (animal == null) {
      return null;
    }
    if (animal.sireId == null || animal.damId == null) {
      return 0;
    }
    return computePairCoefficient(
      animal.sireId,
      animal.damId,
      pedigreeStack: <String>{animalId},
    );
  }

  double _computeInbreedingForAncestor(String ancestorId,
      {int maxDepth = 5, Set<String>? stack}) {
    if (_inbreedingMemo.containsKey(ancestorId)) {
      return _inbreedingMemo[ancestorId]!;
    }
    if (stack != null && stack.contains(ancestorId)) {
      return 0;
    }
    final Animal? ancestor = animalsById[ancestorId];
    if (ancestor == null || ancestor.sireId == null || ancestor.damId == null) {
      _inbreedingMemo[ancestorId] = 0;
      return 0;
    }
    final Set<String> nextStack = <String>{...stack ?? <String>{}, ancestorId};
    final double value = computePairCoefficient(
      ancestor.sireId,
      ancestor.damId,
      maxDepth: maxDepth,
      pedigreeStack: nextStack,
    );
    _inbreedingMemo[ancestorId] = value;
    return value;
  }

  Map<String, List<int>> _ancestorPaths(String? origin,
      {int maxDepth = 5}) {
    final Map<String, List<int>> result = <String, List<int>>{};

    void visit(String? currentId, int depth, Set<String> visitedPath) {
      if (currentId == null || depth > maxDepth) {
        return;
      }
      if (visitedPath.contains(currentId)) {
        return;
      }
      final Animal? current = animalsById[currentId];
      if (current == null) {
        return;
      }
      if (depth > 0) {
        result.putIfAbsent(currentId, () => <int>[]).add(depth);
      }
      final Set<String> nextPath = <String>{...visitedPath, currentId};
      visit(current.sireId, depth + 1, nextPath);
      visit(current.damId, depth + 1, nextPath);
    }

    visit(origin, 0, <String>{});
    result.remove(origin);
    return result;
  }

  List<List<Animal?>> _buildGenerations(String animalId, int depth) {
    final List<List<Animal?>> generations = <List<Animal?>>[];
    final Animal? root = animalsById[animalId];
    generations.add(<Animal?>[root]);
    List<Animal?> previous = <Animal?>[root];

    for (int level = 1; level <= depth; level++) {
      final List<Animal?> current = <Animal?>[];
      for (final Animal? animal in previous) {
        if (animal == null) {
          current..add(null)..add(null);
          continue;
        }
        current.add(
          animal.sireId != null ? animalsById[animal.sireId!] : null,
        );
        current.add(
          animal.damId != null ? animalsById[animal.damId!] : null,
        );
      }
      if (current.every((Animal? value) => value == null)) {
        break;
      }
      generations.add(current);
      previous = current;
    }

    return generations;
  }

  Map<String, int> _countOccurrences(List<List<Animal?>> generations) {
    final Map<String, int> occurrences = <String, int>{};
    for (final List<Animal?> generation in generations) {
      for (final Animal? ancestor in generation) {
        if (ancestor == null) {
          continue;
        }
        occurrences.update(ancestor.id, (int value) => value + 1,
            ifAbsent: () => 1);
      }
    }
    return occurrences;
  }
}