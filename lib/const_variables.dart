enum SupportedLanguage {
  English,
  German,
  Russian
}

class ConstVariables {
  static String current_dictionary_id = "CurrentDictionaryName";
  static String listen_mode = "ListenMode";
  static Map<SupportedLanguage, String> supported_locales = {
    SupportedLanguage.English: "en_EN",
    SupportedLanguage.Russian: "ru_RU",
    SupportedLanguage.German: "de_DE",
  };
  static Map<SupportedLanguage, String> supported_languages = {
    SupportedLanguage.English: "en-EN",
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
}

