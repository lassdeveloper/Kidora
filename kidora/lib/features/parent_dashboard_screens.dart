import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/routes/app_routes.dart';
import '../core/theme/app_theme.dart';
import '../providers/app_providers.dart';
import '../models/child.dart';
import '../models/app_settings.dart';
import '../models/daily_limit.dart';
import '../core/database/database_helper.dart';

// ==========================================================
// ÉCRANS 22 À 26 : ESPACE D'ADMINISTRATION PARENTALE COMPLET
// ==========================================================
class ParentDashboardScreen extends ConsumerStatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  ConsumerState<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends ConsumerState<ParentDashboardScreen> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    final childrenAsync = ref.watch(childrenProvider);
    final activeChild = ref.watch(activeChildProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Espace Administration Parents 🛡️', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFFFF9F1C),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // S'il y a un enfant actif, retourner à l'accueil, sinon à la page de bienvenue
            if (activeChild != null) {
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
            } else {
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.welcome, (route) => false);
            }
          },
        ),
      ),
      body: childrenAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur : $err')),
        data: (children) {
          return Column(
            children: [
              // --- SÉLECTION DE L'ONGLET PARENT ---
              Container(
                color: Colors.white,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTabButton(0, 'Profils Enfants', Icons.people),
                      _buildTabButton(1, 'Statistiques', Icons.bar_chart),
                      _buildTabButton(2, 'Limite de Temps', Icons.timer),
                      _buildTabButton(3, 'Paramètres & Son', Icons.settings),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, thickness: 1),

              // --- CONTENU ACTIF ---
              Expanded(
                child: Container(
                  color: const Color(0xFFF1FAEE).withOpacity(0.3),
                  child: _buildTabContent(children, activeChild),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabButton(int index, String label, IconData icon) {
    final isSelected = _currentTab == index;
    return InkWell(
      onTap: () {
        setState(() {
          _currentTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFFFF9F1C) : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFFFF9F1C) : Colors.grey, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isSelected ? const Color(0xFFFF9F1C) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(List<Child> children, Child? activeChild) {
    switch (_currentTab) {
      case 0:
        return _buildProfilesManagerTab(children, activeChild);
      case 1:
        return _buildAnalyticsTab(activeChild);
      case 2:
        return _buildTimeLimitTab(activeChild);
      case 3:
        return _buildSettingsTab(activeChild);
      default:
        return const SizedBox();
    }
  }

  // ==========================================
  // MODULE 1 : GESTION DES PROFILS ENFANTS
  // ==========================================
  Widget _buildProfilesManagerTab(List<Child> children, Child? activeChild) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Profils Enregistrés',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.createProfile);
                },
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                label: const Text('Ajouter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF9F1C)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: children.isEmpty
                ? const Center(
                    child: Text(
                      'Aucun profil enfant créé pour le moment.\nAjoute ton premier enfant avec le bouton ci-dessus ! ✨',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: Colors.grey, height: 1.5),
                    ),
                  )
                : ListView.builder(
                    itemCount: children.length,
                    itemBuilder: (context, index) {
                      final child = children[index];
                      final isActive = activeChild?.id == child.id;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isActive ? const Color(0xFFFF9F1C) : Colors.grey.shade200,
                            width: isActive ? 2.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(child.avatar, style: const TextStyle(fontSize: 36)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    child.name,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${child.age} ans • Niveau ${child.schoolLevel.toUpperCase()}',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            if (!isActive)
                              TextButton(
                                onPressed: () {
                                  ref.read(activeChildProvider.notifier).setActiveChild(child);
                                },
                                child: const Text('Activer', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2EC4B6))),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF9F1C).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Actif',
                                  style: TextStyle(color: Color(0xFFFF9F1C), fontWeight: FontWeight.bold, fontSize: 11),
                                ),
                              ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () {
                                _confirmDeleteChild(child.id!, child.name);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteChild(int id, String name) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Supprimer $name ?'),
          content: Text('Es-tu sûr de vouloir supprimer définitivement le profil de $name ? Toutes ses progressions seront perdues.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                await ref.read(childrenProvider.notifier).deleteChildProfile(id);
                // Si on a supprimé l'enfant actif, on efface l'état actif
                final activeChild = ref.read(activeChildProvider);
                if (activeChild?.id == id) {
                  await ref.read(activeChildProvider.notifier).clearActiveChild();
                }
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Supprimer', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // ==========================================
  // MODULE 2 : ANALYTICS & STATISTIQUES DÉTAILLÉES
  // ==========================================
  Widget _buildAnalyticsTab(Child? activeChild) {
    if (activeChild == null) {
      return const Center(child: Text('Sélectionne un profil enfant pour voir ses statistiques.', style: TextStyle(fontSize: 15, color: Colors.grey)));
    }

    final progressList = ref.watch(progressProvider);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistiques de ${activeChild.name} 📈',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Total XP & niveau
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('✨', style: TextStyle(fontSize: 32)),
                    const SizedBox(height: 6),
                    const Text('Total XP', style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('${activeChild.xp} pts', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFFF9F1C))),
                  ],
                ),
                Container(width: 1.5, height: 60, color: Colors.grey.shade200),
                Column(
                  children: [
                    const Text('🎖️', style: TextStyle(fontSize: 32)),
                    const SizedBox(height: 6),
                    const Text('Niveau', style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('${activeChild.level}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2EC4B6))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Progression par Matière',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          if (progressList.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: Text(
                  'Aucune leçon complétée pour le moment. Encourage ton enfant à commencer l\'apprentissage ! 📚🚀',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, height: 1.4),
                ),
              ),
            )
          else
            ...progressList.map((p) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)),
                child: Row(
                  children: [
                    Text(_getSubjectEmoji(p.subjectId), style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_getSubjectName(p.subjectId), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: p.successRate / 100.0,
                              minHeight: 6,
                              backgroundColor: Colors.grey.shade100,
                              valueColor: AlwaysStoppedAnimation<Color>(_getSubjectColor(p.subjectId)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${p.completedLessonsCount} leçons',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54),
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  // ==========================================
  // MODULE 3 : GESTION DU TEMPS D'ÉCRAN
  // ==========================================
  Widget _buildTimeLimitTab(Child? activeChild) {
    if (activeChild == null) {
      return const Center(child: Text('Sélectionne un profil enfant pour configurer ses limites.', style: TextStyle(fontSize: 15, color: Colors.grey)));
    }

    final limit = ref.watch(dailyLimitProvider);
    final int currentLimit = limit?.maxMinutesPerDay ?? 30;

    final List<int> times = [15, 30, 45, 60, 0]; // 0 pour sans limite

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gestion du temps d\'écran de ${activeChild.name} ⏱️',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Configure une limite d\'utilisation quotidienne maximale. Une fois le temps écoulé, l\'apprentissage se mettra en pause pour protéger ses yeux.',
            style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.4),
          ),
          const SizedBox(height: 32),

          Expanded(
            child: ListView.builder(
              itemCount: times.length,
              itemBuilder: (context, index) {
                final t = times[index];
                final isSelected = currentLimit == t;
                final label = t == 0 ? 'Pas de limite ♾️' : '$t minutes par jour ⏰';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: InkWell(
                    onTap: () async {
                      await ref.read(dailyLimitProvider.notifier).setMaxMinutes(t);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Limite de temps enregistrée : ${t == 0 ? "Aucune limite" : "$t min"} ! ⏱️'),
                            backgroundColor: const Color(0xFF38B000),
                          ),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFFF9F1C).withOpacity(0.12) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFFF9F1C) : Colors.grey.shade200,
                          width: isSelected ? 2.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                            color: isSelected ? const Color(0xFFFF9F1C) : Colors.grey,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? const Color(0xFFFF9F1C) : const Color(0xFF011627),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // MODULE 4 : PARAMÈTRES & RÉINITIALISATION
  // ==========================================
  Widget _buildSettingsTab(Child? activeChild) {
    final settings = ref.watch(settingsProvider);

    final soundEnabled = settings?.soundEnabled ?? true;
    final musicEnabled = settings?.musicEnabled ?? true;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Réglages Sonores 🔊', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Effets Sonores', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Activer les bruitages lors des réponses'),
            value: soundEnabled,
            activeColor: const Color(0xFFFF9F1C),
            onChanged: (val) {
              if (settings != null) {
                ref.read(settingsProvider.notifier).updateSettings(
                  settings.copyWith(soundEnabled: val),
                );
              }
            },
          ),
          SwitchListTile(
            title: const Text('Musique d\'Ambiance', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Petite musique douce en arrière-plan'),
            value: musicEnabled,
            activeColor: const Color(0xFFFF9F1C),
            onChanged: (val) {
              if (settings != null) {
                ref.read(settingsProvider.notifier).updateSettings(
                  settings.copyWith(musicEnabled: val),
                );
              }
            },
          ),
          const SizedBox(height: 32),

          const Text('Politique locale & Infos 📄', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KIDORA — Application 100% Hors-ligne',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(height: 4),
                Text(
                  'Toutes les données de progression, de profil et d\'utilisation sont stockées en base SQLite locale sur votre appareil de manière totalement privée et sécurisée. Aucune donnée n\'est envoyée sur le réseau.',
                  style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Réinitialisation globale
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _resetAllApplicationData,
              icon: const Icon(Icons.delete_forever, color: Colors.white),
              label: const Text('RÉINITIALISER TOUTES LES DONNÉES', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            ),
          ),
        ],
      ),
    );
  }

  void _resetAllApplicationData() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('⚠️ Réinitialisation Globale ⚠️'),
          content: const Text('Cette action va supprimer définitivement l\'intégralité des données SQLite (profils, historique de leçons, scores de mini-jeux). Cette opération est irréversible. Confirmer ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                final dbHelper = DatabaseHelper.instance;
                final db = await dbHelper.database;
                
                // Supprimer les tables
                await db.delete('children');
                await db.delete('exercise_answers');
                await db.delete('progress');
                await db.delete('child_badges');
                await db.delete('game_scores');
                await db.delete('settings');
                await db.delete('daily_limits');

                // Vider les providers
                await ref.read(activeChildProvider.notifier).clearActiveChild();
                ref.read(childrenProvider.notifier).loadChildren();

                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, AppRoutes.splash, (route) => false);
                }
              },
              child: const Text('Réinitialiser', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // --- HELPERS D'AFFICHAGE ---
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

  Color _getSubjectColor(String subjectId) {
    switch (subjectId) {
      case 'math': return AppColors.math;
      case 'french': return AppColors.french;
      case 'science': return AppColors.science;
      case 'logic': return AppColors.logic;
      default: return AppColors.primary;
    }
  }
}
