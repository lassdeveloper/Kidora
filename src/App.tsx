import React, { useState } from 'react';
import { motion } from 'motion/react';
import { 
  Folder, FileText, Settings, Award, Compass, Heart, Check, 
  Sparkles, Smartphone, Code2, Download, AlertCircle, RefreshCw,
  BookOpen, Terminal, TerminalSquare
} from 'lucide-react';

import AndroidSimulator from './components/AndroidSimulator';
import { FLUTTER_CODEBASE, CodeFile } from './data/flutter_codebase';
import { DatabaseState } from './types';

export default function App() {
  const [selectedFile, setSelectedFile] = useState<CodeFile>(FLUTTER_CODEBASE[0]);
  const [copied, setCopied] = useState(false);
  const [stats, setStats] = useState<DatabaseState | null>(null);

  const handleCopyCode = () => {
    navigator.clipboard.writeText(selectedFile.code);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const handleDownloadCodebase = () => {
    // Generate a quick offline zip or markdown of the files for the user
    const content = FLUTTER_CODEBASE.map(f => `// ==========================================\n// FILE: ${f.path}\n// ==========================================\n${f.code}`).join('\n\n');
    const blob = new Blob([content], { type: 'text/plain;charset=utf-8' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = 'kidora_flutter_codebase.txt';
    link.click();
    URL.revokeObjectURL(url);
  };

  return (
    <div className="min-h-screen w-full bg-[#F4F7F6] text-[#011627] flex flex-col font-sans select-none overflow-hidden">
      
      {/* Visual Navigation Header */}
      <header className="bg-white border-b border-gray-200 px-6 py-4 flex items-center justify-between shadow-sm z-30 shrink-0">
        <div className="flex items-center gap-3">
          <span className="text-3xl animate-bounce">🦊</span>
          <div>
            <div className="flex items-center gap-2">
              <h1 className="text-xl font-black tracking-tight text-[#011627]">KIDORA MVP</h1>
              <span className="text-[10px] bg-red-100 text-red-600 font-extrabold px-2 py-0.5 rounded-full flex items-center gap-0.5">
                ✈️ HORS-LIGNE
              </span>
            </div>
            <p className="text-xs text-gray-400 font-bold">« Apprendre. Jouer. Explorer. » — MVP Android Simulation</p>
          </div>
        </div>

        <div className="hidden md:flex items-center gap-4">
          <div className="flex gap-2 text-xs bg-gray-50 border px-3 py-1.5 rounded-xl font-bold">
            <span className="text-gray-400">Statut simulateur :</span>
            <span className="text-emerald-500 flex items-center gap-1">🟢 Actif & Autonome</span>
          </div>

          <button
            onClick={handleDownloadCodebase}
            className="flex items-center gap-1.5 bg-[#FF9F1C] hover:bg-[#ffaa2b] text-white text-xs font-extrabold px-4 py-2 rounded-xl shadow-sm border-b-2 border-[#e68400] transition-transform active:scale-95"
          >
            <Download className="w-3.5 h-3.5" /> Exporter Codebase Flutter
          </button>
        </div>
      </header>

      {/* Main Dual-Pane Content Body */}
      <main className="flex-1 flex flex-col lg:flex-row overflow-hidden">
        
        {/* LEFT COLUMN: The beautiful live interactive Android Smartphone Simulator */}
        <section className="flex-1 flex flex-col justify-center items-center p-4 bg-gradient-to-tr from-gray-100 to-gray-200 border-r border-gray-200 relative overflow-hidden min-h-[500px] lg:min-h-0">
          
          {/* Subtle grid background for high-tech simulator vibe */}
          <div className="absolute inset-0 bg-[radial-gradient(#e5e7eb_1px,transparent_1px)] [background-size:16px_16px] opacity-60" />
          
          <div className="relative z-10 w-full flex flex-col items-center">
            <AndroidSimulator onDbUpdate={(database) => setStats(database)} />
            
            {/* Simulation tips below the phone */}
            <div className="mt-4 flex gap-4 max-w-sm text-center px-4">
              <p className="text-[11px] text-gray-500 font-medium leading-relaxed bg-white/70 backdrop-blur px-3 py-2 rounded-xl border">
                <strong>💡 Astuce :</strong> Touchez le bouton <strong>🔒 Parent</strong> en haut à droite de l'accueil pour accéder aux analytics, limites d'écran et profils d'enfants !
              </p>
            </div>
          </div>
        </section>

        {/* RIGHT COLUMN: The interactive Flutter Architecture & Code Inspector */}
        <section className="w-full lg:w-[480px] xl:w-[540px] bg-white flex flex-col border-t lg:border-t-0 border-gray-200 shrink-0 overflow-hidden">
          
          {/* Section Header */}
          <div className="p-4 bg-gray-50 border-b border-gray-100 flex items-center justify-between">
            <div className="flex items-center gap-2">
              <Code2 className="w-5 h-5 text-[#2EC4B6]" />
              <div>
                <h3 className="font-extrabold text-sm text-[#011627] tracking-tight uppercase">Structure du Code Flutter</h3>
                <p className="text-[10px] text-gray-400 font-bold">Architecture Propre & Riverpod intégrés</p>
              </div>
            </div>
            <button
              onClick={handleCopyCode}
              className="text-[10px] font-black uppercase tracking-wider bg-gray-200 hover:bg-gray-300 px-2.5 py-1.5 rounded-lg text-gray-600 active:scale-95 transition-all"
            >
              {copied ? '✓ Copié !' : 'Copier Code'}
            </button>
          </div>

          {/* Interactive File Picker List */}
          <div className="h-44 shrink-0 overflow-y-auto border-b border-gray-100 p-3 bg-slate-50 flex flex-col gap-1.5">
            {FLUTTER_CODEBASE.map((file) => (
              <button
                key={file.path}
                onClick={() => setSelectedFile(file)}
                className={`w-full text-left p-2.5 rounded-xl border flex items-center justify-between transition-all active:scale-99 ${
                  selectedFile.path === file.path
                    ? 'bg-white border-[#2EC4B6] shadow-sm'
                    : 'bg-transparent border-transparent hover:bg-white/50'
                }`}
              >
                <div className="flex items-center gap-2.5 min-w-0">
                  <span className="text-lg shrink-0">
                    {file.category === 'Configuration' ? '⚙️' : file.category === 'Database' ? '🗄️' : file.category === 'Features' ? '📱' : '🎨'}
                  </span>
                  <div className="min-w-0">
                    <p className="font-extrabold text-[#011627] text-xs truncate">{file.path}</p>
                    <p className="text-[9px] text-gray-400 truncate mt-0.5">{file.description}</p>
                  </div>
                </div>
                <span className="text-[8px] font-black uppercase tracking-wider bg-gray-200 text-gray-500 px-1.5 py-0.5 rounded shrink-0 ml-2">
                  {file.category}
                </span>
              </button>
            ))}
          </div>

          {/* Code Viewer Panel with scrollable container */}
          <div className="flex-1 bg-slate-900 text-gray-200 p-4 font-mono text-[11px] overflow-auto select-text relative">
            
            {/* File Path Label */}
            <div className="sticky top-0 left-0 bg-slate-900/90 backdrop-blur pb-2 text-slate-400 border-b border-slate-800 text-[10px] mb-3 flex items-center justify-between">
              <span>📂 {selectedFile.path}</span>
              <span className="text-[8px] bg-slate-800 px-2 py-0.5 rounded text-[#2EC4B6] font-bold">DART/YAML</span>
            </div>

            <pre className="whitespace-pre overflow-x-auto leading-relaxed">
              <code>{selectedFile.code}</code>
            </pre>
          </div>

          {/* Footer of codebase column containing SQLite Status */}
          {stats && (
            <div className="p-3 bg-[#F1FAEE] border-t border-gray-100 flex items-center justify-between shrink-0">
              <span className="text-[10px] font-black text-[#2EC4B6] flex items-center gap-1">
                <TerminalSquare className="w-4 h-4" /> Base de données SQLite simulée
              </span>
              <span className="text-[9px] text-gray-400 font-bold">
                {stats.children.length} Enfant(s) • {stats.exerciseAnswers.length} Exercice(s) enregistrés
              </span>
            </div>
          )}

        </section>
      </main>
    </div>
  );
}
