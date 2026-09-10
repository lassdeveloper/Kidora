import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/routes/app_routes.dart';
import '../providers/app_providers.dart';

// ==========================================
// ÉCRAN 3 : CRÉATION DE PROFIL (SAISIE NOM)
// ==========================================
class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer ton Profil', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFFFF9F1C),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                const Text(
                  '🎨✨',
                  style: TextStyle(fontSize: 72),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Quel est ton prénom ?',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF011627),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Écris ton prénom ci-dessous pour que Kidora puisse t\'accompagner personnellement.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _nameController,
                  maxLength: 15,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    labelText: 'Ton prénom',
                    labelStyle: const TextStyle(color: Color(0xFFFF9F1C), fontSize: 16),
                    prefixIcon: const Icon(Icons.person, color: Color(0xFFFF9F1C)),
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Color(0xFFFF9F1C), width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Color(0xFFFF9F1C), width: 3),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'S\'il te plaît, entre ton prénom !';
                    }
                    if (value.trim().length < 2) {
                      return 'Ton prénom doit contenir au moins 2 lettres.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 60),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.avatar,
                          arguments: _nameController.text.trim(),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9F1C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      'Suivant ➔',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
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

// ==========================================
// ÉCRAN 4 : SÉLECTION D'AVATAR
// ==========================================
class AvatarSelectionScreen extends StatefulWidget {
  final String childName;

  const AvatarSelectionScreen({super.key, required this.childName});

  @override
  State<AvatarSelectionScreen> createState() => _AvatarSelectionScreenState();
}

class _AvatarSelectionScreenState extends State<AvatarSelectionScreen> {
  final List<String> _avatars = [
    '🦊', '🦁', '🐨', '🦉', '🐯', '🐼', '🐸', '🦄', '🐰', '🐳', '🦖', '🐝'
  ];
  String _selectedAvatar = '🦊';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choisis ton Compagnon', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFFFF9F1C),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Text(
              'Super, ${widget.childName} !',
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF011627),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Choisis l\'avatar rigolo qui t\'accompagnera dans toutes tes aventures éducatives !',
              style: TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _avatars.length,
                itemBuilder: (context, index) {
                  final avatar = _avatars[index];
                  final isSelected = avatar == _selectedAvatar;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedAvatar = avatar;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFFFBF69).withOpacity(0.3) : Colors.grey.shade50,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? const Color(0xFFFF9F1C) : Colors.transparent,
                          width: 4,
                        ),
                        boxShadow: isSelected
                            ? [
                                const BoxShadow(
                                  color: Color(0x33FF9F1C),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                )
                              ]
                            : [],
                      ),
                      child: Center(
                        child: Text(
                          avatar,
                          style: const TextStyle(fontSize: 48),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.ageLevel,
                    arguments: {
                      'name': widget.childName,
                      'avatar': _selectedAvatar,
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9F1C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  'Continuer ➔',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// ÉCRAN 5 : ÂGE & NIVEAU SCOLAIRE
// ==========================================
class AgeLevelSelectionScreen extends ConsumerStatefulWidget {
  final String childName;
  final String avatar;

  const AgeLevelSelectionScreen({
    super.key,
    required this.childName,
    required this.avatar,
  });

  @override
  ConsumerState<AgeLevelSelectionScreen> createState() => _AgeLevelSelectionScreenState();
}

class _AgeLevelSelectionScreenState extends ConsumerState<AgeLevelSelectionScreen> {
  int _selectedAge = 6;
  String _selectedLevel = 'CP';

  final List<Map<String, dynamic>> _levels = [
    {'label': 'Maternelle (4-5 ans)', 'age': 5, 'level': 'Maternelle'},
    {'label': 'CP - CE1 (6-7 ans)', 'age': 7, 'level': 'CP'},
    {'label': 'CE2 - CM1 (8-9 ans)', 'age': 9, 'level': 'CE2'},
    {'label': 'CM2 - 6ème (10-12 ans)', 'age': 11, 'level': 'CM2'},
  ];

  int _selectedGroupIndex = 1; // CP-CE1 par défaut

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ton Niveau', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFFFF9F1C),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1FAEE),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    widget.avatar,
                    style: const TextStyle(fontSize: 48),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Quel âge as-tu, ${widget.childName} ?',
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF011627),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Choisis ton groupe d\'âge pour adapter la difficulté des questions.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView.builder(
                itemCount: _levels.length,
                itemBuilder: (context, index) {
                  final lvl = _levels[index];
                  final isSelected = index == _selectedGroupIndex;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedGroupIndex = index;
                          _selectedAge = lvl['age'];
                          _selectedLevel = lvl['level'];
                        });
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFFFBF69).withOpacity(0.2) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? const Color(0xFFFF9F1C) : Colors.grey.shade300,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFFF9F1C) : Colors.grey.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.check,
                                  color: isSelected ? Colors.white : Colors.transparent,
                                  size: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                lvl['label'],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? const Color(0xFF011627) : const Color(0xCC000000),
                                ),
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
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  // Sauvegarder dans SQLite via Riverpod
                  final childNotifier = ref.read(childrenProvider.notifier);
                  final activeChildNotifier = ref.read(activeChildProvider.notifier);

                  final newChild = await childNotifier.addChild(
                    widget.childName,
                    _selectedAge,
                    _selectedLevel,
                    widget.avatar,
                  );

                  // Définir l'enfant créé comme actif
                  await activeChildNotifier.setActiveChild(newChild);

                  // Aller à l'accueil
                  if (mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.home,
                      (route) => false,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9F1C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  'C\'est parti ! 🚀',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
