import React, { useState, useEffect } from 'react';
import { motion } from 'motion/react';
import { Sparkles, ArrowRight, UserPlus, Users } from 'lucide-react';
import { CustomAudio } from './CustomAudio';
import { ChildProfile } from '../types';

// ==========================================
// SCREEN 1: SPLASH SCREEN
// ==========================================
export function SplashScreen({ onComplete }: { onComplete: () => void }) {
  useEffect(() => {
    CustomAudio.playClick();
    const timer = setTimeout(() => {
      onComplete();
    }, 2200);
    return () => clearTimeout(timer);
  }, [onComplete]);

  return (
    <div className="h-full w-full bg-gradient-to-b from-[#FFBE0B] to-[#FF9F1C] flex flex-col items-center justify-center text-white p-6 relative overflow-hidden">
      {/* Decorative floating shapes */}
      <motion.div
        animate={{ y: [0, -15, 0], rotate: [0, 10, 0] }}
        transition={{ repeat: Infinity, duration: 4, ease: "easeInOut" }}
        className="absolute top-12 left-12 text-4xl opacity-40"
      >
        🎈
      </motion.div>
      <motion.div
        animate={{ y: [0, 15, 0], rotate: [0, -10, 0] }}
        transition={{ repeat: Infinity, duration: 3.5, ease: "easeInOut", delay: 0.5 }}
        className="absolute bottom-16 right-12 text-4xl opacity-40"
      >
        ⭐
      </motion.div>
      <motion.div
        animate={{ scale: [1, 1.1, 1] }}
        transition={{ repeat: Infinity, duration: 3, ease: "easeInOut" }}
        className="absolute top-1/4 right-8 text-3xl opacity-30"
      >
        🎨
      </motion.div>

      <div className="text-center z-10 flex flex-col items-center">
        {/* Animated mascot symbol */}
        <motion.div
          initial={{ scale: 0, rotate: -45 }}
          animate={{ scale: 1, rotate: 0 }}
          transition={{ type: "spring", stiffness: 100, delay: 0.2 }}
          className="w-24 h-24 bg-white rounded-3xl flex items-center justify-center text-5xl shadow-xl mb-6 border-4 border-[#3A86C8]"
        >
          🦊
        </motion.div>

        <motion.h1
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.5 }}
          className="text-5xl font-extrabold tracking-wider font-display drop-shadow-md"
          style={{ fontFamily: '"Comic Sans MS", "Chalkboard SE", sans-serif' }}
        >
          KIDORA
        </motion.h1>

        <motion.p
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 1.1 }}
          className="text-lg font-medium opacity-90 tracking-wide mt-2 font-body"
        >
          « Apprendre. Jouer. Explorer. »
        </motion.p>
      </div>

      <div className="absolute bottom-10 left-0 right-0 flex justify-center">
        <div className="w-16 h-2 bg-white/30 rounded-full overflow-hidden">
          <motion.div
            initial={{ width: 0 }}
            animate={{ width: "100%" }}
            transition={{ duration: 1.8, ease: "easeInOut" }}
            className="h-full bg-white rounded-full"
          />
        </div>
      </div>
    </div>
  );
}

// ==========================================
// SCREEN 2: BIENVENUE SCREEN
// ==========================================
export function WelcomeScreen({
  onStart,
  onChooseExisting,
  hasExistingProfiles,
}: {
  onStart: () => void;
  onChooseExisting: () => void;
  hasExistingProfiles: boolean;
}) {
  return (
    <div className="h-full w-full bg-[#FDFFFC] flex flex-col justify-between p-6">
      <div className="flex-1 flex flex-col items-center justify-center text-center">
        <motion.div
          animate={{ y: [0, -10, 0] }}
          transition={{ repeat: Infinity, duration: 3, ease: "easeInOut" }}
          className="text-7xl mb-6"
        >
          👋
        </motion.div>

        <h2 
          className="text-3xl font-extrabold text-[#011627] mb-3"
          style={{ fontFamily: '"Comic Sans MS", "Chalkboard SE", sans-serif' }}
        >
          Bienvenue dans KIDORA !
        </h2>

        <p className="text-gray-600 text-base max-w-xs font-medium leading-relaxed">
          Une merveilleuse aventure hors-ligne pour apprendre, jouer et explorer le monde.
        </p>

        {/* Mascot card illustration */}
        <div className="mt-8 p-4 bg-[#F1FAEE] rounded-2xl border-2 border-[#E0E0E0] w-full max-w-xs flex items-center gap-4">
          <span className="text-4xl">🦁</span>
          <div className="text-left">
            <p className="font-bold text-[#011627] text-sm">Prêt pour l'aventure ?</p>
            <p className="text-xs text-gray-500">Gagne des badges, grimpe les niveaux et joue à des jeux amusants !</p>
          </div>
        </div>
      </div>

      <div className="space-y-3 z-10">
        <button
          onClick={() => {
            CustomAudio.playClick();
            onStart();
          }}
          className="w-full bg-[#FF9F1C] hover:bg-[#ffaa2b] active:scale-95 text-white font-extrabold py-4 px-6 rounded-2xl shadow-md border-b-4 border-[#e68400] transition-all flex items-center justify-center gap-2 text-lg"
        >
          <Sparkles className="w-5 h-5" />
          COMMENCER
        </button>

        {hasExistingProfiles && (
          <button
            onClick={() => {
              CustomAudio.playClick();
              onChooseExisting();
            }}
            className="w-full bg-[#2EC4B6] hover:bg-[#34d4c5] active:scale-95 text-white font-bold py-3.5 px-6 rounded-2xl shadow-md border-b-4 border-[#259d92] transition-all flex items-center justify-center gap-2"
          >
            <Users className="w-5 h-5" />
            J'AI DÉJÀ UN PROFIL
          </button>
        )}
      </div>
    </div>
  );
}

// ==========================================
// SCREEN 3: CREATION PROFIL SCREEN
// ==========================================
export function CreateProfileScreen({
  onNext,
  onCancel,
  initialName = '',
}: {
  onNext: (name: string) => void;
  onCancel: () => void;
  initialName?: string;
}) {
  const [name, setName] = useState(initialName);
  const [error, setError] = useState('');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!name.trim()) {
      setError('Oups ! Écris ton prénom pour commencer !');
      return;
    }
    if (name.length > 15) {
      setError('Oups ! Ce prénom est un peu trop long.');
      return;
    }
    CustomAudio.playClick();
    onNext(name.trim());
  };

  return (
    <div className="h-full w-full bg-[#FDFFFC] flex flex-col justify-between p-6">
      <div>
        <div className="flex items-center justify-between mb-6">
          <button
            onClick={() => { CustomAudio.playClick(); onCancel(); }}
            className="text-gray-500 font-bold hover:text-gray-800"
          >
            Retour
          </button>
          <span className="text-xs bg-[#F1FAEE] text-[#2EC4B6] font-extrabold px-3 py-1.5 rounded-full border border-[#2EC4B6]">
            Étape 1 sur 3
          </span>
        </div>

        <h2 
          className="text-2xl font-extrabold text-[#011627] mb-2"
          style={{ fontFamily: '"Comic Sans MS", "Chalkboard SE", sans-serif' }}
        >
          Qui es-tu ? 😊
        </h2>
        <p className="text-sm text-gray-500 mb-6">
          Créons ton premier profil de voyageur. Aucune donnée n'est envoyée sur Internet.
        </p>

        <form onSubmit={handleSubmit} className="space-y-5">
          <div>
            <label className="block text-sm font-extrabold text-[#011627] mb-2">
              Ton prénom ou pseudonyme :
            </label>
            <input
              type="text"
              value={name}
              onChange={(e) => {
                setName(e.target.value);
                setError('');
              }}
              placeholder="Ex: Amina, Léo..."
              className="w-full px-5 py-4 rounded-2xl bg-[#F1FAEE] border-2 border-[#2EC4B6]/30 text-lg font-bold text-[#011627] focus:outline-none focus:border-[#2EC4B6] transition-all"
            />
            {error && (
              <p className="text-[#E71D36] text-sm font-bold mt-2 flex items-center gap-1">
                ⚠️ {error}
              </p>
            )}
          </div>
          
          <div className="p-4 bg-[#F1FAEE] rounded-2xl border border-dashed border-gray-300 flex items-center gap-3">
            <span className="text-2xl">🔒</span>
            <p className="text-xs text-gray-500 leading-relaxed">
              <strong>100% Privé :</strong> Les informations restent uniquement sur ce téléphone et ne sortent jamais.
            </p>
          </div>
        </form>
      </div>

      <div>
        <button
          onClick={handleSubmit}
          className="w-full bg-[#FF9F1C] hover:bg-[#ffaa2b] active:scale-95 text-white font-extrabold py-4 px-6 rounded-2xl shadow-md border-b-4 border-[#e68400] transition-all flex items-center justify-center gap-2 text-lg"
        >
          CONTINUER
          <ArrowRight className="w-5 h-5" />
        </button>
      </div>
    </div>
  );
}

// ==========================================
// SCREEN 4: CHOIX DE L'AVATAR
// ==========================================
const AVAILABLE_AVATARS = [
  '👦', '👧', '🧒', '🧑', '🦸', '🧙', 
  '🦁', '🐼', '🦄', '🦖', '🦊', '🐯',
  '🐙', '🐨', '🐸', '🤖'
];

export function AvatarSelectionScreen({
  onNext,
  onBack,
}: {
  onNext: (avatar: string) => void;
  onBack: () => void;
}) {
  const [selected, setSelected] = useState(AVAILABLE_AVATARS[0]);

  const handleSelect = (avatar: string) => {
    CustomAudio.playClick();
    setSelected(avatar);
  };

  return (
    <div className="h-full w-full bg-[#FDFFFC] flex flex-col justify-between p-6">
      <div>
        <div className="flex items-center justify-between mb-5">
          <button
            onClick={() => { CustomAudio.playClick(); onBack(); }}
            className="text-gray-500 font-bold hover:text-gray-800"
          >
            Retour
          </button>
          <span className="text-xs bg-[#F1FAEE] text-[#2EC4B6] font-extrabold px-3 py-1.5 rounded-full border border-[#2EC4B6]">
            Étape 2 sur 3
          </span>
        </div>

        <h2 
          className="text-2xl font-extrabold text-[#011627] mb-2"
          style={{ fontFamily: '"Comic Sans MS", "Chalkboard SE", sans-serif' }}
        >
          Choisis ton avatar 🎨
        </h2>
        <p className="text-sm text-gray-500 mb-5">
          Sélectionne le compagnon qui te représentera durant tout ton voyage !
        </p>

        {/* Selected avatar preview */}
        <div className="flex justify-center mb-6">
          <motion.div
            key={selected}
            initial={{ scale: 0.6, rotate: -20 }}
            animate={{ scale: 1.1, rotate: 0 }}
            className="w-24 h-24 bg-[#FF9F1C]/10 border-4 border-[#FF9F1C] rounded-full flex items-center justify-center text-5xl shadow-md"
          >
            {selected}
          </motion.div>
        </div>

        {/* Avatar Grid */}
        <div className="grid grid-cols-4 gap-3 max-h-56 overflow-y-auto p-1 bg-gray-55 rounded-2xl">
          {AVAILABLE_AVATARS.map((avatar) => (
            <button
              key={avatar}
              onClick={() => handleSelect(avatar)}
              className={`aspect-square text-3.5xl rounded-2xl flex items-center justify-center border-2 transition-all active:scale-90 ${
                selected === avatar
                  ? 'bg-[#FF9F1C]/20 border-[#FF9F1C] scale-105 shadow-md'
                  : 'bg-[#F1FAEE] border-gray-200 hover:border-[#FF9F1C]/50'
              }`}
            >
              {avatar}
            </button>
          ))}
        </div>
      </div>

      <div className="pt-4">
        <button
          onClick={() => {
            CustomAudio.playClick();
            onNext(selected);
          }}
          className="w-full bg-[#FF9F1C] hover:bg-[#ffaa2b] active:scale-95 text-white font-extrabold py-4 px-6 rounded-2xl shadow-md border-b-4 border-[#e68400] transition-all text-lg"
        >
          CHOISIR L'AVATAR
        </button>
      </div>
    </div>
  );
}

// ==========================================
// SCREEN 5: AGE / NIVEAU SCOLAIRE
// ==========================================
const AGE_GROUPS = [
  { value: '4-5', label: '4–5 ans' },
  { value: '6-7', label: '6–7 ans' },
  { value: '8-9', label: '8–9 ans' },
  { value: '10-12', label: '10–12 ans' },
];

const SCHOOL_LEVELS = [
  'Petite section',
  'Moyenne section',
  'Grande section',
  'CP',
  'CE1',
  'CE2',
  'CM1',
  'CM2'
];

export function AgeLevelScreen({
  onComplete,
  onBack,
}: {
  onComplete: (ageRange: string, level: string) => void;
  onBack: () => void;
}) {
  const [selectedAge, setSelectedAge] = useState('6-7');
  const [selectedLevel, setSelectedLevel] = useState('CP');

  return (
    <div className="h-full w-full bg-[#FDFFFC] flex flex-col justify-between p-6 overflow-y-auto">
      <div>
        <div className="flex items-center justify-between mb-4">
          <button
            onClick={() => { CustomAudio.playClick(); onBack(); }}
            className="text-gray-500 font-bold hover:text-gray-800"
          >
            Retour
          </button>
          <span className="text-xs bg-[#F1FAEE] text-[#2EC4B6] font-extrabold px-3 py-1.5 rounded-full border border-[#2EC4B6]">
            Étape 3 sur 3
          </span>
        </div>

        <h2 
          className="text-2xl font-extrabold text-[#011627] mb-2"
          style={{ fontFamily: '"Comic Sans MS", "Chalkboard SE", sans-serif' }}
        >
          Ton niveau d'école 🏫
        </h2>
        <p className="text-xs text-gray-500 mb-4">
          KIDORA adapte ses leçons et exercices automatiquement en fonction de ton âge et de ta classe !
        </p>

        {/* Age Picker */}
        <div className="mb-4">
          <label className="block text-sm font-extrabold text-[#011627] mb-2">
            Sélectionne ton âge :
          </label>
          <div className="grid grid-cols-2 gap-2">
            {AGE_GROUPS.map((age) => (
              <button
                key={age.value}
                onClick={() => { CustomAudio.playClick(); setSelectedAge(age.value); }}
                className={`py-2.5 px-4 rounded-xl text-sm font-extrabold border-2 transition-all ${
                  selectedAge === age.value
                    ? 'bg-[#2EC4B6]/20 border-[#2EC4B6] text-[#2EC4B6]'
                    : 'bg-[#F1FAEE] border-gray-200 text-gray-600'
                }`}
              >
                {age.label}
              </button>
            ))}
          </div>
        </div>

        {/* School Level Picker */}
        <div>
          <label className="block text-sm font-extrabold text-[#011627] mb-2">
            Sélectionne ta classe :
          </label>
          <div className="grid grid-cols-2 gap-1.5 max-h-36 overflow-y-auto p-1 bg-gray-50 rounded-xl border border-gray-100">
            {SCHOOL_LEVELS.map((lvl) => (
              <button
                key={lvl}
                onClick={() => { CustomAudio.playClick(); setSelectedLevel(lvl); }}
                className={`py-2 px-3 rounded-xl text-xs font-bold border transition-all ${
                  selectedLevel === lvl
                    ? 'bg-[#FF9F1C]/20 border-[#FF9F1C] text-[#FF9F1C]'
                    : 'bg-white border-gray-200 text-gray-600 hover:bg-[#F1FAEE]'
                }`}
              >
                {lvl}
              </button>
            ))}
          </div>
        </div>
      </div>

      <div className="pt-3">
        <button
          onClick={() => {
            CustomAudio.playClick();
            onComplete(selectedAge, selectedLevel);
          }}
          className="w-full bg-[#FF9F1C] hover:bg-[#ffaa2b] active:scale-95 text-white font-extrabold py-3.5 px-6 rounded-2xl shadow-md border-b-4 border-[#e68400] transition-all flex items-center justify-center gap-2 text-lg"
        >
          CRÉER MON AVENTURE 🚀
        </button>
      </div>
    </div>
  );
}
