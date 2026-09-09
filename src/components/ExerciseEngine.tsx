import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { HelpCircle, Check, X, ArrowRight, Award, Flame, RefreshCw } from 'lucide-react';
import { Exercise } from '../data/exercises';
import { CustomAudio } from './CustomAudio';

// ==========================================
// SCREEN 12: SELECTION DE LA LEÇON
// ==========================================
export function LessonSelectionScreen({
  subject,
  category,
  exercisesCount,
  onStart,
  onBack,
}: {
  subject: string;
  category: string;
  exercisesCount: number;
  onStart: () => void;
  onBack: () => void;
}) {
  return (
    <div className="h-full w-full bg-[#FDFFFC] flex flex-col justify-between p-6">
      <div>
        <button onClick={onBack} className="text-gray-500 font-bold mb-4 hover:text-gray-800">Retour</button>
        
        <div className="text-center mt-4">
          <div className="text-6xl mb-4">
            {subject === 'maths' ? '🔢' : subject === 'french' ? '📚' : subject === 'science' ? '🔬' : '🧠'}
          </div>
          
          <h2 
            className="text-2xl font-extrabold text-[#011627] capitalize mb-1"
            style={{ fontFamily: '"Comic Sans MS", "Chalkboard SE", sans-serif' }}
          >
            {category} (Niveau 1)
          </h2>
          
          <span className="text-xs font-bold uppercase bg-amber-100 text-amber-600 px-3 py-1 rounded-full">
            ⭐⭐ Difficulté : Moyen
          </span>

          <div className="mt-8 p-4 bg-gray-50 rounded-2xl border-2 border-gray-100 max-w-xs mx-auto">
            <p className="text-sm text-gray-600 font-medium leading-relaxed">
              Prépare-toi à relever le défi ! Cette leçon contient <strong>{exercisesCount} exercices</strong> adaptés à ton niveau.
            </p>
          </div>

          <div className="mt-6">
            <p className="text-xs text-gray-400 font-bold">Progression</p>
            <div className="w-48 h-3 bg-gray-200 rounded-full mx-auto mt-1 overflow-hidden border">
              <div className="h-full bg-[#2EC4B6]" style={{ width: '0%' }} />
            </div>
            <p className="text-xs text-[#2EC4B6] font-extrabold mt-1">0% Terminé</p>
          </div>
        </div>
      </div>

      <div>
        <button
          onClick={() => { CustomAudio.playClick(); onStart(); }}
          className="w-full bg-[#FF9F1C] hover:bg-[#ffaa2b] active:scale-95 text-white font-extrabold py-4 px-6 rounded-2xl shadow-md border-b-4 border-[#e68400] transition-all text-lg"
        >
          COMMENCER LA LEÇON
        </button>
      </div>
    </div>
  );
}

// ==========================================
// SCREEN 13: PRESENTATION DE LA LEÇON
// ==========================================
export function LessonPresentationScreen({
  category,
  subject,
  onProceed,
}: {
  category: string;
  subject: string;
  onProceed: () => void;
}) {
  const getExplanation = () => {
    switch (category) {
      case 'addition':
        return {
          text: "Additionner, c'est réunir plusieurs quantités ensemble pour trouver un total plus grand !",
          visual: "🍎 + 🍎🍎 = 🍎🍎🍎\n(1 pomme plus 2 pommes font 3 pommes !)"
        };
      case 'compter':
        return {
          text: "Compter, c'est donner un nombre à chaque objet un par un pour connaître la quantité totale !",
          visual: "⭐ (Un), ⭐⭐ (Deux), ⭐⭐⭐ (Trois) !"
        };
      case 'animaux':
        return {
          text: "Les animaux sont des êtres vivants. Ils ont besoin de respirer, boire de l'eau et manger !",
          visual: "🐱 Le chat, 🦁 Le lion, 🐦 L'oiseau !"
        };
      case 'suites':
        return {
          text: "Une suite logique est une série d'objets, de formes ou de chiffres qui se répètent en suivant une règle !",
          visual: "🔴 🔵 🔴 🔵 ➡️ 🔴 (Rouge, Bleu, Rouge, Bleu, puis Rouge !)"
        };
      default:
        return {
          text: `Découvrons ensemble la leçon pour le thème ${category}. Entraîne-toi et gagne des récompenses !`,
          visual: "✨ Prêt ? C'est parti ! ✨"
        };
    }
  };

  const explain = getExplanation();

  return (
    <div className="h-full w-full bg-[#FDFFFC] flex flex-col justify-between p-6">
      <div className="flex-1 flex flex-col justify-center text-center">
        <span className="text-5xl animate-bounce mb-4 block">💡</span>
        
        <h3 
          className="text-2xl font-black text-[#011627] mb-4"
          style={{ fontFamily: '"Comic Sans MS", "Chalkboard SE", sans-serif' }}
        >
          Leçon : {category}
        </h3>

        <div className="bg-[#F1FAEE] p-5 rounded-2xl border-2 border-[#2EC4B6]/20 text-left mb-6">
          <p className="text-base text-gray-700 font-bold leading-relaxed mb-3">
            « {explain.text} »
          </p>
          
          <div className="bg-white p-3.5 rounded-xl border border-[#2EC4B6]/10 text-center text-sm font-black text-[#2EC4B6] whitespace-pre-line">
            {explain.visual}
          </div>
        </div>
      </div>

      <div>
        <button
          onClick={() => { CustomAudio.playClick(); onProceed(); }}
          className="w-full bg-[#2EC4B6] hover:bg-[#34d4c5] active:scale-95 text-white font-extrabold py-4 px-6 rounded-2xl shadow-md border-b-4 border-[#259d92] transition-all text-lg"
        >
          J'AI COMPRIS !
        </button>
      </div>
    </div>
  );
}

// ==========================================
// SCREEN 14: EXERCICE PLAYER ENGINE
// ==========================================
export function ExercisePlayer({
  exercises,
  onComplete,
}: {
  exercises: Exercise[];
  onComplete: (score: number, xpEarned: number, newlyUnlockedBadge: string | null) => void;
}) {
  const [currentIndex, setCurrentIndex] = useState(0);
  const [selectedOption, setSelectedOption] = useState<string | null>(null);
  const [inputText, setInputText] = useState('');
  const [hasValidated, setHasValidated] = useState(false);
  const [isCorrect, setIsCorrect] = useState(false);
  const [score, setScore] = useState(0);
  const [xpTotal, setXpTotal] = useState(0);

  const activeEx = exercises[currentIndex];

  const handleValidate = () => {
    if (hasValidated) return;

    let answer = '';
    if (activeEx.type === 'qcm' || activeEx.type === 'shapes') {
      answer = selectedOption || '';
    } else if (activeEx.type === 'true_false') {
      answer = selectedOption || '';
    } else if (activeEx.type === 'input') {
      answer = inputText.trim().toLowerCase();
    }

    const isAnsCorrect = answer === activeEx.correctAnswer.toLowerCase();
    setIsCorrect(isAnsCorrect);
    setHasValidated(true);

    if (isAnsCorrect) {
      CustomAudio.playSuccess();
      setScore((s) => s + 1);
      setXpTotal((x) => x + 10);
    } else {
      CustomAudio.playFailure();
    }
  };

  const handleNext = () => {
    setSelectedOption(null);
    setInputText('');
    setHasValidated(false);

    if (currentIndex < exercises.length - 1) {
      setCurrentIndex((i) => i + 1);
    } else {
      // Completed all exercises!
      // Check badge unlock rule: If score is perfect (e.g. 5/5) or they terminate first lesson
      let badgeUnlocked: string | null = null;
      if (score + (isCorrect ? 1 : 0) >= exercises.length - 1) {
        badgeUnlocked = `badge_${activeEx.subject}`;
      }
      onComplete(score, xpTotal, badgeUnlocked);
    }
  };

  return (
    <div className="h-full w-full bg-[#FDFFFC] flex flex-col justify-between p-5 overflow-y-auto">
      {/* Top Bar */}
      <div>
        <div className="flex justify-between items-center mb-3">
          <span className="text-xs bg-[#F1FAEE] text-[#2EC4B6] font-extrabold px-3 py-1 rounded-full border">
            Exercice {currentIndex + 1} / {exercises.length}
          </span>
          <span className="text-xs text-amber-500 font-extrabold flex items-center gap-1">
            ⭐ Potentiel : +10 XP
          </span>
        </div>

        {/* Progress bar */}
        <div className="w-full h-2 bg-gray-100 rounded-full mb-5 overflow-hidden">
          <div
            className="h-full bg-[#2EC4B6] transition-all duration-300"
            style={{ width: `${((currentIndex) / exercises.length) * 100}%` }}
          />
        </div>

        {/* Question Panel */}
        <div className="space-y-4">
          {activeEx.visualData && (
            <div className="p-4 bg-[#F1FAEE] border border-[#2EC4B6]/20 rounded-2xl text-center text-4xl shadow-inner max-w-xs mx-auto animate-pulse">
              {activeEx.visualData}
            </div>
          )}

          <h4 className="text-lg font-black text-[#011627] leading-relaxed text-center">
            {activeEx.question}
          </h4>
        </div>

        {/* Answer Selection */}
        <div className="mt-6 space-y-2.5">
          {activeEx.type === 'qcm' || activeEx.type === 'shapes' ? (
            <div className="grid grid-cols-1 gap-2">
              {activeEx.options?.map((opt) => (
                <button
                  key={opt}
                  disabled={hasValidated}
                  onClick={() => { CustomAudio.playClick(); setSelectedOption(opt); }}
                  className={`w-full text-left p-4 rounded-xl font-bold border-2 transition-all active:scale-98 ${
                    selectedOption === opt
                      ? 'bg-[#2EC4B6]/20 border-[#2EC4B6] text-[#011627]'
                      : 'bg-white border-gray-200 hover:border-[#2EC4B6]/50'
                  }`}
                >
                  {opt}
                </button>
              ))}
            </div>
          ) : activeEx.type === 'true_false' ? (
            <div className="grid grid-cols-2 gap-3">
              {['Vrai', 'Faux'].map((opt) => (
                <button
                  key={opt}
                  disabled={hasValidated}
                  onClick={() => { CustomAudio.playClick(); setSelectedOption(opt); }}
                  className={`py-4 px-6 rounded-xl font-black text-lg border-2 transition-all active:scale-95 ${
                    selectedOption === opt
                      ? opt === 'Vrai'
                        ? 'bg-emerald-100 border-emerald-500 text-emerald-700'
                        : 'bg-rose-100 border-rose-500 text-rose-700'
                      : 'bg-white border-gray-200'
                  }`}
                >
                  {opt}
                </button>
              ))}
            </div>
          ) : (
            <div>
              <input
                type="text"
                value={inputText}
                disabled={hasValidated}
                onChange={(e) => setInputText(e.target.value)}
                placeholder="Écris ta réponse ici..."
                className="w-full px-5 py-4 rounded-xl bg-[#F1FAEE] border-2 border-gray-200 text-lg font-bold text-[#011627] text-center focus:outline-none focus:border-[#2EC4B6]"
              />
            </div>
          )}
        </div>
      </div>

      {/* Validation Panel */}
      <div className="mt-6 space-y-4">
        {hasValidated && (
          <motion.div
            initial={{ opacity: 0, y: 15 }}
            animate={{ opacity: 1, y: 0 }}
            className={`p-4 rounded-2xl border-2 flex flex-col gap-2 ${
              isCorrect
                ? 'bg-emerald-50 border-emerald-400 text-emerald-800'
                : 'bg-rose-50 border-rose-400 text-rose-800'
            }`}
          >
            <div className="flex items-center gap-2 font-black">
              {isCorrect ? <Check className="w-5 h-5 text-emerald-500" /> : <X className="w-5 h-5 text-rose-500" />}
              <span>{isCorrect ? 'Excellent ! Bonne réponse ! 🎉' : 'Mince ! Essaie de comprendre :'}</span>
            </div>
            <p className="text-xs font-bold leading-relaxed">{activeEx.explanation}</p>
          </motion.div>
        )}

        {!hasValidated ? (
          <button
            onClick={handleValidate}
            disabled={!selectedOption && !inputText.trim()}
            className={`w-full py-4 rounded-2xl font-extrabold shadow-md text-lg transition-all border-b-4 ${
              selectedOption || inputText.trim()
                ? 'bg-[#2EC4B6] hover:bg-[#34d4c5] active:scale-95 text-white border-[#259d92]'
                : 'bg-gray-200 text-gray-400 border-gray-300 cursor-not-allowed'
            }`}
          >
            VÉRIFIER
          </button>
        ) : (
          <button
            onClick={handleNext}
            className="w-full bg-[#FF9F1C] hover:bg-[#ffaa2b] active:scale-95 text-white font-extrabold py-4 rounded-2xl shadow-md border-b-4 border-[#e68400] transition-all flex items-center justify-center gap-2 text-lg"
          >
            SUIVANT
            <ArrowRight className="w-5 h-5" />
          </button>
        )}
      </div>
    </div>
  );
}

// ==========================================
// SCREEN 15: RESULTATS DE LA LEÇON
// ==========================================
export function LessonResultScreen({
  score,
  total,
  xpEarned,
  onContinue,
}: {
  score: number;
  total: number;
  xpEarned: number;
  onContinue: () => void;
}) {
  const percentage = Math.round((score / total) * 100);
  const isGood = percentage >= 70;

  return (
    <div className="h-full w-full bg-[#FDFFFC] flex flex-col justify-between p-6">
      <div className="flex-1 flex flex-col justify-center text-center">
        <span className="text-6xl animate-bounce mb-4 block">{isGood ? '🎉' : '💪'}</span>
        
        <h3 
          className="text-3xl font-black text-[#011627] mb-2"
          style={{ fontFamily: '"Comic Sans MS", "Chalkboard SE", sans-serif' }}
        >
          {isGood ? 'Bravo !' : 'Bien joué !'}
        </h3>
        
        <p className="text-gray-500 font-bold max-w-xs mx-auto mb-6 text-sm">
          {isGood
            ? "Tu as fait un excellent travail sur cette leçon. Tu es un champion !"
            : "Continue tes efforts ! Chaque exercice t'entraîne et te fait progresser !"}
        </p>

        {/* Stats card */}
        <div className="bg-[#F1FAEE] rounded-3xl p-6 border-2 border-[#2EC4B6]/20 max-w-xs mx-auto w-full space-y-4">
          <div>
            <p className="text-xs text-gray-400 font-extrabold uppercase">Score final</p>
            <p className="text-3xl font-black text-[#011627]">{score} / {total}</p>
          </div>

          <div>
            <p className="text-xs text-gray-400 font-extrabold uppercase mb-1">Bonnes réponses</p>
            <div className="w-full h-4 bg-gray-200 rounded-full overflow-hidden border">
              <div className="h-full bg-[#2EC4B6]" style={{ width: `${percentage}%` }} />
            </div>
            <p className="text-xs text-[#2EC4B6] font-black mt-1">{percentage}% de réussite</p>
          </div>

          <div className="bg-white rounded-xl py-2 px-4 border inline-block">
            <p className="text-xs text-amber-500 font-extrabold flex items-center justify-center gap-1">
              ⭐ +{xpEarned} XP Gagnés !
            </p>
          </div>
        </div>
      </div>

      <div>
        <button
          onClick={() => { CustomAudio.playClick(); onContinue(); }}
          className="w-full bg-[#FF9F1C] hover:bg-[#ffaa2b] active:scale-95 text-white font-extrabold py-4 px-6 rounded-2xl shadow-md border-b-4 border-[#e68400] transition-all text-lg"
        >
          CONTINUER L'AVENTURE
        </button>
      </div>
    </div>
  );
}

// ==========================================
// SCREEN 16: RECOMPENSE (NOUVEAU BADGE !)
// ==========================================
export function RewardScreen({
  badgeTitle,
  badgeIcon,
  onClose,
}: {
  badgeTitle: string;
  badgeIcon: string;
  onClose: () => void;
}) {
  useEffect(() => {
    CustomAudio.playBadge();
  }, []);

  return (
    <div className="h-full w-full bg-gradient-to-b from-indigo-900 to-slate-900 flex flex-col justify-between p-6 text-white text-center">
      <div className="flex-1 flex flex-col justify-center items-center">
        <motion.div
          animate={{ scale: [1, 1.2, 1], rotate: [0, 360, 0] }}
          transition={{ duration: 2, repeat: Infinity }}
          className="text-8xl mb-6 bg-yellow-400/20 w-32 h-32 rounded-full flex items-center justify-center shadow-xl border-4 border-yellow-400"
        >
          {badgeIcon}
        </motion.div>

        <span className="text-xs uppercase tracking-widest font-black text-yellow-400 flex items-center gap-1.5 mb-2">
          <Award className="w-4 h-4 animate-pulse" />
          NOUVEAU BADGE DÉBLOQUÉ !
        </span>

        <h3 
          className="text-3xl font-black mb-4"
          style={{ fontFamily: '"Comic Sans MS", "Chalkboard SE", sans-serif' }}
        >
          {badgeTitle}
        </h3>

        <div className="p-4 bg-white/10 rounded-2xl border border-white/10 max-w-xs">
          <p className="text-xs text-gray-300 font-bold leading-relaxed">
            Félicitations ! Tu as prouvé ta force. Un bonus exceptionnel de <strong>+50 XP</strong> est ajouté à ton profil !
          </p>
        </div>
      </div>

      <div>
        <button
          onClick={() => { CustomAudio.playClick(); onClose(); }}
          className="w-full bg-yellow-400 hover:bg-yellow-350 text-slate-900 font-extrabold py-4 px-6 rounded-2xl shadow-lg border-b-4 border-yellow-600 transition-all text-lg"
        >
          CONTINUER L'AVENTURE 🚀
        </button>
      </div>
    </div>
  );
}
