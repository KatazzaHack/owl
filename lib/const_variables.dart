enum SupportedLanguage { English, German, Russian, French, Hebrew }

class Language {
  String supportedLocale;
  String supportedLanguage;
  String humanLanguage;
  SupportedLanguage sL;
  Language(SupportedLanguage s_L, String supported_locale,
      String supported_language, String human_language) {
    supportedLocale = supported_locale;
    supportedLanguage = supported_language;
    humanLanguage = human_language;
    sL = s_L;
  }
}

class ConstVariables {
  static String FeedbackURL =
      "https://docs.google.com/forms/d/1QZ0ebto10I-v_Qaava70gK9n2iZpR8OlKo-SvfktjYY";
  static String current_dictionary_id = "CurrentDictionaryName";
  static String original_language = "OriginalLanguage";
  static String translate_language = "TranslateLanguage";
  static String speed_id = "CurrentPronounceSpeed";
  static String FAQURL =
      "https://docs.google.com/document/d/1chXW1PM0peFjNzufWAux6JwBpnqrRy6YIQaFYtnQcro";

  static Map<String, Language> reverse_human_languages = {
    "English": Language(SupportedLanguage.English, "en_US", "en-US", "English"),
    "Russian": Language(SupportedLanguage.Russian, "ru_RU", "ru-RU", "Russian"),
    "German": Language(SupportedLanguage.German, "de_DE", "de-DE", "German"),
    "French": Language(SupportedLanguage.French, "fr_FR", "fr-FR", "French"),
    "Hebrew": Language(SupportedLanguage.Hebrew, "he_IL", "he-IL", "Hebrew"),
  };

  static Map<SupportedLanguage, Language> reverse_languages = {
    SupportedLanguage.English:
        Language(SupportedLanguage.English, "en_US", "en-US", "English"),
    SupportedLanguage.Russian:
        Language(SupportedLanguage.Russian, "ru_RU", "ru-RU", "Russian"),
    SupportedLanguage.German:
        Language(SupportedLanguage.German, "de_DE", "de-DE", "German"),
    SupportedLanguage.French:
        Language(SupportedLanguage.French, "fr_FR", "fr-FR", "French"),
    SupportedLanguage.Hebrew:
        Language(SupportedLanguage.Hebrew, "he_IL", "he-IL", "Hebrew"),
  };

  static List<Language> all_languages = reverse_human_languages.values.toList();
}
