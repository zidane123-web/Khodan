import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Base contract implemented by [ApiClient] to ease mocking in tests.
abstract class ApiExecutor {
  SupabaseClient get client;

  Future<T> run<T>(
    Future<T> Function(SupabaseClient client) operation, {
    String? label,
  });
}

/// Wraps Supabase calls with shared error handling, logging and retry logic.
class ApiClient implements ApiExecutor {
  ApiClient({
    SupabaseClient? client,
    this.maxRetries = 1,
    this.retryDelay = const Duration(milliseconds: 200),
  }) : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  final int maxRetries;
  final Duration retryDelay;

  @override
  SupabaseClient get client => _client;

  @override
  Future<T> run<T>(
    Future<T> Function(SupabaseClient client) operation, {
    String? label,
  }) async {
    int retries = 0;
    while (true) {
      try {
        return await operation(_client);
      } on PostgrestException catch (error, stackTrace) {
        _logError(label ?? 'supabase', 'PostgrestException', error, stackTrace);
        final String message = error.message.trim().isEmpty
            ? 'An unexpected Supabase error occurred.'
            : error.message;
        throw DataLayerException(
          message,
          code: error.code,
          details: error.details,
          hint: error.hint,
          cause: error,
        );
      } on TimeoutException catch (error, stackTrace) {
        if (retries < maxRetries) {
          retries += 1;
          await Future<void>.delayed(retryDelay * retries);
          continue;
        }
        _logError(label ?? 'supabase', 'TimeoutException', error, stackTrace);
        throw DataLayerException(
          'Request timed out after ${retries + 1} attempt(s).',
          cause: error,
        );
      } catch (error, stackTrace) {
        if (error is DataLayerException) {
          rethrow;
        }
        _logError(label ?? 'supabase', 'Unexpected', error, stackTrace);
        throw DataLayerException(error.toString(), cause: error);
      }
    }
  }

  void _logError(
    String label,
    String type,
    Object error,
    StackTrace stackTrace,
  ) {
    if (kDebugMode) {
      debugPrint('[$label][$type] $error');
      debugPrint(stackTrace.toString());
    }
  }

  static String encodeDate(DateTime dateTime) =>
      dateTime.toUtc().toIso8601String();
}

/// Normalised exception thrown by the data layer.
class DataLayerException implements Exception {
  DataLayerException(
    this.message, {
    this.code,
    this.details,
    this.hint,
    this.cause,
  });

  final String message;
  final String? code;
  final Object? details;
  final String? hint;
  final Object? cause;

  @override
  String toString() {
    final StringBuffer buffer = StringBuffer('DataLayerException: $message');
    if (code != null) {
      buffer.write(' (code: $code)');
    }
    if (hint != null) {
      buffer.write(' - $hint');
    }
    return buffer.toString();
  }
}
