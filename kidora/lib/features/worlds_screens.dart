import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/routes/app_routes.dart';
import '../core/theme/app_theme.dart';
import '../providers/app_providers.dart';

// ==========================================
// ÉCRAN 7 : CARTE DES MONDES INTERACTIVE
// ==========================================
class WorldsMapScreen extends ConsumerWidget {
  const WorldsMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final child = ref.watch(activeChildProvider);
    final progressList = ref.watch(progressProvider);

    if (child == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final worldsAsync = ref.watch(worldsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carte des Mondes', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF7000FF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: worldsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur : $err')),
        data: (worlds) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF1FAEE), Color(0xFFE8F0FE)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: worlds.length,
              itemBuilder: (context, index) {
                final world = worlds[index];
                final progress = progressList.firstWhere(
                  (p) => p.subjectId == world.subjectId,
                  orElse: () => _createEmptyProgress(child.id!, world.subjectId),
                );

                final isUnlocked = child.level >= world.requiredLevel;
                final subjectColor = _getSubjectColor(world.subjectId);
                final subjectEmoji = _getSubjectEmoji(world.subjectId);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: InkWell(
                    onTap: isUnlocked
                        ? () {
                            // Naviguer vers le monde correspondant
                            Navigator.pushNamed(
                              context,
                              _getSubjectRoute(world.subjectId),
                              arguments: world,
                            );
                          }
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Verrouillé ! Atteins le niveau ${world.requiredLevel} pour débloquer ce monde ! 🌟'),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          },
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isUnlocked ? subjectColor.withOpacity(0.4) : Colors.grey.shade300,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: isUnlocked ? subjectColor.withOpacity(0.1) : Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                isUnlocked ? subjectEmoji : '🔒',
                                style: const TextStyle(fontSize: 36),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  world.name,
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: isUnlocked ? const Color(0xFF011627) : Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (isUnlocked) ...[
                                  Text(
                                    'Progression : ${progress.completedLessonsCount} leçons complétées',
                                    style: const TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: LinearProgressIndicator(
                                      value: progress.successRate / 100.0,
                                      backgroundColor: Colors.grey.shade100,
                                      valueColor: AlwaysStoppedAnimation<Color>(subjectColor),
                                      minHeight: 8,
                                    ),
                                  ),
                                ] else ...[
                                  Text(
                                    'Requis : Niveau ${world.requiredLevel} minimum',
                                    style: const TextStyle(fontSize: 13, color: Colors.redAccent, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (isUnlocked)
                            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Color _getSubjectColor(String subjectId) {
    switch (subjectId) {
      case 'math': return AppColors.math;
      case 'french': return AppColors.french;
      case 'science': return AppColors.science;
      case 'logic': return AppColors.logic;
      default: return AppColors.primary;
    }
  }

  String _getSubjectEmoji(String subjectId) {
    switch (subjectId) {
      case 'math': return '📐';
      case 'french': return '📖';
      case 'science': return '🔬';
      case 'logic': return '🧩';
      default: return '⭐';
    }
  }

  String _getSubjectRoute(String subjectId) {
    switch (subjectId) {
      case 'math': return AppRoutes.maths;
      case 'french': return AppRoutes.french;
      case 'science': return AppRoutes.science;
      case 'logic': return AppRoutes.logic;
      default: return AppRoutes.home;
    }
  }

  dynamic _createEmptyProgress(int childId, String subjectId) {
    return _EmptyProgress(childId, subjectId);
  }
}

class _EmptyProgress {
  final int childId;
  final String subjectId;
  final int completedLessonsCount = 0;
  final double successRate = 0.0;

  _EmptyProgress(this.childId, this.subjectId);
}

// =========================================================
// ÉCRANS 8 À 11 : LE MONDE GÉNÉRIQUE ET DYNAMIQUE PAR MATIÈRE
// =========================================================
class SubjectWorldScreen extends ConsumerWidget {
  final String subjectId;

  const SubjectWorldScreen({super.key, required this.subjectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final child = ref.watch(activeChildProvider);
    final progressList = ref.watch(progressProvider);

    if (child == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final String worldId = 'world_$subjectId';
    final lessonsAsync = ref.watch(lessonsByWorldProvider(worldId));

    final subjectColor = _getSubjectColor(subjectId);
    final subjectEmoji = _getSubjectEmoji(subjectId);
    final subjectName = _getSubjectName(subjectId);

    final progress = progressList.firstWhere(
      (p) => p.subjectId == subjectId,
      orElse: () => _EmptyProgress(child.id!, subjectId) as dynamic,
    );

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              backgroundColor: subjectColor,
              iconTheme: const IconThemeData(color: Colors.white),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  subjectName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [subjectColor, subjectColor.withOpacity(0.7)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 20,
                      bottom: 40,
                      child: Opacity(
                        opacity: 0.25,
                        child: Text(
                          subjectEmoji,
                          style: const TextStyle(fontSize: 90),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- BARRE DE PROGRESSION DU MONDE ---
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: subjectColor.withOpacity(0.2), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Progression Globale',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xCC000000)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${progress.completedLessonsCount} Leçons Validées',
                              style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: subjectColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${progress.successRate.toStringAsFixed(0)}% Étoiles',
                          style: TextStyle(color: subjectColor, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'Tes Leçons : 📖',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF011627),
                  ),
                ),
                const SizedBox(height: 12),

                // --- CHARGEMENT DES LEÇONS DEPUIS SQLITE ---
                lessonsAsync.when(
                  loading: () => const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
                  error: (err, stack) => Center(child: Text('Erreur : $err')),
                  data: (lessons) {
                    if (lessons.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Text('Aucune leçon disponible pour ton niveau.', style: TextStyle(fontSize: 16, color: Colors.grey)),
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: lessons.length,
                      itemBuilder: (context, index) {
                        final lesson = lessons[index];
                        final isFirst = index == 0;
                        // On débloque par défaut la première leçon ou si le taux précédent est suffisant
                        final isUnlocked = isFirst || (progress.completedLessonsCount >= index);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: InkWell(
                            onTap: isUnlocked
                                ? () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.lesson,
                                      arguments: lesson,
                                    );
                                  }
                                : () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Termine la leçon précédente pour débloquer celle-ci ! 🔓'),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                  },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isUnlocked ? Colors.white : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isUnlocked ? subjectColor.withOpacity(0.3) : Colors.grey.shade200,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: isUnlocked ? subjectColor.withOpacity(0.1) : Colors.grey.shade100,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        isUnlocked ? '${index + 1}' : '🔒',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: isUnlocked ? subjectColor : Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          lesson.title,
                                          style: TextStyle(
                                            fontFamily: 'Plus Jakarta Sans',
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: isUnlocked ? const Color(0xFF011627) : Colors.grey,
                                          ),
                                        ),
                                        if (lesson.description != null && isUnlocked) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            lesson.description!,
                                            style: const TextStyle(fontSize: 13, color: Colors.black54),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  if (isUnlocked)
                                    Icon(Icons.play_circle_fill, color: subjectColor, size: 32),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getSubjectColor(String subjectId) {
    switch (subjectId) {
      case 'math': return AppColors.math;
      case 'french': return AppColors.french;
      case 'science': return AppColors.science;
      case 'logic': return AppColors.logic;
      default: return AppColors.primary;
    }
  }

  String _getSubjectEmoji(String subjectId) {
    switch (subjectId) {
      case 'math': return '📐';
      case 'french': return '📖';
      case 'science': return '🔬';
      case 'logic': return '🧩';
      default: return '⭐';
    }
  }

  String _getSubjectName(String subjectId) {
    switch (subjectId) {
      case 'math': return 'Mathématiques';
      case 'french': return 'Français';
      case 'science': return 'Sciences';
      case 'logic': return 'Logique';
      default: return 'Matière';
    }
  }
}
