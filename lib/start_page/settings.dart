class SettingsOWL {
  static final SettingsOWL _settings = SettingsOWL._internal();

  // Setting fields are public.
  bool practiceMod = false;

  factory SettingsOWL() {
    return _settings;
  }

  SettingsOWL._internal();
}