import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:khodan/data/services/api_client.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  late SupabaseClient mockClient;
  late ApiClient apiClient;

  setUp(() {
    mockClient = _MockSupabaseClient();
    apiClient = ApiClient(client: mockClient, maxRetries: 0);
  });

  test('run returns the result of the operation', () async {
    final int result = await apiClient.run<int>(
      (SupabaseClient _) async => 42,
      label: 'test.success',
    );
    expect(result, equals(42));
  });

  test('run wraps PostgrestException into DataLayerException', () async {
    final PostgrestException exception = PostgrestException(
      message: 'boom',
      details: null,
      hint: null,
      code: '400',
    );

    await expectLater(
      apiClient.run<void>(
        (SupabaseClient _) => throw exception,
        label: 'test.error',
      ),
      throwsA(
        isA<DataLayerException>()
            .having((DataLayerException e) => e.message, 'message', contains('boom'))
            .having((DataLayerException e) => e.code, 'code', '400'),
      ),
    );
  });

  test('run retries on TimeoutException and fails after max retries', () async {
    int attempts = 0;
    final ApiClient clientWithRetry = ApiClient(
      client: mockClient,
      maxRetries: 1,
      retryDelay: const Duration(milliseconds: 1),
    );

    await expectLater(
      clientWithRetry.run<void>(
        (SupabaseClient _) async {
          attempts += 1;
          throw TimeoutException('Timed out');
        },
        label: 'test.timeout',
      ),
      throwsA(isA<DataLayerException>().having(
        (DataLayerException e) => e.message,
        'message',
        contains('timed out'),
      )),
    );
    expect(attempts, equals(2)); // initial try + 1 retry
  });
}
