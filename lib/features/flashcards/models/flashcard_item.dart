import 'package:flutter/material.dart';

/// Data model representing a bilingual/multilingual flashcard
/// for Jharkhand primary school classrooms (PALASH MTB-MLE).
class FlashcardItem {
  final String id;
  final String category;
  final String categoryLabel;
  final String visualSymbol;
  final String hindi;
  final String santhali;
  final String santhaliDev;
  final String santhaliLatin;
  final String ho;
  final String mundari;
  final String englishMeaning;
  final String flnCode;
  final Color accentColor;
  final String exampleSentenceSanthali;
  final String exampleSentenceDev;
  final String exampleSentenceHi;
  final String teacherTip;

  const FlashcardItem({
    required this.id,
    required this.category,
    required this.categoryLabel,
    required this.visualSymbol,
    required this.hindi,
    required this.santhali,
    required this.santhaliDev,
    required this.santhaliLatin,
    required this.ho,
    required this.mundari,
    required this.englishMeaning,
    required this.flnCode,
    required this.accentColor,
    required this.exampleSentenceSanthali,
    required this.exampleSentenceDev,
    required this.exampleSentenceHi,
    required this.teacherTip,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'category_label': categoryLabel,
      'visual_symbol': visualSymbol,
      'hindi': hindi,
      'santhali': santhali,
      'santhali_dev': santhaliDev,
      'santhali_latin': santhaliLatin,
      'ho': ho,
      'mundari': mundari,
      'english_meaning': englishMeaning,
      'fln_code': flnCode,
      'accent_color': accentColor.toARGB32(),
      'example_sentence_santhali': exampleSentenceSanthali,
      'example_sentence_dev': exampleSentenceDev,
      'example_sentence_hi': exampleSentenceHi,
      'teacher_tip': teacherTip,
    };
  }

  factory FlashcardItem.fromMap(Map<String, dynamic> map) {
    return FlashcardItem(
      id: map['id'] as String,
      category: map['category'] as String,
      categoryLabel: map['category_label'] as String,
      visualSymbol: map['visual_symbol'] as String,
      hindi: map['hindi'] as String,
      santhali: map['santhali'] as String,
      santhaliDev: map['santhali_dev'] as String,
      santhaliLatin: map['santhali_latin'] as String,
      ho: map['ho'] as String,
      mundari: map['mundari'] as String,
      englishMeaning: map['english_meaning'] as String,
      flnCode: map['fln_code'] as String,
      accentColor: Color(map['accent_color'] as int? ?? 0xFF0D9488),
      exampleSentenceSanthali: map['example_sentence_santhali'] as String? ?? '',
      exampleSentenceDev: map['example_sentence_dev'] as String? ?? '',
      exampleSentenceHi: map['example_sentence_hi'] as String? ?? '',
      teacherTip: map['teacher_tip'] as String? ?? '',
    );
  }
}
