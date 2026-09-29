import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/worksheet_models.dart';

/// Configuration for backward compatibility and customization
class WorksheetConfig {
  final String grade;
  final String subject;
  final String topic;
  final String difficulty;
  final String schoolName;

  const WorksheetConfig({
    required this.grade,
    required this.subject,
    required this.topic,
    required this.difficulty,
    this.schoolName = 'राजकीय उत्क्रमित प्राथमिक विद्यालय, दुमका (PALASH MTB-MLE)',
  });
}

/// Publication-Grade Offline Worksheet PDF Generator for Jharkhand MTB-MLE Primary Schools
class WorksheetPdfGenerator {
  static final WorksheetPdfGenerator instance = WorksheetPdfGenerator._init();
  WorksheetPdfGenerator._init();

  /// Generates a high-resolution, print-ready bilingual A4 PDF worksheet
  Future<Uint8List> generateWorksheetPdf({
    required WorksheetTemplate template,
    String schoolName = 'राजकीय उत्क्रमित प्राथमिक विद्यालय, दुमका (PALASH MTB-MLE)',
  }) async {
    final pdf = pw.Document();

    // Resilient offline font loader
    pw.Font fontRegular;
    pw.Font fontBold;
    try {
      fontRegular = await PdfGoogleFonts.notoSansDevanagariRegular();
      fontBold = await PdfGoogleFonts.notoSansDevanagariBold();
    } catch (e) {
      debugPrint('[WorksheetPdfGenerator] Offline fallback font used: $e');
      fontRegular = pw.Font.helvetica();
      fontBold = pw.Font.helveticaBold();
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 26, vertical: 24),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // -------------------------------------------------------------
              // 1. Official Government & Pedagogy Header
              // -------------------------------------------------------------
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.orange50,
                  borderRadius: pw.BorderRadius.circular(6),
                  border: pw.Border.all(color: PdfColors.orange800, width: 1.5),
                ),
                child: pw.Row(
                  children: [
                    // Embellished Seal / Crest Badge
                    pw.Container(
                      width: 44,
                      height: 44,
                      decoration: pw.BoxDecoration(
                        shape: pw.BoxShape.circle,
                        color: PdfColors.orange800,
                      ),
                      alignment: pw.Alignment.center,
                      child: pw.Text(
                        'पलाश\nवाणी',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 9.5,
                          color: PdfColors.white,
                          lineSpacing: 1.2,
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 12),
                    // Titles and Curriculum Affiliation
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Text(
                            'झारखंड सरकार • स्कूली शिक्षा एवं साक्षरता विभाग',
                            style: pw.TextStyle(font: fontBold, fontSize: 13, color: PdfColors.orange900),
                            textAlign: pw.TextAlign.center,
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'Department of School Education & Literacy, Govt. of Jharkhand',
                            style: pw.TextStyle(fontSize: 8.5, fontBold: pw.Font.helveticaBold(), color: PdfColors.grey800),
                            textAlign: pw.TextAlign.center,
                          ),
                          pw.SizedBox(height: 3),
                          pw.Container(
                            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: pw.BoxDecoration(
                              color: PdfColors.orange200,
                              borderRadius: pw.BorderRadius.circular(3),
                            ),
                            child: pw.Text(
                              'PALASH Mother Tongue-Based Multilingual Education (MTB-MLE) • JCERT FLN',
                              style: pw.TextStyle(font: fontBold, fontSize: 8.5, color: PdfColors.brown900),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 8),

              // -------------------------------------------------------------
              // 2. Student & Classroom Identification Block
              // -------------------------------------------------------------
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey500),
                  borderRadius: pw.BorderRadius.circular(4),
                  color: PdfColors.grey50,
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(
                          flex: 3,
                          child: pw.RichText(
                            text: pw.TextSpan(
                              children: [
                                pw.TextSpan(text: 'विद्यालय (School): ', style: pw.TextStyle(font: fontBold, fontSize: 9.5)),
                                pw.TextSpan(text: schoolName, style: pw.TextStyle(font: fontRegular, fontSize: 9)),
                              ],
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.RichText(
                            textAlign: pw.TextAlign.right,
                            text: pw.TextSpan(
                              children: [
                                pw.TextSpan(text: 'कक्षा: ', style: pw.TextStyle(font: fontBold, fontSize: 9.5)),
                                pw.TextSpan(text: template.grade, style: pw.TextStyle(font: fontBold, fontSize: 9.5, color: PdfColors.deepOrange900)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(
                          flex: 3,
                          child: pw.Text(
                            'विद्यार्थी का नाम (Student Name): ____________________________________',
                            style: pw.TextStyle(font: fontRegular, fontSize: 9),
                          ),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Text(
                            'क्रमांक (Roll No): ________',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(font: fontRegular, fontSize: 9),
                          ),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Text(
                            'दिनांक (Date): ___________',
                            textAlign: pw.TextAlign.right,
                            style: pw.TextStyle(font: fontRegular, fontSize: 9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 8),

              // -------------------------------------------------------------
              // 3. Worksheet Topic, Competency & FLN Code Bar
              // -------------------------------------------------------------
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  border: pw.Border.all(color: PdfColors.blue300),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'विषय: ${template.subject} • प्रकरण: ${template.titleHindi} (${template.titleEnglish})',
                            style: pw.TextStyle(font: fontBold, fontSize: 10.5, color: PdfColors.blue900),
                          ),
                          pw.Text(
                            'अधिगम प्रतिफल (FLN LO Code: ${template.nipunCode}): ${template.competencyTitle}',
                            style: pw.TextStyle(font: fontRegular, fontSize: 8.5, color: PdfColors.grey800),
                          ),
                        ],
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.green700,
                        borderRadius: pw.BorderRadius.circular(3),
                      ),
                      child: pw.Text(
                        template.difficulty,
                        style: pw.TextStyle(font: fontBold, fontSize: 8.5, color: PdfColors.white),
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 8),

              // -------------------------------------------------------------
              // 4. Activity 1: Pictorial Counting / Object Association
              // -------------------------------------------------------------
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.orange700,
                      borderRadius: pw.BorderRadius.circular(3),
                    ),
                    child: pw.Text(
                      'अभ्यास १',
                      style: pw.TextStyle(font: fontBold, fontSize: 9.5, color: PdfColors.white),
                    ),
                  ),
                  pw.SizedBox(width: 6),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          template.instructionsHindi,
                          style: pw.TextStyle(font: fontBold, fontSize: 9.5, color: PdfColors.blueGrey900),
                        ),
                        pw.Text(
                          _cleanPdfText(template.instructionsSanthali),
                          style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 5),

              // Exercise Items Table (Section 1)
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.8),
                columnWidths: {
                  0: const pw.FixedColumnWidth(28),
                  1: const pw.FlexColumnWidth(3.8),
                  2: const pw.FlexColumnWidth(2.2),
                  3: const pw.FlexColumnWidth(3.0),
                },
                children: [
                  // Table Header
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('क्र.', style: pw.TextStyle(font: fontBold, fontSize: 8.5), textAlign: pw.TextAlign.center),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('चित्र समूह (Count Objects)', style: pw.TextStyle(font: fontBold, fontSize: 8.5)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('संख्या लिखें (Number)', style: pw.TextStyle(font: fontBold, fontSize: 8.5), textAlign: pw.TextAlign.center),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('संथाली उच्चारण (Santhali)', style: pw.TextStyle(font: fontBold, fontSize: 8.5)),
                      ),
                    ],
                  ),
                  // Table Rows
                  ...template.countingItems.asMap().entries.map((entry) {
                    final idx = entry.key + 1;
                    final item = entry.value;
                    return _buildCountingRow(
                      index: _toDevanagariDigit(idx),
                      item: item,
                      fontRegular: fontRegular,
                      fontBold: fontBold,
                    );
                  }),
                ],
              ),

              pw.SizedBox(height: 8),

              // -------------------------------------------------------------
              // 5. Activity 2: Bilingual Matching Exercise (Section 2)
              // -------------------------------------------------------------
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.green700,
                      borderRadius: pw.BorderRadius.circular(3),
                    ),
                    child: pw.Text(
                      'अभ्यास २',
                      style: pw.TextStyle(font: fontBold, fontSize: 9.5, color: PdfColors.white),
                    ),
                  ),
                  pw.SizedBox(width: 6),
                  pw.Expanded(
                    child: pw.Text(
                      'सही संथाली शब्द से पेंसिल से रेखा खींचकर मिलान करें (Draw lines to match vernacular terms):',
                      style: pw.TextStyle(font: fontBold, fontSize: 9.5, color: PdfColors.blueGrey900),
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 4),

              // Matching Two-Column Container
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400, width: 0.8),
                  borderRadius: pw.BorderRadius.circular(4),
                  color: PdfColors.grey50,
                ),
                child: _buildMatchingBox(
                  pairs: template.matchingPairs,
                  fontRegular: fontRegular,
                  fontBold: fontBold,
                ),
              ),

              pw.SizedBox(height: 8),

              // -------------------------------------------------------------
              // 6. Activity 3: Tracing & Penmanship Practice Grid (Section 3)
              // -------------------------------------------------------------
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.blue700,
                      borderRadius: pw.BorderRadius.circular(3),
                    ),
                    child: pw.Text(
                      'अभ्यास ३',
                      style: pw.TextStyle(font: fontBold, fontSize: 9.5, color: PdfColors.white),
                    ),
                  ),
                  pw.SizedBox(width: 6),
                  pw.Expanded(
                    child: pw.Text(
                      'अनुरेखण व सुलेख अभ्यास (Tracing & Writing Practice in Dotted Boxes):',
                      style: pw.TextStyle(font: fontBold, fontSize: 9.5, color: PdfColors.blueGrey900),
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 4),

              // Tracing Grid
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: template.tracingItems.map((item) {
                  return pw.Expanded(
                    child: pw.Container(
                      margin: const pw.EdgeInsets.symmetric(horizontal: 3),
                      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey400),
                        borderRadius: pw.BorderRadius.circular(4),
                        color: PdfColors.white,
                      ),
                      child: pw.Row(
                        children: [
                          pw.Container(
                            width: 28,
                            height: 28,
                            decoration: pw.BoxDecoration(
                              color: PdfColors.orange100,
                              border: pw.Border.all(color: PdfColors.orange700),
                              borderRadius: pw.BorderRadius.circular(4),
                            ),
                            alignment: pw.Alignment.center,
                            child: pw.Text(
                              item.symbol,
                              style: pw.TextStyle(font: fontBold, fontSize: 13, color: PdfColors.orange900),
                            ),
                          ),
                          pw.SizedBox(width: 6),
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  '${item.hindiLabel} • ${item.santhaliLabel}',
                                  style: pw.TextStyle(font: fontBold, fontSize: 8),
                                ),
                                pw.SizedBox(height: 3),
                                pw.Row(
                                  children: [
                                    _buildDottedWriteBox(),
                                    pw.SizedBox(width: 4),
                                    _buildDottedWriteBox(),
                                    pw.SizedBox(width: 4),
                                    _buildDottedWriteBox(),
                                  ],
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

              pw.Spacer(),

              // -------------------------------------------------------------
              // 7. Teacher Assessment & FLN Rubric (Official Jharkhand Format)
              // -------------------------------------------------------------
              pw.Container(
                padding: const pw.EdgeInsets.all(7),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(4),
                  border: pw.Border.all(color: PdfColors.grey500, width: 0.8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'शिक्षक मूल्यांकन रुब्रिक (Teacher Assessment Rubric):',
                          style: pw.TextStyle(font: fontBold, fontSize: 9, color: PdfColors.blueGrey900),
                        ),
                        pw.Text(
                          'हस्ताक्षर: ________________________',
                          style: pw.TextStyle(font: fontRegular, fontSize: 8.5),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 3),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          '[   ] स्तर १: पुनर्प्रयास (Needs Support)',
                          style: pw.TextStyle(font: fontRegular, fontSize: 8),
                        ),
                        pw.Text(
                          '[   ] स्तर २: संतोषजनक (Proficient)',
                          style: pw.TextStyle(font: fontRegular, fontSize: 8),
                        ),
                        pw.Text(
                          '[   ] स्तर ३: उत्कृष्ट (Outstanding)',
                          style: pw.TextStyle(font: fontRegular, fontSize: 8),
                        ),
                        pw.Text(
                          'दिनांक: ____________',
                          style: pw.TextStyle(font: fontRegular, fontSize: 8),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 3),

              // Micro Footer
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'PALASH-Vaani Vernacular Pedagogy Engine • 100% Offline Primary Education Aid',
                    style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700),
                  ),
                  pw.Text(
                    'JCERT MTB-MLE Pilot • Dumka / Ranchi, Jharkhand',
                    style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Builds a single counting exercise row with crisp vector objects
  pw.TableRow _buildCountingRow({
    required String index,
    required CountingExerciseItem item,
    required pw.Font fontRegular,
    required pw.Font fontBold,
  }) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: pw.Text(index, style: pw.TextStyle(font: fontRegular, fontSize: 9.5), textAlign: pw.TextAlign.center),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 6),
          child: pw.Row(
            children: List.generate(
              item.count > 10 ? 10 : item.count,
              (i) => pw.Padding(
                padding: const pw.EdgeInsets.only(right: 5),
                child: _buildVectorShape(item.shapeType),
              ),
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 6),
          child: pw.Container(
            height: 22,
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey500, style: pw.BorderStyle.dashed),
              borderRadius: pw.BorderRadius.circular(3),
              color: PdfColors.white,
            ),
            alignment: pw.Alignment.center,
            child: pw.Text(
              '${item.hindiNumber} (${item.englishNumber})',
              style: pw.TextStyle(font: fontBold, fontSize: 8.5, color: PdfColors.grey600),
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 6),
          child: pw.Text(
            '${item.santhaliWord} (${item.santhaliPhonetic})',
            style: pw.TextStyle(font: fontRegular, fontSize: 9),
          ),
        ),
      ],
    );
  }

  /// Builds matching activity layout with shuffled right column so students draw lines
  pw.Widget _buildMatchingBox({
    required List<MatchingExercisePair> pairs,
    required pw.Font fontRegular,
    required pw.Font fontBold,
  }) {
    // Generate an offset shuffled permutation of the right items for genuine matching
    final shuffled = List<MatchingExercisePair>.from(pairs);
    if (shuffled.length > 2) {
      final first = shuffled.removeAt(0);
      shuffled.add(first);
    }

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        // Left Column (Hindi + English)
        pw.Expanded(
          flex: 4,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: pairs.asMap().entries.map((entry) {
              final idx = entry.key + 1;
              final p = entry.value;
              return pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 2.5),
                child: pw.Row(
                  children: [
                    pw.Text(
                      '${_toDevanagariDigit(idx)}. ${p.hindiTerm}',
                      style: pw.TextStyle(font: fontBold, fontSize: 9),
                    ),
                    pw.Spacer(),
                    pw.Container(
                      width: 7,
                      height: 7,
                      decoration: const pw.BoxDecoration(
                        shape: pw.BoxShape.circle,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),

        // Middle Pencil Line Connecting Area
        pw.Expanded(
          flex: 3,
          child: pw.Center(
            child: pw.Text(
              '⤹  रेखा मिलाएँ  ⤸',
              style: pw.TextStyle(font: fontRegular, fontSize: 7.5, color: PdfColors.grey500),
            ),
          ),
        ),

        // Right Column (Santhali Vernacular + Phonetic)
        pw.Expanded(
          flex: 4,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: shuffled.map((p) {
              return pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 2.5),
                child: pw.Row(
                  children: [
                    pw.Container(
                      width: 7,
                      height: 7,
                      decoration: const pw.BoxDecoration(
                        shape: pw.BoxShape.circle,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Expanded(
                      child: pw.Text(
                        '${p.santhaliTerm} (${p.santhaliPhonetic})',
                        style: pw.TextStyle(font: fontRegular, fontSize: 9),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// Dotted tracing box for students
  pw.Widget _buildDottedWriteBox() {
    return pw.Container(
      width: 18,
      height: 18,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400, style: pw.BorderStyle.dashed),
        borderRadius: pw.BorderRadius.circular(2),
      ),
    );
  }

  /// Renders clean pure vector shapes for counting without font glyph dependencies
  pw.Widget _buildVectorShape(ExerciseShapeType type) {
    switch (type) {
      case ExerciseShapeType.circle:
        return pw.Container(
          width: 14,
          height: 14,
          decoration: const pw.BoxDecoration(
            color: PdfColors.red700,
            shape: pw.BoxShape.circle,
          ),
        );
      case ExerciseShapeType.apple:
        return pw.Container(
          width: 14,
          height: 14,
          decoration: const pw.BoxDecoration(
            color: PdfColors.red600,
            shape: pw.BoxShape.circle,
          ),
          child: pw.Center(
            child: pw.Container(
              width: 5,
              height: 5,
              decoration: const pw.BoxDecoration(
                color: PdfColors.amber100,
                shape: pw.BoxShape.circle,
              ),
            ),
          ),
        );
      case ExerciseShapeType.star:
        return pw.Transform.rotate(
          angle: 0.785398, // 45 degree diamond
          child: pw.Container(
            width: 11,
            height: 11,
            decoration: pw.BoxDecoration(
              color: PdfColors.amber800,
              borderRadius: pw.BorderRadius.circular(1.5),
            ),
          ),
        );
      case ExerciseShapeType.square:
        return pw.Container(
          width: 13,
          height: 13,
          decoration: pw.BoxDecoration(
            color: PdfColors.deepPurple700,
            borderRadius: pw.BorderRadius.circular(2),
          ),
        );
      case ExerciseShapeType.triangle:
        return pw.Container(
          width: 14,
          height: 14,
          decoration: pw.BoxDecoration(
            color: PdfColors.teal700,
            borderRadius: pw.BorderRadius.circular(7),
            border: pw.Border.all(color: PdfColors.teal900, width: 2),
          ),
          child: pw.Center(
            child: pw.Container(
              width: 4,
              height: 4,
              decoration: const pw.BoxDecoration(
                color: PdfColors.white,
                shape: pw.BoxShape.circle,
              ),
            ),
          ),
        );
      case ExerciseShapeType.tree:
        return pw.Container(
          width: 14,
          height: 14,
          decoration: const pw.BoxDecoration(
            color: PdfColors.green800,
            shape: pw.BoxShape.circle,
          ),
          child: pw.Center(
            child: pw.Container(
              width: 6,
              height: 6,
              decoration: const pw.BoxDecoration(
                color: PdfColors.lightGreen300,
                shape: pw.BoxShape.circle,
              ),
            ),
          ),
        );
      case ExerciseShapeType.fish:
        return pw.Container(
          width: 16,
          height: 12,
          decoration: pw.BoxDecoration(
            color: PdfColors.blue800,
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Center(
            child: pw.Container(
              width: 4,
              height: 4,
              decoration: const pw.BoxDecoration(
                color: PdfColors.white,
                shape: pw.BoxShape.circle,
              ),
            ),
          ),
        );
    }
  }

  static String _cleanPdfText(String text) {
    return text.replaceAll(RegExp(r'[\u1C50-\u1C7F]'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String _toDevanagariDigit(int number) {
    const devanagariDigits = ['०', '१', '२', '३', '४', '५', '६', '७', '८', '९'];
    return number.toString().split('').map((c) {
      final val = int.tryParse(c);
      return val != null ? devanagariDigits[val] : c;
    }).join();
  }

  /// Print or Export worksheet directly to Android print spooler
  Future<void> printWorksheet({
    required WorksheetTemplate template,
    String schoolName = 'राजकीय उत्क्रमित प्राथमिक विद्यालय, दुमका (PALASH MTB-MLE)',
  }) async {
    final pdfBytes = await generateWorksheetPdf(template: template, schoolName: schoolName);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'PALASH_Worksheet_${template.grade}_${template.id}.pdf',
    );
  }

  /// Download / Share PDF via system share sheet (Save to Downloads, WhatsApp, Drive)
  Future<void> shareOrDownloadWorksheet({
    required WorksheetTemplate template,
    String schoolName = 'राजकीय उत्क्रमित प्राथमिक विद्यालय, दुमका (PALASH MTB-MLE)',
  }) async {
    final pdfBytes = await generateWorksheetPdf(template: template, schoolName: schoolName);
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'PALASH_Worksheet_${template.grade}_${template.id}.pdf',
    );
  }

  /// Legacy method support for backward compatibility
  Future<void> printOrExport(WorksheetConfig config) async {
    // Find best matching template or use first
    final template = WorksheetRepository.allTemplates.firstWhere(
      (t) => t.grade == config.grade || t.topic == config.topic,
      orElse: () => WorksheetRepository.allTemplates.first,
    );
    await printWorksheet(template: template, schoolName: config.schoolName);
  }

  /// Legacy generateWorksheet
  Future<Uint8List> generateWorksheet(WorksheetConfig config) async {
    final template = WorksheetRepository.allTemplates.firstWhere(
      (t) => t.grade == config.grade,
      orElse: () => WorksheetRepository.allTemplates.first,
    );
    return generateWorksheetPdf(template: template, schoolName: config.schoolName);
  }
}
