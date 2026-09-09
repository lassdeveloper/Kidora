import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { Trophy, HelpCircle, RotateCcw, ArrowLeft, Check, Sparkles } from 'lucide-react';
import { CustomAudio } from './CustomAudio';

// ==========================================
// THE 4 MINI-GAMES EXPORTABLE SWITCHER
// ==========================================
export function KidoraMiniGames({
  childId,
  onSaveScore,
  onBack,
}: {
  childId: number;
  onSaveScore: (gameId: string, score: number) => void;
  onBack: () => void;
}) {
  const [activeGame, setActiveGame] = useState<string | null>(null);

  const handleGameComplete = (gameId: string, score: number) => {
    onSaveScore(gameId, score);
  };

  if (activeGame === 'memory') {
    return <MemoryGame onComplete={(score) => handleGameComplete('game_memory', score)} onBack={() => setActiveGame(null)} />;
  }
  if (activeGame === 'catch_number') {
    return <CatchNumberGame onComplete={(score) => handleGameComplete('game_catch_number', score)} onBack={() => setActiveGame(null)} />;
  }
  if (activeGame === 'mystery_word') {
    return <MysteryWordGame onComplete={(score) => handleGameComplete('game_mystery_word', score)} onBack={() => setActiveGame(null)} />;
  }
  if (activeGame === 'shapes') {
    return <ShapesGame onComplete={(score) => handleGameComplete('game_shapes', score)} onBack={() => setActiveGame(null)} />;
  }

  return (
    <div className="h-full w-full bg-[#FDFFFC] flex flex-col p-5 overflow-y-auto">
      <div className="flex items-center gap-3 mb-6">
        <button
          onClick={() => { CustomAudio.playClick(); onBack(); }}
          className="p-2 hover:bg-gray-100 rounded-full transition-all"
        >
          <ArrowLeft className="w-6 h-6 text-[#011627]" />
        </button>
        <h2 
          className="text-2xl font-extrabold text-[#011627]"
          style={{ fontFamily: '"Comic Sans MS", "Chalkboard SE", sans-serif' }}
        >
          Zone de Mini-jeux 🎮
        </h2>
      </div>

      <p className="text-sm text-gray-500 mb-6 font-medium">
        Joue à des jeux amusants hors-ligne pour faire travailler tes méninges et battre ton record !
      </p>

      <div className="grid grid-cols-1 gap-4 flex-1">
        {/* Game 1 — Mémoire */}
        <button
          onClick={() => { CustomAudio.playClick(); setActiveGame('memory'); }}
          className="bg-white hover:shadow-lg transition-all p-4 rounded-2xl border-2 border-[#2EC4B6]/30 text-left flex items-center justify-between group active:scale-98"
        >
          <div className="flex items-center gap-4">
            <span className="text-5xl bg-[#2EC4B6]/10 p-2.5 rounded-2xl group-hover:scale-110 transition-transform">🧠</span>
            <div>
              <p className="font-extrabold text-[#011627] text-lg">Jeu 1 — Mémoire</p>
              <p className="text-xs text-gray-500 font-medium">Retrouve les paires d'animaux cachées !</p>
            </div>
          </div>
          <span className="text-xs font-bold bg-[#2EC4B6]/10 text-[#2EC4B6] px-3 py-1 rounded-full">Jouer</span>
        </button>

        {/* Game 2 — Attrape le nombre */}
        <button
          onClick={() => { CustomAudio.playClick(); setActiveGame('catch_number'); }}
          className="bg-white hover:shadow-lg transition-all p-4 rounded-2xl border-2 border-[#FF9F1C]/30 text-left flex items-center justify-between group active:scale-98"
        >
          <div className="flex items-center gap-4">
            <span className="text-5xl bg-[#FF9F1C]/10 p-2.5 rounded-2xl group-hover:scale-110 transition-transform">🎈</span>
            <div>
              <p className="font-extrabold text-[#011627] text-lg">Jeu 2 — Attrape le nombre</p>
              <p className="text-xs text-gray-500 font-medium">Trouve et éclate le bon ballon volant !</p>
            </div>
          </div>
          <span className="text-xs font-bold bg-[#FF9F1C]/10 text-[#FF9F1C] px-3 py-1 rounded-full">Jouer</span>
        </button>

        {/* Game 3 — Mot mystère */}
        <button
          onClick={() => { CustomAudio.playClick(); setActiveGame('mystery_word'); }}
          className="bg-white hover:shadow-lg transition-all p-4 rounded-2xl border-2 border-[#E71D36]/30 text-left flex items-center justify-between group active:scale-98"
        >
          <div className="flex items-center gap-4">
            <span className="text-5xl bg-[#E71D36]/10 p-2.5 rounded-2xl group-hover:scale-110 transition-transform">📚</span>
            <div>
              <p className="font-extrabold text-[#011627] text-lg">Jeu 3 — Mot mystère</p>
              <p className="text-xs text-gray-500 font-medium">Remets les lettres dans le bon ordre.</p>
            </div>
          </div>
          <span className="text-xs font-bold bg-[#E71D36]/10 text-[#E71D36] px-3 py-1 rounded-full">Jouer</span>
        </button>

        {/* Game 4 — Formes */}
        <button
          onClick={() => { CustomAudio.playClick(); setActiveGame('shapes'); }}
          className="bg-white hover:shadow-lg transition-all p-4 rounded-2xl border-2 border-indigo-200 text-left flex items-center justify-between group active:scale-98"
        >
          <div className="flex items-center gap-4">
            <span className="text-5xl bg-indigo-55 p-2.5 rounded-2xl group-hover:scale-110 transition-transform">🔺</span>
            <div>
              <p className="font-extrabold text-[#011627] text-lg">Jeu 4 — Formes</p>
              <p className="text-xs text-gray-500 font-medium">Identifie la forme géométrique demandée !</p>
            </div>
          </div>
          <span className="text-xs font-bold bg-indigo-50 text-indigo-500 px-3 py-1 rounded-full">Jouer</span>
        </button>
      </div>
    </div>
  );
}

// ==========================================
// GAME 1: MEMORY (CARDS PAIR MATCHING)
// ==========================================
const MEMORY_EMOJIS = ['🐱', '🐶', '🦊', '🦁', '🐸', '🐼', '🦄', '🐨'];

interface Card {
  id: number;
  emoji: string;
  isFlipped: boolean;
  isMatched: boolean;
}

function MemoryGame({ onComplete, onBack }: { onComplete: (score: number) => void; onBack: () => void }) {
  const [cards, setCards] = useState<Card[]>([]);
  const [selectedIndices, setSelectedIndices] = useState<number[]>([]);
  const [moves, setMoves] = useState(0);
  const [score, setScore] = useState(0);
  const [isWon, setIsWon] = useState(false);

  useEffect(() => {
    resetGame();
  }, []);

  const resetGame = () => {
    const duplicated = [...MEMORY_EMOJIS, ...MEMORY_EMOJIS]
      .sort(() => Math.random() - 0.5)
      .map((emoji, index) => ({
        id: index,
        emoji,
        isFlipped: false,
        isMatched: false,
      }));
    setCards(duplicated);
    setSelectedIndices([]);
    setMoves(0);
    setScore(0);
    setIsWon(false);
  };

  const handleCardClick = (index: number) => {
    if (cards[index].isFlipped || cards[index].isMatched || selectedIndices.length >= 2) return;
    CustomAudio.playClick();

    const newCards = [...cards];
    newCards[index].isFlipped = true;
    setCards(newCards);

    const newSelected = [...selectedIndices, index];
    setSelectedIndices(newSelected);

    if (newSelected.length === 2) {
      setMoves((m) => m + 1);
      const [first, second] = newSelected;
      if (cards[first].emoji === cards[second].emoji) {
        // Match!
        setTimeout(() => {
          CustomAudio.playSuccess();
          const matchedCards = [...newCards];
          matchedCards[first].isMatched = true;
          matchedCards[second].isMatched = true;
          setCards(matchedCards);
          setSelectedIndices([]);
          setScore((s) => s + 20);

          // Check Win
          if (matchedCards.every((c) => c.isMatched)) {
            CustomAudio.playLevelUp();
            setIsWon(true);
            const finalScore = Math.max(50, 200 - moves * 5);
            onComplete(finalScore);
          }
        }, 500);
      } else {
        // No match, flip back
        setTimeout(() => {
          CustomAudio.playFailure();
          const flippedBack = [...newCards];
          flippedBack[first].isFlipped = false;
          flippedBack[second].isFlipped = false;
          setCards(flippedBack);
          setSelectedIndices([]);
        }, 1000);
      }
    }
  };

  return (
    <div className="h-full w-full bg-[#F1FAEE] flex flex-col justify-between p-5">
      <div className="flex items-center justify-between mb-4">
        <button onClick={onBack} className="text-[#011627] font-bold text-sm">Quitter</button>
        <span className="text-sm font-extrabold text-[#011627]">Coups : {moves}</span>
        <button onClick={resetGame} className="p-1 rounded-full hover:bg-white/50"><RotateCcw className="w-5 h-5 text-gray-600" /></button>
      </div>

      <div className="flex-1 flex flex-col justify-center">
        {isWon ? (
          <div className="text-center space-y-4">
            <span className="text-6xl animate-bounce block">🏆</span>
            <h3 className="text-2xl font-black text-[#2EC4B6]">Pari Gagné !</h3>
            <p className="text-gray-600 font-bold">Tu as trouvé toutes les paires en seulement {moves} coups !</p>
            <p className="text-sm text-yellow-600 font-extrabold bg-yellow-100 py-1.5 px-4 rounded-full inline-block">+ {score} points de score !</p>
            <button
              onClick={onBack}
              className="mt-6 bg-[#FF9F1C] text-white font-extrabold py-3 px-6 rounded-2xl shadow-md border-b-4 border-[#e68400]"
            >
              Retour aux jeux
            </button>
          </div>
        ) : (
          <div className="grid grid-cols-4 gap-2">
            {cards.map((card, index) => (
              <button
                key={card.id}
                onClick={() => handleCardClick(index)}
                className={`aspect-square rounded-xl text-3xl font-extrabold flex items-center justify-center transition-all transform border-2 ${
                  card.isFlipped || card.isMatched
                    ? 'bg-white border-[#2EC4B6] scale-105 rotate-0 shadow-sm'
                    : 'bg-[#2EC4B6] border-[#259d92] active:scale-95 shadow-md'
                }`}
              >
                {card.isFlipped || card.isMatched ? card.emoji : '❓'}
              </button>
            ))}
          </div>
        )}
      </div>

      {!isWon && (
        <div className="p-3.5 bg-white rounded-2xl border-2 border-dashed border-[#2EC4B6]/20 text-center">
          <p className="text-xs text-gray-500 font-medium">Retrouve les paires d'animaux identiques le plus rapidement possible !</p>
        </div>
      )}
    </div>
  );
}

// ==========================================
// GAME 2: CATCH THE NUMBER (SPAWNED BALLOONS)
// ==========================================
function CatchNumberGame({ onComplete, onBack }: { onComplete: (score: number) => void; onBack: () => void }) {
  const [targetNum, setTargetNum] = useState(0);
  const [bubbles, setBubbles] = useState<number[]>([]);
  const [score, setScore] = useState(0);
  const [clicksCount, setClicksCount] = useState(0);
  const [timeLeft, setTimeLeft] = useState(15);
  const [isGameOver, setIsGameOver] = useState(false);

  useEffect(() => {
    generateRound();
    const timer = setInterval(() => {
      setTimeLeft((prev) => {
        if (prev <= 1) {
          clearInterval(timer);
          setIsGameOver(true);
          CustomAudio.playLevelUp();
          onComplete(score * 10);
          return 0;
        }
        return prev - 1;
      });
    }, 1000);
    return () => clearInterval(timer);
  }, [score]);

  const generateRound = () => {
    const target = Math.floor(Math.random() * 15) + 1;
    setTargetNum(target);

    // Generate 4 bubbles, including the target
    const numsSet = new Set<number>([target]);
    while (numsSet.size < 4) {
      numsSet.add(Math.floor(Math.random() * 20) + 1);
    }
    setBubbles(Array.from(numsSet).sort(() => Math.random() - 0.5));
  };

  const handleBubbleClick = (num: number) => {
    setClicksCount((c) => c + 1);
    if (num === targetNum) {
      CustomAudio.playSuccess();
      setScore((s) => s + 1);
      generateRound();
    } else {
      CustomAudio.playFailure();
    }
  };

  return (
    <div className="h-full w-full bg-[#FFFDF5] flex flex-col justify-between p-5">
      <div className="flex items-center justify-between mb-4">
        <button onClick={onBack} className="text-[#011627] font-bold text-sm">Quitter</button>
        <div className="text-center">
          <p className="text-xs text-gray-400 font-bold uppercase">Temps restant</p>
          <p className="text-lg font-black text-amber-500">⏱️ {timeLeft}s</p>
        </div>
        <span className="text-sm font-extrabold text-[#011627]">Score : {score}</span>
      </div>

      <div className="flex-1 flex flex-col justify-center items-center">
        {isGameOver ? (
          <div className="text-center space-y-4">
            <span className="text-6xl animate-bounce block">🎈</span>
            <h3 className="text-2xl font-black text-[#FF9F1C]">Temps écoulé !</h3>
            <p className="text-gray-600 font-bold">Incroyable ! Tu as attrapé {score} nombres !</p>
            <p className="text-sm text-amber-600 font-extrabold bg-amber-100 py-1.5 px-4 rounded-full inline-block">+ {score * 10} XP gagnés !</p>
            <button
              onClick={onBack}
              className="mt-6 bg-[#FF9F1C] text-white font-extrabold py-3 px-6 rounded-2xl shadow-md border-b-4 border-[#e68400]"
            >
              Retour aux jeux
            </button>
          </div>
        ) : (
          <div className="w-full text-center space-y-8">
            <div className="bg-[#FF9F1C]/10 py-4 px-6 rounded-3xl border-2 border-dashed border-[#FF9F1C]/40 inline-block">
              <p className="text-sm font-bold text-gray-600">Attrape le nombre :</p>
              <h4 className="text-5xl font-black text-[#FF9F1C] mt-1">{targetNum}</h4>
            </div>

            {/* Bubble grids */}
            <div className="grid grid-cols-2 gap-4 max-w-xs mx-auto">
              {bubbles.map((num, i) => (
                <motion.button
                  key={`${num}-${i}`}
                  whileHover={{ scale: 1.1 }}
                  whileTap={{ scale: 0.9 }}
                  onClick={() => handleBubbleClick(num)}
                  className="h-20 w-full bg-gradient-to-br from-[#FF9F1C]/20 to-[#FF9F1C]/40 hover:from-[#FF9F1C]/30 rounded-full border-2 border-[#FF9F1C] text-2xl font-black text-[#011627] flex items-center justify-center shadow-md active:scale-90"
                >
                  🎈 {num}
                </motion.button>
              ))}
            </div>
          </div>
        )}
      </div>

      {!isGameOver && (
        <div className="p-3.5 bg-[#FF9F1C]/5 rounded-2xl border border-dashed border-[#FF9F1C]/20 text-center">
          <p className="text-xs text-gray-500 font-medium">Regarde le nombre demandé et explose le ballon correspondant !</p>
        </div>
      )}
    </div>
  );
}

// ==========================================
// GAME 3: MYSTERY WORD (SPELLING MIXUP)
// ==========================================
const WORD_POOL = [
  { word: 'CHAT', clue: '🐱 Petit félin qui miaule.' },
  { word: 'LION', clue: '🦁 Le roi de la savane.' },
  { word: 'AVION', clue: '✈️ Vole dans le ciel avec des ailes.' },
  { word: 'LIVRE', clue: '📚 On le lit pour apprendre des histoires.' },
  { word: 'POMME', clue: '🍎 Fruit rouge ou vert juteux.' }
];

function MysteryWordGame({ onComplete, onBack }: { onComplete: (score: number) => void; onBack: () => void }) {
  const [currentIndex, setCurrentIndex] = useState(0);
  const [letters, setLetters] = useState<{ id: number; letter: string; used: boolean }[]>([]);
  const [typedLetters, setTypedLetters] = useState<string[]>([]);
  const [win, setWin] = useState(false);
  const [score, setScore] = useState(0);

  const active = WORD_POOL[currentIndex];

  useEffect(() => {
    loadWord();
  }, [currentIndex]);

  const loadWord = () => {
    const currentWord = WORD_POOL[currentIndex].word;
    const shuffled = currentWord
      .split('')
      .map((letter, index) => ({ id: index, letter, used: false }))
      .sort(() => Math.random() - 0.5);
    setLetters(shuffled);
    setTypedLetters([]);
    setWin(false);
  };

  const handleLetterClick = (letterObj: { id: number; letter: string; used: boolean }, index: number) => {
    if (letterObj.used || win) return;
    CustomAudio.playClick();

    // Use letter
    const updated = [...letters];
    updated[index].used = true;
    setLetters(updated);

    const newTyped = [...typedLetters, letterObj.letter];
    setTypedLetters(newTyped);

    // Check progress
    const correctPrefix = active.word.substring(0, newTyped.length);
    if (newTyped.join('') !== correctPrefix) {
      // Mistake! Undo immediately
      CustomAudio.playFailure();
      setTimeout(() => {
        const resetUsed = [...letters];
        resetUsed[index].used = false;
        setLetters(resetUsed);
        setTypedLetters(typedLetters);
      }, 300);
      return;
    }

    // Is fully correct word?
    if (newTyped.join('') === active.word) {
      CustomAudio.playSuccess();
      setWin(true);
      setScore((s) => s + 50);

      if (currentIndex === WORD_POOL.length - 1) {
        onComplete(score + 50);
      }
    }
  };

  const handleNextWord = () => {
    if (currentIndex < WORD_POOL.length - 1) {
      setCurrentIndex((idx) => idx + 1);
    } else {
      onComplete(score);
    }
  };

  return (
    <div className="h-full w-full bg-[#FFF5F6] flex flex-col justify-between p-5">
      <div className="flex items-center justify-between mb-4">
        <button onClick={onBack} className="text-[#011627] font-bold text-sm">Quitter</button>
        <span className="text-xs bg-[#E71D36]/10 text-[#E71D36] px-3 py-1 rounded-full font-bold">Mot {currentIndex + 1} / {WORD_POOL.length}</span>
        <span className="text-sm font-extrabold text-[#011627]">Score : {score}</span>
      </div>

      <div className="flex-1 flex flex-col justify-center items-center text-center">
        <div className="text-4xl mb-3">{active.clue.split(' ')[0]}</div>
        <p className="text-sm text-gray-500 italic mb-6 max-w-xs">{active.clue}</p>

        {/* Display word assembly slots */}
        <div className="flex justify-center gap-2 mb-8">
          {active.word.split('').map((char, i) => (
            <div
              key={i}
              className={`w-12 h-12 rounded-xl border-2 flex items-center justify-center text-2xl font-black uppercase transition-all ${
                typedLetters[i]
                  ? 'bg-white border-[#E71D36] text-[#011627]'
                  : 'bg-[#F1FAEE]/30 border-dashed border-gray-300'
              }`}
            >
              {typedLetters[i] || ''}
            </div>
          ))}
        </div>

        {/* Letter options to click */}
        {win ? (
          <div className="space-y-4">
            <span className="text-4xl">🎉 Bravo !</span>
            <p className="text-xs text-gray-500">Le mot était bien {active.word} !</p>
            <button
              onClick={handleNextWord}
              className="bg-[#E71D36] text-white font-extrabold py-2.5 px-6 rounded-2xl shadow-md border-b-4 border-[#bc1427]"
            >
              {currentIndex < WORD_POOL.length - 1 ? 'Mot suivant ➡️' : 'Terminer !'}
            </button>
          </div>
        ) : (
          <div className="flex justify-center gap-2 max-w-xs flex-wrap">
            {letters.map((letterObj, index) => (
              <button
                key={`${letterObj.id}`}
                disabled={letterObj.used}
                onClick={() => handleLetterClick(letterObj, index)}
                className={`w-12 h-12 rounded-2xl border-2 text-xl font-black transition-all active:scale-90 ${
                  letterObj.used
                    ? 'bg-gray-100 border-gray-200 text-gray-300 scale-95'
                    : 'bg-white border-[#E71D36] text-[#E71D36] shadow-sm'
                }`}
              >
                {letterObj.letter}
              </button>
            ))}
          </div>
        )}
      </div>

      <div className="p-3 bg-[#E71D36]/5 rounded-2xl border border-dashed border-[#E71D36]/20 text-center">
        <p className="text-xs text-gray-500 font-medium">Reconstitue le mot mystère en touchant les lettres dans le bon ordre !</p>
      </div>
    </div>
  );
}

// ==========================================
// GAME 4: SHAPES IDENTIFIER
// ==========================================
const SHAPES_POOL = [
  { name: 'Un Triangle 🔺', correctIcon: '🔺', options: ['🔺', '🔵', '🟩', '⭐️'] },
  { name: 'Un Cercle 🔵', correctIcon: '🔵', options: ['🟩', '🔺', '🔵', '⭐️'] },
  { name: 'Un Carré 🟩', correctIcon: '🟩', options: ['⭐️', '🟩', '🔵', '🔺'] },
  { name: 'Une Étoile ⭐️', correctIcon: '⭐️', options: ['🔵', '🔺', '⭐️', '🟩'] }
];

function ShapesGame({ onComplete, onBack }: { onComplete: (score: number) => void; onBack: () => void }) {
  const [index, setIndex] = useState(0);
  const [score, setScore] = useState(0);
  const [gameComplete, setGameComplete] = useState(false);

  const active = SHAPES_POOL[index];

  const handleOptionClick = (icon: string) => {
    if (gameComplete) return;

    if (icon === active.correctIcon) {
      CustomAudio.playSuccess();
      setScore((s) => s + 25);
    } else {
      CustomAudio.playFailure();
    }

    if (index < SHAPES_POOL.length - 1) {
      setIndex((idx) => idx + 1);
    } else {
      setGameComplete(true);
      CustomAudio.playLevelUp();
      onComplete(score + (icon === active.correctIcon ? 25 : 0));
    }
  };

  return (
    <div className="h-full w-full bg-indigo-50/30 flex flex-col justify-between p-5">
      <div className="flex items-center justify-between mb-4">
        <button onClick={onBack} className="text-[#011627] font-bold text-sm">Quitter</button>
        <span className="text-xs bg-indigo-100 text-indigo-600 px-3 py-1 rounded-full font-bold">Forme {index + 1} / {SHAPES_POOL.length}</span>
        <span className="text-sm font-extrabold text-[#011627]">Score : {score}</span>
      </div>

      <div className="flex-1 flex flex-col justify-center items-center text-center">
        {gameComplete ? (
          <div className="text-center space-y-4">
            <span className="text-6xl animate-bounce block">⭐️</span>
            <h3 className="text-2xl font-black text-indigo-600">Jeu Fini !</h3>
            <p className="text-gray-600 font-bold">Super ! Tu as reconnu toutes les formes !</p>
            <p className="text-sm text-indigo-600 font-extrabold bg-indigo-100 py-1.5 px-4 rounded-full inline-block">+ {score} points de score !</p>
            <button
              onClick={onBack}
              className="mt-6 bg-[#FF9F1C] text-white font-extrabold py-3 px-6 rounded-2xl shadow-md border-b-4 border-[#e68400]"
            >
              Retour aux jeux
            </button>
          </div>
        ) : (
          <div className="w-full text-center space-y-8">
            <div className="bg-indigo-100 py-4 px-6 rounded-3xl border-2 border-dashed border-indigo-200 inline-block">
              <p className="text-sm font-bold text-gray-600">Touche la forme demandée :</p>
              <h4 className="text-3xl font-black text-indigo-600 mt-1">{active.name}</h4>
            </div>

            {/* Shape choices */}
            <div className="grid grid-cols-2 gap-4 max-w-xs mx-auto">
              {active.options.map((opt, i) => (
                <button
                  key={`${opt}-${i}`}
                  onClick={() => handleOptionClick(opt)}
                  className="h-24 w-full bg-white hover:bg-indigo-50 border-2 border-indigo-200 rounded-3xl text-4xl flex items-center justify-center shadow-sm active:scale-90"
                >
                  {opt}
                </button>
              ))}
            </div>
          </div>
        )}
      </div>

      {!gameComplete && (
        <div className="p-3.5 bg-indigo-50 rounded-2xl border border-dashed border-indigo-200 text-center">
          <p className="text-xs text-gray-500 font-medium font-body">Observe l'icône demandée et touche le bouton contenant cette forme géométrique !</p>
        </div>
      )}
    </div>
  );
}
