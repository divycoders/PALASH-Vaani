import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_badge.dart';

class TranslatorScreen extends StatefulWidget {
  const TranslatorScreen({super.key});

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> {
  final TextEditingController _inputController = TextEditingController(text: 'नमस्ते, आप कैसे हैं?');
  String _translatedText = 'ᱡᱚᱦᱟᱨ, ᱟᱢ ᱪᱮᱫ ᱞᱮᱠᱟ ᱢᱮᱱᱟᱢᱟ?';
  String _sourceLang = 'Hindi';
  String _targetLang = 'Santhali (Ol Chiki)';

  void _swapLanguages() {
    setState(() {
      final temp = _sourceLang;
      _sourceLang = _targetLang;
      _targetLang = temp;
      final tempText = _inputController.text;
      _inputController.text = _translatedText;
      _translatedText = tempText;
    });
  }

  void _translate() {
    // Prototype demonstration translation
    setState(() {
      if (_inputController.text.trim().isEmpty) {
        _translatedText = '';
        return;
      }
      if (_sourceLang.startsWith('Hindi')) {
        _translatedText = 'ᱡᱚᱦᱟᱨ (Demo Santhali Translation)';
      } else {
        _translatedText = 'नमस्ते (डेमो हिंदी अनुवाद)';
      }
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner clearly marking demo translation status
          AppCard(
            backgroundColor: AppColors.tertiaryContainer.withValues(alpha: 0.3),
            borderColor: AppColors.tertiary.withValues(alpha: 0.4),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.tertiary, size: 20),
                const SizedBox(width: AppSpacing.sm),
                const Expanded(
                  child: Text(
                    'DEMO TRANSLATION • Real IndicTrans2 model integrates in Milestones 8–10',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Language Switcher Bar
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _sourceLang,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.swap_horiz, color: AppColors.primary),
                  tooltip: 'Swap Languages',
                  onPressed: _swapLanguages,
                ),
                Expanded(
                  child: Text(
                    _targetLang,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Source Input Box
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Input ($_sourceLang)',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                    ),
                    if (_inputController.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _inputController.clear();
                          setState(() => _translatedText = '');
                        },
                        child: const Text('Clear', style: TextStyle(fontSize: 12, color: AppColors.primary)),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _inputController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Type or paste sentence here...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(AppSpacing.md),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.mic, color: AppColors.primary),
                      tooltip: 'Microphone (Voice ASR in M11)',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('ASR Voice recognition opens in Milestone 11')),
                        );
                      },
                    ),
                    AppButton(
                      label: 'Translate',
                      icon: Icons.translate,
                      onPressed: _translate,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Output Translation Box
          AppCard(
            backgroundColor: AppColors.surface,
            borderColor: AppColors.primary.withValues(alpha: 0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    Text(
                      'Translation ($_targetLang)',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                    ),
                    StatusBadge.prototype(),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 80),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: AppSpacing.roundedSm,
                  ),
                  child: Text(
                    _translatedText.isEmpty ? 'Translation will appear here' : _translatedText,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: _translatedText.isEmpty ? AppColors.textMuted : AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.copy, size: 20),
                      tooltip: 'Copy text',
                      onPressed: _translatedText.isEmpty
                          ? null
                          : () {
                              Clipboard.setData(ClipboardData(text: _translatedText));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Copied to clipboard')),
                              );
                            },
                    ),
                    IconButton(
                      icon: const Icon(Icons.volume_up, size: 20),
                      tooltip: 'Pronunciation audio',
                      onPressed: _translatedText.isEmpty
                          ? null
                          : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Offline audio playback in Milestone 7')),
                              );
                            },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
