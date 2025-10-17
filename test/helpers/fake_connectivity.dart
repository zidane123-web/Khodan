import 'dart:async';

import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';

class FakeConnectivityPlatform extends ConnectivityPlatform {
  FakeConnectivityPlatform({List<ConnectivityResult>? initialResult})
    : _current =
          initialResult ?? const <ConnectivityResult>[ConnectivityResult.none];

  List<ConnectivityResult> _current;
  final StreamController<List<ConnectivityResult>> _controller =
      StreamController<List<ConnectivityResult>>.broadcast();

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => _current;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _controller.stream;

  void setResult(List<ConnectivityResult> results) {
    _current = results;
    _controller.add(results);
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}
