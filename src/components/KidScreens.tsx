import React, { useState } from 'react';
import { motion } from 'motion/react';
import { 
  Trophy, BookOpen, Binary, Compass, Brain, User, 
  Map, ShieldAlert, Award, ChevronRight, Lock, MapPin, 
  ArrowLeft, Star, Clock, Check 
} from 'lucide-react';
import { CustomAudio } from './CustomAudio';
import { ChildProfile, DatabaseState } from '../types';

// ==========================================
// MAIN CONTROLLER FOR KIDS GAMEPLAY VIEWS
// ==========================================
export function KidoraHome({
  profile,
  db,
  onNavigate,
  onSelectCategory,
  onLogout,
}: {
  profile: ChildProfile;
  db: DatabaseState;
  onNavigate: (route: string) => void;
  onSelectCategory: (subject: 'maths' | 'french' | 'science' | 'logic', category: string) => void;
  onLogout: () => void;
}) {
  const [subView, setSubView] = useState<'home' | 'map' | 'subject' | 'profile' | 'badges'>('home');
  const [selectedSubject, setSelectedSubject] = useState<'maths' | 'french' | 'science' | 'logic' | null>(null);

  // Quick Stats
  const childAnswers = db.exerciseAnswers.filter(a => a.childId === profile.id);
  const correctCount = childAnswers.filter(a => a.isCorrect).length;
  const badgesCount = db.childBadges.filter(b => b.childId === profile.id).length;

  const handleSubjectClick = (subj: 'maths' | 'french' | 'science' | 'logic') => {
    CustomAudio.playClick();
    setSelectedSubject(subj);
    setSubView('subject');
  };

  const handleCategoryClick = (category: string) => {
    if (selectedSubject) {
      onSelectCategory(selectedSubject, category);
    }
  };

  return (
    <div className="h-full w-full bg-[#FDFFFC] flex flex-col justify-between">
      {/* Scrollable View Area */}
      <div className="flex-1 overflow-y-auto p-4 pb-20">
        
        {/* VIEW: HOME SCREEN */}
        {subView === 'home' && (
          <div className="space-y-5">
            {/* Top Info Header */}
            <div className="flex justify-between items-start">
              <div className="flex items-center gap-3">
                <div className="w-14 h-14 rounded-2xl bg-[#FF9F1C]/10 border-2 border-[#FF9F1C] flex items-center justify-center text-3xl shadow-sm">
                  {profile.avatar}
                </div>
                <div>
                  <h3 className="font-extrabold text-[#011627] text-lg">Bonjour {profile.name} 👋</h3>
                  <div className="flex items-center gap-1.5 mt-0.5">
                    <span className="text-xs bg-amber-100 text-amber-600 font-extrabold px-2 py-0.5 rounded-full flex items-center gap-1">
                      ⭐ Niv. {profile.level}
                    </span>
                    <span className="text-xs text-gray-400 font-bold">{profile.xp} XP</span>
                  </div>
                </div>
              </div>
              
              <button
                onClick={() => { CustomAudio.playClick(); onNavigate('/parent'); }}
                className="p-2.5 bg-gray-50 border border-gray-100 rounded-xl hover:bg-gray-100 text-gray-500 font-bold text-xs flex items-center gap-1"
              >
                🔒 Parent
              </button>
            </div>

            {/* Resume button */}
            <button
              onClick={() => handleSubjectClick('maths')}
              className="w-full bg-[#FF9F1C] hover:bg-[#ffaa2b] text-white p-4 rounded-2xl shadow-md border-b-4 border-[#e68400] text-left flex items-center justify-between transition-all group active:scale-98"
            >
              <div className="flex items-center gap-3">
                <span className="text-3xl bg-white/20 p-1.5 rounded-xl animate-pulse">🚀</span>
                <div>
                  <p className="text-xs text-white/80 font-bold uppercase tracking-wider">Continuer mon voyage</p>
                  <p className="font-extrabold text-base">Île des Mathématiques !</p>
                </div>
              </div>
              <ChevronRight className="w-5 h-5 group-hover:translate-x-1 transition-transform" />
            </button>

            {/* Mes Mondes Category Section */}
            <div>
              <div className="flex justify-between items-center mb-3">
                <h4 className="font-black text-[#011627] text-base flex items-center gap-1.5">
                  <Map className="w-5 h-5 text-[#2EC4B6]" />
                  🌍 MES MONDES
                </h4>
                <button
                  onClick={() => { CustomAudio.playClick(); setSubView('map'); }}
                  className="text-xs font-bold text-[#2EC4B6] hover:underline"
                >
                  Voir la carte
                </button>
              </div>

              <div className="grid grid-cols-2 gap-3">
                {/* Math World */}
                <button
                  onClick={() => handleSubjectClick('maths')}
                  className="bg-white hover:shadow-md border-2 border-rose-100 p-4 rounded-2xl text-center active:scale-95 transition-all"
                >
                  <span className="text-4xl block mb-2">🔢</span>
                  <p className="font-black text-[#011627] text-xs">Mathématiques</p>
                  <span className="text-[10px] text-rose-500 font-extrabold bg-rose-50 px-2 py-0.5 rounded-full mt-1.5 inline-block">7 Thèmes</span>
                </button>

                {/* French World */}
                <button
                  onClick={() => handleSubjectClick('french')}
                  className="bg-white hover:shadow-md border-2 border-blue-100 p-4 rounded-2xl text-center active:scale-95 transition-all"
                >
                  <span className="text-4xl block mb-2">📚</span>
                  <p className="font-black text-[#011627] text-xs">Français</p>
                  <span className="text-[10px] text-blue-500 font-extrabold bg-blue-50 px-2 py-0.5 rounded-full mt-1.5 inline-block">8 Thèmes</span>
                </button>

                {/* Science World */}
                <button
                  onClick={() => handleSubjectClick('science')}
                  className="bg-white hover:shadow-md border-2 border-emerald-100 p-4 rounded-2xl text-center active:scale-95 transition-all"
                >
                  <span className="text-4xl block mb-2">🔬</span>
                  <p className="font-black text-[#011627] text-xs">Sciences</p>
                  <span className="text-[10px] text-emerald-500 font-extrabold bg-emerald-50 px-2 py-0.5 rounded-full mt-1.5 inline-block">8 Thèmes</span>
                </button>

                {/* Logic World */}
                <button
                  onClick={() => handleSubjectClick('logic')}
                  className="bg-white hover:shadow-md border-2 border-indigo-100 p-4 rounded-2xl text-center active:scale-95 transition-all"
                >
                  <span className="text-4xl block mb-2">🧠</span>
                  <p className="font-black text-[#011627] text-xs">Logique</p>
                  <span className="text-[10px] text-indigo-500 font-extrabold bg-indigo-50 px-2 py-0.5 rounded-full mt-1.5 inline-block">7 Thèmes</span>
                </button>
              </div>
            </div>

            {/* Mascot advice box */}
            <div className="p-4 bg-[#F1FAEE] rounded-2xl border-2 border-dashed border-gray-300 flex items-center gap-4">
              <span className="text-4xl animate-bounce">🦊</span>
              <div>
                <p className="font-extrabold text-xs text-[#011627]">Le conseil de Kido :</p>
                <p className="text-[11px] text-gray-500 leading-relaxed mt-0.5">Visite la Forêt du Français ou gagne de superbes badges dans l'onglet Profil !</p>
              </div>
            </div>
          </div>
        )}

        {/* VIEW: WORLDS MAP */}
        {subView === 'map' && (
          <div className="space-y-4 text-[#011627]">
            <div className="flex items-center gap-3">
              <button onClick={() => { CustomAudio.playClick(); setSubView('home'); }} className="p-1 rounded-full hover:bg-gray-100"><ArrowLeft className="w-5 h-5" /></button>
              <h4 className="font-black text-xl">Carte interactive 🗺️</h4>
            </div>
            
            <p className="text-xs text-gray-400 font-bold mb-4">Navigue entre les mondes pour compléter ton aventure !</p>

            <div className="relative flex flex-col gap-6 p-4 bg-gray-55 border-2 border-dashed border-gray-200 rounded-3xl">
              {/* World 1 */}
              <button
                onClick={() => handleSubjectClick('maths')}
                className="w-full bg-white p-4 rounded-2xl shadow-sm hover:shadow-md border-2 border-rose-100 flex items-center justify-between text-left transition-all active:scale-98"
              >
                <div className="flex items-center gap-3">
                  <span className="text-4xl">🏝️</span>
                  <div>
                    <h5 className="font-black text-[#011627] text-sm">🔢 Île des Mathématiques</h5>
                    <p className="text-[10px] text-gray-400 font-extrabold mt-0.5 flex items-center gap-1">✓ Débloqué (Niveau 1+)</p>
                  </div>
                </div>
                <span className="text-xs font-bold text-rose-500 bg-rose-50 px-2.5 py-1 rounded-full border border-rose-200">Visiter</span>
              </button>

              {/* World 2 */}
              <button
                onClick={() => handleSubjectClick('french')}
                className="w-full bg-white p-4 rounded-2xl shadow-sm hover:shadow-md border-2 border-blue-100 flex items-center justify-between text-left transition-all active:scale-98"
              >
                <div className="flex items-center gap-3">
                  <span className="text-4xl">🌲</span>
                  <div>
                    <h5 className="font-black text-[#011627] text-sm">📚 Forêt du Français</h5>
                    <p className="text-[10px] text-gray-400 font-extrabold mt-0.5 flex items-center gap-1">✓ Débloqué (Niveau 1+)</p>
                  </div>
                </div>
                <span className="text-xs font-bold text-blue-500 bg-blue-50 px-2.5 py-1 rounded-full border border-blue-200">Visiter</span>
              </button>

              {/* World 3 (Locked or unlocked based on level) */}
              <button
                disabled={profile.level < 2}
                onClick={() => handleSubjectClick('science')}
                className={`w-full p-4 rounded-2xl flex items-center justify-between text-left transition-all ${
                  profile.level >= 2
                    ? 'bg-white hover:shadow-md border-2 border-emerald-100 active:scale-98'
                    : 'bg-gray-100 opacity-60 border-2 border-gray-200'
                }`}
              >
                <div className="flex items-center gap-3">
                  <span className="text-4xl">{profile.level >= 2 ? '🌋' : '🔒'}</span>
                  <div>
                    <h5 className="font-black text-[#011627] text-sm">🔬 Labo des Sciences</h5>
                    <p className="text-[10px] text-gray-400 font-extrabold mt-0.5">
                      {profile.level >= 2 ? '✓ Débloqué !' : 'Requiert le niveau 2'}
                    </p>
                  </div>
                </div>
                {profile.level >= 2 ? (
                  <span className="text-xs font-bold text-emerald-500 bg-emerald-50 px-2.5 py-1 rounded-full border border-emerald-200">Visiter</span>
                ) : (
                  <Lock className="w-5 h-5 text-gray-400" />
                )}
              </button>

              {/* World 4 */}
              <button
                disabled={profile.level < 3}
                onClick={() => handleSubjectClick('logic')}
                className={`w-full p-4 rounded-2xl flex items-center justify-between text-left transition-all ${
                  profile.level >= 3
                    ? 'bg-white hover:shadow-md border-2 border-indigo-100 active:scale-98'
                    : 'bg-gray-100 opacity-60 border-2 border-gray-200'
                }`}
              >
                <div className="flex items-center gap-3">
                  <span className="text-4xl">{profile.level >= 3 ? '🏰' : '🔒'}</span>
                  <div>
                    <h5 className="font-black text-[#011627] text-sm">🧠 Royaume de la Logique</h5>
                    <p className="text-[10px] text-gray-400 font-extrabold mt-0.5">
                      {profile.level >= 3 ? '✓ Débloqué !' : 'Requiert le niveau 3'}
                    </p>
                  </div>
                </div>
                {profile.level >= 3 ? (
                  <span className="text-xs font-bold text-indigo-500 bg-indigo-50 px-2.5 py-1 rounded-full border border-indigo-200">Visiter</span>
                ) : (
                  <Lock className="w-5 h-5 text-gray-400" />
                )}
              </button>
            </div>
          </div>
        )}

        {/* VIEW: SUBJECT THEMES SELECTION */}
        {subView === 'subject' && selectedSubject && (
          <div className="space-y-4">
            <div className="flex items-center gap-3">
              <button onClick={() => { CustomAudio.playClick(); setSubView('home'); }} className="p-1 rounded-full hover:bg-gray-100"><ArrowLeft className="w-5 h-5" /></button>
              <h4 className="font-black text-xl capitalize">{selectedSubject} 🌟</h4>
            </div>

            <p className="text-xs text-gray-400 font-extrabold">Sélectionne un thème pour commencer à t'exercer :</p>

            <div className="space-y-2.5">
              {/* Mathematics categories */}
              {selectedSubject === 'maths' && [
                { cat: 'compter', desc: 'Apprends à compter jusqu\'à 10, puis 20 !', icon: '🍎' },
                { cat: 'addition', desc: 'Réunis des éléments et calcule des totaux.', icon: '➕' },
                { cat: 'soustraction', desc: 'Retire des éléments de ton paquet.', icon: '➖' },
                { cat: 'multiplication', desc: 'Multiplie tes gains de manière répétée !', icon: '✖️' },
                { cat: 'division', desc: 'Partage équitablement avec tes amis.', icon: '➗' },
                { cat: 'géométrie', desc: 'Identifie les triangles, carrés et cercles.', icon: '🔺' },
                { cat: 'problèmes', desc: 'Résous de petites histoires logiques.', icon: '🤔' },
              ].map((item) => (
                <button
                  key={item.cat}
                  onClick={() => handleCategoryClick(item.cat)}
                  className="w-full bg-white hover:shadow-md border-2 border-rose-100 p-4 rounded-2xl text-left flex items-center justify-between active:scale-98 transition-all"
                >
                  <div className="flex items-center gap-3">
                    <span className="text-3.5xl">{item.icon}</span>
                    <div>
                      <h5 className="font-extrabold text-[#011627] text-sm capitalize">{item.cat}</h5>
                      <p className="text-[10px] text-gray-400 font-bold mt-0.5">{item.desc}</p>
                    </div>
                  </div>
                  <ChevronRight className="w-5 h-5 text-rose-300" />
                </button>
              ))}

              {/* French categories */}
              {selectedSubject === 'french' && [
                { cat: 'alphabet', desc: 'Reconnais les lettres de l\'alphabet.', icon: '🅰️' },
                { cat: 'syllabes', desc: 'Découpe et assemble les sons ensemble.', icon: '🧩' },
                { cat: 'vocabulaire', desc: 'Découvre le nom des animaux et des fruits.', icon: '🥑' },
                { cat: 'lecture', desc: 'Lis des phrases courtes et des énigmes.', icon: '📖' },
                { cat: 'orthographe', desc: 'Écris les mots correctement au pluriel.', icon: '✍️' },
                { cat: 'grammaire', desc: 'Trouve les verbes, noms et adjectifs.', icon: '🔍' },
                { cat: 'conjugaison', desc: 'Conjugue au présent et au futur simple.', icon: '📅' },
              ].map((item) => (
                <button
                  key={item.cat}
                  onClick={() => handleCategoryClick(item.cat)}
                  className="w-full bg-white hover:shadow-md border-2 border-blue-100 p-4 rounded-2xl text-left flex items-center justify-between active:scale-98 transition-all"
                >
                  <div className="flex items-center gap-3">
                    <span className="text-3.5xl">{item.icon}</span>
                    <div>
                      <h5 className="font-extrabold text-[#011627] text-sm capitalize">{item.cat}</h5>
                      <p className="text-[10px] text-gray-400 font-bold mt-0.5">{item.desc}</p>
                    </div>
                  </div>
                  <ChevronRight className="w-5 h-5 text-blue-300" />
                </button>
              ))}

              {/* Science categories */}
              {selectedSubject === 'science' && [
                { cat: 'animaux', desc: 'Étudie la nature et l\'alimentation animale.', icon: '🦁' },
                { cat: 'plantes', desc: 'Découvre le rôle des racines et de la terre.', icon: '🌱' },
                { cat: 'corps humain', desc: 'Apprends à connaître ton squelette et ton cœur.', icon: '❤️' },
                { cat: 'environnement', desc: 'Trie les déchets et protège la nature.', icon: '♻️' },
                { cat: 'espace', desc: 'Découvre le système solaire et le Soleil.', icon: '🚀' },
                { cat: 'météo', desc: 'Mesure la température et l\'eau de pluie.', icon: '🌡️' },
                { cat: 'matière', desc: 'Comprends les glaçons et l\'oxygène gazeux.', icon: '❄️' },
                { cat: 'phénomènes naturels', desc: 'Observe les arcs-en-ciel et les volcans !', icon: '🌋' },
              ].map((item) => (
                <button
                  key={item.cat}
                  onClick={() => handleCategoryClick(item.cat)}
                  className="w-full bg-white hover:shadow-md border-2 border-emerald-100 p-4 rounded-2xl text-left flex items-center justify-between active:scale-98 transition-all"
                >
                  <div className="flex items-center gap-3">
                    <span className="text-3.5xl">{item.icon}</span>
                    <div>
                      <h5 className="font-extrabold text-[#011627] text-sm capitalize">{item.cat}</h5>
                      <p className="text-[10px] text-gray-400 font-bold mt-0.5">{item.desc}</p>
                    </div>
                  </div>
                  <ChevronRight className="w-5 h-5 text-emerald-300" />
                </button>
              ))}

              {/* Logic categories */}
              {selectedSubject === 'logic' && [
                { cat: 'suites', desc: 'Complète des séries de formes et de nombres.', icon: '🔄' },
                { cat: 'couleurs', desc: 'Mélange le bleu, le rouge et le jaune.', icon: '🎨' },
                { cat: 'observation', desc: 'Trouve l\'intrus caché parmi les objets.', icon: '🧐' },
                { cat: 'classement', desc: 'Classe du plus lourd au plus léger.', icon: '⚖️' },
                { cat: 'puzzles', desc: 'Calcule les faces des cubes et des boîtes.', icon: '🎲' },
                { cat: 'mémoire', desc: 'Retiens les suites de fruits et de nombres.', icon: '🧠' },
              ].map((item) => (
                <button
                  key={item.cat}
                  onClick={() => handleCategoryClick(item.cat)}
                  className="w-full bg-white hover:shadow-md border-2 border-indigo-100 p-4 rounded-2xl text-left flex items-center justify-between active:scale-98 transition-all"
                >
                  <div className="flex items-center gap-3">
                    <span className="text-3.5xl">{item.icon}</span>
                    <div>
                      <h5 className="font-extrabold text-[#011627] text-sm capitalize">{item.cat}</h5>
                      <p className="text-[10px] text-gray-400 font-bold mt-0.5">{item.desc}</p>
                    </div>
                  </div>
                  <ChevronRight className="w-5 h-5 text-indigo-300" />
                </button>
              ))}
            </div>
          </div>
        )}

        {/* VIEW: PROFIL CARD */}
        {subView === 'profile' && (
          <div className="space-y-5">
            <h4 className="font-black text-xl mb-4 text-[#011627]">Mon Profil Voyageur 👤</h4>

            {/* Profile dashboard */}
            <div className="bg-gradient-to-br from-[#2EC4B6]/20 to-[#2EC4B6]/5 border-2 border-[#2EC4B6] p-5 rounded-3xl text-center space-y-4">
              <span className="text-6xl block">{profile.avatar}</span>
              <h5 className="text-2xl font-black text-[#011627]">{profile.name}</h5>
              
              <div className="grid grid-cols-2 gap-3 max-w-xs mx-auto">
                <div className="bg-white rounded-xl p-3 border">
                  <p className="text-[10px] text-gray-400 font-extrabold uppercase">Niveau actuel</p>
                  <p className="text-lg font-black text-amber-500">⭐️ {profile.level}</p>
                </div>
                <div className="bg-white rounded-xl p-3 border">
                  <p className="text-[10px] text-gray-400 font-extrabold uppercase">Points XP</p>
                  <p className="text-lg font-black text-amber-500">✨ {profile.xp}</p>
                </div>
              </div>

              {/* Progress bar to next level */}
              <div className="pt-2">
                <div className="flex justify-between text-xs font-bold text-gray-500 px-1 mb-1">
                  <span>Prochain Niveau</span>
                  <span>{profile.xp} / {profile.level * 250} XP</span>
                </div>
                <div className="w-full h-3 bg-white/50 rounded-full overflow-hidden border">
                  <div className="h-full bg-[#FF9F1C]" style={{ width: `${Math.min(100, (profile.xp / (profile.level * 250)) * 100)}%` }} />
                </div>
              </div>
            </div>

            {/* Sub achievements card */}
            <div className="bg-white p-4 rounded-2xl border-2 space-y-3">
              <h5 className="font-black text-[#011627] text-sm">🏆 Mes Trophées</h5>
              
              <div className="flex items-center justify-between border-b pb-2">
                <span className="text-xs text-gray-500 font-bold flex items-center gap-1.5">
                  <Check className="w-4 h-4 text-[#2EC4B6]" /> Exercices validés
                </span>
                <span className="text-xs font-extrabold text-[#011627]">{correctCount}</span>
              </div>

              <div className="flex items-center justify-between border-b pb-2">
                <span className="text-xs text-gray-500 font-bold flex items-center gap-1.5">
                  <Award className="w-4 h-4 text-amber-500" /> Badges débloqués
                </span>
                <span className="text-xs font-extrabold text-[#011627]">{badgesCount} / 6</span>
              </div>

              <div className="flex items-center justify-between pt-1">
                <span className="text-xs text-gray-500 font-bold flex items-center gap-1.5">
                  <Clock className="w-4 h-4 text-[#FF9F1C]" /> Classe d'école
                </span>
                <span className="text-xs font-extrabold text-[#011627]">{profile.schoolLevel}</span>
              </div>
            </div>

            <button
              onClick={() => { CustomAudio.playClick(); setSubView('badges'); }}
              className="w-full bg-[#2EC4B6] hover:bg-[#34d4c5] text-white font-extrabold py-3.5 px-6 rounded-2xl shadow-md border-b-4 border-[#259d92] text-sm"
            >
              VOIR TOUS MES BADGES
            </button>

            <button
              onClick={() => { CustomAudio.playClick(); onLogout(); }}
              className="w-full bg-gray-50 hover:bg-gray-100 text-gray-600 font-bold py-2.5 rounded-xl border text-xs"
            >
              Changer de Profil de Joueur
            </button>
          </div>
        )}

        {/* VIEW: BADGES LIST */}
        {subView === 'badges' && (
          <div className="space-y-4">
            <div className="flex items-center gap-3">
              <button onClick={() => { CustomAudio.playClick(); setSubView('profile'); }} className="p-1 rounded-full hover:bg-gray-100"><ArrowLeft className="w-5 h-5" /></button>
              <h4 className="font-black text-xl text-[#011627]">Boîte à Badges 🏆</h4>
            </div>

            <p className="text-xs text-gray-400 font-bold mb-4">Termine tes leçons avec succès pour collectionner tous les badges !</p>

            <div className="grid grid-cols-2 gap-3">
              {[
                { id: 'badge_first_step', title: 'Premier pas', desc: 'Avoir créé ton premier profil enfant.', icon: '🏆' },
                { id: 'badge_10_correct', desc: 'Avoir répondu correctement à 10 exercices.', title: 'Cerveau Agile', icon: '⭐' },
                { id: 'badge_maths', desc: 'Avoir terminé une leçon de Mathématiques.', title: 'Mathématicien', icon: '🔢' },
                { id: 'badge_french', desc: 'Avoir terminé une leçon de Français.', title: 'Jeune Lecteur', icon: '📚' },
                { id: 'badge_science', desc: 'Avoir terminé une leçon de Sciences.', title: 'Explorateur', icon: '🔬' },
                { id: 'badge_logic', desc: 'Avoir terminé une leçon de Logique.', title: 'Maître Logique', icon: '🧠' }
              ].map((badge) => {
                const isUnlocked = db.childBadges.some(b => b.childId === profile.id && b.badgeId === badge.id);
                return (
                  <div
                    key={badge.id}
                    className={`p-4 rounded-2xl border-2 text-center flex flex-col items-center justify-between ${
                      isUnlocked
                        ? 'bg-white border-yellow-400 shadow-sm'
                        : 'bg-gray-50 border-gray-200 opacity-60'
                    }`}
                  >
                    <div className={`w-14 h-14 rounded-full flex items-center justify-center text-3xl mb-2 ${
                      isUnlocked ? 'bg-yellow-400/20' : 'bg-gray-200 text-gray-400 blur-[1px]'
                    }`}>
                      {badge.icon}
                    </div>
                    <p className="text-xs font-black text-[#011627] leading-none mb-1">{badge.title}</p>
                    <p className="text-[9px] text-gray-400 font-medium leading-tight">{badge.desc}</p>
                    
                    <span className={`text-[9px] font-extrabold px-2 py-0.5 rounded-full mt-2 inline-block border ${
                      isUnlocked ? 'bg-yellow-50 text-yellow-600 border-yellow-200' : 'bg-gray-200 text-gray-500 border-gray-300'
                    }`}>
                      {isUnlocked ? '✓ Débloqué' : '🔒 Verrouillé'}
                    </span>
                  </div>
                );
              })}
            </div>
          </div>
        )}

      </div>

      {/* Bottom Tabs Nav Bar (Screen 6 tabs block) */}
      <div className="absolute bottom-0 left-0 right-0 h-16 bg-white border-t border-gray-150 flex items-center justify-around px-4 shadow-md z-20">
        <button
          onClick={() => { CustomAudio.playClick(); setSubView('home'); }}
          className={`flex flex-col items-center gap-0.5 px-3 py-1.5 rounded-xl transition-all ${
            subView === 'home' || subView === 'map' || subView === 'subject'
              ? 'text-[#FF9F1C] font-extrabold scale-105'
              : 'text-gray-400 font-medium'
          }`}
        >
          <Compass className="w-5 h-5" />
          <span className="text-[10px]">Mondes</span>
        </button>

        <button
          onClick={() => { CustomAudio.playClick(); onNavigate('/games'); }}
          className="flex flex-col items-center gap-0.5 px-3 py-1.5 rounded-xl text-gray-400 font-medium hover:text-[#2EC4B6]"
        >
          <Compass className="w-5 h-5 rotate-45 text-amber-500 animate-pulse" />
          <span className="text-[10px] text-amber-600 font-extrabold">Mini-jeux 🎮</span>
        </button>

        <button
          onClick={() => { CustomAudio.playClick(); setSubView('profile'); }}
          className={`flex flex-col items-center gap-0.5 px-3 py-1.5 rounded-xl transition-all ${
            subView === 'profile' || subView === 'badges'
              ? 'text-[#2EC4B6] font-extrabold scale-105'
              : 'text-gray-400 font-medium'
          }`}
        >
          <User className="w-5 h-5" />
          <span className="text-[10px]">Profil</span>
        </button>
      </div>
    </div>
  );
}
