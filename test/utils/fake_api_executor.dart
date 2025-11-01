import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:khodan/data/services/api_client.dart';

/// Simple synchronous fake used to stub Supabase calls in unit/widget tests.
class FakeApiExecutor implements ApiExecutor {
  FakeApiExecutor({required Map<String, dynamic> responses})
    : _responses = Map<String, dynamic>.from(responses);

  final Map<String, dynamic> _responses;

  @override
  SupabaseClient get client =>
      throw UnimplementedError('FakeApiExecutor does not expose a client.');

  @override
  Future<T> run<T>(
    Future<T> Function(SupabaseClient client) operation, {
    String? label,
  }) async {
    if (!_responses.containsKey(label)) {
      throw StateError('No fake response registered for label $label');
    }
    final dynamic value = _responses[label];
    if (value is Future<T>) {
      return value;
    }
    if (value is Future<dynamic>) {
      return value.then((dynamic resolved) => resolved as T);
    }
    return value as T;
  }
}
