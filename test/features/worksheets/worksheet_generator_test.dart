import 'package:flutter_test/flutter_test.dart';
import 'package:palash_vaani/features/worksheets/models/worksheet_models.dart';
import 'package:palash_vaani/features/worksheets/services/worksheet_pdf_generator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Worksheet Models & Repository Tests', () {
    test('WorksheetRepository contains multi-grade NIPUN FLN templates', () {
      final all = WorksheetRepository.allTemplates;
      expect(all.length, greaterThanOrEqualTo(6));

      final grade1 = WorksheetRepository.getTemplatesForGrade('Grade 1');
      final grade2 = WorksheetRepository.getTemplatesForGrade('Grade 2');
      final grade3 = WorksheetRepository.getTemplatesForGrade('Grade 3');

      expect(grade1.isNotEmpty, isTrue);
      expect(grade2.isNotEmpty, isTrue);
      expect(grade3.isNotEmpty, isTrue);
    });

    test('Each template contains counting items, matching pairs, and tracing symbols', () {
      for (final template in WorksheetRepository.allTemplates) {
        expect(template.id.isNotEmpty, isTrue);
        expect(template.grade.isNotEmpty, isTrue);
        expect(template.titleHindi.isNotEmpty, isTrue);
        expect(template.titleEnglish.isNotEmpty, isTrue);
        expect(template.nipunCode.startsWith('FLN-'), isTrue);
        expect(template.countingItems.isNotEmpty, isTrue);
        expect(template.matchingPairs.isNotEmpty, isTrue);
        expect(template.tracingItems.isNotEmpty, isTrue);
      }
    });

    test('Retrieves template by ID accurately', () {
      final counting = WorksheetRepository.getTemplateById('g1_math_counting');
      expect(counting.id, equals('g1_math_counting'));
      expect(counting.grade, equals('Grade 1'));
      expect(counting.subject, contains('गणित'));
    });
  });

  group('Worksheet PDF Generator Tests', () {
    test('Generates valid A4 PDF bytes for Grade 1 Math Counting Worksheet', () async {
      final template = WorksheetRepository.getTemplateById('g1_math_counting');
      final pdfBytes = await WorksheetPdfGenerator.instance.generateWorksheetPdf(
        template: template,
        schoolName: 'राजकीय उत्क्रमित प्राथमिक विद्यालय, दुमका',
      );

      expect(pdfBytes, isNotNull);
      expect(pdfBytes.isNotEmpty, isTrue);
      // Valid PDF files start with %PDF
      final header = String.fromCharCodes(pdfBytes.take(4));
      expect(header, equals('%PDF'));
    });

    test('Generates valid A4 PDF bytes across all curriculum templates without error', () async {
      for (final template in WorksheetRepository.allTemplates) {
        final pdfBytes = await WorksheetPdfGenerator.instance.generateWorksheetPdf(
          template: template,
          schoolName: 'राजकीय उत्क्रमित प्राथमिक विद्यालय (PALASH Pilot)',
        );
        expect(pdfBytes.length, greaterThan(1000));
        final header = String.fromCharCodes(pdfBytes.take(4));
        expect(header, equals('%PDF'));
      }
    });
  });
}
