enum SupportedLanguage { English, German, Russian }

class ConstVariables {
  static String FeedbackURL =
      "https://docs.google.com/forms/d/1QZ0ebto10I-v_Qaava70gK9n2iZpR8OlKo-SvfktjYY";
  static String current_dictionary_id = "CurrentDictionaryName";
  static String original_language = "OriginalLanguage";
  static String translate_language = "TranslateLanguage";

  static Map<SupportedLanguage, String> supported_locales = {
    SupportedLanguage.English: "en_US",
    SupportedLanguage.Russian: "ru_RU",
    SupportedLanguage.German: "de_DE",
  };
  static Map<SupportedLanguage, String> supported_languages = {
    SupportedLanguage.English: "en-US",
    SupportedLanguage.Russian: "ru-RU",
    SupportedLanguage.German: "de-DE",
  };
  static Map<SupportedLanguage, String> human_languages = {
    SupportedLanguage.English: "English",
    SupportedLanguage.Russian: "Russian",
    SupportedLanguage.German: "German",
  };

  static Map<String, SupportedLanguage> reverse_human_languages = {
    "English": SupportedLanguage.English,
    "Russian": SupportedLanguage.Russian,
    "German": SupportedLanguage.German,
  };

  static List<SupportedLanguage> all_languages = [
    SupportedLanguage.English,
    SupportedLanguage.German,
    SupportedLanguage.Russian,
  ];
}
