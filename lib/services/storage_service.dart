import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _apiKeyKey = 'groq_api_key';
  static const String _languageKey = 'language';

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
}
