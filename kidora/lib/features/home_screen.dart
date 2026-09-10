import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/routes/app_routes.dart';
import '../core/theme/app_theme.dart';
import '../providers/app_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Timer? _minutesTimer;

  @override
  void initState() {
    super.initState();
    // Démarrer un minuteur pour décompter le temps d'utilisation (1 minute par minute réelle d'activité)
    _minutesTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _incrementTimeUsage();
    });
  }

  void _incrementTimeUsage() {
    final activeChild = ref.read(activeChildProvider);
    if (activeChild != null) {
      ref.read(dailyLimitProvider.notifier).useMinutes(1).then((_) {
        // Re-vérifier s'il a dépassé la limite
        final limit = ref.read(dailyLimitProvider);
        if (limit != null && limit.minutesUsedToday >= limit.maxMinutesPerDay) {
          // Bloquer l'accès en naviguant vers l'écran de pause/limite
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.pause, (route) => false);
        }
      });
    }
  }

  @override
  void dispose() {
    _minutesTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = ref.watch(activeChildProvider);
    final limit = ref.watch(dailyLimitProvider);
    final unlockedBadges = ref.watch(badgesProvider);

    // Si pas d'enfant actif, on redirige vers Welcome (sécurité)
    if (child == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, AppRoutes.welcome);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Charger les badges et progressions au démarrage si pas déjà fait
    if (child.id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(badgesProvider.notifier).loadUnlockedBadges(child.id!);
        ref.read(progressProvider.notifier).loadProgress(child.id!);
      });
    }

    final minutesRemaining = limit != null ? (limit.maxMinutesPerDay - limit.minutesUsedToday) : 30;
    final progressPercentage = (child.xp % 100) / 100.0;

    return Scaffold(
      body: Container(
        color: const Color(0xFFF1FAEE).withOpacity(0.4),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- HEADER DE L'ENFANT ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFFFF9F1C), width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  child.avatar,
                                  style: const TextStyle(fontSize: 32),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Salut ${child.name} ! 👋',
                                  style: const TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF011627),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF9F1C),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Niveau ${child.level}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Bouton Espace Parents avec challenge
                      IconButton(
                        icon: const Icon(Icons.lock, color: Colors.grey, size: 28),
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.parentAccess);
                        },
                        tooltip: 'Espace Parents',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // --- BARRE DE PROGRESSION ET STATS ---
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE0E0E0), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Text('✨', style: TextStyle(fontSize: 20)),
                                const SizedBox(width: 6),
                                Text(
                                  '${child.xp} XP',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Text('⏱️', style: TextStyle(fontSize: 20)),
                                const SizedBox(width: 6),
                                Text(
                                  '$minutesRemaining min restantes',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: minutesRemaining <= 5 ? Colors.red : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progressPercentage,
                            backgroundColor: Colors.grey.shade100,
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2EC4B6)),
                            minHeight: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Encore ${(100 - (child.xp % 100))} XP pour le niveau suivant !',
                            style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- BANDEAU JEUX / CARTE ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Choisis ton aventure : 🚀',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF011627),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.games),
                        icon: const Icon(Icons.sports_esports, color: Color(0xFF2EC4B6)),
                        label: const Text(
                          'Mini-Jeux',
                          style: TextStyle(color: Color(0xFF2EC4B6), fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // --- LES 4 MONDES (GRANDS BOUTONS TACTILES) ---
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.95,
                    children: [
                      _buildSubjectCard(
                        context: context,
                        title: 'Maths',
                        subtitle: 'L\'Île des Chiffres',
                        icon: '📐',
                        color: AppColors.math,
                        route: AppRoutes.maths,
                      ),
                      _buildSubjectCard(
                        context: context,
                        title: 'Français',
                        subtitle: 'La Forêt des Mots',
                        icon: '📖',
                        color: AppColors.french,
                        route: AppRoutes.french,
                      ),
                      _buildSubjectCard(
                        context: context,
                        title: 'Sciences',
                        subtitle: 'Labo de Chimie',
                        icon: '🔬',
                        color: AppColors.science,
                        route: AppRoutes.science,
                      ),
                      _buildSubjectCard(
                        context: context,
                        title: 'Logique',
                        subtitle: 'Royaume des Puzzles',
                        icon: '🧩',
                        color: AppColors.logic,
                        route: AppRoutes.logic,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // --- BOUTON CARTE DES MONDES INTERACTIVE ---
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, AppRoutes.worlds),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7000FF), Color(0xFF8B26FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7000FF).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Text('🗺️', style: TextStyle(fontSize: 40)),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Carte des Mondes',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Plus Jakarta Sans',
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Visualise ta progression générale !',
                                  style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- BADGES RÉCENTS ---
                  if (unlockedBadges.isNotEmpty) ...[
                    const Text(
                      'Tes derniers trophées : 🏆',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF011627),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: unlockedBadges.length > 5 ? 5 : unlockedBadges.length,
                        itemBuilder: (context, index) {
                          final badge = unlockedBadges[index];
                          return Container(
                            margin: const EdgeInsets.only(right: 12),
                            width: 70,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFFFBF69), width: 2),
                            ),
                            child: Center(
                              child: Tooltip(
                                message: badge.badgeId,
                                child: Text(
                                  _getBadgeIcon(badge.badgeId),
                                  style: const TextStyle(fontSize: 32),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String icon,
    required Color color,
    required String route,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.3), width: 3),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Text(
                icon,
                style: const TextStyle(fontSize: 32),
              ),
            ),
            const Spacer(),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
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
