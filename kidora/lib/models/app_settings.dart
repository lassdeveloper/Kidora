class AppSettings {
  final int childId;
  final String language;
  final bool soundEnabled;
  final bool musicEnabled;
  final bool themeDark;

  AppSettings({
    required this.childId,
    this.language = 'FR',
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.themeDark = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'child_id': childId,
      'language': language,
      'sound_enabled': soundEnabled ? 1 : 0,
      'music_enabled': musicEnabled ? 1 : 0,
      'theme_dark': themeDark ? 1 : 0,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      childId: map['child_id'] as int,
      language: map['language'] as String? ?? 'FR',
      soundEnabled: (map['sound_enabled'] as int? ?? 1) == 1,
      musicEnabled: (map['music_enabled'] as int? ?? 1) == 1,
      themeDark: (map['theme_dark'] as int? ?? 0) == 1,
    );
  }

  AppSettings copyWith({
    int? childId,
    String? language,
    bool? soundEnabled,
    bool? musicEnabled,
    bool? themeDark,
  }) {
    return AppSettings(
      childId: childId ?? this.childId,
      language: language ?? this.language,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      themeDark: themeDark ?? this.themeDark,
    );
  }
}
