import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/config.dart';
import '../../core/widgets.dart';
import 'cloud_errors.dart';
import 'speech_engine.dart';

class CloudSttException implements Exception {
  CloudSttException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// MODE CONNECTE (facultatif, desactive par defaut) : quand Internet est disponible, l'audio est envoye a un
/// service d'IA externe (Rodium AI) pour une meilleure transcription, puis le fichier est supprime de l'appareil.
/// Hors ligne ou mode desactive : la reconnaissance locale (Vosk) est utilisee.
class ConnectedModeNotifier extends Notifier<bool> {
  @override
  bool build() {
    _load();
    return false;
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    if (p.getBool('connected_mode') == true && kRodiumKey.isNotEmpty) {
      state = true;
    }
  }

  Future<void> set(bool v) async {
    state = v && kRodiumKey.isNotEmpty;
    final p = await SharedPreferences.getInstance();
    await p.setBool('connected_mode', state);
  }
}

final connectedModeProvider =
    NotifierProvider<ConnectedModeNotifier, bool>(ConnectedModeNotifier.new);

class CloudSpeechEngine implements SpeechEngine {
  AudioRecorder? _rec;
  String? _path;

  @override
  bool get isReal => true;

  @override
  Future<void> prepare() async {}

  @override
  Future<void> start(void Function(String partial) onPartial) async {
    final rec = AudioRecorder();
    if (!await rec.hasPermission()) {
      await rec.dispose();
      throw CloudSttException('Microphone non autorisé.');
    }
    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/sura_${DateTime.now().millisecondsSinceEpoch}.wav';
    await rec.start(
        const RecordConfig(
            encoder: AudioEncoder.wav, sampleRate: 16000, numChannels: 1),
        path: path);
    _rec = rec;
    _path = path;
    onPartial(
        'Enregistrement en cours : la transcription apparaîtra à l’arrêt.');
  }

  @override
  Future<String> stop() async {
    final rec = _rec;
    final path = _path;
    _rec = null;
    _path = null;
    if (rec == null || path == null) return '';
    try {
      await rec.stop();
      return await _transcribe(path);
    } finally {
      await rec.dispose();
      try {
        final f = File(path);
        if (await f.exists()) await f.delete(); // l'audio n'est jamais conserve
      } catch (_) {}
    }
  }

  Future<String> _transcribe(String path) async {
    if (kRodiumKey.isEmpty) {
      throw CloudSttException(
          'Clé API absente (compilez avec --dart-define=RODIUM_KEY=...).');
    }
    final req = http.MultipartRequest(
        'POST', Uri.parse('$kRodiumBase/audio/transcriptions'))
      ..headers['Authorization'] = 'Bearer $kRodiumKey'
      ..fields['model'] = kCloudSttModel
      ..fields['language'] = 'fr'
      ..fields['response_format'] = 'json'
      ..fields['prompt'] =
          'Consultation médicale en français : fièvre, toux, maux de tête, température, allergies, traitement.'
      ..files.add(await http.MultipartFile.fromPath('file', path));
    try {
      final res = await http.Response.fromStream(
          await req.send().timeout(const Duration(seconds: 60)));
      if (res.statusCode != 200) {
        throw CloudSttException(cloudErrorMessage(res.statusCode, res.body));
      }
      final j = jsonDecode(res.body);
      return (j is Map ? (j['text'] ?? '') : '').toString().trim();
    } on TimeoutException {
      throw CloudSttException('Délai dépassé : connexion trop lente.');
    } on SocketException {
      throw CloudSttException('Pas de connexion Internet.');
    }
  }
}

/// Choisit le moteur au moment de l'enregistrement : cloud si le mode connecte est actif ET Internet disponible,
/// sinon le moteur local.
class HybridSpeechEngine implements SpeechEngine {
  HybridSpeechEngine(this._ref, this._local);
  final Ref _ref;
  final SpeechEngine _local;
  final CloudSpeechEngine _cloud = CloudSpeechEngine();
  late SpeechEngine _active = _local;

  bool get _wantsCloud =>
      _ref.read(connectedModeProvider) && kRodiumKey.isNotEmpty;

  @override
  bool get isReal => _local.isReal || _wantsCloud;

  @override
  Future<void> prepare() async {
    var cloud = _wantsCloud;
    if (cloud) {
      final r = await Connectivity().checkConnectivity();
      cloud = !r.contains(ConnectivityResult.none);
    }
    _active = cloud ? _cloud : _local;
    await _active.prepare();
  }

  @override
  Future<void> start(void Function(String partial) onPartial) =>
      _active.start(onPartial);

  @override
  Future<String> stop() => _active.stop();
}

/// Reglage dans Parametres.
class ConnectedModeCard extends ConsumerWidget {
  const ConnectedModeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final on = ref.watch(connectedModeProvider);
    final ready = kRodiumKey.isNotEmpty;
    return SuraCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(
              child: Text('Mode connecté (IA distante)',
                  style: TextStyle(fontWeight: FontWeight.w800))),
          Switch(
              value: on,
              onChanged: ready
                  ? (v) => ref.read(connectedModeProvider.notifier).set(v)
                  : null),
        ]),
        Text(
          ready
              ? 'Désactivé par défaut. Avec Internet, l’audio est envoyé à un service d’IA externe pour une meilleure transcription, puis supprimé de l’appareil. Hors ligne, la reconnaissance locale est utilisée. Modèle : $kCloudSttModel.'
              : 'Non configuré : compilez avec --dart-define=RODIUM_KEY=…',
          style: const TextStyle(fontSize: 12),
        ),
      ]),
    );
  }
}

/// Texte de consentement : change quand le mode connecte est actif (l'audio quitte alors l'appareil).
class ConsentInfoCard extends ConsumerWidget {
  const ConsentInfoCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cloud = ref.watch(connectedModeProvider) && kRodiumKey.isNotEmpty;
    return SuraCard(
      child: Text(cloud
          ? '✓ Hors ligne : l’enregistrement reste sur cet appareil\n⚠ Avec Internet (mode connecté) : l’audio est envoyé à un service d’IA externe pour être transcrit, puis supprimé de l’appareil\n✓ Vous pouvez refuser sans que cela change votre prise en charge'
          : '✓ L’enregistrement reste sur cet appareil\n✓ Le fichier audio est supprimé après validation\n✓ Vous pouvez refuser sans que cela change votre prise en charge'),
    );
  }
}
