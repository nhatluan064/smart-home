import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:smart_home_ai/providers/device_provider.dart';
import 'package:smart_home_ai/providers/auth_provider.dart';
import 'package:smart_home_ai/models/device_model.dart';

final voiceProvider = NotifierProvider<VoiceNotifier, VoiceState>(VoiceNotifier.new);

class VoiceState {
  final bool isListening;
  final String lastWords;
  final bool isSpeaking;

  VoiceState({
    this.isListening = false,
    this.lastWords = '',
    this.isSpeaking = false,
  });

  VoiceState copyWith({
    bool? isListening,
    String? lastWords,
    bool? isSpeaking,
  }) {
    return VoiceState(
      isListening: isListening ?? this.isListening,
      lastWords: lastWords ?? this.lastWords,
      isSpeaking: isSpeaking ?? this.isSpeaking,
    );
  }
}

class VoiceNotifier extends Notifier<VoiceState> {
  final SpeechToText _speech = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  @override
  VoiceState build() {
    _init();
    return VoiceState();
  }

  Future<void> _init() async {
    _isInitialized = await _speech.initialize(
      onStatus: (status) {
        if (status == 'notListening') {
           // Check if mounted before updating state to avoid errors
           // In Notifier, we can check if the provider is still alive, but simple check:
           state = state.copyWith(isListening: false);
        }
      },
      onError: (error) => print('Error: $error'),
    );

    await _flutterTts.setLanguage("vi-VN");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
  }

  Future<void> startListening() async {
    if (!_isInitialized) await _init();
    
    state = state.copyWith(isListening: true, lastWords: '');
    
    await _speech.listen(
      onResult: (result) {
        state = state.copyWith(lastWords: result.recognizedWords);
        if (result.finalResult) {
          _processCommand(result.recognizedWords);
        }
      },
      localeId: 'vi_VN',
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
    state = state.copyWith(isListening: false);
  }

  Future<void> speak(String text) async {
    state = state.copyWith(isSpeaking: true);
    await _flutterTts.speak(text);
    await _flutterTts.awaitSpeakCompletion(true);
    state = state.copyWith(isSpeaking: false);
  }

  void _processCommand(String command) async {
    final lowerCommand = command.toLowerCase();
    final authState = ref.read(authProvider);
    final assistantName = authState.assistantName?.toLowerCase() ?? 'trợ lý';

    if (lowerCommand.contains('bật')) {
      _handleDeviceControl(lowerCommand, true);
    } else if (lowerCommand.contains('tắt')) {
      _handleDeviceControl(lowerCommand, false);
    } else if (lowerCommand.contains('chào')) {
      speak("Chào bạn, mình là $assistantName. Mình có thể giúp gì?");
    }
  }

  void _handleDeviceControl(String command, bool turnOn) {
    final devices = ref.read(deviceProvider);
    final notifier = ref.read(deviceProvider.notifier);
    
    Device? targetDevice;
    for (final device in devices) {
      if (command.contains(device.name.toLowerCase())) {
        targetDevice = device;
        break;
      }
    }

    if (targetDevice != null) {
      notifier.setDeviceState(targetDevice.id, turnOn);
      speak("Đã ${turnOn ? 'bật' : 'tắt'} ${targetDevice.name}");
    } else {
      speak("Mình không tìm thấy thiết bị nào tên như vậy.");
    }
  }
}
