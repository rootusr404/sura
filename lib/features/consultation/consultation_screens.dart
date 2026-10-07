import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/config.dart';
import '../../core/format.dart';
import '../../core/theme.dart';
import '../../core/tiles.dart';
import '../../core/widgets.dart';
import '../../data/database.dart';
import '../../data/providers.dart';
import '../../domain/models.dart';
import '../../domain/rules.dart';
import 'cloud_stt.dart';
import 'manual_form.dart';
import 'speech_engine.dart';

/// Charge la consultation (flux Drift) puis construit l'ecran.
class WithConsultation extends ConsumerWidget {
  const WithConsultation({super.key, required this.id, required this.builder});
  final String id;
  final Widget Function(BuildContext, Consultation) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(consultationProvider(id)).when(
          data: (c) => c == null
              ? Scaffold(
                  appBar: suraAppBar(context, 'Consultation'),
                  body: const Center(child: Text('Consultation introuvable.')))
              : builder(context, c),
          loading: () => const Scaffold(body: LoadingView()),
          error: (e, _) => Scaffold(
            appBar: suraAppBar(context, 'Consultation'),
            body: Padding(
                padding: const EdgeInsets.all(16),
                child: InfoBanner('Erreur technique : $e',
                    kind: BannerKind.error)),
          ),
        );
  }
}

Future<void> _go(
    BuildContext context, WidgetRef ref, String id, String stage) async {
  await ref.read(consultationServiceProvider).setStage(id, stage);
  if (context.mounted) context.push('/consult/$id/$stage');
}

// ---------------------------------------------------------------- 1. Consentement
class ConsentScreen extends ConsumerWidget {
  const ConsentScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) => WithConsultation(
        id: id,
        builder: (ctx, c) => StepScaffold(
          consultationId: id,
          stage: 'consent',
          title: 'Consentement',
          body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            PatientHeader(c.patientId),
            const Text(
                'Avant de commencer, j’ai besoin de votre accord pour enregistrer la conversation.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            const ConsentInfoCard(),
          ]),
          bottom: [
            PrimaryButton('Le patient accepte', icon: Icons.check,
                onPressed: () async {
              await ref.read(consultationServiceProvider).setConsent(id, true);
              if (context.mounted) await _go(context, ref, id, 'record');
            }),
            SecondaryButton('Le patient refuse', onPressed: () async {
              await ref.read(consultationServiceProvider).setConsent(id, false);
              if (context.mounted) await _go(context, ref, id, 'refused');
            }),
          ],
        ),
      );
}

class RefusedScreen extends ConsumerWidget {
  const RefusedScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) => WithConsultation(
        id: id,
        builder: (ctx, c) => StepScaffold(
          consultationId: id,
          stage: 'consent',
          title: 'Consentement refusé',
          body: const Column(children: [
            SizedBox(height: 24),
            Icon(Icons.front_hand_outlined, size: 56),
            SizedBox(height: 12),
            Text('Aucun enregistrement audio',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            SizedBox(height: 8),
            Text(
                'Vous pouvez remplir la consultation à la main : le refus sera consigné dans le dossier.',
                textAlign: TextAlign.center),
          ]),
          bottom: [
            PrimaryButton('Continuer en saisie manuelle',
                onPressed: () => _go(context, ref, id, 'structured')),
            SecondaryButton('Retour à l’accueil',
                onPressed: () => context.go('/home')),
          ],
        ),
      );
}

// ---------------------------------------------------------------- 2. Enregistrement
class RecordScreen extends ConsumerStatefulWidget {
  const RecordScreen({super.key, required this.id});
  final String id;
  @override
  ConsumerState<RecordScreen> createState() => _RecordState();
}

class _RecordState extends ConsumerState<RecordScreen> {
  bool recording = false;
  bool denied = false;
  bool preparing = false;
  bool processing = false;
  int secs = 0;
  String partial = '';
  String? error;
  Timer? timer;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> _manual() async {
    await ref.read(consultationServiceProvider).switchToManual(widget.id);
    if (mounted) await _go(context, ref, widget.id, 'structured');
  }

  Future<void> _toggle() async {
    final engine = ref.read(speechEngineProvider);
    if (preparing || processing) return;
    if (!recording) {
      final st = await Permission.microphone.request();
      if (!st.isGranted) {
        if (mounted) setState(() => denied = true);
        return;
      }
      setState(() {
        preparing = true;
        error = null;
        partial = '';
      });
      try {
        await engine.prepare();
        await engine.start((p) {
          if (mounted) setState(() => partial = p);
        });
      } catch (e) {
        if (mounted) {
          setState(() {
            preparing = false;
            error =
                'Moteur vocal indisponible. Vous pouvez saisir à la main. ($e)';
          });
        }
        return;
      }
      if (!mounted) return;
      setState(() {
        preparing = false;
        recording = true;
        secs = 0;
      });
      timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => secs++);
      });
    } else {
      timer?.cancel();
      setState(() {
        recording = false;
        processing = true;
      });
      var text = '';
      try {
        text = await engine.stop();
      } catch (e) {
        text = '';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  'Transcription impossible : $e. Saisissez ou corrigez à la main.')));
        }
      }
      await ref
          .read(consultationServiceProvider)
          .saveTranscript(widget.id, text);
      if (!mounted) return;
      setState(() => processing = false);
      await _go(context, ref, widget.id, 'transcript');
    }
  }

  @override
  Widget build(BuildContext context) {
    final engine = ref.watch(speechEngineProvider);
    final status = preparing
        ? 'Chargement du moteur vocal…'
        : (processing
            ? 'Transcription en cours…'
            : (recording ? 'Enregistrement en cours' : 'Prêt'));
    return StepScaffold(
      consultationId: widget.id,
      stage: 'record',
      title: 'Enregistrement',
      body: denied
          ? Column(children: [
              const InfoBanner(
                  'Microphone non autorisé. Sans micro, SŪRA ne peut pas enregistrer. Autorisez-le dans les réglages ou saisissez à la main.',
                  kind: BannerKind.warn),
              PrimaryButton('Ouvrir les réglages du téléphone',
                  icon: Icons.settings, onPressed: openAppSettings),
              SecondaryButton('Saisir à la main', onPressed: _manual),
            ])
          : Column(children: [
              const SizedBox(height: 8),
              if (!engine.isReal)
                const InfoBanner(
                    'Moteur vocal de démonstration : un texte d’exemple sera proposé à la fin.',
                    kind: BannerKind.warn),
              if (error != null) InfoBanner(error!, kind: BannerKind.error),
              Text(status),
              Text('${two(secs ~/ 60)}:${two(secs % 60)}',
                  style: const TextStyle(
                      fontSize: 48, fontWeight: FontWeight.w800)),
              const SizedBox(height: 20),
              if (preparing || processing)
                const SizedBox(
                    height: 96,
                    child: Center(child: CircularProgressIndicator()))
              else
                GestureDetector(
                  onTap: _toggle,
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                        color: recording ? T.argile : T.teal,
                        shape: BoxShape.circle),
                    child: Icon(recording ? Icons.stop : Icons.mic,
                        color: Colors.white, size: 44),
                  ),
                ),
              const SizedBox(height: 12),
              Text(recording ? 'Appuyez pour arrêter' : 'Appuyez pour démarrer',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              if (recording && partial.isNotEmpty)
                SuraCard(child: Text(partial)),
              if (error != null)
                SecondaryButton('Saisir à la main', onPressed: _manual),
              const InfoBanner(
                  'Traitement local par défaut. En mode connecté, si Internet est disponible, l’audio est envoyé à un service externe pour transcription puis supprimé.'),
            ]),
    );
  }
}

// ---------------------------------------------------------------- 3. Transcription
class TranscriptScreen extends ConsumerStatefulWidget {
  const TranscriptScreen({super.key, required this.id});
  final String id;
  @override
  ConsumerState<TranscriptScreen> createState() => _TranscriptState();
}

class _TranscriptState extends ConsumerState<TranscriptScreen> {
  final ctl = TextEditingController();
  bool filled = false;
  bool started = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    if (started) return;
    started = true;
    final c = await ref.read(repoProvider).getConsultation(widget.id);
    if (c != null && c.transcript == null) {
      // TODO (Membre 2) : remplacer le mock par whisper_edge / vosk_flutter (interface TranscriptionService).
      final text = await ref.read(transcriptionProvider).transcribe(null);
      await ref
          .read(consultationServiceProvider)
          .saveTranscript(widget.id, text);
    }
  }

  @override
  Widget build(BuildContext context) => WithConsultation(
        id: widget.id,
        builder: (ctx, c) {
          if (c.transcript == null) {
            return const Scaffold(
              body: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Transcription en cours…',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                  Text('Traitement 100 % local — aucune connexion requise'),
                ]),
              ),
            );
          }
          if (!filled) {
            ctl.text = c.transcript!;
            filled = true;
          }
          return StepScaffold(
            consultationId: widget.id,
            stage: 'transcript',
            title: 'Transcription',
            body:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              InfoBanner(
                  kUseRealStt
                      ? 'SŪRA propose cette transcription (reconnaissance vocale automatique, elle peut contenir des erreurs). Vérifiez et corrigez avant de continuer.'
                      : 'SŪRA propose cette transcription. Vérifiez et corrigez avant de continuer. (Texte de démonstration : moteur réel non activé.)',
                  kind: BannerKind.warn),
              TextField(
                  controller: ctl,
                  maxLines: 8,
                  decoration:
                      const InputDecoration(border: OutlineInputBorder())),
            ]),
            bottom: [
              PrimaryButton('Confirmer et continuer', onPressed: () async {
                final svc = ref.read(consultationServiceProvider);
                await svc.saveTranscript(widget.id, ctl.text);
                await svc.saveStructured(
                    widget.id, Extractor.extract(ctl.text));
                if (context.mounted) {
                  await _go(context, ref, widget.id, 'structured');
                }
              }),
            ],
          );
        },
      );
}

// ---------------------------------------------------------------- 4. Informations structurees / saisie manuelle
class StructuredScreen extends ConsumerWidget {
  const StructuredScreen({super.key, required this.id});
  final String id;
  @override
  Widget build(BuildContext context, WidgetRef ref) => WithConsultation(
      id: id,
      builder: (ctx, c) =>
          c.mode == 'manual' ? ManualEntryForm(c: c) : _StructuredForm(c: c));
}

class _StructuredForm extends ConsumerStatefulWidget {
  const _StructuredForm({required this.c});
  final Consultation c;
  @override
  ConsumerState<_StructuredForm> createState() => _StructuredFormState();
}

class _StructuredFormState extends ConsumerState<_StructuredForm> {
  late final TextEditingController motif,
      symptoms,
      duration,
      temp,
      allergies,
      treatment;

  @override
  void initState() {
    super.initState();
    var s = Structured.decode(widget.c.structuredJson);
    if (s.isEmpty && widget.c.transcript != null) {
      s = Extractor.extract(widget.c.transcript!);
    }
    motif = TextEditingController(text: s.motif ?? '');
    symptoms = TextEditingController(text: s.symptoms.join(', '));
    duration = TextEditingController(text: s.duration ?? '');
    temp = TextEditingController(
        text: s.temperature?.toString().replaceAll('.', ',') ?? '');
    allergies = TextEditingController(text: s.allergies ?? '');
    treatment = TextEditingController(text: s.treatment ?? '');
  }

  String? _v(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  Future<void> _next() async {
    final s = Structured(
      motif: _v(motif),
      symptoms: Extractor.symptomsFromFields(symptoms.text, motif.text),
      duration: _v(duration),
      durationDays: Extractor.daysFromText(duration.text),
      temperature: Extractor.parseTemperature(temp.text),
      allergies: _v(allergies),
      treatment: _v(treatment),
    );
    await ref.read(consultationServiceProvider).saveStructured(widget.c.id, s);
    if (mounted) await _go(context, ref, widget.c.id, 'missing');
  }

  @override
  Widget build(BuildContext context) {
    final manual = widget.c.mode == 'manual';
    return StepScaffold(
      consultationId: widget.c.id,
      stage: 'structured',
      title: manual ? 'Saisie manuelle' : 'Informations',
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        InfoBanner(
            manual
                ? 'Saisie manuelle : remplissez les informations de la consultation. Les champs sont facultatifs.'
                : 'SŪRA propose ces informations. Vérifiez et corrigez si nécessaire.',
            kind: manual ? BannerKind.warn : BannerKind.info),
        LabeledField(
            label: 'Motif de consultation',
            controller: motif,
            hint: 'Ex. fièvre depuis 3 jours'),
        LabeledField(
            label: 'Symptômes (séparés par des virgules)',
            controller: symptoms,
            hint: 'Fièvre, toux…'),
        LabeledField(label: 'Durée', controller: duration, hint: 'Ex. 3 jours'),
        LabeledField(
            label: 'Température (°C)',
            controller: temp,
            hint: 'Ex. 38,5',
            keyboard: TextInputType.number),
        LabeledField(label: 'Allergies connues', controller: allergies),
        LabeledField(label: 'Traitement en cours', controller: treatment),
      ]),
      bottom: [
        PrimaryButton('Vérifier les informations manquantes', onPressed: _next)
      ],
    );
  }
}

// ---------------------------------------------------------------- 5. Informations manquantes (R6 : jamais bloquant)
class MissingScreen extends ConsumerWidget {
  const MissingScreen({super.key, required this.id});
  final String id;
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      WithConsultation(id: id, builder: (ctx, c) => _MissingForm(c: c));
}

class _MissingForm extends ConsumerStatefulWidget {
  const _MissingForm({required this.c});
  final Consultation c;
  @override
  ConsumerState<_MissingForm> createState() => _MissingFormState();
}

class _MissingFormState extends ConsumerState<_MissingForm> {
  late final Structured s = Structured.decode(widget.c.structuredJson);
  late final List<String> missing = MissingFinder.find(s);
  late final Map<String, TextEditingController> ctl = {
    for (final k in missing) k: TextEditingController()
  };

  String? _v(String k) {
    final t = ctl[k]?.text.trim() ?? '';
    return t.isEmpty ? null : t;
  }

  Future<void> _next() async {
    final t = Extractor.parseTemperature(ctl['temperature']?.text ?? '');
    final n = Structured(
      motif: s.motif,
      symptoms: s.symptoms,
      duration: s.duration,
      durationDays: s.durationDays,
      temperature: t ?? s.temperature,
      allergies: _v('allergies') ?? s.allergies,
      treatment: _v('treatment') ?? s.treatment,
    );
    await ref.read(consultationServiceProvider).saveStructured(widget.c.id, n);
    if (mounted) await _go(context, ref, widget.c.id, 'urgency');
  }

  @override
  Widget build(BuildContext context) => StepScaffold(
        consultationId: widget.c.id,
        stage: 'missing',
        title: 'Infos manquantes',
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (missing.isEmpty)
            const InfoBanner('Aucune information manquante.')
          else ...[
            InfoBanner(
                '${missing.length} information(s) semblent manquer. Vous pouvez continuer sans les renseigner : SŪRA ne bloque pas la consultation.',
                kind: BannerKind.warn),
            for (final k in missing)
              LabeledField(
                label: MissingFinder.labels[k]!,
                controller: ctl[k]!,
                keyboard: k == 'temperature' ? TextInputType.number : null,
              ),
          ],
        ]),
        bottom: [PrimaryButton('Continuer', onPressed: _next)],
      );
}

// ---------------------------------------------------------------- 6. Niveau d'urgence (R7, R8)
class UrgencyScreen extends ConsumerWidget {
  const UrgencyScreen({super.key, required this.id});
  final String id;
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      WithConsultation(id: id, builder: (ctx, c) => _UrgencyView(c: c));
}

class _UrgencyView extends ConsumerStatefulWidget {
  const _UrgencyView({required this.c});
  final Consultation c;
  @override
  ConsumerState<_UrgencyView> createState() => _UrgencyViewState();
}

class _UrgencyViewState extends ConsumerState<_UrgencyView> {
  Urgency? chosen;

  @override
  Widget build(BuildContext context) {
    final patient = ref.watch(patientProvider(widget.c.patientId)).value;
    final res = ref.read(consultationServiceProvider).evaluate(
        Structured.decode(widget.c.structuredJson), patient?.ageYears);
    final sel = chosen ?? res.level;
    Widget choice(Urgency u) {
      final on = sel == u;
      final fill = switch (u) {
        Urgency.eleve => T.argile,
        Urgency.modere => T.ambre,
        Urgency.faible => T.savane
      };
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: InkWell(
            onTap: () => setState(() => chosen = u),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: on ? fill : null,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: fill, width: 2),
              ),
              child: Text(
                  '${u.symbol} ${u.label[0]}${u.label.substring(1).toLowerCase()}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: on
                          ? (u == Urgency.modere ? T.ink : Colors.white)
                          : null)),
            ),
          ),
        ),
      );
    }

    return StepScaffold(
      consultationId: widget.c.id,
      stage: 'urgency',
      title: 'Niveau d’urgence',
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('SŪRA propose',
            style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        UrgencyBadge(res.level, large: true),
        const SizedBox(height: 12),
        SuraCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Raisons', style: TextStyle(fontWeight: FontWeight.w800)),
          for (final r in res.reasons) Text('• $r'),
        ])),
        const InfoBanner(
            'Proposition indicative : votre jugement clinique prime toujours.'),
        const Text('Votre décision',
            style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Row(children: [
          choice(Urgency.eleve),
          choice(Urgency.modere),
          choice(Urgency.faible)
        ]),
        if (sel != res.level) ...[
          const SizedBox(height: 10),
          const InfoBanner(
              'Votre décision remplace la proposition de SŪRA. Elle sera enregistrée avec la date et votre identifiant.',
              kind: BannerKind.warn),
        ],
      ]),
      bottom: [
        PrimaryButton('Valider ce niveau', icon: Icons.check,
            onPressed: () async {
          await ref
              .read(consultationServiceProvider)
              .saveUrgency(widget.c.id, res.level, sel, res.reasons);
          if (context.mounted) await _go(context, ref, widget.c.id, 'recap');
        }),
      ],
    );
  }
}

// ---------------------------------------------------------------- 7. Recapitulatif
class RecapScreen extends ConsumerWidget {
  const RecapScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) => WithConsultation(
        id: id,
        builder: (ctx, c) {
          final s = Structured.decode(c.structuredJson);
          Widget line(String k, String? v) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text.rich(TextSpan(children: [
                  TextSpan(
                      text: '$k : ',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  TextSpan(
                      text: v ?? 'Non renseigné',
                      style: TextStyle(
                          fontStyle:
                              v == null ? FontStyle.italic : FontStyle.normal)),
                ])),
              );
          return StepScaffold(
            consultationId: id,
            stage: 'recap',
            title: 'Récapitulatif',
            body:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              PatientHeader(c.patientId),
              if (c.mode == 'manual')
                const InfoBanner('Saisie manuelle', kind: BannerKind.warn),
              SuraCard(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    line('Motif', s.motif),
                    line('Symptômes',
                        s.symptoms.isEmpty ? null : s.symptoms.join(', ')),
                    line('Durée', s.duration),
                    line(
                        'Température',
                        s.temperature == null
                            ? null
                            : '${s.temperature.toString().replaceAll('.', ',')} °C'),
                    line('Allergies', s.allergies),
                    line('Traitement', s.treatment),
                  ])),
              if (c.urgencyFinal != null)
                SuraCard(
                    child: Row(children: [
                  const Expanded(
                      child: Text('Urgence',
                          style: TextStyle(fontWeight: FontWeight.w800))),
                  UrgencyBadge(Urgency.values[c.urgencyFinal!]),
                ])),
            ]),
            bottom: [
              PrimaryButton('Passer à la validation',
                  onPressed: () => _go(context, ref, id, 'validate'))
            ],
          );
        },
      );
}

// ---------------------------------------------------------------- 8. Validation (R8)
class ValidateScreen extends ConsumerWidget {
  const ValidateScreen({super.key, required this.id});
  final String id;
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      WithConsultation(id: id, builder: (ctx, c) => _ValidateView(c: c));
}

class _ValidateView extends ConsumerStatefulWidget {
  const _ValidateView({required this.c});
  final Consultation c;
  @override
  ConsumerState<_ValidateView> createState() => _ValidateViewState();
}

class _ValidateViewState extends ConsumerState<_ValidateView> {
  final checks = List<bool>.filled(5, false);

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    final labels = [
      'Patient identifié',
      c.consent == 'refused'
          ? 'Refus de consentement consigné'
          : 'Consentement accordé et horodaté',
      c.mode == 'manual' ? 'Saisie vérifiée' : 'Transcription vérifiée',
      'Informations structurées correctes',
      'Niveau d’urgence validé par l’agent',
    ];
    final n = checks.where((x) => x).length;
    return StepScaffold(
      consultationId: c.id,
      stage: 'validate',
      title: 'Validation',
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const InfoBanner(
            'Vérification finale avant sauvegarde. L’IA ne valide jamais seule.'),
        for (var i = 0; i < 5; i++)
          SuraCard(
            onTap: () => setState(() => checks[i] = !checks[i]),
            child: Row(children: [
              Icon(checks[i] ? Icons.check_box : Icons.check_box_outline_blank,
                  color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(child: Text(labels[i])),
            ]),
          ),
      ]),
      bottom: [
        PrimaryButton(
            n == 5
                ? 'Enregistrer la consultation'
                : 'Cochez tous les points ($n/5)',
            icon: Icons.save_outlined,
            onPressed: n == 5
                ? () async {
                    await ref.read(consultationServiceProvider).validate(c.id);
                    ref.read(syncServiceProvider).run();
                    if (context.mounted) context.go('/consult/${c.id}/saved');
                  }
                : null),
      ],
    );
  }
}

// ---------------------------------------------------------------- Fin : sauvegarde locale (R9) - sans barre de navigation
class SavedScreen extends ConsumerWidget {
  const SavedScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) => WithConsultation(
        id: id,
        builder: (ctx, c) => Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_outline,
                        size: 72, color: T.savane),
                    const SizedBox(height: 12),
                    const Text('Consultation enregistrée',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    const Text(
                        'Sauvegardée de façon sécurisée sur cet appareil.',
                        textAlign: TextAlign.center),
                    const SizedBox(height: 10),
                    SyncChip(c.syncStatus),
                    const SizedBox(height: 16),
                    const InfoBanner(
                        'Envoi automatique dès la connexion. Aucune donnée ne sera perdue.'),
                    PrimaryButton('Retour à l’accueil',
                        icon: Icons.home_outlined,
                        onPressed: () => context.go('/home')),
                    SecondaryButton('Voir le dossier du patient',
                        onPressed: () =>
                            context.go('/patients/${c.patientId}')),
                  ]),
            ),
          ),
        ),
      );
}

// ---------------------------------------------------------------- Detail d'une consultation enregistree
class ConsultationDetailScreen extends ConsumerWidget {
  const ConsultationDetailScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) => WithConsultation(
        id: id,
        builder: (ctx, c) {
          final s = Structured.decode(c.structuredJson);
          final reasons =
              (jsonDecode(c.reasonsJson) as List).map((e) => '$e').toList();
          return Scaffold(
            appBar: suraAppBar(context, 'Consultation'),
            body: ListView(padding: const EdgeInsets.all(16), children: [
              PatientHeader(c.patientId),
              Row(children: [
                if (c.urgencyFinal != null)
                  UrgencyBadge(Urgency.values[c.urgencyFinal!], large: true),
                const SizedBox(width: 10),
                SyncChip(c.status == 'draft' ? 'draft' : c.syncStatus),
              ]),
              const SizedBox(height: 10),
              Text(fmtWhen(c.createdAt)),
              const SizedBox(height: 10),
              SuraCard(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('Motif : ${s.motif ?? 'Non renseigné'}'),
                    Text(
                        'Symptômes : ${s.symptoms.isEmpty ? 'Non renseigné' : s.symptoms.join(', ')}'),
                    Text('Durée : ${s.duration ?? 'Non renseigné'}'),
                    Text(
                        'Température : ${s.temperature == null ? 'Non renseigné' : '${s.temperature.toString().replaceAll('.', ',')} °C'}'),
                    Text('Allergies : ${s.allergies ?? 'Non renseigné'}'),
                    Text('Traitement : ${s.treatment ?? 'Non renseigné'}'),
                  ])),
              if (reasons.isNotEmpty)
                SuraCard(
                    child: Text(
                        'Raisons de l’urgence :\n${reasons.map((r) => '• $r').join('\n')}')),
              SecondaryButton('Voir le dossier du patient',
                  onPressed: () => context.push('/patients/${c.patientId}')),
            ]),
          );
        },
      );
}
