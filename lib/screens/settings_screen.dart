import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _storageService = StorageService();
  final _apiKeyController = TextEditingController();
  String _selectedLanguage = 'de';
  bool _isLoading = true;
  bool _obscureApiKey = true;

  final List<Map<String, String>> _languages = [
    {'code': 'de', 'name': 'Deutsch'},
    {'code': 'en', 'name': 'English'},
    {'code': 'es', 'name': 'Español'},
    {'code': 'fr', 'name': 'Français'},
    {'code': 'it', 'name': 'Italiano'},
    {'code': 'pt', 'name': 'Português'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final apiKey = await _storageService.getApiKey();
    final language = await _storageService.getLanguage();

    setState(() {
      if (apiKey != null) {
        _apiKeyController.text = apiKey;
      }
      _selectedLanguage = language;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    await _storageService.saveApiKey(_apiKeyController.text.trim());
    await _storageService.saveLanguage(_selectedLanguage);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true); // Return true to indicate settings changed
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // API Key Section
            Text(
              'Groq API Key',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Get your free API key from console.groq.com',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _apiKeyController,
              obscureText: _obscureApiKey,
              decoration: InputDecoration(
                hintText: 'gsk_...',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureApiKey ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureApiKey = !_obscureApiKey;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Language Section
            Text(
              'Language',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Select transcription language',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedLanguage,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: _languages.map((lang) {
                return DropdownMenuItem(
                  value: lang['code'],
                  child: Text(lang['name']!),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedLanguage = value;
                  });
                }
              },
            ),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: _saveSettings,
                child: const Text('Save Settings'),
              ),
            ),

            const SizedBox(height: 24),

            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Flüstern uses Groq\'s Whisper API for transcription and LLM for formatting.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
