import 'package:flutter/material.dart';

/// Type of visual shape for counting exercises in PDF and UI
enum ExerciseShapeType {
  circle,
  star,
  square,
  triangle,
  apple,
  tree,
  fish,
}

/// A single item in the counting section
class CountingExerciseItem {
  final int count;
  final ExerciseShapeType shapeType;
  final Color color;
  final String hindiNumber;
  final String englishNumber;
  final String santhaliWord;
  final String santhaliPhonetic;
  final String santhaliOlChiki;

  const CountingExerciseItem({
    required this.count,
    required this.shapeType,
    required this.color,
    required this.hindiNumber,
    required this.englishNumber,
    required this.santhaliWord,
    required this.santhaliPhonetic,
    required this.santhaliOlChiki,
  });
}

/// A pair for matching exercise (Hindi -> Santhali)
class MatchingExercisePair {
  final String hindiTerm;
  final String englishHint;
  final String santhaliTerm;
  final String santhaliPhonetic;
  final String santhaliOlChiki;

  const MatchingExercisePair({
    required this.hindiTerm,
    required this.englishHint,
    required this.santhaliTerm,
    required this.santhaliPhonetic,
    required this.santhaliOlChiki,
  });
}

/// An item for tracing and handwriting practice
class TracingExerciseItem {
  final String symbol;
  final String hindiLabel;
  final String santhaliLabel;
  final String olChikiLabel;
  final String phoneticGuide;

  const TracingExerciseItem({
    required this.symbol,
    required this.hindiLabel,
    required this.santhaliLabel,
    required this.olChikiLabel,
    required this.phoneticGuide,
  });
}

/// Complete worksheet template structure
class WorksheetTemplate {
  final String id;
  final String grade;
  final String subject;
  final String titleHindi;
  final String titleEnglish;
  final String difficulty;
  final String nipunCode;
  final String competencyTitle;
  final String instructionsHindi;
  final String instructionsSanthali;
  final List<CountingExerciseItem> countingItems;
  final List<MatchingExercisePair> matchingPairs;
  final List<TracingExerciseItem> tracingItems;

  String get topic => '$titleHindi ($titleEnglish)';

  const WorksheetTemplate({
    required this.id,
    required this.grade,
    required this.subject,
    required this.titleHindi,
    required this.titleEnglish,
    required this.difficulty,
    required this.nipunCode,
    required this.competencyTitle,
    required this.instructionsHindi,
    required this.instructionsSanthali,
    required this.countingItems,
    required this.matchingPairs,
    required this.tracingItems,
  });
}

/// Repository providing authentic NIPUN Bharat MTB-MLE worksheets for Jharkhand
class WorksheetRepository {
  WorksheetRepository._();

  static const List<WorksheetTemplate> allTemplates = [
    // -------------------------------------------------------------
    // 1. Grade 1 - Mathematics: Counting 1-10 (वस्तु गणना एवं अंक ज्ञान)
    // -------------------------------------------------------------
    WorksheetTemplate(
      id: 'g1_math_counting',
      grade: 'Grade 1',
      subject: 'गणित (Mathematics)',
      titleHindi: 'वस्तु गणना एवं संख्या ज्ञान (१ से १०)',
      titleEnglish: 'Object Counting & Numerals (1–10)',
      difficulty: 'बुनियादी (Beginner)',
      nipunCode: 'FLN-M1.1',
      competencyTitle: '१ से १० तक वस्तुओं की मौखिक व लिखित गिनती, संथाली व हिंदी अंक पहचान',
      instructionsHindi: 'चित्रों को गिनें और खाली डिब्बे में सही संख्या तथा संथाली नाम लिखें।',
      instructionsSanthali: 'ᱡᱤᱱᱤᱥ ᱠᱚ ᱞᱮᱠᱷᱟᱭ ᱢᱮ ᱟᱨ ᱥᱟᱹᱦᱤ ᱮᱞ ᱥᱟᱶᱛᱮ ᱧᱩᱛᱩᱢ ᱚᱞ ᱢᱮ। (Jinis ko lekhay me ar sahi el sawnte nutum ol me.)',
      countingItems: [
        CountingExerciseItem(
          count: 3,
          shapeType: ExerciseShapeType.apple,
          color: Color(0xFFD32F2F),
          hindiNumber: '३',
          englishNumber: '3',
          santhaliWord: 'पे',
          santhaliPhonetic: 'Pe',
          santhaliOlChiki: 'ᱯᱮ',
        ),
        CountingExerciseItem(
          count: 5,
          shapeType: ExerciseShapeType.tree,
          color: Color(0xFF388E3C),
          hindiNumber: '५',
          englishNumber: '5',
          santhaliWord: 'मोणे',
          santhaliPhonetic: 'Mone',
          santhaliOlChiki: 'ᱢᱚᱬᱮ',
        ),
        CountingExerciseItem(
          count: 2,
          shapeType: ExerciseShapeType.star,
          color: Color(0xFFFBC02D),
          hindiNumber: '२',
          englishNumber: '2',
          santhaliWord: 'बार',
          santhaliPhonetic: 'Bar',
          santhaliOlChiki: 'ᱵᱟᱨ',
        ),
        CountingExerciseItem(
          count: 4,
          shapeType: ExerciseShapeType.fish,
          color: Color(0xFF1976D2),
          hindiNumber: '४',
          englishNumber: '4',
          santhaliWord: 'पून',
          santhaliPhonetic: 'Pun',
          santhaliOlChiki: 'ᱯᱩᱱ',
        ),
        CountingExerciseItem(
          count: 1,
          shapeType: ExerciseShapeType.circle,
          color: Color(0xFFE64A19),
          hindiNumber: '१',
          englishNumber: '1',
          santhaliWord: 'मिद',
          santhaliPhonetic: 'Mid',
          santhaliOlChiki: 'ᱢᱤᱫ',
        ),
      ],
      matchingPairs: [
        MatchingExercisePair(
          hindiTerm: '१ (एक)',
          englishHint: 'One',
          santhaliTerm: 'मिद',
          santhaliPhonetic: 'Mid',
          santhaliOlChiki: '᱑ (ᱢᱤᱫ)',
        ),
        MatchingExercisePair(
          hindiTerm: '२ (दो)',
          englishHint: 'Two',
          santhaliTerm: 'बार',
          santhaliPhonetic: 'Bar',
          santhaliOlChiki: '᱒ (ᱵᱟᱨ)',
        ),
        MatchingExercisePair(
          hindiTerm: '३ (तीन)',
          englishHint: 'Three',
          santhaliTerm: 'पे',
          santhaliPhonetic: 'Pe',
          santhaliOlChiki: '᱓ (ᱯᱮ)',
        ),
        MatchingExercisePair(
          hindiTerm: '४ (चार)',
          englishHint: 'Four',
          santhaliTerm: 'पून',
          santhaliPhonetic: 'Pun',
          santhaliOlChiki: '᱔ (ᱯᱩᱱ)',
        ),
        MatchingExercisePair(
          hindiTerm: '५ (पाँच)',
          englishHint: 'Five',
          santhaliTerm: 'मोणे',
          santhaliPhonetic: 'Mone',
          santhaliOlChiki: '᱕ (ᱢᱚᱬᱮ)',
        ),
      ],
      tracingItems: [
        TracingExerciseItem(
          symbol: '१',
          hindiLabel: 'एक',
          santhaliLabel: 'मिद (Mid)',
          olChikiLabel: '᱑',
          phoneticGuide: 'Mid',
        ),
        TracingExerciseItem(
          symbol: '२',
          hindiLabel: 'दो',
          santhaliLabel: 'बार (Bar)',
          olChikiLabel: '᱒',
          phoneticGuide: 'Bar',
        ),
        TracingExerciseItem(
          symbol: '३',
          hindiLabel: 'तीन',
          santhaliLabel: 'पे (Pe)',
          olChikiLabel: '᱓',
          phoneticGuide: 'Pe',
        ),
      ],
    ),

    // -------------------------------------------------------------
    // 2. Grade 1 - Language & Phonics: Vowels & Consonants (वर्ण व ध्वनि)
    // -------------------------------------------------------------
    WorksheetTemplate(
      id: 'g1_lang_phonics',
      grade: 'Grade 1',
      subject: 'भाषा एवं ध्वनि (Language & Phonics)',
      titleHindi: 'ओल चिकी एवं देवनागरी वर्ण-ध्वनि अभ्यास',
      titleEnglish: 'Ol Chiki & Devanagari Script & Phonics',
      difficulty: 'बुनियादी (Beginner)',
      nipunCode: 'FLN-L1.2',
      competencyTitle: 'बुनियादी संथाली वर्णों (ओल चिकी) की पहचान व देवनागरी ध्वनि संबंध',
      instructionsHindi: 'वर्णों की ध्वनि पहचानें, चित्रों से मिलान करें और अनुरेखण (Tracing) करें।',
      instructionsSanthali: 'ᱟᱠᱷᱚᱨ ᱠᱚ ᱩᱨᱩᱢ ᱢᱮ, ᱪᱤᱛᱟᱹᱨ ᱥᱟᱶ ᱡᱚᱲᱟᱣ ᱢᱮ ᱟᱨ ᱚᱞ ᱪᱮᱫ ᱢᱮ। (Akhor ko urum me, chitar sawn jodaw me ar ol ched me.)',
      countingItems: [
        CountingExerciseItem(
          count: 2,
          shapeType: ExerciseShapeType.tree,
          color: Color(0xFF2E7D32),
          hindiNumber: 'दारे (पेड़)',
          englishNumber: 'Dare',
          santhaliWord: 'दारे',
          santhaliPhonetic: 'Dare (Tree)',
          santhaliOlChiki: 'ᱫᱟᱨᱮ',
        ),
        CountingExerciseItem(
          count: 3,
          shapeType: ExerciseShapeType.fish,
          color: Color(0xFF0288D1),
          hindiNumber: 'हाकु (मछली)',
          englishNumber: 'Haku',
          santhaliWord: 'हाकु',
          santhaliPhonetic: 'Haku (Fish)',
          santhaliOlChiki: 'ᱦᱟᱹᱠᱩ',
        ),
        CountingExerciseItem(
          count: 1,
          shapeType: ExerciseShapeType.star,
          color: Color(0xFFF57C00),
          hindiNumber: 'सिंगी (सूरज)',
          englishNumber: 'Singi',
          santhaliWord: 'सिंगी',
          santhaliPhonetic: 'Singi (Sun)',
          santhaliOlChiki: 'ᱥᱤᱧᱤ',
        ),
      ],
      matchingPairs: [
        MatchingExercisePair(
          hindiTerm: 'पेड़ (Tree)',
          englishHint: 'Tree',
          santhaliTerm: 'दारे',
          santhaliPhonetic: 'Dare',
          santhaliOlChiki: 'ᱫᱟᱨᱮ (Dare)',
        ),
        MatchingExercisePair(
          hindiTerm: 'पानी (Water)',
          englishHint: 'Water',
          santhaliTerm: 'दाग',
          santhaliPhonetic: 'Dag',
          santhaliOlChiki: 'ᱫᱟᱜ (Dag)',
        ),
        MatchingExercisePair(
          hindiTerm: 'फूल (Flower)',
          englishHint: 'Flower',
          santhaliTerm: 'बाहा',
          santhaliPhonetic: 'Baha',
          santhaliOlChiki: 'ᱵᱟᱦᱟ (Baha)',
        ),
        MatchingExercisePair(
          hindiTerm: 'मछली (Fish)',
          englishHint: 'Fish',
          santhaliTerm: 'हाकु',
          santhaliPhonetic: 'Haku',
          santhaliOlChiki: 'ᱦᱟᱹᱠᱩ (Haku)',
        ),
        MatchingExercisePair(
          hindiTerm: 'पक्षी (Bird)',
          englishHint: 'Bird',
          santhaliTerm: 'चेंदें',
          santhaliPhonetic: 'Chende',
          santhaliOlChiki: 'ᱪᱮᱬᱮ (Chende)',
        ),
      ],
      tracingItems: [
        TracingExerciseItem(
          symbol: 'ᱚ',
          hindiLabel: 'अ (ओ)',
          santhaliLabel: 'ओल (La)',
          olChikiLabel: 'ᱚ',
          phoneticGuide: 'Ol (Letter A)',
        ),
        TracingExerciseItem(
          symbol: 'ᱛ',
          hindiLabel: 'त (At)',
          santhaliLabel: 'अत (At)',
          olChikiLabel: 'ᱛ',
          phoneticGuide: 'At (Letter T)',
        ),
        TracingExerciseItem(
          symbol: 'ᱜ',
          hindiLabel: 'ग (Ag)',
          santhaliLabel: 'अग (Ag)',
          olChikiLabel: 'ᱜ',
          phoneticGuide: 'Ag (Letter G)',
        ),
      ],
    ),

    // -------------------------------------------------------------
    // 3. Grade 2 - Mathematics: Basic Addition & Number Stories (जोड़ व पहेली)
    // -------------------------------------------------------------
    WorksheetTemplate(
      id: 'g2_math_addition',
      grade: 'Grade 2',
      subject: 'गणित (Mathematics)',
      titleHindi: 'चित्र जोड़ एवं संख्या बोध (६ से २०)',
      titleEnglish: 'Pictorial Addition & Counting (6–20)',
      difficulty: 'मध्यम (Intermediate)',
      nipunCode: 'FLN-M2.2',
      competencyTitle: 'स्थानीय वस्तुओं के समूह बनाकर बुनियादी जोड़ एवं संथाली संख्या संबंध',
      instructionsHindi: 'वस्तुओं के दोनों समूहों को जोड़कर कुल संख्या देवनागरी और संथाली में लिखें।',
      instructionsSanthali: 'ᱵᱟᱱᱟᱨ ᱫᱚᱞ ᱨᱮᱱᱟᱜ ᱡᱤᱱᱤᱥ ᱠᱚ ᱡᱚᱲᱟᱣ ᱠᱟᱛᱮ ᱞᱮᱠᱷᱟᱭ ᱢᱮ ᱟᱨ ᱚᱞ ᱢᱮ। (Banar dol renag jinis ko jodaw kate lekhay me ar ol me.)',
      countingItems: [
        CountingExerciseItem(
          count: 6,
          shapeType: ExerciseShapeType.apple,
          color: Color(0xFFD32F2F),
          hindiNumber: '६ (३+३)',
          englishNumber: '6',
          santhaliWord: 'तुरुय',
          santhaliPhonetic: 'Turuy',
          santhaliOlChiki: 'ᱛᱩᱨᱩᱭ',
        ),
        CountingExerciseItem(
          count: 7,
          shapeType: ExerciseShapeType.tree,
          color: Color(0xFF2E7D32),
          hindiNumber: '७ (४+३)',
          englishNumber: '7',
          santhaliWord: 'एयाय',
          santhaliPhonetic: 'Eyay',
          santhaliOlChiki: 'ᱮᱭᱟᱭ',
        ),
        CountingExerciseItem(
          count: 8,
          shapeType: ExerciseShapeType.star,
          color: Color(0xFFFFA000),
          hindiNumber: '८ (५+३)',
          englishNumber: '8',
          santhaliWord: 'इरल',
          santhaliPhonetic: 'Iral',
          santhaliOlChiki: 'ᱤᱨᱟᱹᱞ',
        ),
        CountingExerciseItem(
          count: 10,
          shapeType: ExerciseShapeType.circle,
          color: Color(0xFF1976D2),
          hindiNumber: '१० (५+५)',
          englishNumber: '10',
          santhaliWord: 'गेल',
          santhaliPhonetic: 'Gel',
          santhaliOlChiki: 'ᱜᱮᱞ',
        ),
      ],
      matchingPairs: [
        MatchingExercisePair(
          hindiTerm: '६ (छह)',
          englishHint: 'Six',
          santhaliTerm: 'तुरुय',
          santhaliPhonetic: 'Turuy',
          santhaliOlChiki: '᱖ (ᱛᱩᱨᱩᱭ)',
        ),
        MatchingExercisePair(
          hindiTerm: '७ (सात)',
          englishHint: 'Seven',
          santhaliTerm: 'एयाय',
          santhaliPhonetic: 'Eyay',
          santhaliOlChiki: '᱗ (ᱮᱭᱟᱭ)',
        ),
        MatchingExercisePair(
          hindiTerm: '८ (आठ)',
          englishHint: 'Eight',
          santhaliTerm: 'इरल',
          santhaliPhonetic: 'Iral',
          santhaliOlChiki: '᱘ (ᱤᱨᱟᱹᱞ)',
        ),
        MatchingExercisePair(
          hindiTerm: '९ (नौ)',
          englishHint: 'Nine',
          santhaliTerm: 'आरे',
          santhaliPhonetic: 'Are',
          santhaliOlChiki: '᱙ (ᱟᱨᱮ)',
        ),
        MatchingExercisePair(
          hindiTerm: '१० (दस)',
          englishHint: 'Ten',
          santhaliTerm: 'गेल',
          santhaliPhonetic: 'Gel',
          santhaliOlChiki: '᱑᱐ (ᱜᱮᱞ)',
        ),
      ],
      tracingItems: [
        TracingExerciseItem(
          symbol: '६',
          hindiLabel: 'छह',
          santhaliLabel: 'तुरुय (Turuy)',
          olChikiLabel: '᱖',
          phoneticGuide: 'Turuy',
        ),
        TracingExerciseItem(
          symbol: '७',
          hindiLabel: 'सात',
          santhaliLabel: 'एयाय (Eyay)',
          olChikiLabel: '᱗',
          phoneticGuide: 'Eyay',
        ),
        TracingExerciseItem(
          symbol: '१०',
          hindiLabel: 'दस',
          santhaliLabel: 'गेल (Gel)',
          olChikiLabel: '᱑᱐',
          phoneticGuide: 'Gel',
        ),
      ],
    ),

    // -------------------------------------------------------------
    // 4. Grade 2 - EVS & Nature: Plants & Animals (हमारे आस-पास)
    // -------------------------------------------------------------
    WorksheetTemplate(
      id: 'g2_evs_nature',
      grade: 'Grade 2',
      subject: 'पर्यावरण व परिवेश (EVS & Nature)',
      titleHindi: 'हमारे आस-पास के जीव-जंतु व पेड़-पौधे',
      titleEnglish: 'Domestic Animals & Nature Around Us',
      difficulty: 'मध्यम (Intermediate)',
      nipunCode: 'FLN-E2.1',
      competencyTitle: 'स्थानीय परिवेश के पालतू व वन्य जीवों की संथाली व हिंदी में पहचान',
      instructionsHindi: 'जीव-जंतुओं के नाम पहचानें और सही संथाली नाम से रेखा खींचकर मिलान करें।',
      instructionsSanthali: 'ᱡᱤᱭᱟᱹᱞᱤ ᱠᱚᱣᱟᱜ ᱧᱩᱛᱩᱢ ᱩᱨᱩᱢ ᱢᱮ ᱟᱨ ᱥᱟᱹᱦᱤ ᱥᱟᱱᱛᱟᱲᱤ ᱧᱩᱛᱩᱢ ᱥᱟᱶ ᱜᱟᱨ ᱴᱟᱱᱟᱣ ᱠᱟᱛᱮ ᱡᱚᱲᱟᱣ ᱢᱮ।',
      countingItems: [
        CountingExerciseItem(
          count: 2,
          shapeType: ExerciseShapeType.apple,
          color: Color(0xFFC62828),
          hindiNumber: 'सेब / फल',
          englishNumber: 'Fruits',
          santhaliWord: 'जो (Jo)',
          santhaliPhonetic: 'Jo',
          santhaliOlChiki: 'ᱡᱚ',
        ),
        CountingExerciseItem(
          count: 4,
          shapeType: ExerciseShapeType.tree,
          color: Color(0xFF2E7D32),
          hindiNumber: 'पत्ते',
          englishNumber: 'Leaves',
          santhaliWord: 'साकाम (Sakam)',
          santhaliPhonetic: 'Sakam',
          santhaliOlChiki: 'ᱥᱟᱠᱟᱢ',
        ),
        CountingExerciseItem(
          count: 3,
          shapeType: ExerciseShapeType.fish,
          color: Color(0xFF00838F),
          hindiNumber: 'नदी की मछली',
          englishNumber: 'Fish',
          santhaliWord: 'हाकु (Haku)',
          santhaliPhonetic: 'Haku',
          santhaliOlChiki: 'ᱦᱟᱹᱠᱩ',
        ),
      ],
      matchingPairs: [
        MatchingExercisePair(
          hindiTerm: 'गाय / बैल (Cow/Ox)',
          englishHint: 'Cattle',
          santhaliTerm: 'डांगरा',
          santhaliPhonetic: 'Dangra',
          santhaliOlChiki: 'ᱰᱟᱝᱨᱟ (Dangra)',
        ),
        MatchingExercisePair(
          hindiTerm: 'पत्ता (Leaf)',
          englishHint: 'Leaf',
          santhaliTerm: 'साकाम',
          santhaliPhonetic: 'Sakam',
          santhaliOlChiki: 'ᱥᱟᱠᱟᱢ (Sakam)',
        ),
        MatchingExercisePair(
          hindiTerm: 'फल (Fruit)',
          englishHint: 'Fruit',
          santhaliTerm: 'जो',
          santhaliPhonetic: 'Jo',
          santhaliOlChiki: 'ᱡᱚ (Jo)',
        ),
        MatchingExercisePair(
          hindiTerm: 'घर (House)',
          englishHint: 'Home',
          santhaliTerm: 'ओड़ाः',
          santhaliPhonetic: "Oṛa'",
          santhaliOlChiki: "ᱚᱲᱟᱜ (Oṛa')",
        ),
        MatchingExercisePair(
          hindiTerm: 'सूरज (Sun)',
          englishHint: 'Sun',
          santhaliTerm: 'सिंगी',
          santhaliPhonetic: 'Singi',
          santhaliOlChiki: 'ᱥᱤᱧᱤ (Singi)',
        ),
      ],
      tracingItems: [
        TracingExerciseItem(
          symbol: 'दारे',
          hindiLabel: 'पेड़',
          santhaliLabel: 'दारे (Tree)',
          olChikiLabel: 'ᱫᱟᱨᱮ',
          phoneticGuide: 'Dare',
        ),
        TracingExerciseItem(
          symbol: 'दाग',
          hindiLabel: 'पानी',
          santhaliLabel: 'दाग (Water)',
          olChikiLabel: 'ᱫᱟᱜ',
          phoneticGuide: 'Dag',
        ),
        TracingExerciseItem(
          symbol: 'बाहा',
          hindiLabel: 'फूल',
          santhaliLabel: 'बाहा (Flower)',
          olChikiLabel: 'ᱵᱟᱦᱟ',
          phoneticGuide: 'Baha',
        ),
      ],
    ),

    // -------------------------------------------------------------
    // 5. Grade 3 - Mathematics: Shapes & Patterns (आकृतियाँ व प्रतिरूप)
    // -------------------------------------------------------------
    WorksheetTemplate(
      id: 'g3_math_shapes',
      grade: 'Grade 3',
      subject: 'गणित (Mathematics)',
      titleHindi: 'आकृतियाँ, स्थानिक समझ एवं प्रतिरूप',
      titleEnglish: 'Geometric Shapes, Spatial Sense & Patterns',
      difficulty: 'उन्नत (Advanced)',
      nipunCode: 'FLN-M3.1',
      competencyTitle: 'बुनियादी 2D आकृतियों (वृत्त, त्रिभुज, चतुर्भुज) की पहचान व दैनिक वस्तुओं में वर्गीकरण',
      instructionsHindi: 'आकृतियों को पहचानें, उनके संथाली नाम लिखें और नीचे दिए गए प्रतिरूप को पूरा करें।',
      instructionsSanthali: 'ᱜᱚᱲᱦᱚᱱ ᱠᱚ ᱩᱨᱩᱢ ᱢᱮ, ᱚᱱᱟ ᱠᱚᱨᱮᱱᱟᱜ ᱧᱩᱛᱩᱢ ᱚᱞ ᱢᱮ ᱟᱨ ᱞᱟᱛᱟᱨ ᱨᱮᱱᱟᱜ ᱪᱤᱛᱟᱹᱨ ᱯᱩᱨᱟᱹᱣ ᱢᱮ।',
      countingItems: [
        CountingExerciseItem(
          count: 4,
          shapeType: ExerciseShapeType.circle,
          color: Color(0xFFD84315),
          hindiNumber: 'वृत्त / गोला',
          englishNumber: 'Circle',
          santhaliWord: 'गुलाय',
          santhaliPhonetic: 'Gulay',
          santhaliOlChiki: 'ᱜᱩᱞᱟᱹᱭ',
        ),
        CountingExerciseItem(
          count: 3,
          shapeType: ExerciseShapeType.triangle,
          color: Color(0xFF00897B),
          hindiNumber: 'त्रिभुज',
          englishNumber: 'Triangle',
          santhaliWord: 'पे कोण',
          santhaliPhonetic: 'Pe Kon',
          santhaliOlChiki: 'ᱯᱮ ᱠᱳᱬ',
        ),
        CountingExerciseItem(
          count: 5,
          shapeType: ExerciseShapeType.square,
          color: Color(0xFF5E35B1),
          hindiNumber: 'चतुर्भुज / चौकोर',
          englishNumber: 'Square',
          santhaliWord: 'पून कोण',
          santhaliPhonetic: 'Pun Kon',
          santhaliOlChiki: 'ᱯᱩᱱ ᱠᱳᱬ',
        ),
      ],
      matchingPairs: [
        MatchingExercisePair(
          hindiTerm: 'वृत्त (गोला / रोटी)',
          englishHint: 'Circle / Round',
          santhaliTerm: 'गुलाय',
          santhaliPhonetic: 'Gulay',
          santhaliOlChiki: 'ᱜᱩᱞᱟᱹᱭ (Gulay)',
        ),
        MatchingExercisePair(
          hindiTerm: 'त्रिभुज (तीन कोने)',
          englishHint: 'Triangle (3 corners)',
          santhaliTerm: 'पे कोण',
          santhaliPhonetic: 'Pe Kon',
          santhaliOlChiki: 'ᱯᱮ ᱠᱳᱬ (Pe Kon)',
        ),
        MatchingExercisePair(
          hindiTerm: 'चतुर्भुज (चार कोने)',
          englishHint: 'Square / Rect (4 corners)',
          santhaliTerm: 'पून कोण',
          santhaliPhonetic: 'Pun Kon',
          santhaliOlChiki: 'ᱯᱩᱱ ᱠᱳᱬ (Pun Kon)',
        ),
        MatchingExercisePair(
          hindiTerm: 'बड़ा (Big)',
          englishHint: 'Big / Large',
          santhaliTerm: 'मारांग',
          santhaliPhonetic: 'Marang',
          santhaliOlChiki: 'ᱢᱟᱨᱟᱝ (Marang)',
        ),
        MatchingExercisePair(
          hindiTerm: 'छोटा (Small)',
          englishHint: 'Small',
          santhaliTerm: 'हुडिंग',
          santhaliPhonetic: 'Huding',
          santhaliOlChiki: 'ᱦᱩᱰᱤᱧ (Huding)',
        ),
      ],
      tracingItems: [
        TracingExerciseItem(
          symbol: '◯',
          hindiLabel: 'वृत्त',
          santhaliLabel: 'गुलाय (Gulay)',
          olChikiLabel: 'ᱜᱩᱞᱟᱹᱭ',
          phoneticGuide: 'Gulay',
        ),
        TracingExerciseItem(
          symbol: '△',
          hindiLabel: 'त्रिभुज',
          santhaliLabel: 'पे कोण (Pe Kon)',
          olChikiLabel: 'ᱯᱮ ᱠᱳᱬ',
          phoneticGuide: 'Pe Kon',
        ),
        TracingExerciseItem(
          symbol: '▢',
          hindiLabel: 'चतुर्भुज',
          santhaliLabel: 'पून कोण (Pun Kon)',
          olChikiLabel: 'ᱯᱩᱱ ᱠᱳᱬ',
          phoneticGuide: 'Pun Kon',
        ),
      ],
    ),

    // -------------------------------------------------------------
    // 6. Grade 3 - Language: Classroom & Daily Sentences (कक्षा व दैनिक बातचीत)
    // -------------------------------------------------------------
    WorksheetTemplate(
      id: 'g3_lang_sentences',
      grade: 'Grade 3',
      subject: 'भाषा एवं ध्वनि (Language & Phonics)',
      titleHindi: 'कक्षा वार्तालाप एवं सरल वाक्य रचना',
      titleEnglish: 'Classroom Routine Sentences & Phrasing',
      difficulty: 'उन्नत (Advanced)',
      nipunCode: 'FLN-L3.3',
      competencyTitle: 'द्विभाषी छोटे वाक्यों का अर्थ ग्रहण, पढ़ना व शिक्षक के साथ संवाद',
      instructionsHindi: 'वाक्यों का सही अर्थ समझकर मिलान करें और रिक्त स्थानों की पूर्ति करें।',
      instructionsSanthali: 'ᱟᱹᱭᱟᱹᱛ ᱠᱚᱨᱮᱱᱟᱜ ᱢᱮᱱᱮᱛ ᱵᱩᱡᱷᱟᱹᱣ ᱠᱟᱛᱮ ᱡᱚᱲᱟᱣ ᱢᱮ ᱟᱨ ᱠᱷᱟᱹᱞᱤ ᱴᱷᱟᱶ ᱯᱮᱨᱮᱡ ᱢᱮ।',
      countingItems: [
        CountingExerciseItem(
          count: 3,
          shapeType: ExerciseShapeType.apple,
          color: Color(0xFFD32F2F),
          hindiNumber: 'किताबें (Books)',
          englishNumber: 'Books',
          santhaliWord: 'पुथि (Puthi)',
          santhaliPhonetic: 'Puthi',
          santhaliOlChiki: 'ᱯᱩᱛᱷᱤ',
        ),
        CountingExerciseItem(
          count: 2,
          shapeType: ExerciseShapeType.tree,
          color: Color(0xFF388E3C),
          hindiNumber: 'शिक्षक (Teachers)',
          englishNumber: 'Teachers',
          santhaliWord: 'माचेत (Machet)',
          santhaliPhonetic: 'Machet',
          santhaliOlChiki: 'ᱢᱟᱪᱮᱛ',
        ),
        CountingExerciseItem(
          count: 5,
          shapeType: ExerciseShapeType.star,
          color: Color(0xFFFBC02D),
          hindiNumber: 'विद्यालय (School)',
          englishNumber: 'School',
          santhaliWord: 'आसड़ा (Asda)',
          santhaliPhonetic: 'Asda',
          santhaliOlChiki: 'ᱟᱥᱲᱟ',
        ),
      ],
      matchingPairs: [
        MatchingExercisePair(
          hindiTerm: 'नमस्ते बच्चों! (Hello children)',
          englishHint: 'Greeting',
          santhaliTerm: 'जोहार गिद्रा! (Johar Gidra)',
          santhaliPhonetic: 'Johar Gidra',
          santhaliOlChiki: 'ᱡᱚᱦᱟᱨ ᱜᱤᱫᱽᱨᱟᱹ',
        ),
        MatchingExercisePair(
          hindiTerm: 'बैठ जाओ (Sit down)',
          englishHint: 'Command',
          santhaliTerm: 'दुड़ुब मे (Dudub Me)',
          santhaliPhonetic: 'Dudub Me',
          santhaliOlChiki: 'ᱫᱩᱲᱩᱵ ᱢᱮ',
        ),
        MatchingExercisePair(
          hindiTerm: 'किताब खोलो (Open book)',
          englishHint: 'Classroom',
          santhaliTerm: 'पुथि ओताव मे (Puthi Otav Me)',
          santhaliPhonetic: 'Puthi Otav Me',
          santhaliOlChiki: 'ᱯᱩᱛᱷᱤ ᱚᱛᱟᱣ ᱢᱮ',
        ),
        MatchingExercisePair(
          hindiTerm: 'हाथ धो लो (Wash hands)',
          englishHint: 'Hygiene',
          santhaliTerm: 'ती अरुब मे (Ti Arub Me)',
          santhaliPhonetic: 'Ti Arub Me',
          santhaliOlChiki: 'ᱛᱤ ᱟᱹᱨᱩᱵ ᱢᱮ',
        ),
        MatchingExercisePair(
          hindiTerm: 'पानी पियो (Drink water)',
          englishHint: 'Health',
          santhaliTerm: 'दाग ञुय मे (Dag Nuy Me)',
          santhaliPhonetic: 'Dag Nuy Me',
          santhaliOlChiki: 'ᱫᱟᱜ ᱧᱩᱭ ᱢᱮ',
        ),
      ],
      tracingItems: [
        TracingExerciseItem(
          symbol: 'जोहार',
          hindiLabel: 'नमस्ते',
          santhaliLabel: 'जोहार (Johar)',
          olChikiLabel: 'ᱡᱚᱦᱟᱨ',
          phoneticGuide: 'Johar',
        ),
        TracingExerciseItem(
          symbol: 'पुथि',
          hindiLabel: 'किताब',
          santhaliLabel: 'पुथि (Book)',
          olChikiLabel: 'ᱯᱩᱛᱷᱤ',
          phoneticGuide: 'Puthi',
        ),
        TracingExerciseItem(
          symbol: 'माचेत',
          hindiLabel: 'शिक्षक',
          santhaliLabel: 'माचेत (Teacher)',
          olChikiLabel: 'ᱢᱟᱪᱮᱛ',
          phoneticGuide: 'Machet',
        ),
      ],
    ),
  ];

  static List<WorksheetTemplate> getTemplatesForGrade(String grade) {
    return allTemplates.where((t) => t.grade == grade).toList();
  }

  static WorksheetTemplate getTemplateById(String id) {
    return allTemplates.firstWhere(
      (t) => t.id == id,
      orElse: () => allTemplates.first,
    );
  }
}
