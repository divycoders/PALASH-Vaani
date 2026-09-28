class VocabularyModel {
  final String id;
  final String? lessonId;
  final String wordHi;
  final String wordSat;
  final String olChiki;
  final String latin;
  final String meaningEn;
  final String category;
  final String verificationStatus;

  const VocabularyModel({
    required this.id,
    this.lessonId,
    required this.wordHi,
    required this.wordSat,
    required this.olChiki,
    required this.latin,
    required this.meaningEn,
    required this.category,
    this.verificationStatus = 'Prototype / Pending Native Verification',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lesson_id': lessonId,
      'word_hi': wordHi,
      'word_sat': wordSat,
      'ol_chiki': olChiki,
      'latin': latin,
      'meaning_en': meaningEn,
      'category': category,
      'verification_status': verificationStatus,
    };
  }

  factory VocabularyModel.fromMap(Map<String, dynamic> map) {
    return VocabularyModel(
      id: map['id'] as String,
      lessonId: map['lesson_id'] as String?,
      wordHi: map['word_hi'] as String,
      wordSat: map['word_sat'] as String,
      olChiki: map['ol_chiki'] as String,
      latin: map['latin'] as String,
      meaningEn: map['meaning_en'] as String,
      category: map['category'] as String,
      verificationStatus: map['verification_status'] as String? ?? 'Prototype / Pending Native Verification',
    );
  }
}
