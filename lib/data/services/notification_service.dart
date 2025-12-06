import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Encapsulates Firebase Cloud Messaging initialization and helpers.
class NotificationService {
  NotificationService({FirebaseMessaging? messaging}) : _messaging = messaging;

  FirebaseMessaging? _messaging;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    try {
      _messaging ??= FirebaseMessaging.instance;
      await _messaging!.requestPermission();
      if (!kIsWeb) {
        await _messaging!.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
      _initialized = true;
    } catch (error, stackTrace) {
      debugPrint('NotificationService: Firebase Messaging disabled ($error)');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  FirebaseMessaging get _client {
    final FirebaseMessaging? messaging = _messaging;
    if (messaging == null) {
      throw StateError('NotificationService.initialize must be called first.');
    }
    return messaging;
  }

  Future<String?> getToken() => _initialized ? _client.getToken() : Future<String?>.value();

  Future<void> subscribeToTopic(String topic) =>
      _initialized ? _client.subscribeToTopic(topic) : Future<void>.value();

  Future<void> unsubscribeFromTopic(String topic) =>
      _initialized ? _client.unsubscribeFromTopic(topic) : Future<void>.value();

  Stream<RemoteMessage> get onForegroundMessage =>
      _initialized ? FirebaseMessaging.onMessage : const Stream<RemoteMessage>.empty();

  Stream<RemoteMessage> get onMessageOpenedApp =>
      _initialized ? FirebaseMessaging.onMessageOpenedApp : const Stream<RemoteMessage>.empty();
}
