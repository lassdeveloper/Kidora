import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/routes/app_routes.dart';
import '../core/theme/app_theme.dart';
import '../models/lesson.dart';
import '../models/exercise.dart';
import '../models/exercise_answer.dart';
import '../providers/app_providers.dart';

class ExerciseScreen extends ConsumerStatefulWidget {
  final Lesson lesson;

  const ExerciseScreen({super.key, required this.lesson});

  @override
  ConsumerState<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends ConsumerState<ExerciseScreen> {
  int _currentIndex = 0;
  String? _selectedAnswer;
  bool _isSubmitted = false;
  bool _isAnswerCorrect = false;
  final TextEditingController _textController = TextEditingController();

  final List<bool> _lessonResults = [];
  final List<ExerciseAnswer> _answersToSave = [];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submitAnswer(Exercise exercise) {
    if (_isSubmitted) return;

    final String finalAnswer = exercise.type == 'input' 
        ? _textController.text.trim() 
        : _selectedAnswer ?? '';

    if (finalAnswer.isEmpty && exercise.type != 'input') return;

    final isCorrect = finalAnswer.toLowerCase() == exercise.correctAnswer.toLowerCase();

    setState(() {
      _isSubmitted = true;
      _isAnswerCorrect = isCorrect;
      _lessonResults.add(isCorrect);
    });

    final child = ref.read(activeChildProvider);
    if (child != null && child.id != null) {
      final answer = ExerciseAnswer(
        childId: child.id!,
        exerciseId: exercise.id,
        isCorrect: isCorrect,
        answeredAt: DateTime.now(),
      );
      _answersToSave.add(answer);
    }
  }

  void _nextQuestion(List<Exercise> exercises) async {
    if (_currentIndex < exercises.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _isSubmitted = false;
        _textController.clear();
      });
    } else {
      // Toutes les questions de la leçon ont été complétées !
      final child = ref.read(activeChildProvider);
      if (child != null && child.id != null) {
        final exerciseRepo = ref.read(exerciseRepositoryProvider);

        // 1. Enregistrer toutes les réponses dans SQLite
        for (var ans in _answersToSave) {
          await exerciseRepo.insertAnswer(ans);
        }

        // 2. Calculer l'XP total gagné pour la leçon
        final baseVal = exercises.isNotEmpty ? exercises.first.xpValue : 10;
        final xpGained = _calculateLessonXp(_lessonResults, baseVal);

        // 3. Créditer l'XP à l'enfant actif
        await ref.read(activeChildProvider.notifier).earnXp(xpGained);

        // 4. Mettre à jour la progression de la matière
        final progressRepo = ref.read(progressRepositoryProvider);
        final subjectId = _getSubjectIdFromWorld(widget.lesson.worldId);
        final existingProgress = await progressRepo.getProgressByChildAndSubject(child.id!, subjectId);
        
        final completedCount = (existingProgress?.completedLessonsCount ?? 0) + 1;
        final successRate = (_lessonResults.where((r) => r).length / exercises.length) * 100.0;

        await ref.read(progressProvider.notifier).updateSubjectProgress(
          child.id!,
          subjectId,
          completedCount,
          successRate,
        );

        // 5. Vérifier les badges (Trophées) débloqués
        final badgeRepo = ref.read(badgeRepositoryProvider);
        final allAnswers = await exerciseRepo.getAnswersByChild(child.id!);
        final currentlyUnlocked = ref.read(badgesProvider);
        
        final badgeService = ref.read(badgeServiceProvider);
        final newlyUnlocked = await badgeService.checkAndUnlockBadges(
          child: child,
          answers: allAnswers,
          currentlyUnlocked: currentlyUnlocked,
        );

        // Rediriger vers l'écran des résultats
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.result,
            arguments: {
              'lesson': widget.lesson,
              'gainedXp': xpGained,
              'correctAnswers': _lessonResults.where((r) => r).length,
              'totalQuestions': exercises.length,
              'newBadges': newlyUnlocked,
            },
          );
        }
      }
    }
  }

  int _calculateLessonXp(List<bool> results, int baseVal) {
    if (results.isEmpty) return 0;
    int total = 0;
    for (var r in results) {
      if (r) total += baseVal;
    }
    // Bonus de leçon complétée
    total += 50;
    // Bonus de score parfait
    if (results.every((r) => r)) {
      total += 30;
    }
    return total;
  }

  String _getSubjectIdFromWorld(String worldId) {
    if (worldId.contains('math')) return 'math';
    if (worldId.contains('french')) return 'french';
    if (worldId.contains('science')) return 'science';
    if (worldId.contains('logic')) return 'logic';
    return '';
  }

  Color _getSubjectColorFromWorld(String worldId) {
    if (worldId.contains('math')) return AppColors.math;
    if (worldId.contains('french')) return AppColors.french;
    if (worldId.contains('science')) return AppColors.science;
    if (worldId.contains('logic')) return AppColors.logic;
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(exercisesByLessonProvider(widget.lesson.id));
    final subjectColor = _getSubjectColorFromWorld(widget.lesson.worldId);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: subjectColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: exercisesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur : $err')),
        data: (exercises) {
          if (exercises.isEmpty) {
            return const Center(child: Text('Aucun exercice disponible pour cette leçon.', style: TextStyle(fontSize: 16, color: Colors.grey)));
          }

          final exercise = exercises[_currentIndex];

          return SafeArea(
            child: Column(
              children: [
                // --- PROGRESSION VISUELLE ---
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: (_currentIndex + 1) / exercises.length,
                            backgroundColor: Colors.grey.shade100,
                            valueColor: AlwaysStoppedAnimation<Color>(subjectColor),
                            minHeight: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${_currentIndex + 1} / ${exercises.length}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ),

                // --- CONTAINER DE LA QUESTION ---
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (exercise.visualData != null && exercise.visualData!.isNotEmpty) ...[
                          Text(
                            exercise.visualData!,
                            style: const TextStyle(fontSize: 80),
                          ),
                          const SizedBox(height: 16),
                        ],
                        Text(
                          exercise.question,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF011627),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // --- INTERFACES DES RÉPONSES SELON TYPE ---
                        _buildAnswerInterface(exercise, subjectColor),
                      ],
                    ),
                  ),
                ),

                // --- FEEDBACK EN BAS DE L'ÉCRAN ---
                _buildFeedbackPanel(exercise, exercises, subjectColor),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnswerInterface(Exercise exercise, Color subjectColor) {
    if (exercise.type == 'qcm') {
      return Column(
        children: exercise.options.map((opt) {
          final isSelected = _selectedAnswer == opt;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _isSubmitted
                    ? null
                    : () {
                        setState(() {
                          _selectedAnswer = opt;
                        });
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? subjectColor.withOpacity(0.1) : Colors.white,
                  foregroundColor: Colors.black,
                  surfaceTintColor: Colors.white,
                  elevation: 2,
                  side: BorderSide(
                    color: isSelected ? subjectColor : Colors.grey.shade300,
                    width: isSelected ? 3 : 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  opt,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? subjectColor : const Color(0xFF011627),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }).toList(),
      );
    } else if (exercise.type == 'true_false') {
      final options = ['Vrai', 'Faux'];
      return Row(
        children: options.map((opt) {
          final isSelected = _selectedAnswer == opt;
          final optColor = opt == 'Vrai' ? const Color(0xFF38B000) : const Color(0xFFE71D36);
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: SizedBox(
                height: 80,
                child: ElevatedButton(
                  onPressed: _isSubmitted
                      ? null
                      : () {
                          setState(() {
                            _selectedAnswer = opt;
                          });
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected ? optColor.withOpacity(0.1) : Colors.white,
                    foregroundColor: optColor,
                    surfaceTintColor: Colors.white,
                    elevation: 2,
                    side: BorderSide(
                      color: isSelected ? optColor : Colors.grey.shade300,
                      width: isSelected ? 3 : 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    opt,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? optColor : const Color(0xFF011627),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      );
    } else if (exercise.type == 'input') {
      return Column(
        children: [
          TextField(
            controller: _textController,
            enabled: !_isSubmitted,
            keyboardType: TextInputType.text,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: 'Écris ta réponse ici...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: subjectColor, width: 2),
              ),
            ),
          ),
        ],
      );
    }
    return const SizedBox();
  }

  Widget _buildFeedbackPanel(Exercise exercise, List<Exercise> exercises, Color subjectColor) {
    if (!_isSubmitted) {
      final bool canSubmit = exercise.type == 'input' 
          ? _textController.text.isNotEmpty 
          : _selectedAnswer != null;

      return Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: canSubmit ? () => _submitAnswer(exercise) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: subjectColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Vérifier ma réponse ! 👍',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      );
    }

    final panelColor = _isAnswerCorrect ? const Color(0xFF38B000) : const Color(0xFFE71D36);

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: panelColor.withOpacity(0.12),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border(
          top: BorderSide(color: panelColor, width: 3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _isAnswerCorrect ? '🎉 Super Juste !' : '💡 Presque !',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: panelColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _isAnswerCorrect 
                ? 'Excellent travail ! Tu as vu juste.' 
                : 'La bonne réponse était : ${exercise.correctAnswer}.',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF011627)),
          ),
          if (exercise.explanation != null) ...[
            const SizedBox(height: 4),
            Text(
              exercise.explanation!,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => _nextQuestion(exercises),
              style: ElevatedButton.styleFrom(
                backgroundColor: panelColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                _currentIndex == exercises.length - 1 ? 'Terminer ! 🏁' : 'Continuer ➔',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
