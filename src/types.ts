export interface ChildProfile {
  id: number;
  name: string;
  age: number;
  schoolLevel: string;
  avatar: string;
  xp: number;
  level: number;
  createdAt: string;
}

export interface SubjectProgress {
  subjectId: 'maths' | 'french' | 'science' | 'logic';
  completedLessonsCount: number;
  successRate: number; // percentage
  studyTimeSeconds: number;
}

export interface ExerciseAnswerRow {
  id: number;
  childId: number;
  exerciseId: string;
  isCorrect: boolean;
  answeredAt: string;
}

export interface UnlockedBadge {
  childId: number;
  badgeId: string;
  unlockedAt: string;
}

export interface GameScoreRow {
  id: number;
  childId: number;
  gameId: string;
  score: number;
  playedAt: string;
}

export interface KidoraSettings {
  childId: number;
  language: 'FR' | 'EN';
  soundEnabled: boolean;
  musicEnabled: boolean;
  themeDark: boolean;
}

export interface DailyLimit {
  childId: number;
  maxMinutesPerDay: number; // 15, 30, 45, 60 or 0 (No limit)
  minutesUsedToday: number;
  lastResetDate: string;
}

export interface DatabaseState {
  children: ChildProfile[];
  exerciseAnswers: ExerciseAnswerRow[];
  childBadges: UnlockedBadge[];
  gameScores: GameScoreRow[];
  settings: Record<number, KidoraSettings>;
  dailyLimits: Record<number, DailyLimit>;
}
