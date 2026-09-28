import 'package:flutter/material.dart';
import '../services/connectivity_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Interactive Network Status Indicator for the application shell.
/// Displays live Offline/Online badge with explanation of local-first execution.
class NetworkStatusIndicator extends StatelessWidget {
  final IConnectivityService connectivityService;

  const NetworkStatusIndicator({
    super.key,
    required this.connectivityService,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppNetworkStatus>(
      stream: connectivityService.onStatusChanged,
      initialData: connectivityService.currentStatus,
      builder: (context, snapshot) {
        final status = snapshot.data ?? AppNetworkStatus.offline;
        final isOffline = status == AppNetworkStatus.offline;

        final badgeColor = isOffline ? AppColors.offline : AppColors.online;
        final badgeText = isOffline ? 'Offline' : 'Online';

        return Tooltip(
          message: isOffline
              ? 'Device is offline. Local-first pedagogy active.'
              : 'Device has network connection. Local-first pedagogy active.',
          child: InkWell(
            onTap: () => _showConnectivityDialog(context, status),
            borderRadius: AppSpacing.roundedPill,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.12),
                borderRadius: AppSpacing.roundedPill,
                border: Border.all(
                  color: badgeColor.withValues(alpha: 0.4),
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.circle,
                    size: 8,
                    color: badgeColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    badgeText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: badgeColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showConnectivityDialog(BuildContext context, AppNetworkStatus status) {
    final isOffline = status == AppNetworkStatus.offline;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: AppSpacing.roundedLg,
          ),
          title: Row(
            children: [
              Icon(
                isOffline ? Icons.cloud_off : Icons.cloud_done,
                color: isOffline ? AppColors.offline : AppColors.online,
              ),
              const SizedBox(width: AppSpacing.sm),
              const Flexible(
                child: Text('Offline-First Architecture'),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Device Network: ',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    TextSpan(
                      text: isOffline ? 'Offline (No Connection)' : 'Online (Active Connection)',
                      style: TextStyle(
                        color: isOffline ? AppColors.offline : AppColors.online,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'PALASH-Vaani (पलाश-वाणी) is architected for strict on-device execution in rural and low-connectivity classrooms.\n\n'
                '• All lesson data is retrieved from local SQLite storage.\n'
                '• Audio, intent matching, and translation run on-device.\n'
                '• Zero data is transmitted to cloud APIs or external servers.',
                style: TextStyle(fontSize: 13, height: 1.45),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Understood'),
            ),
          ],
        );
      },
    );
  }
}
