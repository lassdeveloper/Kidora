import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/routes/app_routes.dart';
import '../core/theme/app_theme.dart';
import '../providers/app_providers.dart';

// ==========================================
// ÉCRAN 17 : PROFIL ENFANT
// ==========================================
class ChildProfileScreen extends ConsumerWidget {
  const ChildProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final child = ref.watch(activeChildProvider);
    final progressList = ref.watch(progressProvider);
    final unlockedBadges = ref.watch(badgesProvider);

    if (child == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final int unlockedCount = unlockedBadges.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFFFF9F1C),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFF1FAEE).withOpacity(0.3),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // --- COMPAGNON AVATAR CARD ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFFF9F1C).withOpacity(0.3), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFBF69).withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          child.avatar,
                          style: const TextStyle(fontSize: 64),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      child.name,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF011627),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${child.age} ans • Niveau Scolaire : ${child.schoolLevel.toUpperCase()}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildBadgeMiniStat('✨ ${child.xp} XP', const Color(0xFFFF9F1C)),
                        const SizedBox(width: 12),
                        _buildBadgeMiniStat('🎖️ Niveau ${child.level}', const Color(0xFF2EC4B6)),
                        const SizedBox(width: 12),
                        _buildBadgeMiniStat('🏆 $unlockedCount Badges', const Color(0xFF7000FF)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- BOUTON DE GALERIE DE BADGES ---
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.badges),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF7000FF).withOpacity(0.2), width: 2),
                  ),
                  child: const Row(
                    children: [
                      Text('🏆', style: TextStyle(fontSize: 28)),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Voir ma vitrine de trophées',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF7000FF)),
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, color: Color(0xFF7000FF), size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- STATISTIQUES PAR MATIÈRE ---
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Ma Progression Pédagogique :',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF011627),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              _buildProgressRow('Mathématiques', 'math', progressList),
              _buildProgressRow('Français', 'french', progressList),
              _buildProgressRow('Sciences', 'science', progressList),
              _buildProgressRow('Logique', 'logic', progressList),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadgeMiniStat(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }

  Widget _buildProgressRow(String title, String subjectId, List<dynamic> progressList) {
    final progress = progressList.firstWhere(
      (p) => p.subjectId == subjectId,
      orElse: () => _EmptyProgressProfile(subjectId),
    );

    final color = _getSubjectColor(subjectId);
    final emoji = _getSubjectEmoji(subjectId);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text(
                      '${progress.completedLessonsCount} chap. validés',
                      style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(
                    value: progress.successRate / 100.0,
                    backgroundColor: Colors.grey.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
        ],
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
}

class _EmptyProgressProfile {
  final String subjectId;
  final int completedLessonsCount = 0;
  final double successRate = 0.0;

  _EmptyProgressProfile(this.subjectId);
}

// ==========================================
// ÉCRAN 18 : GALERIE DE BADGES
// ==========================================
class BadgesGalleryScreen extends ConsumerWidget {
  const BadgesGalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unlockedBadges = ref.watch(badgesProvider);
    final allBadgesAsync = ref.watch(allBadgesProvider);

    final unlockedSet = unlockedBadges.map((ub) => ub.badgeId).toSet();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Trophées', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF7000FF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: allBadgesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur : $err')),
        data: (allBadges) {
          return GridView.builder(
            padding: const EdgeInsets.all(24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: allBadges.length,
            itemBuilder: (context, index) {
              final badge = allBadges[index];
              final isUnlocked = unlockedSet.contains(badge.id);

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isUnlocked ? const Color(0xFFFFBF69) : Colors.grey.shade200,
                    width: isUnlocked ? 3 : 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icône floutée/grisée si bloquée
                    ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        isUnlocked ? Colors.transparent : Colors.grey,
                        BlendMode.saturation,
                      ),
                      child: Text(
                        badge.icon,
                        style: const TextStyle(fontSize: 48),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      badge.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isUnlocked ? const Color(0xFF011627) : Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      badge.description,
                      style: const TextStyle(fontSize: 11, color: Colors.black54),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isUnlocked ? const Color(0xFF38B000).withOpacity(0.12) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isUnlocked ? 'Débloqué !' : 'Verrouillé',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isUnlocked ? const Color(0xFF38B000) : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
