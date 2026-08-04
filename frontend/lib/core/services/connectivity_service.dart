import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ConnectionStatus { online, offline, poor }

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<ConnectionStatus> _controller = StreamController<ConnectionStatus>.broadcast();

  ConnectivityService() {
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.isEmpty || results.contains(ConnectivityResult.none)) {
        _controller.add(ConnectionStatus.offline);
      } else if (results.contains(ConnectivityResult.mobile) || results.contains(ConnectivityResult.wifi)) {
        _controller.add(ConnectionStatus.online);
      } else {
        _controller.add(ConnectionStatus.poor);
      }
    });
  }

  Stream<ConnectionStatus> get statusStream => _controller.stream;

  Future<ConnectionStatus> checkCurrentStatus() async {
    final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return ConnectionStatus.offline;
    } else if (results.contains(ConnectivityResult.mobile) || results.contains(ConnectivityResult.wifi)) {
      return ConnectionStatus.online;
    }
    return ConnectionStatus.poor;
  }
}

final Provider<ConnectivityService> connectivityServiceProvider = Provider<ConnectivityService>((Ref ref) {
  return ConnectivityService();
});

final StreamProvider<ConnectionStatus> connectivityStatusProvider = StreamProvider<ConnectionStatus>((Ref ref) {
  final ConnectivityService service = ref.watch(connectivityServiceProvider);
  return service.statusStream;
});
