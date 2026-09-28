import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Network status for PALASH-Vaani application
enum AppNetworkStatus {
  online,
  offline,
}

/// Abstract contract for network connectivity monitoring
abstract class IConnectivityService {
  Stream<AppNetworkStatus> get onStatusChanged;
  Future<AppNetworkStatus> checkStatus();
  AppNetworkStatus get currentStatus;
  bool get isOffline;
  bool get isOnline;
  void dispose();
}

/// Production implementation using connectivity_plus platform plugin
class ConnectivityService implements IConnectivityService {
  final Connectivity _connectivity;
  final StreamController<AppNetworkStatus> _statusController =
      StreamController<AppNetworkStatus>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  AppNetworkStatus _currentStatus = AppNetworkStatus.offline;

  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity() {
    _init();
  }

  void _init() {
    _subscription = _connectivity.onConnectivityChanged.listen(_handleResults);
    // Initial async status probe
    checkStatus();
  }

  void _handleResults(List<ConnectivityResult> results) {
    final status = _mapResultsToStatus(results);
    if (status != _currentStatus) {
      _currentStatus = status;
      _statusController.add(_currentStatus);
    }
  }

  AppNetworkStatus _mapResultsToStatus(List<ConnectivityResult> results) {
    if (results.isEmpty ||
        (results.length == 1 && results.contains(ConnectivityResult.none))) {
      return AppNetworkStatus.offline;
    }
    final hasActiveNetwork = results.any((r) =>
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.ethernet ||
        r == ConnectivityResult.vpn);

    return hasActiveNetwork ? AppNetworkStatus.online : AppNetworkStatus.offline;
  }

  @override
  Stream<AppNetworkStatus> get onStatusChanged => _statusController.stream;

  @override
  Future<AppNetworkStatus> checkStatus() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _currentStatus = _mapResultsToStatus(results);
      return _currentStatus;
    } catch (_) {
      // In case of any platform exception, fail-safe to offline mode
      _currentStatus = AppNetworkStatus.offline;
      return _currentStatus;
    }
  }

  @override
  AppNetworkStatus get currentStatus => _currentStatus;

  @override
  bool get isOffline => _currentStatus == AppNetworkStatus.offline;

  @override
  bool get isOnline => _currentStatus == AppNetworkStatus.online;

  @override
  void dispose() {
    _subscription?.cancel();
    _statusController.close();
  }
}

/// Mock connectivity service for unit testing and deterministic offline scenarios
class MockConnectivityService implements IConnectivityService {
  AppNetworkStatus _currentStatus;
  final StreamController<AppNetworkStatus> _controller =
      StreamController<AppNetworkStatus>.broadcast();

  MockConnectivityService({AppNetworkStatus initialStatus = AppNetworkStatus.offline})
      : _currentStatus = initialStatus;

  void setStatus(AppNetworkStatus status) {
    if (_currentStatus != status) {
      _currentStatus = status;
      _controller.add(_currentStatus);
    }
  }

  @override
  Stream<AppNetworkStatus> get onStatusChanged => _controller.stream;

  @override
  Future<AppNetworkStatus> checkStatus() async => _currentStatus;

  @override
  AppNetworkStatus get currentStatus => _currentStatus;

  @override
  bool get isOffline => _currentStatus == AppNetworkStatus.offline;

  @override
  bool get isOnline => _currentStatus == AppNetworkStatus.online;

  @override
  void dispose() {
    _controller.close();
  }
}
