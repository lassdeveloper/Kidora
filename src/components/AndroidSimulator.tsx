import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { Wifi, Signal, Battery, AlertTriangle, Play, HelpCircle } from 'lucide-react';

import { ChildProfile, DatabaseState, KidoraSettings, DailyLimit, ExerciseAnswerRow } from '../types';
import { KIDORA_EXERCISES } from '../data/exercises';
import { CustomAudio } from './CustomAudio';

// Import subcomponent screens
import { 
  SplashScreen, WelcomeScreen, CreateProfileScreen, 
  AvatarSelectionScreen, AgeLevelScreen 
} from './WelcomeScreens';
import { KidoraMiniGames } from './MiniGames';
import { 
  LessonSelectionScreen, LessonPresentationScreen, 
  ExercisePlayer, LessonResultScreen, RewardScreen 
} from './ExerciseEngine';
import { ParentAccessGate, ParentScreensController } from './ParentScreens';
import { KidoraHome } from './KidScreens';

// ==========================================
// SEED INITIAL DATABASE STATE (LOCAL STORAGE PRESERVED)
// ==========================================
const STORAGE_KEY = 'kidora_local_db';

const INITIAL_DB: DatabaseState = {
  children: [
    {
      id: 1,
      name: 'Amina',
      age: 8,
      schoolLevel: 'CE1',
      avatar: '👧',
      xp: 1250,
      level: 8,
      createdAt: new Date().toISOString()
    }
  ],
  exerciseAnswers: [
    // Pre-populate some answers to show stats instantly
    { id: 1, childId: 1, exerciseId: 'math_count_1', isCorrect: true, answeredAt: new Date().toISOString() },
    { id: 2, childId: 1, exerciseId: 'math_add_1', isCorrect: true, answeredAt: new Date().toISOString() },
    { id: 3, childId: 1, exerciseId: 'french_vocab_1', isCorrect: true, answeredAt: new Date().toISOString() },
    { id: 4, childId: 1, exerciseId: 'science_anim_1', isCorrect: true, answeredAt: new Date().toISOString() },
    { id: 5, childId: 1, exerciseId: 'logic_seq_1', isCorrect: false, answeredAt: new Date().toISOString() }
  ],
  childBadges: [
    { childId: 1, badgeId: 'badge_first_step', unlockedAt: new Date().toISOString() },
    { childId: 1, badgeId: 'badge_10_correct', unlockedAt: new Date().toISOString() }
  ],
  gameScores: [],
  settings: {
    1: { childId: 1, language: 'FR', soundEnabled: true, musicEnabled: true, themeDark: false }
  },
  dailyLimits: {
    1: { childId: 1, maxMinutesPerDay: 30, minutesUsedToday: 18, lastResetDate: new Date().toDateString() }
  }
};

export default function AndroidSimulator({
  onDbUpdate,
}: {
  onDbUpdate?: (db: DatabaseState) => void;
}) {
  const [db, setDb] = useState<DatabaseState>(() => {
    const cached = localStorage.getItem(STORAGE_KEY);
    if (cached) {
      try {
        const parsed = JSON.parse(cached);
        return parsed;
      } catch (e) {
        return INITIAL_DB;
      }
    }
    return INITIAL_DB;
  });

  const [activeChildId, setActiveChildId] = useState<number | null>(() => {
    return db.children.length > 0 ? db.children[0].id : null;
  });

  const [route, setRoute] = useState<string>('/splash');
  const [currentSubject, setCurrentSubject] = useState<'maths' | 'french' | 'science' | 'logic' | null>(null);
  const [currentCategory, setCurrentCategory] = useState<string | null>(null);
  const [activeExercises, setActiveExercises] = useState<any[]>([]);
  
  // Scoring parameters for current session
  const [sessionScore, setSessionScore] = useState(0);
  const [sessionXp, setSessionXp] = useState(0);
  const [newlyUnlockedBadge, setNewlyUnlockedBadge] = useState<string | null>(null);

  // Profile creation flow buffer
  const [formName, setFormName] = useState('');
  const [formAvatar, setFormAvatar] = useState('👦');

  // Time tracker state
  const [simulatedMinutesLeft, setSimulatedMinutesLeft] = useState(12);
  const [isTimeLocked, setIsTimeLocked] = useState(false);

  // Notify parent component about changes
  useEffect(() => {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(db));
    if (onDbUpdate) {
      onDbUpdate(db);
    }
  }, [db]);

  const activeChild = db.children.find(c => c.id === activeChildId) || null;

  // Handles time tracking simulation
  useEffect(() => {
    if (!activeChildId) return;
    const limit = db.dailyLimits[activeChildId] || { maxMinutesPerDay: 30, minutesUsedToday: 18 };
    
    if (limit.maxMinutesPerDay > 0 && limit.minutesUsedToday >= limit.maxMinutesPerDay) {
      setIsTimeLocked(true);
    } else {
      setIsTimeLocked(false);
      setSimulatedMinutesLeft(limit.maxMinutesPerDay - limit.minutesUsedToday);
    }
  }, [activeChildId, db.dailyLimits]);

  // ==========================================
  // DB WRITE FUNCTIONS (SIMULATING SQLITE WRITE CONTROLLER)
  // ==========================================
  const handleCreateProfile = (ageRange: string, schoolLvl: string) => {
    const newId = db.children.length > 0 ? Math.max(...db.children.map(c => c.id)) + 1 : 1;
    const newChild: ChildProfile = {
      id: newId,
      name: formName,
      age: parseInt(ageRange.split('-')[0]) || 6,
      schoolLevel: schoolLvl,
      avatar: formAvatar,
      xp: 0,
      level: 1,
      createdAt: new Date().toISOString()
    };

    // Initialize Settings and daily limits rows
    const childSettings: KidoraSettings = {
      childId: newId,
      language: 'FR',
      soundEnabled: true,
      musicEnabled: true,
      themeDark: false
    };

    const childLimits: DailyLimit = {
      childId: newId,
      maxMinutesPerDay: 30,
      minutesUsedToday: 0,
      lastResetDate: new Date().toDateString()
    };

    // Award "First Step" badge to newly created child profile
    const firstStepBadge = {
      childId: newId,
      badgeId: 'badge_first_step',
      unlockedAt: new Date().toISOString()
    };

    setDb(prev => ({
      ...prev,
      children: [...prev.children, newChild],
      settings: { ...prev.settings, [newId]: childSettings },
      dailyLimits: { ...prev.dailyLimits, [newId]: childLimits },
      childBadges: [...prev.childBadges, firstStepBadge]
    }));

    setActiveChildId(newId);
    setRoute('/home');
  };

  const handleUpdateSettings = (childId: number, updated: Partial<KidoraSettings>) => {
    setDb(prev => {
      const current = prev.settings[childId] || { childId, language: 'FR', soundEnabled: true, musicEnabled: true, themeDark: false };
      return {
        ...prev,
        settings: {
          ...prev.settings,
          [childId]: { ...current, ...updated }
        }
      };
    });
  };

  const handleUpdateLimit = (childId: number, maxMins: number) => {
    setDb(prev => {
      const current = prev.dailyLimits[childId] || { childId, maxMinutesPerDay: 30, minutesUsedToday: 0, lastResetDate: new Date().toDateString() };
      return {
        ...prev,
        dailyLimits: {
          ...prev.dailyLimits,
          [childId]: { ...current, maxMinutesPerDay: maxMins, minutesUsedToday: 0 }
        }
      };
    });
  };

  const handleAddChildProfile = (name: string, age: number, level: string, avatar: string) => {
    const newId = Math.max(...db.children.map(c => c.id)) + 1;
    const newChild: ChildProfile = {
      id: newId,
      name,
      age,
      schoolLevel: level,
      avatar,
      xp: 0,
      level: 1,
      createdAt: new Date().toISOString()
    };

    setDb(prev => ({
      ...prev,
      children: [...prev.children, newChild],
      settings: {
        ...prev.settings,
        [newId]: { childId: newId, language: 'FR', soundEnabled: true, musicEnabled: true, themeDark: false }
      },
      dailyLimits: {
        ...prev.dailyLimits,
        [newId]: { childId: newId, maxMinutesPerDay: 30, minutesUsedToday: 0, lastResetDate: new Date().toDateString() }
      }
    }));
  };

  const handleDeleteChildProfile = (id: number) => {
    setDb(prev => ({
      ...prev,
      children: prev.children.filter(c => c.id !== id),
      exerciseAnswers: prev.exerciseAnswers.filter(a => a.childId !== id),
      childBadges: prev.childBadges.filter(b => b.childId !== id),
      gameScores: prev.gameScores.filter(s => s.childId !== id)
    }));
    if (activeChildId === id) {
      setActiveChildId(db.children.find(c => c.id !== id)?.id || null);
    }
  };

  const handleResetProgress = () => {
    setDb(INITIAL_DB);
    setActiveChildId(1);
    setRoute('/splash');
  };

  const handleSaveMiniGameScore = (gameId: string, score: number) => {
    if (!activeChildId) return;
    const newRow = {
      id: Date.now(),
      childId: activeChildId,
      gameId,
      score,
      playedAt: new Date().toISOString()
    };
    setDb(prev => ({
      ...prev,
      gameScores: [...prev.gameScores, newRow]
    }));
  };

  const handleSelectCategory = (subj: 'maths' | 'french' | 'science' | 'logic', cat: string) => {
    setCurrentSubject(subj);
    setCurrentCategory(cat);

    // Filter exercises matching category and age range of active child
    const age = activeChild?.age || 6;
    const list = KIDORA_EXERCISES.filter(ex => ex.subject === subj && ex.category === cat && age >= ex.ageMin && age <= ex.ageMax);
    setActiveExercises(list.length > 0 ? list : KIDORA_EXERCISES.filter(ex => ex.subject === subj && ex.category === cat).slice(0, 5));

    setRoute('/lesson-selection');
  };

  const handleExerciseSessionComplete = (score: number, xpEarned: number, badge: string | null) => {
    setSessionScore(score);
    setSessionXp(xpEarned);
    setNewlyUnlockedBadge(badge);

    if (activeChildId && activeChild) {
      // 1. Record exercise answer rows in database
      const timestamp = new Date().toISOString();
      const newAnswers: ExerciseAnswerRow[] = activeExercises.map((ex, i) => ({
        id: Date.now() + i,
        childId: activeChildId,
        exerciseId: ex.id,
        isCorrect: i < score, // Simulating first 'score' answers correct
        answeredAt: timestamp
      }));

      // 2. Compute level up formula: Level = floor(XP / 250) + 1
      const updatedXp = activeChild.xp + xpEarned;
      const updatedLevel = Math.floor(updatedXp / 250) + 1;

      if (updatedLevel > activeChild.level) {
        setTimeout(() => CustomAudio.playLevelUp(), 1000);
      }

      const updatedChildren = db.children.map(c => {
        if (c.id === activeChildId) {
          return { ...c, xp: updatedXp, level: updatedLevel };
        }
        return c;
      });

      // 3. Unlock badges rows if newly unlocked
      let updatedBadges = [...db.childBadges];
      if (badge && !db.childBadges.some(b => b.childId === activeChildId && b.badgeId === badge)) {
        updatedBadges.push({
          childId: activeChildId,
          badgeId: badge,
          unlockedAt: timestamp
        });
      }

      setDb(prev => ({
        ...prev,
        children: updatedChildren,
        exerciseAnswers: [...prev.exerciseAnswers, ...newAnswers],
        childBadges: updatedBadges
      }));
    }

    setRoute('/result');
  };

  return (
    <div className="w-full max-w-sm mx-auto flex justify-center items-center h-full p-2">
      {/* Physical Android Device Frame Wrapper */}
      <div className="w-full aspect-[9/18.5] max-h-[700px] rounded-[42px] border-8 border-slate-800 bg-slate-900 shadow-2xl relative overflow-hidden flex flex-col">
        
        {/* Notch / Speaker Earphone */}
        <div className="absolute top-0 left-1/2 -translate-x-1/2 w-32 h-6 bg-slate-800 rounded-b-2xl z-50 flex items-center justify-center gap-1.5">
          <div className="w-12 h-1 bg-slate-900 rounded-full" />
          <div className="w-2.5 h-2.5 bg-slate-900 rounded-full" />
        </div>

        {/* Status Bar Indicator */}
        <div className="h-7 bg-slate-900 text-white flex justify-between items-center px-6 text-[10px] z-40 select-none font-bold">
          <div className="flex items-center gap-1">
            <span>12:35</span>
            <span className="text-[9px] bg-red-600 px-1 py-0.2 rounded font-extrabold flex items-center gap-0.5">
              ✈️ HORS-LIGNE
            </span>
          </div>
          <div className="flex items-center gap-1.5">
            <Signal className="w-3 h-3 text-gray-500 opacity-50 line-through" />
            <Wifi className="w-3 h-3 text-gray-500 opacity-50 line-through" />
            <Battery className="w-4 h-4 text-emerald-500 fill-emerald-500" />
            <span>98%</span>
          </div>
        </div>

        {/* Time-locked block screen (Screen 20 Limit Block) */}
        {isTimeLocked ? (
          <div className="flex-1 bg-white flex flex-col justify-between p-6 text-center select-none z-50">
            <div className="flex-1 flex flex-col justify-center items-center">
              <span className="text-6xl animate-bounce mb-4 block">😴</span>
              <h3 className="text-2xl font-black text-[#011627] mb-2">Limite de Temps Atteinte</h3>
              <p className="text-sm text-gray-500 max-w-xs leading-relaxed font-body">
                « Bravo pour aujourd'hui ! Faisons une petite pause. » Il est temps de reposer tes yeux !
              </p>
              
              <div className="mt-6 p-4 bg-amber-50 rounded-2xl border border-dashed text-xs text-amber-800 font-bold max-w-xs">
                💡 Conseil Parent : Vous pouvez augmenter ou désactiver la limite quotidienne d'apprentissage dans les paramètres de l'espace parent.
              </div>
            </div>
            
            <button
              onClick={() => { CustomAudio.playClick(); handleUpdateLimit(activeChildId!, 0); setIsTimeLocked(false); }}
              className="w-full bg-[#2EC4B6] hover:bg-[#34d4c5] text-white font-extrabold py-3 rounded-xl border-b-4 border-[#259d92]"
            >
              🔓 Déverrouiller (Code Parent requis)
            </button>
          </div>
        ) : (
          /* Internal Screen Display Router */
          <div className="flex-1 bg-[#FDFFFC] relative overflow-hidden flex flex-col text-[#011627]">
            <AnimatePresence mode="wait">
              
              {/* SPLASH SCREEN */}
              {route === '/splash' && (
                <motion.div key="splash" className="h-full w-full" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}>
                  <SplashScreen onComplete={() => setRoute(db.children.length > 0 ? '/home' : '/onboarding')} />
                </motion.div>
              )}

              {/* WELCOME SCREEN */}
              {route === '/onboarding' && (
                <motion.div key="welcome" className="h-full w-full" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}>
                  <WelcomeScreen
                    onStart={() => setRoute('/create-child')}
                    onChooseExisting={() => setRoute('/home')}
                    hasExistingProfiles={db.children.length > 0}
                  />
                </motion.div>
              )}

              {/* CREATE PROFILE */}
              {route === '/create-child' && (
                <motion.div key="create-child" className="h-full w-full" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}>
                  <CreateProfileScreen
                    initialName={formName}
                    onNext={(name) => { setFormName(name); setRoute('/avatar'); }}
                    onCancel={() => setRoute('/onboarding')}
                  />
                </motion.div>
              )}

              {/* AVATAR SELECTION */}
              {route === '/avatar' && (
                <motion.div key="avatar" className="h-full w-full" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}>
                  <AvatarSelectionScreen
                    onNext={(avatar) => { setFormAvatar(avatar); setRoute('/age-level'); }}
                    onBack={() => setRoute('/create-child')}
                  />
                </motion.div>
              )}

              {/* AGE / LEVEL SELECTION */}
              {route === '/age-level' && (
                <motion.div key="age-level" className="h-full w-full" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}>
                  <AgeLevelScreen
                    onComplete={handleCreateProfile}
                    onBack={() => setRoute('/avatar')}
                  />
                </motion.div>
              )}

              {/* CORE KID HOME SCREEN */}
              {route === '/home' && activeChild && (
                <motion.div key="home" className="h-full w-full" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}>
                  <KidoraHome
                    profile={activeChild}
                    db={db}
                    onNavigate={(r) => setRoute(r)}
                    onSelectCategory={handleSelectCategory}
                    onLogout={() => setRoute('/onboarding')}
                  />
                </motion.div>
              )}

              {/* MINI GAMES SCREEN */}
              {route === '/games' && activeChildId && (
                <motion.div key="games" className="h-full w-full" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}>
                  <KidoraMiniGames
                    childId={activeChildId}
                    onSaveScore={handleSaveMiniGameScore}
                    onBack={() => setRoute('/home')}
                  />
                </motion.div>
              )}

              {/* LESSON SELECTION SCREEN */}
              {route === '/lesson-selection' && currentSubject && currentCategory && (
                <motion.div key="lesson-sel" className="h-full w-full" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}>
                  <LessonSelectionScreen
                    subject={currentSubject}
                    category={currentCategory}
                    exercisesCount={activeExercises.length}
                    onStart={() => setRoute('/lesson-presentation')}
                    onBack={() => setRoute('/home')}
                  />
                </motion.div>
              )}

              {/* LESSON PRESENTATION SCREEN */}
              {route === '/lesson-presentation' && currentCategory && currentSubject && (
                <motion.div key="lesson-pres" className="h-full w-full" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}>
                  <LessonPresentationScreen
                    category={currentCategory}
                    subject={currentSubject}
                    onProceed={() => setRoute('/exercise')}
                  />
                </motion.div>
              )}

              {/* INTERACTIVE EXERCISES ENGINE */}
              {route === '/exercise' && activeExercises.length > 0 && (
                <motion.div key="exercise-engine" className="h-full w-full" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}>
                  <ExercisePlayer
                    exercises={activeExercises}
                    onComplete={handleExerciseSessionComplete}
                  />
                </motion.div>
              )}

              {/* EXERCISE RESULTS CARD */}
              {route === '/result' && (
                <motion.div key="result" className="h-full w-full" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}>
                  <LessonResultScreen
                    score={sessionScore}
                    total={activeExercises.length}
                    xpEarned={sessionXp}
                    onContinue={() => setRoute(newlyUnlockedBadge ? '/reward' : '/home')}
                  />
                </motion.div>
              )}

              {/* REWARD BADGE CELEBRATION */}
              {route === '/reward' && newlyUnlockedBadge && (
                <motion.div key="reward" className="h-full w-full" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}>
                  <RewardScreen
                    badgeTitle={newlyUnlockedBadge === 'badge_maths' ? 'Grand Mathématicien' : newlyUnlockedBadge === 'badge_french' ? 'Jeune Lecteur' : newlyUnlockedBadge === 'badge_science' ? 'Petit Explorateur' : 'Maître Logique'}
                    badgeIcon={newlyUnlockedBadge === 'badge_maths' ? '🔢' : newlyUnlockedBadge === 'badge_french' ? '📚' : newlyUnlockedBadge === 'badge_science' ? '🔬' : '🧠'}
                    onClose={() => setRoute('/home')}
                  />
                </motion.div>
              )}

              {/* PARENT PASSCODE GATE */}
              {route === '/parent' && (
                <motion.div key="parent-gate" className="h-full w-full" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}>
                  <ParentAccessGate
                    onSuccess={() => setRoute('/parent/dashboard')}
                    onCancel={() => setRoute('/home')}
                  />
                </motion.div>
              )}

              {/* PARENT SYSTEM DASHBOARD */}
              {route === '/parent/dashboard' && (
                <motion.div key="parent-dashboard" className="h-full w-full" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}>
                  <ParentScreensController
                    db={db}
                    activeChild={activeChild}
                    onUpdateSettings={handleUpdateSettings}
                    onUpdateLimit={handleUpdateLimit}
                    onAddChild={handleAddChildProfile}
                    onDeleteChild={handleDeleteChildProfile}
                    onResetProgress={handleResetProgress}
                    onSwitchChild={(id) => { setActiveChildId(id); }}
                    onExit={() => setRoute('/home')}
                  />
                </motion.div>
              )}

            </AnimatePresence>
          </div>
        )}

        {/* Physical Home Button Indicator Bar */}
        <div className="h-4 bg-slate-900 flex justify-center items-center z-50 select-none">
          <button
            onClick={() => { CustomAudio.playClick(); setRoute('/home'); }}
            className="w-16 h-1 bg-slate-700 hover:bg-slate-500 rounded-full transition-colors"
          />
        </div>
      </div>
    </div>
  );
}
