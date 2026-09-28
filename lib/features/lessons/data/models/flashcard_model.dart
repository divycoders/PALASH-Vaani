class FlashcardModel {
  final String id;
  final String category;
  final int itemIndex;
  final String visualSymbol;
  final String wordHi;
  final String wordSat;
  final String latin;
  final String description;
  final String? audioPath;
  final String verificationStatus;

  const FlashcardModel({
    required this.id,
    required this.category,
    required this.itemIndex,
    required this.visualSymbol,
    required this.wordHi,
    required this.wordSat,
    required this.latin,
    required this.description,
    this.audioPath,
    this.verificationStatus = 'Prototype / Pending Native Verification',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'item_index': itemIndex,
      'visual_symbol': visualSymbol,
      'word_hi': wordHi,
      'word_sat': wordSat,
      'latin': latin,
      'description': description,
      'audio_path': audioPath,
      'verification_status': verificationStatus,
    };
  }

  factory FlashcardModel.fromMap(Map<String, dynamic> map) {
    return FlashcardModel(
      id: map['id'] as String,
      category: map['category'] as String,
      itemIndex: map['item_index'] as int,
      visualSymbol: map['visual_symbol'] as String,
      wordHi: map['word_hi'] as String,
      wordSat: map['word_sat'] as String,
      latin: map['latin'] as String,
      description: map['description'] as String,
      audioPath: map['audio_path'] as String?,
      verificationStatus: map['verification_status'] as String? ?? 'Prototype / Pending Native Verification',
    );
  }
}
