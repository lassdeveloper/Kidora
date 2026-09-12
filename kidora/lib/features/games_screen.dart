import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../models/game_score.dart';

// ==========================================
// ÉCRAN 19 : PORTAIL MINI-JEUX
// ==========================================
class GamesScreen extends ConsumerStatefulWidget {
  const GamesScreen({super.key});

  @override
  ConsumerState<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends ConsumerState<GamesScreen> {
  final Map<String, int> _bestScores = {};

  @override
  void initState() {
    super.initState();
    _loadBestScores();
  }

  Future<void> _loadBestScores() async {
    final child = ref.read(activeChildProvider);
    if (child == null || child.id == null) return;

    final gameRepo = ref.read(gameRepositoryProvider);
    final games = ['game_memory', 'game_catch_number', 'game_mystery_word', 'game_shapes'];

    for (var gId in games) {
      final scores = await gameRepo.getScoresByChildAndGame(child.id!, gId);
      if (scores.isNotEmpty) {
        setState(() {
          _bestScores[gId] = scores.first.score;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = ref.watch(activeChildProvider);
    if (child == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Espace Mini-Jeux 🎮', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF2EC4B6),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: const Color(0xFFF1FAEE).withOpacity(0.3),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choisis ton jeu ! 🕹️',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF011627),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Entraîne tes neurones tout en t\'amusant et bats tes meilleurs scores !',
                style: TextStyle(fontSize: 15, color: Colors.black54),
              ),
              const SizedBox(height: 24),

              _buildGameCard(
                title: 'Mémoire Animale',
                desc: 'Trouve les paires d\'animaux cachées sous les cartes ! 🦁🦊',
                emoji: '🧩',
                bestScore: _bestScores['game_memory'] ?? 0,
                color: const Color(0xFFFF9F1C),
                onPlay: () => _launchGame(context, _MemoryGame(onGameCompleted: _loadBestScores)),
              ),
              const SizedBox(height: 20),
              _buildGameCard(
                title: 'Attrape le Nombre',
                desc: 'Résous l\'addition et attrape la bonne bulle volante ! 🫧🎈',
                emoji: '🔢',
                bestScore: _bestScores['game_catch_number'] ?? 0,
                color: const Color(0xFFFF5964),
                onPlay: () => _launchGame(context, _CatchNumberGame(onGameCompleted: _loadBestScores)),
              ),
              const SizedBox(height: 20),
              _buildGameCard(
                title: 'Mot Mystère',
                desc: 'Remets les lettres dans le bon ordre pour retrouver le mot caché ! 🔠',
                emoji: '📚',
                bestScore: _bestScores['game_mystery_word'] ?? 0,
                color: const Color(0xFF35A7FF),
                onPlay: () => _launchGame(context, _MysteryWordGame(onGameCompleted: _loadBestScores)),
              ),
              const SizedBox(height: 20),
              _buildGameCard(
                title: 'Formes Magiques',
                desc: 'Reconnais la bonne forme géométrique le plus rapidement possible ! 🟡🔺',
                emoji: '📐',
                bestScore: _bestScores['game_shapes'] ?? 0,
                color: const Color(0xFF38B000),
                onPlay: () => _launchGame(context, _ShapesGame(onGameCompleted: _loadBestScores)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _launchGame(BuildContext context, Widget gameWidget) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => gameWidget),
    ).then((_) => _loadBestScores());
  }

  Widget _buildGameCard({
    required String title,
    required String desc,
    required String emoji,
    required int bestScore,
    required Color color,
    required VoidCallback onPlay,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.3), width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 32)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      bestScore > 0 ? 'Meilleur score : $bestScore pts 🌟' : 'Aucun score pour l\'instant',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            desc,
            style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.4),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onPlay,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Jouer ! 🚀',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// MINI-JEU 1 : JEU DE MÉMOIRE (MEMORY)
// ==========================================
class _MemoryGame extends ConsumerStatefulWidget {
  final VoidCallback onGameCompleted;
  const _MemoryGame({required this.onGameCompleted});

  @override
  ConsumerState<_MemoryGame> createState() => _MemoryGameState();
}

class _MemoryGameState extends ConsumerState<_MemoryGame> {
  final List<String> _emojis = ['🦊', '🐨', '🦁', '🦉', '🐯', '🐼', '🐸', '🦄'];
  List<String> _cards = [];
  List<bool> _cardFlips = [];
  List<bool> _cardMatches = [];

  int? _firstSelectedIndex;
  bool _busy = false;
  int _moves = 0;
  int _score = 0;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    _cards = [..._emojis, ..._emojis];
    _cards.shuffle();
    _cardFlips = List.generate(16, (_) => false);
    _cardMatches = List.generate(16, (_) => false);
    _firstSelectedIndex = null;
    _moves = 0;
    _score = 0;
    _finished = false;
    _busy = false;
  }

  void _onCardTap(int index) {
    if (_busy || _cardFlips[index] || _cardMatches[index]) return;

    setState(() {
      _cardFlips[index] = true;
    });

    if (_firstSelectedIndex == null) {
      _firstSelectedIndex = index;
    } else {
      _moves++;
      final firstIdx = _firstSelectedIndex!;
      if (_cards[firstIdx] == _cards[index]) {
        // Paire trouvée !
        setState(() {
          _cardMatches[firstIdx] = true;
          _cardMatches[index] = true;
          _firstSelectedIndex = null;
        });
        _checkGameFinished();
      } else {
        // Pas une paire
        _busy = true;
        Timer(const Duration(milliseconds: 1000), () {
          setState(() {
            _cardFlips[firstIdx] = false;
            _cardFlips[index] = false;
            _firstSelectedIndex = null;
            _busy = false;
          });
        });
      }
    }
  }

  void _checkGameFinished() async {
    if (_cardMatches.every((m) => m)) {
      // Calcul du score (base de 1000 points - 30 points par coup joué)
      _score = (1000 - (_moves * 30)).clamp(100, 1000);
      setState(() {
        _finished = true;
      });

      final child = ref.read(activeChildProvider);
      if (child != null && child.id != null) {
        final scoreObj = GameScore(
          childId: child.id!,
          gameId: 'game_memory',
          score: _score,
          playedAt: DateTime.now(),
        );
        await ref.read(gameRepositoryProvider).insertScore(scoreObj);
        widget.onGameCompleted();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mémoire Animale 🦊', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFFFF9F1C),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_finished) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Coups : $_moves', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Color(0xFFFF9F1C)),
                    onPressed: () => setState(() => _startNewGame()),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: 16,
                  itemBuilder: (context, index) {
                    final showContent = _cardFlips[index] || _cardMatches[index];
                    return GestureDetector(
                      onTap: () => _onCardTap(index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: showContent ? Colors.white : const Color(0xFFFF9F1C),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFFBF69), width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                            )
                          ],
                        ),
                        child: Center(
                          child: Text(
                            showContent ? _cards[index] : '❓',
                            style: const TextStyle(fontSize: 32),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ] else ...[
              const Text('🎉 MAGNIFIQUE ! 🎉', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFFFF9F1C))),
              const SizedBox(height: 16),
              Text('Tu as trouvé toutes les paires en seulement $_moves coups !', style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              Text('Score : $_score points 🌟', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => setState(() => _startNewGame()),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF9F1C)),
                  child: const Text('Rejouer !', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// =================================================
// MINI-JEU 2 : ATTRAPE LE NOMBRE (CATCH NUMBER)
// =================================================
class _CatchNumberGame extends ConsumerStatefulWidget {
  final VoidCallback onGameCompleted;
  const _CatchNumberGame({required this.onGameCompleted});

  @override
  ConsumerState<_CatchNumberGame> createState() => _CatchNumberGameState();
}

class _CatchNumberGameState extends ConsumerState<_CatchNumberGame> {
  int _score = 0;
  int _questionCount = 0;
  late int _val1;
  late int _val2;
  late int _correctAnswer;
  List<int> _options = [];
  bool _gameOver = false;

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  void _generateQuestion() {
    if (_questionCount >= 10) {
      _finishGame();
      return;
    }
    _val1 = (1 + (1 * _questionCount) + (1 * _score)) % 9 + 1;
    _val2 = (2 + _questionCount) % 5 + 1;
    _correctAnswer = _val1 + _val2;

    _options = [
      _correctAnswer,
      _correctAnswer + 1,
      _correctAnswer - 1,
      _correctAnswer + 3,
    ];
    _options.shuffle();
  }

  void _answerQuestion(int ans) {
    if (ans == _correctAnswer) {
      _score += 100;
    }
    setState(() {
      _questionCount++;
      _generateQuestion();
    });
  }

  void _finishGame() async {
    setState(() {
      _gameOver = true;
    });

    final child = ref.read(activeChildProvider);
    if (child != null && child.id != null) {
      final scoreObj = GameScore(
        childId: child.id!,
        gameId: 'game_catch_number',
        score: _score,
        playedAt: DateTime.now(),
      );
      await ref.read(gameRepositoryProvider).insertScore(scoreObj);
      widget.onGameCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attrape le Nombre 🫧', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFFFF5964),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_gameOver) ...[
              Text('Score : $_score', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              const Text('🫧 Calcule la bonne somme : 🫧', style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Text('$_val1 + $_val2 = ?', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFFFF5964))),
              const SizedBox(height: 40),
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: 4,
                itemBuilder: (context, index) {
                  final opt = _options[index];
                  return GestureDetector(
                    onTap: () => _answerQuestion(opt),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFF5964), width: 4),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 3)),
                        ],
                      ),
                      child: Center(
                        child: Text('$opt', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFFFF5964))),
                      ),
                    ),
                  );
                },
              ),
            ] else ...[
              const Text('🎮 JEU TERMINÉ ! 🎮', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFFFF5964))),
              const SizedBox(height: 16),
              Text('Félicitations ! Tu as marqué un superbe score de :', style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              Text('$_score points 🌟', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFFFF5964))),
              const SizedBox(height: 40),
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => setState(() {
                    _score = 0;
                    _questionCount = 0;
                    _gameOver = false;
                    _generateQuestion();
                  }),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5964)),
                  child: const Text('Rejouer !', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// =================================================
// MINI-JEU 3 : MOT MYSTÈRE (MYSTERY WORD)
// =================================================
class _MysteryWordGame extends ConsumerStatefulWidget {
  final VoidCallback onGameCompleted;
  const _MysteryWordGame({required this.onGameCompleted});

  @override
  ConsumerState<_MysteryWordGame> createState() => _MysteryWordGameState();
}

class _MysteryWordGameState extends ConsumerState<_MysteryWordGame> {
  final List<Map<String, String>> _words = [
    {'hint': '🦁', 'word': 'LION'},
    {'hint': '🦊', 'word': 'RENARD'},
    {'hint': '🐱', 'word': 'CHAT'},
    {'hint': '🐶', 'word': 'CHIEN'},
    {'hint': '🐼', 'word': 'PANDA'},
  ];

  int _currentIndex = 0;
  List<String> _shuffledLetters = [];
  List<String> _guessLetters = [];
  int _score = 0;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _loadWord();
  }

  void _loadWord() {
    if (_currentIndex >= _words.length) {
      _finishGame();
      return;
    }
    final word = _words[_currentIndex]['word']!;
    _shuffledLetters = word.split('')..shuffle();
    _guessLetters = [];
  }

  void _selectLetter(String letter) {
    setState(() {
      _guessLetters.add(letter);
      _shuffledLetters.remove(letter);
    });

    final targetWord = _words[_currentIndex]['word']!;
    if (_guessLetters.length == targetWord.length) {
      final finalGuess = _guessLetters.join('');
      if (finalGuess == targetWord) {
        _score += 200;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bravo ! C\'est juste ! 🎉'), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mince ! Réessaie ! 💡'), backgroundColor: Colors.red));
      }
      Timer(const Duration(milliseconds: 1500), () {
        setState(() {
          _currentIndex++;
          _loadWord();
        });
      });
    }
  }

  void _resetCurrent() {
    setState(() {
      _loadWord();
    });
  }

  void _finishGame() async {
    setState(() {
      _finished = true;
    });

    final child = ref.read(activeChildProvider);
    if (child != null && child.id != null) {
      final scoreObj = GameScore(
        childId: child.id!,
        gameId: 'game_mystery_word',
        score: _score,
        playedAt: DateTime.now(),
      );
      await ref.read(gameRepositoryProvider).insertScore(scoreObj);
      widget.onGameCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mot Mystère 📚', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF35A7FF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_finished) ...[
              Text('Score : $_score', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Text(_words[_currentIndex]['hint']!, style: const TextStyle(fontSize: 100)),
              const SizedBox(height: 24),
              const Text('Reconstitue le mot avec ces lettres :', style: TextStyle(fontSize: 15, color: Colors.grey)),
              const SizedBox(height: 16),
              // Lettres devinées
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_words[_currentIndex]['word']!.length, (index) {
                    final display = index < _guessLetters.length ? _guessLetters[index] : '';
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(10)),
                      child: Center(child: Text(display, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 32),
              // Lettres disponibles
              Wrap(
                spacing: 12,
                children: _shuffledLetters.map((l) {
                  return GestureDetector(
                    onTap: () => _selectLetter(l),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(color: const Color(0xFF35A7FF), borderRadius: BorderRadius.circular(12)),
                      child: Center(child: Text(l, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white))),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),
              IconButton(icon: const Icon(Icons.refresh, size: 36, color: Color(0xFF35A7FF)), onPressed: _resetCurrent),
            ] else ...[
              const Text('🎉 MOTS TROUVÉS ! 🎉', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF35A7FF))),
              const SizedBox(height: 16),
              Text('Score final :', style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              Text('$_score points 🌟', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF35A7FF))),
              const SizedBox(height: 40),
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => setState(() {
                    _currentIndex = 0;
                    _score = 0;
                    _finished = false;
                    _loadWord();
                  }),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF35A7FF)),
                  child: const Text('Rejouer !', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// =================================================
// MINI-JEU 4 : FORMES MAGIQUES (SHAPES)
// =================================================
class _ShapesGame extends ConsumerStatefulWidget {
  final VoidCallback onGameCompleted;
  const _ShapesGame({required this.onGameCompleted});

  @override
  ConsumerState<_ShapesGame> createState() => _ShapesGameState();
}

class _ShapesGameState extends ConsumerState<_ShapesGame> {
  final List<Map<String, dynamic>> _shapes = [
    {'name': 'Triangle', 'emoji': '🔺'},
    {'name': 'Cercle', 'emoji': '🔴'},
    {'name': 'Carré', 'emoji': '🟧'},
    {'name': 'Étoile', 'emoji': '⭐'},
  ];

  int _score = 0;
  int _rounds = 0;
  late int _targetIndex;
  List<String> _options = [];
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _nextRound();
  }

  void _nextRound() {
    if (_rounds >= 10) {
      _finishGame();
      return;
    }
    _targetIndex = _rounds % _shapes.length;
    _options = _shapes.map((s) => s['name'] as String).toList()..shuffle();
  }

  void _answer(String name) {
    if (name == _shapes[_targetIndex]['name']) {
      _score += 100;
    }
    setState(() {
      _rounds++;
      _nextRound();
    });
  }

  void _finishGame() async {
    setState(() {
      _finished = true;
    });

    final child = ref.read(activeChildProvider);
    if (child != null && child.id != null) {
      final scoreObj = GameScore(
        childId: child.id!,
        gameId: 'game_shapes',
        score: _score,
        playedAt: DateTime.now(),
      );
      await ref.read(gameRepositoryProvider).insertScore(scoreObj);
      widget.onGameCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formes Magiques 📐', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF38B000),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_finished) ...[
              Text('Score : $_score', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              const Text('Quelle est cette forme ?', style: TextStyle(fontSize: 18, color: Colors.grey)),
              const SizedBox(height: 16),
              Text(_shapes[_targetIndex]['emoji']!, style: const TextStyle(fontSize: 120)),
              const SizedBox(height: 40),
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 2,
                ),
                itemCount: 4,
                itemBuilder: (context, index) {
                  final name = _options[index];
                  return SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => _answer(name),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38B000)),
                      child: Text(name, style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              ),
            ] else ...[
              const Text('🎉 EXTRAORDINAIRE ! 🎉', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF38B000))),
              const SizedBox(height: 16),
              Text('Score final :', style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              Text('$_score points 🌟', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF38B000))),
              const SizedBox(height: 40),
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => setState(() {
                    _rounds = 0;
                    _score = 0;
                    _finished = false;
                    _nextRound();
                  }),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38B000)),
                  child: const Text('Rejouer !', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
