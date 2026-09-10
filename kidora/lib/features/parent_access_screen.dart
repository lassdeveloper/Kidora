import 'dart:math';
import 'package:flutter/material.dart';
import '../core/routes/app_routes.dart';

class ParentAccessScreen extends StatefulWidget {
  const ParentAccessScreen({super.key});

  @override
  State<ParentAccessScreen> createState() => _ParentAccessScreenState();
}

class _ParentAccessScreenState extends State<ParentAccessScreen> {
  late int _num1;
  late int _num2;
  late int _correctResult;
  final TextEditingController _answerController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _generateChallenge();
  }

  void _generateChallenge() {
    // Générer un défi mathématique suffisant pour un enfant mais simple pour un adulte
    final random = Random();
    _num1 = random.nextInt(6) + 5; // Entre 5 et 10
    _num2 = random.nextInt(6) + 4; // Entre 4 et 9
    _correctResult = _num1 * _num2;
    _answerController.clear();
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accès Parental 🛡️', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFFFF9F1C),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                const Icon(
                  Icons.lock_person,
                  size: 80,
                  color: Color(0xFFFF9F1C),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Zone Réservée aux Parents',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF011627),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Pour confirmer que tu es bien un adulte, résous cette opération mathématique :',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Challenge opération
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                  ),
                  child: Text(
                    '$_num1  ×  $_num2  =  ?',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF011627),
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Champ de saisie
                TextFormField(
                  controller: _answerController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: 'Ta réponse...',
                    hintStyle: TextStyle(fontSize: 20, color: Colors.grey.shade400),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Color(0xFFFF9F1C), width: 3),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'S\'il te plaît, résous le calcul !';
                    }
                    final parsed = int.tryParse(value.trim());
                    if (parsed == null) {
                      return 'Entre un nombre valide !';
                    }
                    if (parsed != _correctResult) {
                      return 'Oups, ce n\'est pas correct !';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 48),

                // Boutons
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pushReplacementNamed(context, AppRoutes.parentDashboard);
                      } else {
                        // Recréer le calcul en cas d'erreur
                        setState(() {
                          _generateChallenge();
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9F1C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Déverrouiller l\'Espace Parents 🔓',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Retourner à l\'espace enfant',
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
