import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_badge.dart';

class DiagnosticsScreen extends StatelessWidget {
  const DiagnosticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          AppCard(
            leading: const Icon(Icons.analytics, color: AppColors.offline, size: 28),
            title: 'System Diagnostics & Telemetry',
            subtitle: 'सिस्टम स्थिति और हार्डवेयर निदान • Milestone 17 Target',
            trailing: StatusBadge.offline(),
            child: const Text(
              'Hardware readiness and engine diagnostics for rural, low-resource deployment on target Android ~2 GB devices.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Core System Status Table
          Text(
            'Subsystem Architecture Status',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),

          AppCard(
            child: Column(
              children: [
                _buildDiagnosticRow(
                  title: 'Network Mode',
                  subtitle: 'Strict local execution, no cloud APIs',
                  status: 'Local Only',
                  statusColor: AppColors.offline,
                ),
                const Divider(),
                _buildDiagnosticRow(
                  title: 'Flutter Foundation',
                  subtitle: 'Theme, routing, responsive shell',
                  status: 'Active (M1)',
                  statusColor: AppColors.success,
                ),
                const Divider(),
                _buildDiagnosticRow(
                  title: 'Curriculum Database',
                  subtitle: 'Local SQLite curriculum storage',
                  status: 'Pending (M3)',
                  statusColor: AppColors.warning,
                ),
                const Divider(),
                _buildDiagnosticRow(
                  title: 'Classroom Intent Engine',
                  subtitle: 'Normalized rule-based matcher',
                  status: 'Pending (M6)',
                  statusColor: AppColors.warning,
                ),
                const Divider(),
                _buildDiagnosticRow(
                  title: 'Translation Engine',
                  subtitle: 'IndicTrans2 / Demo fallback',
                  status: 'Demo Mode (M8)',
                  statusColor: AppColors.tertiary,
                ),
                const Divider(),
                _buildDiagnosticRow(
                  title: 'Speech Recognition (ASR)',
                  subtitle: 'Hindi & Santhali speech input',
                  status: 'Pending (M11)',
                  statusColor: AppColors.warning,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Latency & Benchmark Metrics Card
          Text(
            'Hardware Telemetry & Benchmarks',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'Note: Live hardware profiling and latency timers will be hooked up in Milestone 17 & 19.',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.sm),

          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Target Hardware Profile:', style: TextStyle(fontWeight: FontWeight.bold)),
                    StatusBadge(label: 'Android 9+ (2 GB RAM)', color: AppColors.offline),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  '• ASR Latency: [Measurement connects in M11]\n'
                  '• Intent Matching Latency: [Measurement connects in M6]\n'
                  '• Translation Latency: [Measurement connects in M9/M10]\n'
                  '• Total Pipeline Latency: [Benchmark target ≤ 3.0s in M19]\n'
                  '• RAM Consumption: [Hardware profiler in M19]',
                  style: TextStyle(fontSize: 13, height: 1.6, fontFamily: 'monospace'),
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: 'Run Diagnostic Check',
                  icon: Icons.refresh,
                  variant: AppButtonVariant.outlined,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Hardware diagnostic runner will be implemented in Milestone 17')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticRow({
    required String title,
    required String subtitle,
    required String status,
    required Color statusColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                Text(subtitle, style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
              ],
            ),
          ),
          StatusBadge(label: status, color: statusColor),
        ],
      ),
    );
  }
}
