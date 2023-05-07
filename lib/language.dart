class Language {
  final int id;
  final String name;
  final String code;

  Language(this.id, this.name, this.code);

  static List<Language> languageList() {
    return <Language>[
      Language(0, "English", "en"),
      Language(1, "Deutsch", "de"),
    ];
  }
}
