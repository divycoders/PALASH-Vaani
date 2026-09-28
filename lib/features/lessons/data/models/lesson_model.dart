class LessonModel {
  final String id;
  final String grade;
  final String subject;
  final String topic;
  final String titleHi;
  final String titleSat;
  final String titleEn;
  final String objectiveHi;
  final String objectiveSat;
  final String contentHi;
  final String contentSat;
  final String activityHi;
  final String activitySat;
  final String assessmentHi;
  final String assessmentSat;
  final String verificationStatus;
  final bool isCompleted;
  final String createdAt;

  const LessonModel({
    required this.id,
    required this.grade,
    required this.subject,
    required this.topic,
    required this.titleHi,
    required this.titleSat,
    required this.titleEn,
    required this.objectiveHi,
    required this.objectiveSat,
    required this.contentHi,
    required this.contentSat,
    required this.activityHi,
    required this.activitySat,
    required this.assessmentHi,
    required this.assessmentSat,
    this.verificationStatus = 'Prototype / Pending Native Verification',
    this.isCompleted = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'grade': grade,
      'subject': subject,
      'topic': topic,
      'title_hi': titleHi,
      'title_sat': titleSat,
      'title_en': titleEn,
      'objective_hi': objectiveHi,
      'objective_sat': objectiveSat,
      'content_hi': contentHi,
      'content_sat': contentSat,
      'activity_hi': activityHi,
      'activity_sat': activitySat,
      'assessment_hi': assessmentHi,
      'assessment_sat': assessmentSat,
      'verification_status': verificationStatus,
      'is_completed': isCompleted ? 1 : 0,
      'created_at': createdAt,
    };
  }

  factory LessonModel.fromMap(Map<String, dynamic> map) {
    return LessonModel(
      id: map['id'] as String,
      grade: map['grade'] as String,
      subject: map['subject'] as String,
      topic: map['topic'] as String,
      titleHi: map['title_hi'] as String,
      titleSat: map['title_sat'] as String,
      titleEn: map['title_en'] as String,
      objectiveHi: map['objective_hi'] as String,
      objectiveSat: map['objective_sat'] as String,
      contentHi: map['content_hi'] as String,
      contentSat: map['content_sat'] as String,
      activityHi: map['activity_hi'] as String,
      activitySat: map['activity_sat'] as String,
      assessmentHi: map['assessment_hi'] as String,
      assessmentSat: map['assessment_sat'] as String,
      verificationStatus: map['verification_status'] as String? ?? 'Prototype / Pending Native Verification',
      isCompleted: (map['is_completed'] as int? ?? 0) == 1,
      createdAt: map['created_at'] as String,
    );
  }
}
