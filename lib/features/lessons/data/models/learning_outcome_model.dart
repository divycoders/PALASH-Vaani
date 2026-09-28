class LearningOutcomeModel {
  final String id;
  final String lessonId;
  final String code;
  final String descriptionHi;
  final String descriptionSat;
  final String descriptionEn;
  final String verificationStatus;

  const LearningOutcomeModel({
    required this.id,
    required this.lessonId,
    required this.code,
    required this.descriptionHi,
    required this.descriptionSat,
    required this.descriptionEn,
    this.verificationStatus = 'Prototype / Pending Native Verification',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lesson_id': lessonId,
      'code': code,
      'description_hi': descriptionHi,
      'description_sat': descriptionSat,
      'description_en': descriptionEn,
      'verification_status': verificationStatus,
    };
  }

  factory LearningOutcomeModel.fromMap(Map<String, dynamic> map) {
    return LearningOutcomeModel(
      id: map['id'] as String,
      lessonId: map['lesson_id'] as String,
      code: map['code'] as String,
      descriptionHi: map['description_hi'] as String,
      descriptionSat: map['description_sat'] as String,
      descriptionEn: map['description_en'] as String,
      verificationStatus: map['verification_status'] as String? ?? 'Prototype / Pending Native Verification',
    );
  }
}
