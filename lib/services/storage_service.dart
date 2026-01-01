import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _apiKeyKey = 'groq_api_key';
  static const String _languageKey = 'language';
  static const String _hotkeysEnabledKey = 'hotkeys_enabled';
  static const String _fillerFilterEnabledKey = 'filler_filter_enabled';

  Future<void> saveApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyKey, apiKey);
  }

  Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyKey);
  }

  Future<void> saveLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
  }

  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'de'; // Default: German
  }

  Future<bool> hasApiKey() async {
    final apiKey = await getApiKey();
    return apiKey != null && apiKey.isNotEmpty;
  }

  Future<void> setHotkeysEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hotkeysEnabledKey, enabled);
  }

  Future<bool> getHotkeysEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hotkeysEnabledKey) ?? true;
  }

  Future<void> setFillerFilterEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_fillerFilterEnabledKey, enabled);
  }

  Future<bool> getFillerFilterEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_fillerFilterEnabledKey) ?? true;
  }
}
