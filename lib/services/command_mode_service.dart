import 'package:flutter/foundation.dart';
import 'groq_api_service.dart';

enum CommandType {
  delete,
  summarize,
  translate,
  format,
  shorten,
  expand,
  fixGrammar,
  makeInformal,
  makeFormal,
  none,
}

class CommandModeService {
  static final CommandModeService instance = CommandModeService._internal();
  CommandModeService._internal();

  final Map<CommandType, List<RegExp>> _commandPatterns = {
    CommandType.delete: [
      RegExp(r'\b(lösche?|delete|remove|entferne?)\b', caseSensitive: false),
    ],
    CommandType.summarize: [
      RegExp(r'\b(fasse? zusammen|zusammenfassen|summarize|zusammenfassung)\b',
          caseSensitive: false),
    ],
    CommandType.translate: [
      RegExp(r'\b(übersetze?|translate|übersetzung)\b', caseSensitive: false),
    ],
    CommandType.format: [
      RegExp(r'\b(formatiere?|format|formatierung)\b', caseSensitive: false),
    ],
    CommandType.shorten: [
      RegExp(r'\b(kürze?|kürzer|shorten|verkürze?)\b', caseSensitive: false),
    ],
    CommandType.expand: [
      RegExp(r'\b(erweitere?|länger|expand|ausführlicher)\b',
          caseSensitive: false),
    ],
    CommandType.fixGrammar: [
      RegExp(r'\b(korrigiere?|fix|verbessere?|grammar|grammatik)\b',
          caseSensitive: false),
    ],
    CommandType.makeInformal: [
      RegExp(r'\b(informell|informal|locker|casual)\b', caseSensitive: false),
    ],
    CommandType.makeFormal: [
      RegExp(r'\b(formell|formal|förmlich|professionell)\b',
          caseSensitive: false),
    ],
  };

  /// Detects if the text contains a command
  CommandType detectCommand(String text) {
    for (final entry in _commandPatterns.entries) {
      for (final pattern in entry.value) {
        if (pattern.hasMatch(text)) {
          return entry.key;
        }
      }
    }
    return CommandType.none;
  }

  /// Checks if text contains a command and returns both the command and cleaned text
  ({CommandType command, String cleanedText}) parseCommand(String text) {
    final command = detectCommand(text);
    if (command == CommandType.none) {
      return (command: CommandType.none, cleanedText: text);
    }

    // Remove command keywords from text
    String cleaned = text;
    for (final pattern in _commandPatterns[command]!) {
      cleaned = cleaned.replaceAll(pattern, '').trim();
    }

    // Clean up extra spaces
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();

    return (command: command, cleanedText: cleaned);
  }

  /// Processes a command and returns the modified text
  Future<String> processCommand({
    required String text,
    required CommandType command,
    required String apiKey,
    String? targetLanguage,
  }) async {
    if (command == CommandType.none) {
      return text;
    }

    final groqService = GroqApiService(apiKey);
    final prompt = _buildCommandPrompt(command, text, targetLanguage);

    try {
      final result = await groqService.executeCommand(prompt);
      debugPrint('Command executed: $command -> $result');
      return result;
    } catch (e) {
      debugPrint('Failed to process command: $e');
      return text; // Return original text on error
    }
  }

  String _buildCommandPrompt(
      CommandType command, String text, String? targetLanguage) {
    switch (command) {
      case CommandType.delete:
        return 'Delete the last sentence from this text and return only the remaining text:\n\n$text';

      case CommandType.summarize:
        return 'Summarize this text in 2-3 sentences:\n\n$text';

      case CommandType.translate:
        final target = targetLanguage ?? 'English';
        return 'Translate this text to $target:\n\n$text';

      case CommandType.format:
        return 'Format this text with proper paragraphs, punctuation, and capitalization:\n\n$text';

      case CommandType.shorten:
        return 'Make this text shorter while keeping the main message:\n\n$text';

      case CommandType.expand:
        return 'Expand this text with more details and explanations:\n\n$text';

      case CommandType.fixGrammar:
        return 'Fix all grammar and spelling mistakes in this text:\n\n$text';

      case CommandType.makeInformal:
        return 'Rewrite this text in an informal, casual style:\n\n$text';

      case CommandType.makeFormal:
        return 'Rewrite this text in a formal, professional style:\n\n$text';

      case CommandType.none:
        return text;
    }
  }

  /// User-friendly command name
  String getCommandName(CommandType command) {
    switch (command) {
      case CommandType.delete:
        return 'Delete';
      case CommandType.summarize:
        return 'Summarize';
      case CommandType.translate:
        return 'Translate';
      case CommandType.format:
        return 'Format';
      case CommandType.shorten:
        return 'Shorten';
      case CommandType.expand:
        return 'Expand';
      case CommandType.fixGrammar:
        return 'Fix Grammar';
      case CommandType.makeInformal:
        return 'Make Informal';
      case CommandType.makeFormal:
        return 'Make Formal';
      case CommandType.none:
        return 'None';
    }
  }
}
