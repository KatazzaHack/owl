class Settings {
  static final Settings _settings = Settings._internal();

  // Setting fields are public.
  bool practiceMod = false;

  factory Settings() {
    return _settings;
  }

  Settings._internal();
}