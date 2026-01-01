import 'dart:io';
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
  bool _hotkeysEnabled = true;
  bool _fillerFilterEnabled = true;
  bool _autoPasteEnabled = true;
  bool _commandModeEnabled = true;

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
    final hotkeysEnabled = await _storageService.getHotkeysEnabled();
    final fillerFilterEnabled = await _storageService.getFillerFilterEnabled();
    final autoPasteEnabled = await _storageService.getAutoPasteEnabled();
    final commandModeEnabled = await _storageService.getCommandModeEnabled();

    setState(() {
      if (apiKey != null) {
        _apiKeyController.text = apiKey;
      }
      _selectedLanguage = language;
      _hotkeysEnabled = hotkeysEnabled;
      _fillerFilterEnabled = fillerFilterEnabled;
      _autoPasteEnabled = autoPasteEnabled;
      _commandModeEnabled = commandModeEnabled;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    await _storageService.saveApiKey(_apiKeyController.text.trim());
    await _storageService.saveLanguage(_selectedLanguage);
    await _storageService.setHotkeysEnabled(_hotkeysEnabled);
    await _storageService.setFillerFilterEnabled(_fillerFilterEnabled);
    await _storageService.setAutoPasteEnabled(_autoPasteEnabled);
    await _storageService.setCommandModeEnabled(_commandModeEnabled);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved!'),
          backgroundColor: Colors.green,
        ),
      );
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
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Settings',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ],
              ),
            ),

            // Settings content
            Padding(
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
                          _obscureApiKey
                              ? Icons.visibility
                              : Icons.visibility_off,
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
                    value: _selectedLanguage,
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

                  // Advanced Features
                  Text(
                    'Advanced Features',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),

                  // Auto-Paste
                  SwitchListTile(
                    title: const Text('Auto-Paste'),
                    subtitle: const Text(
                        'Automatically paste transcription into active window (Windows only)'),
                    value: _autoPasteEnabled,
                    onChanged: (value) {
                      setState(() {
                        _autoPasteEnabled = value;
                      });
                    },
                  ),
                  const SizedBox(height: 8),

                  // Command Mode
                  SwitchListTile(
                    title: const Text('Command Mode'),
                    subtitle: const Text(
                        'Use voice commands like "summarize", "translate", "delete last sentence"'),
                    value: _commandModeEnabled,
                    onChanged: (value) {
                      setState(() {
                        _commandModeEnabled = value;
                      });
                    },
                  ),
                  const SizedBox(height: 8),

                  // Filler Filtering
                  SwitchListTile(
                    title: const Text('Filler Word Filtering'),
                    subtitle: const Text(
                        'Remove common filler words like "vielen Dank", "äh", etc.'),
                    value: _fillerFilterEnabled,
                    onChanged: (value) {
                      setState(() {
                        _fillerFilterEnabled = value;
                      });
                    },
                  ),
                  const SizedBox(height: 32),

                  // Keyboard Shortcuts Section (Desktop only)
                  if (Platform.isWindows ||
                      Platform.isMacOS ||
                      Platform.isLinux) ...[
                    Text(
                      'Keyboard Shortcuts',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Global shortcuts work even when the app is in the background',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Enable Global Hotkeys'),
                      subtitle: Text(
                        'Press ${Platform.isMacOS ? 'Cmd' : 'Ctrl'}+Shift+R to record',
                      ),
                      value: _hotkeysEnabled,
                      onChanged: (value) {
                        setState(() {
                          _hotkeysEnabled = value;
                        });
                      },
                    ),
                    if (_hotkeysEnabled) ...[
                      const SizedBox(height: 8),
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.mic),
                          title: const Text('Start/Stop Recording'),
                          subtitle: Text(
                            Platform.isMacOS
                                ? 'Cmd+Shift+R'
                                : 'Ctrl+Shift+R',
                          ),
                          trailing: const Icon(Icons.keyboard),
                        ),
                      ),
                    ],
                    if (!_hotkeysEnabled)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Hotkeys are disabled. You can only record using the app button.',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 32),
                  ],

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
                            'Flüstern uses Groq\'s Whisper API for transcription and LLM for intelligent formatting.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
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
