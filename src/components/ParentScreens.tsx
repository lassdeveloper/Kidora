import React, { useState, useEffect } from 'react';
import { motion } from 'motion/react';
import { 
  Lock, ArrowLeft, BarChart3, Clock, Users, Settings, 
  Trash2, RefreshCw, Volume2, VolumeX, Plus, HelpCircle 
} from 'lucide-react';
import { CustomAudio } from './CustomAudio';
import { ChildProfile, DatabaseState, KidoraSettings, DailyLimit } from '../types';

// ==========================================
// SCREEN 21: ACCES PARENT GATE
// ==========================================
export function ParentAccessGate({
  onSuccess,
  onCancel,
}: {
  onSuccess: () => void;
  onCancel: () => void;
}) {
  const [num1, setNum1] = useState(0);
  const [num2, setNum2] = useState(0);
  const [ans, setAns] = useState('');
  const [error, setError] = useState(false);

  useEffect(() => {
    // Generate simple multiplication gate
    setNum1(Math.floor(Math.random() * 5) + 5); // 5 to 9
    setNum2(Math.floor(Math.random() * 5) + 4); // 4 to 8
  }, []);

  const handleVerify = (e: React.FormEvent) => {
    e.preventDefault();
    if (parseInt(ans) === num1 * num2) {
      CustomAudio.playSuccess();
      onSuccess();
    } else {
      CustomAudio.playFailure();
      setError(true);
      setAns('');
    }
  };

  return (
    <div className="h-full w-full bg-[#FDFFFC] flex flex-col justify-between p-6">
      <div>
        <button onClick={onCancel} className="text-gray-500 font-bold mb-6 hover:text-gray-800">Quitter</button>

        <div className="text-center space-y-4 mt-8">
          <span className="text-5xl block">🔒</span>
          <h3 
            className="text-2xl font-extrabold text-[#011627]"
            style={{ fontFamily: '"Comic Sans MS", "Chalkboard SE", sans-serif' }}
          >
            Espace Sécurisé Parent
          </h3>
          <p className="text-sm text-gray-500 max-w-xs mx-auto">
            Pour entrer dans l'espace parent, résous ce calcul pour prouver que tu es un adulte :
          </p>
        </div>

        <form onSubmit={handleVerify} className="mt-8 space-y-4 max-w-xs mx-auto text-center">
          <div className="text-3xl font-black text-[#011627] bg-[#F1FAEE] py-4 rounded-2xl border">
            {num1} × {num2} = ?
          </div>

          <input
            type="number"
            value={ans}
            onChange={(e) => {
              setAns(e.target.value);
              setError(false);
            }}
            placeholder="Écris le résultat..."
            className="w-full text-center px-4 py-3.5 rounded-xl border-2 text-lg font-extrabold text-[#011627] focus:outline-none focus:border-[#2EC4B6]"
            autoFocus
          />

          {error && (
            <p className="text-[#E71D36] text-xs font-bold">
              Oups ! Mauvais calcul. Réessaie !
            </p>
          )}
        </form>
      </div>

      <div>
        <button
          onClick={handleVerify}
          className="w-full bg-[#2EC4B6] hover:bg-[#34d4c5] text-white font-extrabold py-4 px-6 rounded-2xl shadow-md border-b-4 border-[#259d92]"
        >
          ACCÉDER À L'ESPACE PARENT
        </button>
      </div>
    </div>
  );
}

// ==========================================
// MAIN PARENT SCREEN CONTROLLER
// ==========================================
export function ParentScreensController({
  db,
  activeChild,
  onUpdateSettings,
  onUpdateLimit,
  onAddChild,
  onDeleteChild,
  onResetProgress,
  onSwitchChild,
  onExit,
}: {
  db: DatabaseState;
  activeChild: ChildProfile | null;
  onUpdateSettings: (childId: number, settings: Partial<KidoraSettings>) => void;
  onUpdateLimit: (childId: number, maxMinutes: number) => void;
  onAddChild: (name: string, age: number, level: string, avatar: string) => void;
  onDeleteChild: (id: number) => void;
  onResetProgress: () => void;
  onSwitchChild: (id: number) => void;
  onExit: () => void;
}) {
  const [parentTab, setParentTab] = useState<'dashboard' | 'progress' | 'time' | 'profiles' | 'settings'>('dashboard');

  // New Child Profile Form States
  const [newChildName, setNewChildName] = useState('');
  const [newChildAge, setNewChildAge] = useState(6);
  const [newChildLevel, setNewChildLevel] = useState('CP');
  const [newChildAvatar, setNewChildAvatar] = useState('👦');

  // Stats calculation
  const childAnswers = activeChild ? db.exerciseAnswers.filter(a => a.childId === activeChild.id) : [];
  const correctCount = childAnswers.filter(a => a.isCorrect).length;
  const wrongCount = childAnswers.length - correctCount;

  const mathCount = childAnswers.filter(a => a.exerciseId.startsWith('math_')).length;
  const frenchCount = childAnswers.filter(a => a.exerciseId.startsWith('french_')).length;
  const scienceCount = childAnswers.filter(a => a.exerciseId.startsWith('science_')).length;
  const logicCount = childAnswers.filter(a => a.exerciseId.startsWith('logic_')).length;

  const currentSettings = activeChild ? db.settings[activeChild.id] || { language: 'FR', soundEnabled: true, musicEnabled: true, themeDark: false } : { language: 'FR', soundEnabled: true, musicEnabled: true, themeDark: false };
  const currentLimit = activeChild ? db.dailyLimits[activeChild.id] || { maxMinutesPerDay: 30, minutesUsedToday: 0 } : { maxMinutesPerDay: 30, minutesUsedToday: 0 };

  const handleAddChildSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newChildName.trim()) return;
    onAddChild(newChildName.trim(), newChildAge, newChildLevel, newChildAvatar);
    setNewChildName('');
    CustomAudio.playSuccess();
    setParentTab('profiles');
  };

  return (
    <div className="h-full w-full bg-[#FDFFFC] flex flex-col justify-between">
      {/* Top Bar Navigation */}
      <div className="p-4 border-b border-gray-100 flex items-center justify-between">
        <div className="flex items-center gap-2">
          <button onClick={onExit} className="p-1 rounded-full hover:bg-gray-150 text-gray-500">
            <ArrowLeft className="w-5 h-5" />
          </button>
          <span className="font-extrabold text-sm text-[#011627] tracking-tight uppercase">Espace Parent 👨‍👩‍👧</span>
        </div>
        {activeChild && (
          <div className="flex items-center gap-1.5 bg-gray-50 border px-2.5 py-1 rounded-full text-[11px] font-bold">
            <span>{activeChild.avatar}</span>
            <span>{activeChild.name}</span>
          </div>
        )}
      </div>

      {/* Main Tab View */}
      <div className="flex-1 overflow-y-auto p-4 pb-20">
        
        {/* TAB 1: DASHBOARD PARENT */}
        {parentTab === 'dashboard' && activeChild && (
          <div className="space-y-5">
            <div className="bg-[#F1FAEE] p-4 rounded-2xl border flex items-center justify-between">
              <div>
                <p className="text-xs text-gray-400 font-extrabold uppercase">Élève Actif</p>
                <h4 className="text-xl font-black text-[#011627]">{activeChild.name} ({activeChild.age} ans)</h4>
                <p className="text-xs text-gray-500 font-medium">Classe : {activeChild.schoolLevel}</p>
              </div>
              <span className="text-4xl bg-white w-12 h-12 rounded-full flex items-center justify-center border shadow-sm">
                {activeChild.avatar}
              </span>
            </div>

            {/* General progress indicators */}
            <div className="space-y-3.5 bg-white p-4 rounded-2xl border">
              <h5 className="font-black text-[#011627] text-sm mb-1">📊 Progression Globale</h5>
              
              {/* Mathematics */}
              <div>
                <div className="flex justify-between text-xs font-bold text-gray-500 mb-1">
                  <span>Mathématiques</span>
                  <span>{Math.min(100, Math.round((mathCount / 25) * 100))}%</span>
                </div>
                <div className="w-full h-3 bg-gray-100 rounded-full overflow-hidden border">
                  <div className="h-full bg-rose-400" style={{ width: `${Math.min(100, (mathCount / 25) * 100)}%` }} />
                </div>
              </div>

              {/* French */}
              <div>
                <div className="flex justify-between text-xs font-bold text-gray-500 mb-1">
                  <span>Français</span>
                  <span>{Math.min(100, Math.round((frenchCount / 25) * 100))}%</span>
                </div>
                <div className="w-full h-3 bg-gray-100 rounded-full overflow-hidden border">
                  <div className="h-full bg-blue-400" style={{ width: `${Math.min(100, (frenchCount / 25) * 100)}%` }} />
                </div>
              </div>

              {/* Science */}
              <div>
                <div className="flex justify-between text-xs font-bold text-gray-500 mb-1">
                  <span>Sciences</span>
                  <span>{Math.min(100, Math.round((scienceCount / 25) * 100))}%</span>
                </div>
                <div className="w-full h-3 bg-gray-100 rounded-full overflow-hidden border">
                  <div className="h-full bg-emerald-400" style={{ width: `${Math.min(100, (scienceCount / 25) * 100)}%` }} />
                </div>
              </div>

              {/* Logic */}
              <div>
                <div className="flex justify-between text-xs font-bold text-gray-500 mb-1">
                  <span>Logique</span>
                  <span>{Math.min(100, Math.round((logicCount / 25) * 100))}%</span>
                </div>
                <div className="w-full h-3 bg-gray-100 rounded-full overflow-hidden border">
                  <div className="h-full bg-indigo-400" style={{ width: `${Math.min(100, (logicCount / 25) * 100)}%` }} />
                </div>
              </div>
            </div>

            {/* Study Time Summaries */}
            <div className="grid grid-cols-2 gap-3">
              <div className="bg-white rounded-2xl p-4 border text-center">
                <Clock className="w-6 h-6 text-[#FF9F1C] mx-auto mb-1.5" />
                <p className="text-[10px] text-gray-400 font-extrabold uppercase">Temps Aujourd'hui</p>
                <p className="text-lg font-black text-[#011627]">12 minutes</p>
              </div>

              <div className="bg-white rounded-2xl p-4 border text-center">
                <Users className="w-6 h-6 text-[#2EC4B6] mx-auto mb-1.5" />
                <p className="text-[10px] text-gray-400 font-extrabold uppercase">Activités Terminées</p>
                <p className="text-lg font-black text-[#011627]">{childAnswers.length} exercices</p>
              </div>
            </div>
          </div>
        )}

        {/* TAB 2: DETAILED PROGRESS */}
        {parentTab === 'progress' && activeChild && (
          <div className="space-y-4">
            <h4 className="font-black text-lg text-[#011627] mb-2">Progression Détaillée 📊</h4>
            
            <div className="bg-white p-4 rounded-2xl border space-y-4">
              <div className="border-b pb-3 text-center">
                <p className="text-xs text-gray-400 font-extrabold uppercase">Ratio de Bonnes Réponses</p>
                <h5 className="text-3xl font-black text-[#2EC4B6] mt-1">{correctCount} / {childAnswers.length}</h5>
                <p className="text-[10px] text-gray-400 mt-1">Exercices validés avec succès</p>
              </div>

              {/* Graphical Visualizer bar chart */}
              <div>
                <p className="text-xs text-gray-400 font-extrabold uppercase mb-3">Activités par matière</p>
                <div className="flex items-end justify-between px-6 pt-6 h-28 border-b relative">
                  {/* Maths Bar */}
                  <div className="flex flex-col items-center gap-1.5 w-10">
                    <div className="w-6 bg-rose-400 rounded-t-lg transition-all" style={{ height: `${Math.max(10, mathCount * 12)}px` }} />
                    <span className="text-[10px] text-gray-500 font-bold">Mat</span>
                  </div>

                  {/* French Bar */}
                  <div className="flex flex-col items-center gap-1.5 w-10">
                    <div className="w-6 bg-blue-400 rounded-t-lg transition-all" style={{ height: `${Math.max(10, frenchCount * 12)}px` }} />
                    <span className="text-[10px] text-gray-500 font-bold">Fra</span>
                  </div>

                  {/* Science Bar */}
                  <div className="flex flex-col items-center gap-1.5 w-10">
                    <div className="w-6 bg-emerald-400 rounded-t-lg transition-all" style={{ height: `${Math.max(10, scienceCount * 12)}px` }} />
                    <span className="text-[10px] text-gray-500 font-bold">Sci</span>
                  </div>

                  {/* Logic Bar */}
                  <div className="flex flex-col items-center gap-1.5 w-10">
                    <div className="w-6 bg-indigo-400 rounded-t-lg transition-all" style={{ height: `${Math.max(10, logicCount * 12)}px` }} />
                    <span className="text-[10px] text-gray-500 font-bold">Log</span>
                  </div>
                </div>
              </div>
            </div>

            {/* Offline disclaimer */}
            <div className="p-3.5 bg-gray-50 rounded-2xl border text-center text-xs text-gray-400 font-medium">
              Toutes les statistiques sont stockées localement et calculées sur l'appareil.
            </div>
          </div>
        )}

        {/* TAB 3: GESTION DU TEMPS */}
        {parentTab === 'time' && activeChild && (
          <div className="space-y-5">
            <h4 className="font-black text-lg text-[#011627]">Limites de Temps Quotidiennes ⏱️</h4>
            <p className="text-xs text-gray-500 leading-relaxed font-medium">
              Contrôlez le temps d'écran d'apprentissage de votre enfant. Lorsque la limite est atteinte, l'application se verrouille automatiquement jusqu'au lendemain.
            </p>

            <div className="bg-white p-5 rounded-2xl border space-y-4">
              <label className="block text-sm font-extrabold text-[#011627]">
                Limite quotidienne autorisée :
              </label>

              <div className="grid grid-cols-2 gap-2.5">
                {[15, 30, 45, 60, 0].map((minutes) => (
                  <button
                    key={minutes}
                    onClick={() => { CustomAudio.playClick(); onUpdateLimit(activeChild.id, minutes); }}
                    className={`py-3 px-4 rounded-xl text-xs font-black border-2 transition-all ${
                      currentLimit.maxMinutesPerDay === minutes
                        ? 'bg-[#2EC4B6]/20 border-[#2EC4B6] text-[#2EC4B6]'
                        : 'bg-gray-50 border-gray-200 text-gray-500 hover:bg-gray-100'
                    }`}
                  >
                    {minutes === 0 ? 'Pas de limite' : `${minutes} minutes`}
                  </button>
                ))}
              </div>
            </div>

            <div className="bg-amber-50 p-4 rounded-2xl border border-amber-200 flex items-start gap-3">
              <span className="text-xl">💡</span>
              <p className="text-[11px] text-amber-800 leading-relaxed font-medium">
                La limite s'applique de manière autonome. Elle comptabilise l'utilisation totale des leçons, exercices et mini-jeux pour la journée en cours.
              </p>
            </div>
          </div>
        )}

        {/* TAB 4: GESTION DES PROFILS */}
        {parentTab === 'profiles' && (
          <div className="space-y-5">
            <h4 className="font-black text-lg text-[#011627]">Profils Voyageurs 👥</h4>

            {/* List children */}
            <div className="space-y-2.5">
              {db.children.map((child) => (
                <div key={child.id} className="bg-white p-4 rounded-2xl border flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <span className="text-3xl bg-gray-50 w-10 h-10 rounded-full flex items-center justify-center border">{child.avatar}</span>
                    <div>
                      <h5 className="font-extrabold text-[#011627] text-sm">{child.name}</h5>
                      <p className="text-[10px] text-gray-400 font-bold">{child.age} ans — {child.schoolLevel}</p>
                    </div>
                  </div>

                  <div className="flex items-center gap-2">
                    {activeChild?.id !== child.id && (
                      <button
                        onClick={() => { CustomAudio.playClick(); onSwitchChild(child.id); }}
                        className="text-xs bg-[#2EC4B6]/10 text-[#2EC4B6] px-2.5 py-1.5 rounded-lg font-bold hover:bg-[#2EC4B6]/20"
                      >
                        Utiliser
                      </button>
                    )}
                    <button
                      onClick={() => {
                        if (window.confirm(`Supprimer définitivement le profil de ${child.name} ? Cette action est irréversible !`)) {
                          CustomAudio.playFailure();
                          onDeleteChild(child.id);
                        }
                      }}
                      className="p-2 text-rose-500 hover:bg-rose-50 rounded-lg border border-transparent hover:border-rose-200"
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </div>
                </div>
              ))}
            </div>

            {/* Add profile form */}
            <form onSubmit={handleAddChildSubmit} className="bg-gray-50 p-4 rounded-2xl border-2 border-dashed space-y-4">
              <p className="font-black text-[#011627] text-sm flex items-center gap-1.5">
                <Plus className="w-4 h-4" /> Ajouter un autre enfant
              </p>

              <div>
                <label className="block text-[11px] font-bold text-gray-500 uppercase mb-1">Prénom :</label>
                <input
                  type="text"
                  value={newChildName}
                  onChange={(e) => setNewChildName(e.target.value)}
                  placeholder="Ex: Léo, Alice..."
                  className="w-full px-3 py-2 bg-white rounded-lg border focus:outline-none focus:border-[#2EC4B6] text-sm font-bold"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-[11px] font-bold text-gray-500 uppercase mb-1">Âge :</label>
                  <select
                    value={newChildAge}
                    onChange={(e) => setNewChildAge(parseInt(e.target.value))}
                    className="w-full px-2 py-2 bg-white rounded-lg border text-xs font-bold"
                  >
                    {[4, 5, 6, 7, 8, 9, 10, 11, 12].map((a) => (
                      <option key={a} value={a}>{a} ans</option>
                    ))}
                  </select>
                </div>

                <div>
                  <label className="block text-[11px] font-bold text-gray-500 uppercase mb-1">Classe :</label>
                  <select
                    value={newChildLevel}
                    onChange={(e) => setNewChildLevel(e.target.value)}
                    className="w-full px-2 py-2 bg-white rounded-lg border text-xs font-bold"
                  >
                    {['Petite section', 'Moyenne section', 'Grande section', 'CP', 'CE1', 'CE2', 'CM1', 'CM2'].map((l) => (
                      <option key={l} value={l}>{l}</option>
                    ))}
                  </select>
                </div>
              </div>

              <div>
                <label className="block text-[11px] font-bold text-gray-500 uppercase mb-1">Avatar :</label>
                <div className="flex gap-2 max-w-full overflow-x-auto p-1 bg-white border rounded-lg">
                  {['👦', '👧', '🧒', '🦁', '🐼', '🦊', '🦄', '🤖'].map((av) => (
                    <button
                      key={av}
                      type="button"
                      onClick={() => { CustomAudio.playClick(); setNewChildAvatar(av); }}
                      className={`text-2xl p-1.5 rounded-lg border transition-all ${
                        newChildAvatar === av ? 'bg-[#FF9F1C]/20 border-[#FF9F1C]' : 'border-transparent'
                      }`}
                    >
                      {av}
                    </button>
                  ))}
                </div>
              </div>

              <button
                type="submit"
                disabled={!newChildName.trim()}
                className="w-full bg-[#FF9F1C] hover:bg-[#ffaa2b] text-white py-2.5 rounded-xl font-bold shadow-sm text-xs transition-all disabled:opacity-50"
              >
                CRÉER LE PROFIL
              </button>
            </form>
          </div>
        )}

        {/* TAB 5: PARAMETRES */}
        {parentTab === 'settings' && (
          <div className="space-y-4">
            <h4 className="font-black text-lg text-[#011627] mb-2">Paramètres de l'application ⚙️</h4>

            <div className="bg-white p-4 rounded-2xl border space-y-4">
              {/* Language */}
              <div className="flex items-center justify-between border-b pb-3">
                <div>
                  <p className="text-xs font-extrabold text-[#011627]">Langue de l'application</p>
                  <p className="text-[10px] text-gray-400 font-bold">Actuelle : {currentSettings.language}</p>
                </div>
                <div className="flex gap-1 bg-gray-50 p-1 border rounded-lg">
                  {['FR', 'EN'].map((lang) => (
                    <button
                      key={lang}
                      onClick={() => {
                        CustomAudio.playClick();
                        if (activeChild) onUpdateSettings(activeChild.id, { language: lang as 'FR' | 'EN' });
                      }}
                      className={`text-xs px-2.5 py-1 rounded font-black ${
                        currentSettings.language === lang ? 'bg-[#2EC4B6] text-white shadow-sm' : 'text-gray-500'
                      }`}
                    >
                      {lang}
                    </button>
                  ))}
                </div>
              </div>

              {/* Sound effects */}
              <div className="flex items-center justify-between border-b pb-3">
                <div>
                  <p className="text-xs font-extrabold text-[#011627]">Effets Sonores</p>
                  <p className="text-[10px] text-gray-400 font-bold">Bruits de clics et félicitations</p>
                </div>
                <button
                  onClick={() => {
                    CustomAudio.playClick();
                    const nextVal = !currentSettings.soundEnabled;
                    CustomAudio.setSoundEnabled(nextVal);
                    if (activeChild) onUpdateSettings(activeChild.id, { soundEnabled: nextVal });
                  }}
                  className={`p-2 rounded-xl border ${
                    currentSettings.soundEnabled ? 'bg-emerald-50 text-emerald-600 border-emerald-200' : 'bg-gray-50 text-gray-400'
                  }`}
                >
                  {currentSettings.soundEnabled ? <Volume2 className="w-5 h-5" /> : <VolumeX className="w-5 h-5" />}
                </button>
              </div>

              {/* Reset Data */}
              <div className="pt-2">
                <button
                  onClick={() => {
                    if (window.confirm('Voulez-vous réinitialiser TOUTES les progressions, scores, réglages et profils ? Cette action supprimera tout.')) {
                      onResetProgress();
                    }
                  }}
                  className="w-full bg-rose-50 hover:bg-rose-100 text-rose-600 font-extrabold py-2.5 rounded-xl border border-rose-200 text-xs transition-all flex items-center justify-center gap-1.5"
                >
                  <RefreshCw className="w-4 h-4" /> Réinitialiser toutes les données locales
                </button>
              </div>
            </div>

            {/* About Box */}
            <div className="bg-[#F1FAEE] p-4 rounded-2xl border text-left">
              <p className="font-extrabold text-xs text-[#011627] mb-1">ℹ️ Informations sur KIDORA</p>
              <p className="text-[10px] text-gray-500 leading-relaxed font-body">
                KIDORA MVP v1.0.0 — Une application éducative autonome et sécurisée, sans publicités ni collectes de données en ligne, conçue spécialement pour l'épanouissement des enfants.
              </p>
            </div>
          </div>
        )}

      </div>

      {/* Bottom Parent Tab bar */}
      <div className="absolute bottom-0 left-0 right-0 h-16 bg-white border-t border-gray-150 flex items-center justify-around px-4 shadow-md z-20">
        <button
          onClick={() => { CustomAudio.playClick(); setParentTab('dashboard'); }}
          className={`flex flex-col items-center gap-0.5 px-3 py-1.5 rounded-xl transition-all ${
            parentTab === 'dashboard' ? 'text-[#2EC4B6] font-extrabold scale-105' : 'text-gray-400 font-medium'
          }`}
        >
          <BarChart3 className="w-5 h-5" />
          <span className="text-[10px]">Analytics</span>
        </button>

        <button
          onClick={() => { CustomAudio.playClick(); setParentTab('progress'); }}
          className={`flex flex-col items-center gap-0.5 px-3 py-1.5 rounded-xl transition-all ${
            parentTab === 'progress' ? 'text-[#2EC4B6] font-extrabold scale-105' : 'text-gray-400 font-medium'
          }`}
        >
          <BarChart3 className="w-5 h-5 rotate-90" />
          <span className="text-[10px]">Détails</span>
        </button>

        <button
          onClick={() => { CustomAudio.playClick(); setParentTab('time'); }}
          className={`flex flex-col items-center gap-0.5 px-3 py-1.5 rounded-xl transition-all ${
            parentTab === 'time' ? 'text-[#2EC4B6] font-extrabold scale-105' : 'text-gray-400 font-medium'
          }`}
        >
          <Clock className="w-5 h-5" />
          <span className="text-[10px]">Temps</span>
        </button>

        <button
          onClick={() => { CustomAudio.playClick(); setParentTab('profiles'); }}
          className={`flex flex-col items-center gap-0.5 px-3 py-1.5 rounded-xl transition-all ${
            parentTab === 'profiles' ? 'text-[#2EC4B6] font-extrabold scale-105' : 'text-gray-400 font-medium'
          }`}
        >
          <Users className="w-5 h-5" />
          <span className="text-[10px]">Profils</span>
        </button>

        <button
          onClick={() => { CustomAudio.playClick(); setParentTab('settings'); }}
          className={`flex flex-col items-center gap-0.5 px-3 py-1.5 rounded-xl transition-all ${
            parentTab === 'settings' ? 'text-[#2EC4B6] font-extrabold scale-105' : 'text-gray-400 font-medium'
          }`}
        >
          <Settings className="w-5 h-5" />
          <span className="text-[10px]">Réglages</span>
        </button>
      </div>
    </div>
  );
}
