class FillerFilterService {
  static final FillerFilterService instance = FillerFilterService._internal();
  FillerFilterService._internal();

  // Common German filler words and phrases to filter out
  final List<String> _germanFillers = [
    'vielen dank',
    'vielen herzlichen dank',
    'herzlichen dank',
    'danke schön',
    'danke sehr',
    'äh',
    'ähm',
    'also',
    'irgendwie',
    'sozusagen',
    'quasi',
    'praktisch',
    'gewissermaßen',
    'eigentlich',
    'halt',
    'eben',
    'ja gut',
    'na ja',
    'okay',
    'alles klar',
    'bis dann',
    'bis später',
    'tschüss',
    'auf wiedersehen',
    'wiederhören',
  ];

  // Common English filler words and phrases
  final List<String> _englishFillers = [
    'thank you very much',
    'thank you so much',
    'thanks a lot',
    'thanks so much',
    'um',
    'uh',
    'like',
    'you know',
    'i mean',
    'sort of',
    'kind of',
    'basically',
    'actually',
    'literally',
    'honestly',
    'okay',
    'alright',
    'see you later',
    'goodbye',
    'bye bye',
    'talk to you later',
  ];

  /// Filter out filler words from text
  String filterFillers(String text, {String language = 'de'}) {
    String filtered = text;
    final fillers = language == 'de' ? _germanFillers : _englishFillers;

    // Remove filler phrases at the beginning or end of text
    for (final filler in fillers) {
      final pattern = RegExp(
        r'^' + RegExp.escape(filler) + r'\b\.?\s*',
        caseSensitive: false,
      );
      filtered = filtered.replaceAll(pattern, '');

      final endPattern = RegExp(
        r'\s*\b' + RegExp.escape(filler) + r'\.?\s*$',
        caseSensitive: false,
      );
      filtered = filtered.replaceAll(endPattern, '');
    }

    // Clean up multiple spaces and trim
    filtered = filtered.replaceAll(RegExp(r'\s+'), ' ').trim();

    // Remove leading/trailing punctuation if text starts with lowercase after filtering
    if (filtered.isNotEmpty && filtered[0] == filtered[0].toLowerCase()) {
      filtered = filtered.substring(0, 1).toUpperCase() + filtered.substring(1);
    }

    return filtered;
  }

  /// Check if text is mostly fillers
  bool isMostlyFillers(String text, {String language = 'de'}) {
    final filtered = filterFillers(text, language: language);
    // If filtering removes more than 80% of content, it's mostly fillers
    return filtered.length < text.length * 0.2;
  }

  /// Get list of fillers for a language
  List<String> getFillers(String language) {
    return language == 'de' ? _germanFillers : _englishFillers;
  }

  /// Add custom filler word
  void addCustomFiller(String filler, String language) {
    if (language == 'de') {
      if (!_germanFillers.contains(filler.toLowerCase())) {
        _germanFillers.add(filler.toLowerCase());
      }
    } else {
      if (!_englishFillers.contains(filler.toLowerCase())) {
        _englishFillers.add(filler.toLowerCase());
      }
    }
  }

  /// Remove custom filler word
  void removeCustomFiller(String filler, String language) {
    if (language == 'de') {
      _germanFillers.remove(filler.toLowerCase());
    } else {
      _englishFillers.remove(filler.toLowerCase());
    }
  }
}
