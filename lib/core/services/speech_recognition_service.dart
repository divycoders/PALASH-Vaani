import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechRecognitionService {
  static final SpeechRecognitionService instance = SpeechRecognitionService._init();
  SpeechRecognitionService._init();

  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;
  bool _isAvailable = false;
  List<LocaleName> _availableLocales = [];
  String? _lastError;

  bool get isListening => _speech.isListening;
  bool get isAvailable => _isAvailable;
  String? get lastError => _lastError;
  List<LocaleName> get availableLocales => _availableLocales;

  Future<bool> initialize({
    Function(String status)? onStatus,
    Function(String error)? onError,
  }) async {
    if (_isInitialized) return _isAvailable;
    try {
      _isAvailable = await _speech.initialize(
        onError: (val) {
          _lastError = val.errorMsg;
          debugPrint('SpeechRecognition onError: ${val.errorMsg} (permanent: ${val.permanent})');
          onError?.call(val.errorMsg);
        },
        onStatus: (val) {
          debugPrint('SpeechRecognition onStatus: $val');
          onStatus?.call(val);
        },
      );
      if (_isAvailable) {
        _availableLocales = await _speech.locales();
        debugPrint('SpeechRecognition available locales: ${_availableLocales.map((e) => e.localeId).toList()}');
      }
      _isInitialized = true;
    } catch (e) {
      debugPrint('Speech recognition initialization error: $e');
      _lastError = e.toString();
      _isAvailable = false;
    }
    return _isAvailable;
  }

  Function(String status)? _currentStatusCallback;
  Function(String error)? _currentErrorCallback;

  Future<void> startListening({
    required Function(String recognizedWords) onResult,
    Function(String status)? onStatus,
    Function(String error)? onError,
    Function(double soundLevel)? onSoundLevelChange,
    String languageCode = 'hi_IN',
  }) async {
    _currentStatusCallback = onStatus;
    _currentErrorCallback = onError;

    final available = await initialize(
      onStatus: (status) {
        _currentStatusCallback?.call(status);
      },
      onError: (error) {
        _currentErrorCallback?.call(error);
      },
    );
    if (!available) {
      debugPrint('Speech recognition not available on this device');
      onError?.call('माइक उपलब्ध नहीं है (Speech recognition unavailable on this device)');
      return;
    }

    try {
      // Find best available locale
      String? targetLocaleId;
      if (_availableLocales.isNotEmpty) {
        // Look for exact match or language prefix match
        final normalized = languageCode.replaceAll('-', '_').toLowerCase();
        for (final loc in _availableLocales) {
          final locNorm = loc.localeId.replaceAll('-', '_').toLowerCase();
          if (locNorm == normalized) {
            targetLocaleId = loc.localeId;
            break;
          }
        }
        if (targetLocaleId == null) {
          // Look for any Hindi locale
          for (final loc in _availableLocales) {
            if (loc.localeId.toLowerCase().startsWith('hi')) {
              targetLocaleId = loc.localeId;
              break;
            }
          }
        }
      }

      final options = SpeechListenOptions(
        listenMode: ListenMode.dictation,
        cancelOnError: false,
        partialResults: true,
        onDevice: true,
        localeId: targetLocaleId,
      );

      await _speech.listen(
        onResult: (result) {
          if (result.recognizedWords.isNotEmpty) {
            onResult(result.recognizedWords);
          }
        },
        onSoundLevelChange: onSoundLevelChange,
        listenOptions: options,
      );
    } catch (e) {
      debugPrint('Error starting speech listener: $e');
      onError?.call(e.toString());
    }
  }

  Future<void> stopListening() async {
    try {
      if (_speech.isListening) {
        await _speech.stop();
      }
    } catch (e) {
      debugPrint('Error stopping speech listener: $e');
    }
  }
}
