import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/services/audio_tts_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../data/flashcard_repository.dart';
import '../../models/flashcard_item.dart';
import '../widgets/flashcard_flip_card.dart';
import '../widgets/flashcard_grid_item.dart';

enum FlashcardViewMode {
  singleCard,
  gridView,
}

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  int _currentIndex = 0;
  String _selectedCategory = 'Numbers';
  int _flashcardStars = 0;
  FlashcardViewMode _viewMode = FlashcardViewMode.singleCard;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Timer? _autoPlayTimer;
  bool _isAutoPlayActive = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
        _currentIndex = 0;
      });
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  List<FlashcardItem> _getFilteredCards() {
    if (_searchQuery.isNotEmpty) {
      return FlashcardRepository.searchCards(_searchQuery);
    }
    return FlashcardRepository.getCardsByCategory(_selectedCategory);
  }

  void _onCategorySelected(String categoryId) {
    if (_selectedCategory == categoryId && _searchQuery.isEmpty) return;
    setState(() {
      _selectedCategory = categoryId;
      _searchController.clear();
      _searchQuery = '';
      _currentIndex = 0;
      _stopAutoPlay();
    });
  }

  void _toggleAutoPlay() {
    if (_isAutoPlayActive) {
      _stopAutoPlay();
    } else {
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    final cards = _getFilteredCards();
    if (cards.isEmpty) return;

    setState(() {
      _isAutoPlayActive = true;
      _viewMode = FlashcardViewMode.singleCard;
    });

    _speakWord(cards[_currentIndex < cards.length ? _currentIndex : 0]);

    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      final currentCards = _getFilteredCards();
      if (currentCards.isEmpty) {
        _stopAutoPlay();
        return;
      }
      setState(() {
        if (_currentIndex < currentCards.length - 1) {
          _currentIndex++;
        } else {
          _currentIndex = 0;
        }
      });
      _speakWord(currentCards[_currentIndex]);
    });
  }

  void _stopAutoPlay() {
    if (!_isAutoPlayActive) return;
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
    setState(() {
      _isAutoPlayActive = false;
    });
  }

  void _shuffleCards() {
    setState(() {
      _currentIndex = 0;
      _stopAutoPlay();
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔀 कार्ड क्रम बदल दिया गया है (Deck Shuffled)!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> _speakWord(FlashcardItem card) async {
    await AudioTtsService.instance.speak(card.santhaliDev, languageCode: 'hi-IN');
  }

  Future<void> _speakTeacherExplanation(FlashcardItem card) async {
    final hoClean = card.ho.split(' ')[0];
    final hiClean = card.hindi.split(' ')[0];
    final teacherScript = 'प्यारे बच्चों, इसे संथाली में कहते हैं ${card.santhaliDev}, हो भाषा में $hoClean, और हिंदी में $hiClean।';
    await AudioTtsService.instance.speak(teacherScript, languageCode: 'hi-IN');
  }

  Future<void> _speakSentence(FlashcardItem card) async {
    await AudioTtsService.instance.speak(card.exampleSentenceDev, languageCode: 'hi-IN');
  }

  Future<void> _practiceAndEarnStar(FlashcardItem card) async {
    await _speakWord(card);
    setState(() {
      _flashcardStars += 1;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.stars_rounded, color: Colors.amber, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '🌟 बहुत खूब! आपने सही उच्चारण किया! (+1 Star ⭐ कुल: $_flashcardStars)',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryDark,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _getStarLevelTitle() {
    if (_flashcardStars >= 15) {
      return 'NIPUN FLN मास्टर (Expert)';
    } else if (_flashcardStars >= 5) {
      return 'मातृभाषा शिक्षार्थी (Learner)';
    } else {
      return 'बालवाटिका खोजकर्ता (Explorer)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentCards = _getFilteredCards();
    final safeIndex = _currentIndex < currentCards.length ? _currentIndex : 0;
    final currentCard = currentCards.isNotEmpty ? currentCards[safeIndex] : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Gamified Star Reward Tracker
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber.shade50, Colors.amber.shade100.withValues(alpha: 0.5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade300),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.star_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 2,
                        children: [
                          Text(
                            '$_flashcardStars Stars ⭐',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _getStarLevelTitle(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'मातृभाषा में उच्चारण दोहराएं और स्टार्स जीतें!',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                // View Mode Toggle
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.view_carousel_outlined,
                          size: 20,
                          color: _viewMode == FlashcardViewMode.singleCard
                              ? AppColors.primary
                              : Colors.grey,
                        ),
                        tooltip: 'कार्ड व्यू',
                        onPressed: () {
                          setState(() => _viewMode = FlashcardViewMode.singleCard);
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.grid_view_rounded,
                          size: 20,
                          color: _viewMode == FlashcardViewMode.gridView
                              ? AppColors.primary
                              : Colors.grey,
                        ),
                        tooltip: 'कैटलॉग ग्रिड',
                        onPressed: () {
                          setState(() {
                            _viewMode = FlashcardViewMode.gridView;
                            _stopAutoPlay();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // 2. Search & Controls Bar
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'शब्द खोजें (उदा: बाघ, ᱫᱟᱨᱮ, Book, Tree)...',
                      hintStyle: const TextStyle(fontSize: 12),
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () => _searchController.clear(),
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Auto-play Button
              InkWell(
                onTap: _toggleAutoPlay,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: _isAutoPlayActive ? Colors.red.shade50 : AppColors.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isAutoPlayActive ? Colors.red : AppColors.primaryLight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isAutoPlayActive ? Icons.stop_circle_outlined : Icons.play_circle_outline,
                        color: _isAutoPlayActive ? Colors.red : AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isAutoPlayActive ? 'रोकें' : 'स्लाइड शो',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _isAutoPlayActive ? Colors.red : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // 3. Category Selector Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // "All" chip
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text('सभी (${FlashcardRepository.allCards.length})'),
                    selected: _selectedCategory == 'All' && _searchQuery.isEmpty,
                    selectedColor: AppColors.primaryContainer,
                    checkmarkColor: AppColors.primary,
                    onSelected: (_) => _onCategorySelected('All'),
                  ),
                ),
                ...FlashcardRepository.categories.map((cat) {
                  final isSelected = _selectedCategory == cat.id && _searchQuery.isEmpty;
                  final count = FlashcardRepository.getCardsByCategory(cat.id).length;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      avatar: Icon(cat.icon, size: 14, color: isSelected ? cat.color : Colors.grey.shade600),
                      label: Text('${cat.labelHi} ($count)'),
                      selected: isSelected,
                      selectedColor: cat.color.withValues(alpha: 0.18),
                      checkmarkColor: cat.color,
                      onSelected: (_) => _onCategorySelected(cat.id),
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // 4. Main Content Area
          if (currentCards.isEmpty)
            Container(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              alignment: Alignment.center,
              child: Column(
                children: [
                  const Icon(Icons.search_off_rounded, size: 48, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text(
                    'कोई फ़्लैशकार्ड नहीं मिला: "$_searchQuery"',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  AppButton(
                    label: 'सभी कार्ड देखें',
                    icon: Icons.refresh,
                    variant: AppButtonVariant.outlined,
                    onPressed: () {
                      _searchController.clear();
                      _onCategorySelected('All');
                    },
                  ),
                ],
              ),
            )
          else if (_viewMode == FlashcardViewMode.singleCard && currentCard != null) ...[
            // Single 3D Flip Card
            FlashcardFlipCard(
              card: currentCard,
              currentIndex: safeIndex,
              totalCount: currentCards.length,
              onSpeakWord: () => _speakWord(currentCard),
              onSpeakTeacherExplanation: () => _speakTeacherExplanation(currentCard),
              onSpeakSentence: () => _speakSentence(currentCard),
              onPracticeStar: () => _practiceAndEarnStar(currentCard),
            ),

            const SizedBox(height: AppSpacing.md),

            // Card Navigation Controls
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: AppButton(
                    label: 'पिछला',
                    icon: Icons.arrow_back,
                    variant: AppButtonVariant.secondary,
                    onPressed: safeIndex > 0
                        ? () {
                            setState(() => _currentIndex = safeIndex - 1);
                            _stopAutoPlay();
                          }
                        : null,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  icon: const Icon(Icons.shuffle_rounded),
                  tooltip: 'रैंडम कार्ड (Shuffle)',
                  onPressed: _shuffleCards,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  flex: 3,
                  child: AppButton(
                    label: 'अगला',
                    icon: Icons.arrow_forward,
                    variant: AppButtonVariant.primary,
                    onPressed: safeIndex < currentCards.length - 1
                        ? () {
                            setState(() => _currentIndex = safeIndex + 1);
                            _stopAutoPlay();
                          }
                        : null,
                  ),
                ),
              ],
            ),
          ] else ...[
            // 2-Column Catalog Grid View
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: currentCards.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.95,
              ),
              itemBuilder: (context, index) {
                final card = currentCards[index];
                return FlashcardGridItem(
                  card: card,
                  onTap: () {
                    setState(() {
                      _currentIndex = index;
                      _viewMode = FlashcardViewMode.singleCard;
                    });
                  },
                  onSpeak: () => _speakWord(card),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
