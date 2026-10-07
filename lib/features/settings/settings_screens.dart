import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config.dart';
import '../../core/widgets.dart';
import '../../data/providers.dart';
import '../../data/repository.dart';
import '../auth/auth_service.dart';
import '../auth/biometric_service.dart';
import '../consultation/cloud_stt.dart';
import 'pin_pad.dart';

// ------------------------------------------------------------------ Securite
class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});
  @override
  ConsumerState<SecurityScreen> createState() => _SecurityState();
}

class _SecurityState extends ConsumerState<SecurityScreen> {
  bool available = false;
  bool on = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final b = ref.read(biometricProvider);
    final a = await b.available();
    final e = await b.enabled();
    if (mounted) {
      setState(() {
        available = a;
        on = e && a;
      });
    }
  }

  Future<void> _toggle(bool v) async {
    final b = ref.read(biometricProvider);
    if (v) {
      final ok = await b.authenticate();
      if (!ok) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Biométrie non confirmée : réglage inchangé.')));
        }
        return;
      }
    }
    await b.setEnabled(v);
    if (mounted) setState(() => on = v);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: suraAppBar(context, 'Sécurité'),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          SuraCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Expanded(
                    child: Text('Déverrouillage biométrique',
                        style: TextStyle(fontWeight: FontWeight.w800))),
                Switch(value: on, onChanged: available ? _toggle : null),
              ]),
              Text(
                  available
                      ? 'Empreinte ou visage. Le PIN reste toujours disponible.'
                      : 'Non disponible sur cet appareil (ou non configurée dans les réglages du téléphone).',
                  style: const TextStyle(fontSize: 12)),
            ]),
          ),
          SuraCard(
            onTap: () => context.push('/settings/pin'),
            child: const Row(children: [
              Expanded(
                  child: Text('Changer le PIN',
                      style: TextStyle(fontWeight: FontWeight.w800))),
              Icon(Icons.chevron_right),
            ]),
          ),
          const InfoBanner(
              'PIN à 6 chiffres. Après 5 échecs, l’appareil se verrouille temporairement (durée croissante).'),
          InfoBanner(
            kDbEncrypted
                ? 'Données chiffrées sur cet appareil.'
                : 'Chiffrement de la base locale : non activé dans cette version.',
            kind: kDbEncrypted ? BannerKind.info : BannerKind.warn,
          ),
        ]),
      );
}

// ------------------------------------------------------------------ Changer le PIN (actuel -> nouveau -> confirmation)
class ChangePinScreen extends ConsumerStatefulWidget {
  const ChangePinScreen({super.key});
  @override
  ConsumerState<ChangePinScreen> createState() => _ChangePinState();
}

class _ChangePinState extends ConsumerState<ChangePinScreen> {
  static const titles = [
    'Entrez votre PIN actuel',
    'Choisissez un nouveau PIN',
    'Confirmez le nouveau PIN'
  ];
  int step = 0;
  String pin = '';
  String? newPin;
  String msg = '';

  Future<void> _key(String k) async {
    if (k == '⌫') {
      if (pin.isNotEmpty) {
        setState(() => pin = pin.substring(0, pin.length - 1));
      }
      return;
    }
    if (pin.length >= 6) return;
    setState(() => pin += k);
    if (pin.length == 6) await _done();
  }

  Future<void> _done() async {
    final auth = ref.read(authProvider);
    if (step == 0) {
      final r = await auth.verifyPin(pin);
      if (!mounted) return;
      if (r == PinResult.ok) {
        setState(() {
          step = 1;
          pin = '';
          msg = '';
        });
      } else {
        setState(() {
          pin = '';
          msg = r == PinResult.locked
              ? 'Trop de tentatives. Réessayez dans un instant.'
              : 'PIN incorrect';
        });
      }
    } else if (step == 1) {
      setState(() {
        newPin = pin;
        pin = '';
        step = 2;
      });
    } else {
      if (pin == newPin) {
        await auth.setPin(pin);
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('PIN modifié.')));
        context.pop();
      } else {
        setState(() {
          pin = '';
          newPin = null;
          step = 1;
          msg = 'Les PIN ne correspondent pas. Recommencez.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: suraAppBar(context, 'Changer le PIN'),
        body: SafeArea(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(titles[step],
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            PinDots(pin.length),
            SizedBox(
                height: 28,
                child: Text(msg,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error))),
            PinKeypad(onKey: _key),
          ]),
        ),
      );
}

// ------------------------------------------------------------------ Stockage hors ligne
class StorageScreen extends ConsumerWidget {
  const StorageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patients = ref.watch(allPatientsProvider).value ?? [];
    final cons =
        ref.watch(consultationsProvider(const ConsFilter())).value ?? [];
    final drafts = cons.where((c) => c.status == 'draft').length;
    final saved = cons.where((c) => c.status == 'saved').length;
    final pending = cons
        .where((c) => c.status == 'saved' && c.syncStatus != 'synced')
        .length;
    final synced = cons
        .where((c) => c.status == 'saved' && c.syncStatus == 'synced')
        .length;

    Widget line(String k, String v) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(k),
                Text(v, style: const TextStyle(fontWeight: FontWeight.w800))
              ]),
        );

    return Scaffold(
      appBar: suraAppBar(context, 'Stockage hors ligne'),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        SuraCard(
          child: Column(children: [
            line('Patients', '${patients.length}'),
            line('Consultations enregistrées', '$saved'),
            line('Brouillons', '$drafts'),
            line('En attente d’envoi', '$pending'),
            line('Déjà synchronisées', '$synced'),
          ]),
        ),
        const InfoBanner(
            'Aucun fichier audio n’est conservé. Une consultation en attente d’envoi n’est jamais supprimée.'),
        SecondaryButton('Libérer l’espace (dossiers déjà envoyés)',
            onPressed: synced == 0
                ? null
                : () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (d) => AlertDialog(
                        title: const Text('Libérer l’espace ?'),
                        content: Text(
                            '$synced consultation(s) déjà envoyées seront retirées de cet appareil. Elles restent sur le serveur.'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(d, false),
                              child: const Text('Annuler')),
                          TextButton(
                              onPressed: () => Navigator.pop(d, true),
                              child: const Text('Libérer')),
                        ],
                      ),
                    );
                    if (ok == true) {
                      final n = await ref.read(repoProvider).purgeSynced();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                '$n consultation(s) retirée(s) de l’appareil.')));
                      }
                    }
                  }),
      ]),
    );
  }
}

// ------------------------------------------------------------------ A propos
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connected = ref.watch(connectedModeProvider);
    final transcription = connected && kRodiumKey.isNotEmpty
        ? 'IA distante si Internet ($kCloudSttModel), sinon locale'
        : (kUseRealStt
            ? 'Reconnaissance vocale locale (Vosk)'
            : 'Texte de démonstration (moteur réel non activé)');
    Widget line(String k, String v) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
                width: 130,
                child: Text(k,
                    style: const TextStyle(fontWeight: FontWeight.w700))),
            Expanded(child: Text(v)),
          ]),
        );
    return Scaffold(
      appBar: suraAppBar(context, 'À propos de SŪRA'),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const SuraCard(
          child: Column(children: [
            Text('SŪRA',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
            Text('Version 0.1.0 (MVP)'),
            SizedBox(height: 8),
            Text(
                'Assistant de consultation hors ligne pour agents de santé de première ligne.',
                textAlign: TextAlign.center),
          ]),
        ),
        const InfoBanner(
            'SŪRA propose, l’agent vérifie et valide. L’IA ne pose jamais de diagnostic.'),
        const SuraCard(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Ce que fait l’application',
                style: TextStyle(fontWeight: FontWeight.w800)),
            SizedBox(height: 6),
            Text(
                '• Consultation guidée en 8 étapes (6 en saisie manuelle si le patient refuse)\n'
                '• Fonctionne sans Internet : données enregistrées sur l’appareil\n'
                '• Synchronisation automatique au retour du réseau\n'
                '• Identification du patient par QR (identifiant opaque)\n'
                '• Niveau d’urgence proposé, toujours modifiable par l’agent'),
          ]),
        ),
        SuraCard(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('État de cette installation',
                style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            line('Synchronisation',
                kUseFirebase ? 'Firebase (réelle)' : 'Démonstration (simulée)'),
            line('Transcription', transcription),
            line(
                'Chiffrement',
                kDbEncrypted
                    ? 'Base locale chiffrée'
                    : 'Base locale non chiffrée (prévu)'),
          ]),
        ),
        const SuraCard(
          child: Text(
              'Confidentialité : l’audio n’est jamais conservé. Par défaut il reste sur l’appareil ; en mode connecté facultatif, '
              'il est envoyé à un service d’IA externe avec le consentement du patient. Les niveaux d’urgence sont des propositions '
              'de démonstration, à faire valider cliniquement avant tout usage réel.'),
        ),
        const Padding(
          padding: EdgeInsets.all(8),
          child: Text(
              'Projet réalisé pour le FlutterFire Summer Camp 2026 (hackathon).',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12)),
        ),
      ]),
    );
  }
}
