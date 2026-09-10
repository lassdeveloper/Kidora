import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/routes/app_routes.dart';
import '../core/theme/app_theme.dart';
import '../models/lesson.dart';

class LessonDetailScreen extends ConsumerWidget {
  final Lesson lesson;

  const LessonDetailScreen({super.key, required this.lesson});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectColor = _getSubjectColorFromWorld(lesson.worldId);
    final subjectEmoji = _getSubjectEmojiFromWorld(lesson.worldId);

    // Générer du contenu pédagogique simulé de manière intelligente selon le type de leçon
    final pedagogicalContent = _getPedagogicalContent(lesson.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(lesson.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: subjectColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: const Color(0xFFFDFFFC),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- HEADER LUDIQUE ---
                      Center(
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: subjectColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              subjectEmoji,
                              style: const TextStyle(fontSize: 48),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Text(
                          lesson.title,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF011627),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (lesson.description != null) ...[
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            lesson.description!,
                            style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),

                      // --- EN-TÊTE DE SECTION ---
                      const Row(
                        children: [
                          Text('💡', style: TextStyle(fontSize: 22)),
                          SizedBox(width: 8),
                          Text(
                            'Ce que nous allons apprendre :',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF011627),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // --- EXPLICATIONS ET EXEMPLES ---
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: subjectColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: subjectColor.withOpacity(0.2), width: 2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pedagogicalContent['concept']!,
                              style: const TextStyle(fontSize: 16, color: Color(0xFF011627), height: 1.5, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Exemple concret :',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black54),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200, width: 1.5),
                              ),
                              child: Text(
                                pedagogicalContent['example']!,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: subjectColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // --- PETIT CONSEIL COMPAGNON ---
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFBF69).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFFFBF69).withOpacity(0.3), width: 2),
                        ),
                        child: const Row(
                          children: [
                            Text('🦊', style: TextStyle(fontSize: 32)),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Prends ton temps, lis bien la question et tout se passera super bien ! Tu es capable de tout réussir ! 💪',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xCC000000)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- BOUTON DE LANCEMENT ---
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.exercise,
                        arguments: lesson,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: subjectColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      'Commencer les exercices ! 🚀',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getSubjectColorFromWorld(String worldId) {
    if (worldId.contains('math')) return AppColors.math;
    if (worldId.contains('french')) return AppColors.french;
    if (worldId.contains('science')) return AppColors.science;
    if (worldId.contains('logic')) return AppColors.logic;
    return AppColors.primary;
  }

  String _getSubjectEmojiFromWorld(String worldId) {
    if (worldId.contains('math')) return '📐';
    if (worldId.contains('french')) return '📖';
    if (worldId.contains('science')) return '🔬';
    if (worldId.contains('logic')) return '🧩';
    return '⭐';
  }

  Map<String, String> _getPedagogicalContent(String lessonId) {
    if (lessonId.contains('math_count')) {
      return {
        'concept': 'Apprendre à dénombrer les objets de 1 à 10 de manière visuelle et rapide. Compter est la base absolue de toutes les mathématiques !',
        'example': '🍎 + 🍎 + 🍎 = 3 Pommes !',
      };
    } else if (lessonId.contains('math_add')) {
      return {
        'concept': 'L\'addition permet d\'assembler deux collections d\'objets pour trouver la somme totale.',
        'example': '3 billes bleues + 2 billes rouges = 5 billes !',
      };
    } else if (lessonId.contains('french_alpha')) {
      return {
        'concept': 'Reconnaître les lettres de l\'alphabet, distinguer les voyelles des consonnes et associer les sons.',
        'example': 'La lettre "A" fait le son [a] comme dans "Ananas" 🍍',
      };
    } else if (lessonId.contains('science_body')) {
      return {
        'concept': 'Découvrir le corps humain, les différents membres de notre anatomie ainsi que nos cinq fantastiques sens.',
        'example': 'Nous utilisons nos 👀 Yeux pour voir et nos 👂 Oreilles pour entendre !',
      };
    } else if (lessonId.contains('logic_seq')) {
      return {
        'concept': 'Repérer des suites logiques, des régularités géométriques ou de couleurs pour ordonner des objets de manière ordonnée.',
        'example': '🔴 🔵 🔴 🔵 ... La suite logique est 🔴 !',
      };
    }
    return {
      'concept': 'Explorons ensemble les notions clés de ce chapitre à l\'aide d\'exercices amusants, concrets et très visuels.',
      'example': 'Lis attentivement la question et fais de ton mieux !',
    };
  }
}
