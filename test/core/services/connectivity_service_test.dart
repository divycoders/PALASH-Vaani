import 'package:flutter_test/flutter_test.dart';
import 'package:palash_vaani/core/services/connectivity_service.dart';

void main() {
  group('MockConnectivityService Tests', () {
    late MockConnectivityService service;

    setUp(() {
      service = MockConnectivityService(initialStatus: AppNetworkStatus.offline);
    });

    tearDown(() {
      service.dispose();
    });

    test('Initial state is offline', () async {
      expect(service.currentStatus, AppNetworkStatus.offline);
      expect(service.isOffline, isTrue);
      expect(service.isOnline, isFalse);

      final checked = await service.checkStatus();
      expect(checked, AppNetworkStatus.offline);
    });

    test('Status updates correctly to online and emits to stream', () async {
      final statuses = <AppNetworkStatus>[];
      final subscription = service.onStatusChanged.listen(statuses.add);

      service.setStatus(AppNetworkStatus.online);

      // Give stream controller microtask time
      await Future<void>.delayed(Duration.zero);

      expect(service.currentStatus, AppNetworkStatus.online);
      expect(service.isOffline, isFalse);
      expect(service.isOnline, isTrue);
      expect(statuses, [AppNetworkStatus.online]);

      // Update back to offline
      service.setStatus(AppNetworkStatus.offline);
      await Future<void>.delayed(Duration.zero);

      expect(service.currentStatus, AppNetworkStatus.offline);
      expect(service.isOffline, isTrue);
      expect(statuses, [AppNetworkStatus.online, AppNetworkStatus.offline]);

      await subscription.cancel();
    });

    test('Setting same status does not duplicate stream event', () async {
      final statuses = <AppNetworkStatus>[];
      final subscription = service.onStatusChanged.listen(statuses.add);

      service.setStatus(AppNetworkStatus.offline);
      await Future<void>.delayed(Duration.zero);

      expect(statuses, isEmpty);

      await subscription.cancel();
    });
  });
}
