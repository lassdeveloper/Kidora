import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/routes/app_routes.dart';
import '../core/theme/app_theme.dart';
import '../models/lesson.dart';

class ResultScreen extends ConsumerWidget {
  final Map<String, dynamic> data;

  const ResultScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Lesson lesson = data['lesson'] as Lesson;
    final int gainedXp = data['gainedXp'] as int;
    final int correctAnswers = data['correctAnswers'] as int;
    final int totalQuestions = data['totalQuestions'] as int;
    final List<String> newBadges = data['newBadges'] as List<String>;

    final double successPercentage = (correctAnswers / totalQuestions) * 100.0;
    final subjectColor = _getSubjectColorFromWorld(lesson.worldId);

    // Déterminer les étoiles
    int stars = 0;
    if (successPercentage >= 99.0) {
      stars = 3;
    } else if (successPercentage >= 60.0) {
      stars = 2;
    } else if (successPercentage >= 20.0) {
      stars = 1;
    }

    // Message personnalisé
    String congratsMessage = 'Continue tes efforts !';
    String congratsEmoji = '💪';
    if (stars == 3) {
      congratsMessage = 'Parfait ! Score magique !';
      congratsEmoji = '👑✨';
    } else if (stars == 2) {
      congratsMessage = 'Félicitations ! Très bon travail !';
      congratsEmoji = '🌟😎';
    } else if (stars == 1) {
      congratsMessage = 'Pas mal ! Tu progresses !';
      congratsEmoji = '👍🎈';
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFDFFFC), Color(0xFFE8F0FE)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        congratsEmoji,
                        style: const TextStyle(fontSize: 72),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        congratsMessage,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF011627),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tu as terminé la leçon : ${lesson.title}',
                        style: const TextStyle(fontSize: 15, color: Colors.black54, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // --- AFFICHAGE DES ÉTOILES ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          final isGold = index < stars;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Icon(
                              Icons.star,
                              color: isGold ? const Color(0xFFFFBF69) : Colors.grey.shade300,
                              size: 60,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 24),

                      // --- CARTES DES STATS (SCORE ET XP) ---
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              title: 'Score',
                              value: '$correctAnswers / $totalQuestions',
                              icon: '🎯',
                              color: const Color(0xFF2EC4B6),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              title: 'Points XP',
                              value: '+$gainedXp XP',
                              icon: '✨',
                              color: const Color(0xFFFF9F1C),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // --- EN-TÊTE BADGES DÉBLOQUÉS ---
                      if (newBadges.isNotEmpty) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF9F1C), Color(0xFFFFBF69)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF9F1C).withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                '🏆 NOUVEAU TROPHÉE DÉBLOQUÉ ! 🏆',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: newBadges.map((bId) {
                                  return Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      _getBadgeIcon(bId),
                                      style: const TextStyle(fontSize: 36),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Félicitations, va voir ton profil pour voir tous tes badges !',
                                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
                ),
              ),

              // --- BOUTONS D'ACTION EN BAS ---
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF9F1C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 4,
                        ),
                        child: const Text(
                          'Continuer vers l\'Accueil ➔',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  AppRoutes.exercise,
                                  arguments: lesson,
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: subjectColor, width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                'Recommencer 🔄',
                                style: TextStyle(color: subjectColor, fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context); // Retourner à l'écran du monde
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: subjectColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Mondes 🗺️',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
        ],
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

  String _getBadgeIcon(String badgeId) {
    switch (badgeId) {
      case 'badge_math_l1': return '🥇';
      case 'badge_french_l1': return '🎒';
      case 'badge_science_l1': return '🧪';
      case 'badge_logic_l1': return '🧠';
      case 'streak_3': return '🔥';
      case 'streak_7': return '👑';
      default: return '⭐';
    }
  }
}
