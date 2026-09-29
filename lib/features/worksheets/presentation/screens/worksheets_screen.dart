import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../models/worksheet_models.dart';
import '../../services/worksheet_pdf_generator.dart';

class WorksheetsScreen extends StatefulWidget {
  const WorksheetsScreen({super.key});

  @override
  State<WorksheetsScreen> createState() => _WorksheetsScreenState();
}

class _WorksheetsScreenState extends State<WorksheetsScreen> {
  String _selectedGrade = 'Grade 1';
  String _selectedSubjectFilter = 'All';
  late WorksheetTemplate _selectedTemplate;
  late TextEditingController _schoolNameController;

  bool _isDownloadingPdf = false;
  bool _isPrintingPdf = false;

  final List<String> _grades = ['Grade 1', 'Grade 2', 'Grade 3'];
  final List<String> _subjectFilters = [
    'All',
    'गणित (Maths)',
    'भाषा (Language)',
    'पर्यावरण (EVS)',
  ];

  @override
  void initState() {
    super.initState();
    _selectedTemplate = WorksheetRepository.allTemplates.first;
    _schoolNameController = TextEditingController(
      text: 'राजकीय उत्क्रमित प्राथमिक विद्यालय, दुमका (PALASH MTB-MLE)',
    );
  }

  @override
  void dispose() {
    _schoolNameController.dispose();
    super.dispose();
  }

  List<WorksheetTemplate> get _filteredTemplates {
    return WorksheetRepository.allTemplates.where((t) {
      final matchesGrade = t.grade == _selectedGrade;
      if (!matchesGrade) return false;
      if (_selectedSubjectFilter == 'All') return true;
      if (_selectedSubjectFilter.startsWith('गणित') && t.subject.contains('गणित')) return true;
      if (_selectedSubjectFilter.startsWith('भाषा') && t.subject.contains('भाषा')) return true;
      if (_selectedSubjectFilter.startsWith('पर्यावरण') && t.subject.contains('पर्यावरण')) return true;
      return false;
    }).toList();
  }

  Future<void> _downloadOrSharePdf() async {
    setState(() => _isDownloadingPdf = true);
    try {
      await WorksheetPdfGenerator.instance.shareOrDownloadWorksheet(
        template: _selectedTemplate,
        schoolName: _schoolNameController.text.trim().isEmpty
            ? 'राजकीय उत्क्रमित प्राथमिक विद्यालय (PALASH MTB-MLE)'
            : _schoolNameController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.success,
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    '✓ कार्यपत्रक PDF सफलतापूर्वक तैयार! (${_selectedTemplate.titleHindi})',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text('PDF जनरेट करने में त्रुटि: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloadingPdf = false);
      }
    }
  }

  Future<void> _printPdf() async {
    setState(() => _isPrintingPdf = true);
    try {
      await WorksheetPdfGenerator.instance.printWorksheet(
        template: _selectedTemplate,
        schoolName: _schoolNameController.text.trim().isEmpty
            ? 'राजकीय उत्क्रमित प्राथमिक विद्यालय (PALASH MTB-MLE)'
            : _schoolNameController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.primary,
            content: Text('प्रिंटर / PDF प्रीव्यू विंडो खुल गई है।'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text('प्रिंट करने में त्रुटि: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPrintingPdf = false);
      }
    }
  }

  void _showFullScreenPreview() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedLg),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 650),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dialog Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.picture_as_pdf, color: Colors.white, size: 22),
                    const SizedBox(width: AppSpacing.sm),
                    const Expanded(
                      child: Text(
                        'पूर्ण A4 कार्यपत्रक पूर्वावलोकन (Full Preview)',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              // Scrollable Sheet Body
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: _buildA4PaperPreview(isFullScreen: true),
                ),
              ),
              // Dialog Footer Action
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'डाउनलोड / शेयर PDF',
                        icon: Icons.download_rounded,
                        onPressed: () {
                          Navigator.pop(ctx);
                          _downloadOrSharePdf();
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppButton(
                        label: 'प्रिंट करें',
                        icon: Icons.print_rounded,
                        variant: AppButtonVariant.outlined,
                        onPressed: () {
                          Navigator.pop(ctx);
                          _printPdf();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -------------------------------------------------------------
          // 1. Hero Header Banner
          // -------------------------------------------------------------
          AppCard(
            backgroundColor: AppColors.primaryContainer.withValues(alpha: 0.35),
            borderColor: AppColors.primaryLight.withValues(alpha: 0.4),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: AppSpacing.roundedMd,
                      ),
                      child: const Icon(
                        Icons.description,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'द्विभाषी प्राथमिक कार्यपत्रक जनरेटर',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          const Text(
                            'Offline MTB-MLE Worksheet Engine • JCERT & PALASH FLN',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Wrap(
                            spacing: AppSpacing.xs,
                            runSpacing: AppSpacing.xs,
                            children: [
                              StatusBadge.offline(),
                              const StatusBadge(label: '100% Offline Engine', color: AppColors.success),
                              const StatusBadge(label: 'Hindi ⇄ Santhali (Ol Chiki)', color: AppColors.tagLanguage),
                              const StatusBadge(label: 'A4 Printable', color: AppColors.tagMath),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'ग्रामीण व जनजातीय प्राथमिक विद्यालयों के लिए उच्च-गुणवत्ता मुद्रण-योग्य द्विभाषी अभ्यास पत्रक। बिना इंटरनेट, सीधे डिवाइस पर तीव्र जनरेशन।',
                  style: TextStyle(fontSize: 12.5, height: 1.4, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // -------------------------------------------------------------
          // 2. Customization & Filter Controls Card
          // -------------------------------------------------------------
          AppCard(
            title: 'कार्यपत्रक चयन एवं विद्यालय विवरण (Worksheet Settings)',
            subtitle: 'कक्षा, विषय व अपने विद्यालय का नाम दर्ज करें',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // School Name Input
                TextFormField(
                  controller: _schoolNameController,
                  decoration: InputDecoration(
                    labelText: 'विद्यालय का नाम (School Name for Header)',
                    hintText: 'उदा. राजकीय प्राथमिक विद्यालय...',
                    prefixIcon: const Icon(Icons.school_outlined, color: AppColors.primary),
                    border: OutlineInputBorder(borderRadius: AppSpacing.roundedSm),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  onChanged: (val) => setState(() {}),
                ),

                const SizedBox(height: AppSpacing.md),

                // Grade Selector Pills
                const Text(
                  'कक्षा का चयन करें (Select Grade):',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: _grades.map((grade) {
                    final isSelected = _selectedGrade == grade;
                    return ChoiceChip(
                      label: Text(
                        grade == 'Grade 1' ? 'Grade 1 (बालवाटिका / १)' : grade,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surfaceVariant,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedGrade = grade;
                            final available = _filteredTemplates;
                            if (available.isNotEmpty) {
                              _selectedTemplate = available.first;
                            }
                          });
                        }
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: AppSpacing.md),

                // Subject Filter Tabs
                const Text(
                  'विषय फ़िल्टर (Subject Filter):',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: _subjectFilters.map((sub) {
                    final isSelected = _selectedSubjectFilter == sub;
                    return FilterChip(
                      label: Text(
                        sub,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.secondary,
                      backgroundColor: AppColors.surfaceVariant,
                      checkmarkColor: Colors.white,
                      onSelected: (selected) {
                        setState(() {
                          _selectedSubjectFilter = sub;
                          final available = _filteredTemplates;
                          if (available.isNotEmpty && !available.contains(_selectedTemplate)) {
                            _selectedTemplate = available.first;
                          }
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: AppSpacing.md),

                // Worksheet Template Cards Selector
                const Text(
                  'उपलब्ध अभ्यास कार्यपत्रक (Select Worksheet Topic):',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.xs),
                ..._filteredTemplates.map((template) {
                  final isSelected = _selectedTemplate.id == template.id;
                  Color subjectColor = AppColors.tagMath;
                  if (template.subject.contains('भाषा')) subjectColor = AppColors.tagLanguage;
                  if (template.subject.contains('पर्यावरण')) subjectColor = AppColors.tagScience;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: InkWell(
                      onTap: () {
                        setState(() => _selectedTemplate = template);
                      },
                      borderRadius: AppSpacing.roundedSm,
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryContainer.withValues(alpha: 0.25) : AppColors.surface,
                          borderRadius: AppSpacing.roundedSm,
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
                            width: isSelected ? 2.0 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 48,
                              decoration: BoxDecoration(
                                color: subjectColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: subjectColor.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          template.subject,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: subjectColor,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.success.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          template.nipunCode,
                                          style: const TextStyle(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.success,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.xxs),
                                  Text(
                                    template.titleHindi,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  Text(
                                    template.titleEnglish,
                                    style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                              color: isSelected ? AppColors.primary : AppColors.outline,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // -------------------------------------------------------------
          // 3. Prominent Action Bar (Download PDF & Print)
          // -------------------------------------------------------------
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppSpacing.roundedMd,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.picture_as_pdf, color: AppColors.primary, size: 24),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'A4 कार्यपत्रक डाउनलोड व प्रिंट',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark,
                              ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.fullscreen, color: AppColors.primary),
                      tooltip: 'फुलस्क्रीन देखें',
                      onPressed: _showFullScreenPreview,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: AppButton(
                        label: _isDownloadingPdf ? 'PDF तैयार हो रही है...' : 'डाउनलोड / शेयर PDF',
                        icon: Icons.download_rounded,
                        variant: AppButtonVariant.primary,
                        isLoading: _isDownloadingPdf,
                        onPressed: _isDownloadingPdf || _isPrintingPdf ? null : _downloadOrSharePdf,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      flex: 4,
                      child: AppButton(
                        label: _isPrintingPdf ? 'प्रिंटिंग...' : 'प्रिंट करें',
                        icon: Icons.print_outlined,
                        variant: AppButtonVariant.outlined,
                        isLoading: _isPrintingPdf,
                        onPressed: _isDownloadingPdf || _isPrintingPdf ? null : _printPdf,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // -------------------------------------------------------------
          // 4. Live A4 Paper Mockup Preview
          // -------------------------------------------------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'लाइव पूर्वावलोकन (Live Preview)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton.icon(
                onPressed: _showFullScreenPreview,
                icon: const Icon(Icons.zoom_in, size: 18),
                label: const Text('ज़ूम (Zoom)'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),

          // Paper Sheet Card
          _buildA4PaperPreview(isFullScreen: false),

          const SizedBox(height: AppSpacing.lg),

          // -------------------------------------------------------------
          // 5. PALASH MTB-MLE FLN Pedagogy Info Footer
          // -------------------------------------------------------------
          AppCard(
            backgroundColor: AppColors.surfaceVariant.withValues(alpha: 0.5),
            borderColor: AppColors.outlineVariant,
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.verified, color: AppColors.success, size: 18),
                    SizedBox(width: AppSpacing.xs),
                    Text(
                      'झारखंड शिक्षा परियोजना परिषद (JEPC) संरेखण',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  '• बुनियादी स्तर (FLN) पर मातृभाषा से मानक हिंदी की ओर स्वाभाविक भाषाई सेतु (Bilingual Bridge)।\n'
                  '• संथाली शब्दावली एवं ओल चिकी का सटीक देवनागरी उच्चारण मार्गदर्शन।\n'
                  '• 100% स्थानीय गणना व प्रिंटिंग — दूरस्थ संथाली बहुल विद्यालयों में इंटरनेट की आवश्यकता नहीं।',
                  style: TextStyle(fontSize: 12, height: 1.45, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds realistic A4 paper mockup matching the PDF
  Widget _buildA4PaperPreview({required bool isFullScreen}) {
    final schoolName = _schoolNameController.text.trim().isEmpty
        ? 'राजकीय उत्क्रमित प्राथमिक विद्यालय, दुमका (PALASH MTB-MLE)'
        : _schoolNameController.text.trim();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppSpacing.roundedSm,
        border: Border.all(color: AppColors.outlineVariant, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(isFullScreen ? AppSpacing.xl : AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Official Header Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFE65100), width: 1.5),
            ),
            child: Row(
              children: [
                // Seal Badge
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFE65100),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'पलाश\nवाणी',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    children: const [
                      Text(
                        'झारखंड सरकार • स्कूली शिक्षा एवं साक्षरता विभाग',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFFBF360C)),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Department of School Education & Literacy, Govt. of Jharkhand',
                        style: TextStyle(fontSize: 8.5, color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 2),
                      Text(
                        'PALASH Mother Tongue-Based Multilingual Education (MTB-MLE) • FLN',
                        style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF4E342E)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xs),

          // 2. Student Info Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(4),
              color: Colors.grey.shade50,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'विद्यालय (School): $schoolName',
                        style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      'कक्षा: ${_selectedTemplate.grade}',
                      style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Expanded(
                      flex: 3,
                      child: Text('विद्यार्थी का नाम: ____________________', style: TextStyle(fontSize: 9)),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text('रोल नं: _____', style: TextStyle(fontSize: 9)),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text('दिनांक: ________', style: TextStyle(fontSize: 9)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xs),

          // 3. Topic & Competency Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFF90CAF9)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'विषय: ${_selectedTemplate.subject} • प्रकरण: ${_selectedTemplate.titleHindi}',
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
                      ),
                      Text(
                        'FLN Code (${_selectedTemplate.nipunCode}): ${_selectedTemplate.competencyTitle}',
                        style: const TextStyle(fontSize: 8.5, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    _selectedTemplate.difficulty,
                    style: const TextStyle(fontSize: 8.5, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // 4. Activity 1: Counting / Objects
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(3)),
                child: const Text('अभ्यास १', style: TextStyle(fontSize: 8.5, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  _selectedTemplate.instructionsHindi,
                  style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            _selectedTemplate.instructionsSanthali,
            style: const TextStyle(fontSize: 8, color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xs),

          // Activity 1 Items Table
          Table(
            border: TableBorder.all(color: Colors.grey.shade400, width: 0.8),
            columnWidths: const {
              0: FixedColumnWidth(26),
              1: FlexColumnWidth(3.8),
              2: FlexColumnWidth(2.2),
              3: FlexColumnWidth(3.0),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(color: Colors.grey.shade200),
                children: const [
                  Padding(
                    padding: EdgeInsets.all(4),
                    child: Text('क्र.', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  ),
                  Padding(
                    padding: EdgeInsets.all(4),
                    child: Text('चित्र (Objects)', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(4),
                    child: Text('संख्या (No.)', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  ),
                  Padding(
                    padding: EdgeInsets.all(4),
                    child: Text('संथाली उच्चारण', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              ..._selectedTemplate.countingItems.take(4).toList().asMap().entries.map((entry) {
                final idx = entry.key + 1;
                final item = entry.value;
                return TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text('$idx', style: const TextStyle(fontSize: 9), textAlign: TextAlign.center),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                      child: Row(
                        children: List.generate(
                          item.count > 6 ? 6 : item.count,
                          (i) => Padding(
                            padding: const EdgeInsets.only(right: 3),
                            child: _buildUiVectorShape(item.shapeType, item.color),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
                      child: Container(
                        height: 20,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade500, style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(3),
                          color: const Color(0xFFF5F5F5),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${item.hindiNumber} / ${item.englishNumber}',
                          style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                      child: Text(
                        '${item.santhaliWord} (${item.santhaliPhonetic})',
                        style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // 5. Activity 2: Matching
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(3)),
                child: const Text('अभ्यास २', style: TextStyle(fontSize: 8.5, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: AppSpacing.xs),
              const Expanded(
                child: Text(
                  'सही संथाली शब्द से पेंसिल से रेखा खींचकर मिलाएँ (Bilingual Matching):',
                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400, width: 0.8),
              borderRadius: BorderRadius.circular(4),
              color: Colors.grey.shade50,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _selectedTemplate.matchingPairs.take(3).toList().asMap().entries.map((e) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Text('${e.key + 1}. ${e.value.hindiTerm}', style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold)),
                            const Spacer(),
                            const Icon(Icons.circle, size: 6, color: Colors.grey),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text('⤹ रेखा ⤸', style: TextStyle(fontSize: 7.5, color: Colors.grey.shade600)),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _selectedTemplate.matchingPairs.take(3).toList().reversed.map((p) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            const Icon(Icons.circle, size: 6, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${p.santhaliTerm} (${p.santhaliPhonetic})',
                                style: const TextStyle(fontSize: 8.5),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // 6. Activity 3: Tracing Grid
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFF1976D2), borderRadius: BorderRadius.circular(3)),
                child: const Text('अभ्यास ३', style: TextStyle(fontSize: 8.5, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: AppSpacing.xs),
              const Text('अनुरेखण व सुलेख (Tracing Grid):', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),

          Row(
            children: _selectedTemplate.tracingItems.map((item) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE0B2),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        alignment: Alignment.center,
                        child: Text(item.symbol, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFE65100))),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.hindiLabel, style: const TextStyle(fontSize: 7.5, fontWeight: FontWeight.bold)),
                            Row(
                              children: List.generate(
                                2,
                                (i) => Container(
                                  width: 14,
                                  height: 14,
                                  margin: const EdgeInsets.only(right: 2, top: 2),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: AppSpacing.sm),

          // 7. Assessment Footer
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('शिक्षक मूल्यांकन: [ ] स्तर १  [ ] स्तर २  [ ] स्तर ३', style: TextStyle(fontSize: 8)),
                Text('शिक्षक हस्ताक्षर: ____________', style: TextStyle(fontSize: 8)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUiVectorShape(ExerciseShapeType type, Color color) {
    switch (type) {
      case ExerciseShapeType.circle:
        return Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        );
      case ExerciseShapeType.star:
        return Icon(Icons.star, size: 13, color: color);
      case ExerciseShapeType.square:
        return Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        );
      case ExerciseShapeType.triangle:
        return Icon(Icons.change_history, size: 13, color: color);
      case ExerciseShapeType.apple:
        return const Text('🍎', style: TextStyle(fontSize: 11));
      case ExerciseShapeType.tree:
        return const Text('🌳', style: TextStyle(fontSize: 11));
      case ExerciseShapeType.fish:
        return const Text('🐟', style: TextStyle(fontSize: 11));
    }
  }
}
