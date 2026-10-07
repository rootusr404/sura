import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vosk_flutter/vosk_flutter.dart';

import '../../core/config.dart';
import '../../domain/transcription.dart';
import 'cloud_stt.dart';

/// Moteur vocal hybride : Vosk local par defaut, transcription distante facultative.
abstract class SpeechEngine {
  bool get isReal;
  Future<void> prepare();
  Future<void> start(void Function(String partial) onPartial);
  Future<String> stop();
}

/// Moteur de demonstration (texte d'exemple). Utilise quand kUseRealStt = false.
class MockSpeechEngine implements SpeechEngine {
  @override
  bool get isReal => false;
  @override
  Future<void> prepare() async {}
  @override
  Future<void> start(void Function(String partial) onPartial) async {}
  @override
  Future<String> stop() => MockTranscriptionService().transcribe(null);
}

/// Vosk (modele francais leger vosk-model-small-fr-0.22, ~41 Mo) : le plugin capte lui-meme le micro.
/// Qualite moyenne (taux d'erreur de mots de l'ordre de 20 a 27 % selon les jeux de test publies) :
/// c'est pourquoi la transcription est TOUJOURS editable (R4).
class VoskSpeechEngine implements SpeechEngine {
  static const _asset = 'assets/models/vosk-model-small-fr-0.22.zip';

  final VoskFlutterPlugin _vosk = VoskFlutterPlugin.instance();
  Model? _model;
  Recognizer? _recognizer;
  SpeechService? _service;
  StreamSubscription<String>? _subPartial;
  StreamSubscription<String>? _subResult;
  final List<String> _finals = [];
  String _lastPartial = '';

  @override
  bool get isReal => true;

  @override
  Future<void> prepare() async {
    if (_service != null) return;
    final path = await ModelLoader().loadFromAssets(_asset);
    _model = await _vosk.createModel(path);
    _recognizer =
        await _vosk.createRecognizer(model: _model!, sampleRate: 16000);
    _service = await _vosk.initSpeechService(_recognizer!);
  }

  String _field(String json, String key) {
    try {
      final m = jsonDecode(json);
      return (m is Map ? (m[key] ?? '') : '').toString().trim();
    } catch (_) {
      return '';
    }
  }

  @override
  Future<void> start(void Function(String partial) onPartial) async {
    final s = _service!;
    _finals.clear();
    _lastPartial = '';
    await _subPartial?.cancel();
    await _subResult?.cancel();
    _subPartial = s.onPartial().listen((e) {
      final t = _field(e, 'partial');
      _lastPartial = t;
      onPartial(_finals.isEmpty ? t : '${_finals.join(' ')} $t');
    });
    _subResult = s.onResult().listen((e) {
      final t = _field(e, 'text');
      if (t.isNotEmpty) {
        _finals.add(t);
        _lastPartial = '';
        onPartial(_finals.join(' '));
      }
    });
    await s.start();
  }

  @override
  Future<String> stop() async {
    await _service?.stop();
    // Laisse le temps au dernier resultat d'arriver.
    await Future.delayed(const Duration(milliseconds: 700));
    await _subPartial?.cancel();
    await _subResult?.cancel();
    var text = _finals.join(' ').trim();
    final tail = _lastPartial.trim();
    if (tail.isNotEmpty && !text.endsWith(tail)) text = '$text $tail'.trim();
    return text;
  }
}

final speechEngineProvider = Provider<SpeechEngine>((ref) => HybridSpeechEngine(
    ref, kUseRealStt ? VoskSpeechEngine() : MockSpeechEngine()));
