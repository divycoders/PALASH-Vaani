import 'package:flutter/material.dart';
import '../services/audio_tts_service.dart';
import '../theme/app_colors.dart';

/// Natural Audio Playback Button
/// Granular audio control for classroom teachers and students:
/// - Plays natural, warm primary-educator speech for any lesson part
/// - Displays real-time animated waveform/pulsing indicator when active
/// - Supports instant tap-to-stop toggle behavior
class NaturalAudioButton extends StatelessWidget {
  final String textToSpeak;
  final String speakId;
  final String? label;
  final IconData icon;
  final double iconSize;
  final Color? color;
  final Color? backgroundColor;
  final bool isCompact;
  final String tooltip;

  const NaturalAudioButton({
    super.key,
    required this.textToSpeak,
    required this.speakId,
    this.label,
    this.icon = Icons.volume_up_rounded,
    this.iconSize = 18.0,
    this.color,
    this.backgroundColor,
    this.isCompact = false,
    this.tooltip = 'आवाज़ सुनें (Listen Audio)',
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: AudioTtsService.instance.currentPlayingIdNotifier,
      builder: (context, playingId, _) {
        final isPlayingThis = playingId == speakId;

        final effectiveColor = isPlayingThis
            ? Colors.red.shade700
            : (color ?? AppColors.primary);

        final effectiveBg = isPlayingThis
            ? Colors.red.shade50
            : (backgroundColor ?? (isCompact ? Colors.white : Colors.transparent));

        if (label != null) {
          return ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: isPlayingThis ? Colors.red.shade600 : (backgroundColor ?? AppColors.primary),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: isPlayingThis ? 3 : 1,
            ),
            onPressed: () {
              AudioTtsService.instance.speakClean(textToSpeak, id: speakId);
            },
            icon: Icon(
              isPlayingThis ? Icons.stop_circle_rounded : icon,
              size: iconSize + 2,
              color: Colors.white,
            ),
            label: Text(
              isPlayingThis ? 'रोकें (Stop)' : label!,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          );
        }

        if (isCompact) {
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                AudioTtsService.instance.speakClean(textToSpeak, id: speakId);
              },
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: effectiveBg,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isPlayingThis ? Colors.red.shade400 : AppColors.outlineVariant,
                    width: isPlayingThis ? 1.5 : 1.0,
                  ),
                  boxShadow: isPlayingThis
                      ? [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.25),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  isPlayingThis ? Icons.stop_circle_rounded : icon,
                  size: iconSize,
                  color: effectiveColor,
                ),
              ),
            ),
          );
        }

        return Tooltip(
          message: isPlayingThis ? 'रोकें (Stop Audio)' : tooltip,
          child: IconButton(
            iconSize: iconSize,
            color: effectiveColor,
            style: IconButton.styleFrom(
              backgroundColor: effectiveBg,
              padding: const EdgeInsets.all(6),
            ),
            icon: Icon(isPlayingThis ? Icons.stop_circle_rounded : icon),
            onPressed: () {
              AudioTtsService.instance.speakClean(textToSpeak, id: speakId);
            },
          ),
        );
      },
    );
  }
}
