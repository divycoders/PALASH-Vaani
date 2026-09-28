class ClassroomPhraseModel {
  final String id;
  final String intent;
  final String hindi;
  final String santhali;
  final String olChiki;
  final String latin;
  final String? audioPath;
  final String verificationStatus;

  const ClassroomPhraseModel({
    required this.id,
    required this.intent,
    required this.hindi,
    required this.santhali,
    required this.olChiki,
    required this.latin,
    this.audioPath,
    this.verificationStatus = 'Prototype / Pending Native Verification',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'intent': intent,
      'hindi': hindi,
      'santhali': santhali,
      'ol_chiki': olChiki,
      'latin': latin,
      'audio_path': audioPath,
      'verification_status': verificationStatus,
    };
  }

  factory ClassroomPhraseModel.fromMap(Map<String, dynamic> map) {
    return ClassroomPhraseModel(
      id: map['id'] as String,
      intent: map['intent'] as String,
      hindi: map['hindi'] as String,
      santhali: map['santhali'] as String,
      olChiki: map['ol_chiki'] as String,
      latin: map['latin'] as String,
      audioPath: map['audio_path'] as String?,
      verificationStatus: map['verification_status'] as String? ?? 'Prototype / Pending Native Verification',
    );
  }
}
