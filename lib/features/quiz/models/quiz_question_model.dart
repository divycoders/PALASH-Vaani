/// Model definitions for PALASH-Vaani Interactive Kids Dynamic Quiz
class QuizOption {
  final String label;
  final String? scriptText; // e.g. Ol Chiki or equation
  final String? phonetic; // e.g. Devanagari phonetic guide
  final String? visual; // Emoji or badge
  final bool isCorrect;

  const QuizOption({
    required this.label,
    this.scriptText,
    this.phonetic,
    this.visual,
    required this.isCorrect,
  });
}

class QuizQuestion {
  final String id;
  final String category; // 'Maths', 'Language', 'EVS'
  final String titleHi;
  final String? titleSat; // Ol Chiki title
  final String spokenAudioPrompt; // Teacher narration for pre-literate kids
  final String visualSymbol;
  final List<QuizOption> options;
  final String explanation; // Pedagogical explanation shown on answer

  const QuizQuestion({
    required this.id,
    required this.category,
    required this.titleHi,
    this.titleSat,
    required this.spokenAudioPrompt,
    required this.visualSymbol,
    required this.options,
    required this.explanation,
  });
}
