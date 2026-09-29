import 'package:flutter/material.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback? onComplete;

  const OnboardingScreen({super.key, this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _slides = [
    {
      'title': 'पलाश-वाणी (PALASH-Vaani)',
      'subtitle': 'मातृभाषा आधारित प्राथमिक बहुभाषी शिक्षण (MTB-MLE)',
      'description':
          'झारखंड के जनजातीय क्षेत्रों के प्राथमिक विद्यालयों के लिए समर्पित मंच। हिंदी भाषी शिक्षकों और संथाली, हो व मुंडारी भाषी बच्चों के बीच सीखने की दूरी को मिटाना।',
      'icon': Icons.school_rounded,
      'isLogo': true,
      'badge': 'PALASH FLN • SIH 2026 (ID: 26042)',
    },
    {
      'title': 'कक्षा ध्वनि सेतु (Real-Time Voice Bridge)',
      'subtitle': 'हिंदी, अंग्रेज़ी व हिंग्लिश से जनजातीय अनुवाद',
      'description':
          'शिक्षक स्वाभाविक रूप से बोलें या निर्देश दें—ऐप तुरंत संथाली (ओल चिकी), हो और मुंडारी में अनुवाद और शुद्ध स्थानीय ऑडियो उच्चारण प्रस्तुत करता है।',
      'icon': Icons.record_voice_over_rounded,
      'isLogo': false,
      'badge': 'सब-3 से. त्वरित संवाद (Sub-50ms)',
    },
    {
      'title': 'दोहरी-लिपि व बाल प्रश्नोत्तरी (FLN Tools)',
      'subtitle': 'ओल चिकी लिपि + देवनागरी ध्वन्यात्मक मार्गदर्शिका',
      'description':
          'गैर-जनजातीय शिक्षकों के लिए बोलने में सहजता, बच्चों के लिए असीमित दैनिक गणित व भाषा प्रश्नोत्तरी, और 1-क्लिक ऑफ़लाइन प्रिंटेबल वर्कशीट्स।',
      'icon': Icons.auto_stories_rounded,
      'isLogo': false,
      'badge': 'FLN गणित, भाषा व पर्यावरण',
    },
    {
      'title': '100% ऑफ़लाइन व सुरक्षित (Offline-First)',
      'subtitle': 'कम लागत वाले टैबलेट्स (≤2GB RAM) पर तीव्र संचालन',
      'description':
          'बिना इंटरनेट या सिम कार्ड के दूरदराज के जंगलों और गांवों के स्कूलों में पूरी तरह से कार्यशील। सारा डेटा और पाठ्यचर्या स्थानीय डिवाइस पर सुरक्षित।',
      'icon': Icons.offline_bolt_rounded,
      'isLogo': false,
      'badge': 'जीरो क्लाउड निर्भरता • शून्य लैग',
    },
  ];

  Future<void> _completeOnboarding() async {
    await DatabaseHelper.instance.setOnboardingCompleted(completed: true);
    if (!mounted) return;
    if (widget.onComplete != null) {
      widget.onComplete!();
    } else {
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _completeOnboarding,
            child: const Text(
              'छोड़ें (Skip)',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? AppSpacing.xxl : AppSpacing.xl,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (slide['isLogo'] == true) ...[
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Image.asset(
                                'assets/images/app_logo.png',
                                width: isTablet ? 200 : 160,
                                height: isTablet ? 200 : 160,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  width: 160,
                                  height: 160,
                                  color: AppColors.primaryContainer,
                                  child: const Icon(Icons.school, size: 80, color: AppColors.primary),
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
                          Container(
                            width: isTablet ? 150 : 120,
                            height: isTablet ? 150 : 120,
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
                            ),
                            child: Icon(
                              slide['icon'] as IconData,
                              size: isTablet ? 72 : 56,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.xl),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            slide['badge'] as String,
                            style: const TextStyle(
                              color: AppColors.primaryDark,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          slide['title'] as String,
                          style: TextStyle(
                            fontSize: isTablet ? 24 : 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          slide['subtitle'] as String,
                          style: TextStyle(
                            fontSize: isTablet ? 15 : 13.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 500),
                          child: Text(
                            slide['description'] as String,
                            style: const TextStyle(
                              fontSize: 13.5,
                              color: AppColors.textSecondary,
                              height: 1.45,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Navigation & Dots
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? AppSpacing.xxl : AppSpacing.xl,
                vertical: AppSpacing.lg,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page Indicators
                  Row(
                    children: List.generate(
                      _slides.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(right: 6),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primary
                              : AppColors.primaryLight.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  // Next / Start Button
                  ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currentPage == _slides.length - 1
                              ? 'कक्षा शुरू करें (Start)'
                              : 'आगे बढ़ें (Next)',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

