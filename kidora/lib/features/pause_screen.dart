import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/routes/app_routes.dart';
import '../providers/app_providers.dart';

class PauseScreen extends ConsumerWidget {
  const PauseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final child = ref.watch(activeChildProvider);
    final limit = ref.watch(dailyLimitProvider);

    if (child == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final int minutesUsed = limit?.minutesUsedToday ?? 0;
    final int maxMinutes = limit?.maxMinutesPerDay ?? 30;
    final int minutesRemaining = (maxMinutes - minutesUsed).clamp(0, maxMinutes);

    final bool isTimeUp = minutesRemaining <= 0;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFDFFFC), Color(0xFFE8F0FE)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Text(
                  isTimeUp ? '😴🛌💤' : '⏸️🦉🐢',
                  style: const TextStyle(fontSize: 80),
                ),
                const SizedBox(height: 32),
                Text(
                  isTimeUp ? 'C\'est l\'heure de se reposer !' : 'Pause Apprentissage',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF011627),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  isTimeUp
                      ? 'Tu as bien travaillé aujourd\'hui ! Tes yeux ont besoin d\'une pause. Va jouer dehors ou lis un livre ! 🌳📖'
                      : 'Fais une petite pause, étire tes bras et bois de l\'eau avant de continuer ! 💧✨',
                  style: const TextStyle(fontSize: 16, color: Colors.black54, height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Informations sur le temps d'utilisation
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: isTimeUp ? Colors.redAccent.withOpacity(0.3) : const Color(0xFFFF9F1C).withOpacity(0.3), width: 3),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.timer, size: 28, color: Colors.grey),
                      const SizedBox(width: 12),
                      Text(
                        isTimeUp
                            ? 'Limite atteinte : $maxMinutes min ⏰'
                            : 'Temps d\'écran restant : $minutesRemaining min ⏱️',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isTimeUp ? Colors.redAccent : const Color(0xFF011627),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Boutons d'action
                if (!isTimeUp) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Reprendre la session
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2EC4B6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        'Reprendre l\'Apprentissage ! 🚀',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.parentAccess);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFFF9F1C), width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock, color: Color(0xFFFF9F1C)),
                        SizedBox(width: 8),
                        Text(
                          'Espace Parents / Déverrouiller',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFFF9F1C)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
