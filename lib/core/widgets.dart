import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/providers.dart';
import '../domain/models.dart';
import '../features/consultation/consultation_service.dart';
import 'theme.dart';

bool isDark(BuildContext c) => Theme.of(c).brightness == Brightness.dark;

AppBar suraAppBar(BuildContext c, String title,
        {bool back = true, List<Widget>? actions}) =>
    AppBar(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      backgroundColor: isDark(c) ? T.tealDark : T.teal,
      foregroundColor: Colors.white,
      automaticallyImplyLeading: back,
      actions: actions,
    );

/// Icone de bascule clair/sombre (ecrans racines uniquement, decision V3).
class ThemeToggle extends ConsumerWidget {
  const ThemeToggle({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => IconButton(
        icon: const Icon(Icons.brightness_6_outlined),
        tooltip: 'Thème clair / sombre',
        onPressed: () => ref
            .read(themeModeProvider.notifier)
            .toggle(Theme.of(context).brightness),
      );
}

class SuraCard extends StatelessWidget {
  const SuraCard(
      {super.key,
      required this.child,
      this.onTap,
      this.color,
      this.padding = const EdgeInsets.all(14)});
  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) {
    final dark = isDark(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color:
                      dark ? const Color(0xFF33474A) : const Color(0xFFE3E5E2)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton(this.label,
      {super.key, required this.onPressed, this.icon});
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            onPressed: onPressed,
            icon: Icon(icon ?? Icons.arrow_forward, size: 20),
            label: Text(label,
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          ),
        ),
      );
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton(this.label, {super.key, required this.onPressed});
  final String label;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              side: BorderSide(
                  color: Theme.of(context).colorScheme.primary, width: 2),
            ),
            onPressed: onPressed,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      );
}

/// Urgence : triple codage couleur + forme + libelle (jamais la couleur seule).
class UrgencyBadge extends StatelessWidget {
  const UrgencyBadge(this.level, {super.key, this.large = false});
  final Urgency level;
  final bool large;
  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (level) {
      Urgency.eleve => (T.argile, Colors.white),
      Urgency.modere => (T.ambre, T.ink),
      Urgency.faible => (T.savane, Colors.white),
    };
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: large ? 18 : 8, vertical: large ? 14 : 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(large ? 12 : 99),
        border: level == Urgency.modere
            ? Border.all(color: T.ambreDark, width: 2)
            : null,
      ),
      child: Text(
        '${level.symbol} ${level.label}',
        textAlign: TextAlign.center,
        style: TextStyle(
            color: fg, fontWeight: FontWeight.w800, fontSize: large ? 22 : 11),
      ),
    );
  }
}

/// Statuts de synchronisation : symbole + libelle (R15).
class SyncChip extends StatelessWidget {
  const SyncChip(this.status, {super.key});
  final String status;
  @override
  Widget build(BuildContext context) {
    final (sym, label) = switch (status) {
      'syncing' => ('⟳', 'Sync…'),
      'synced' => ('✓', 'Synchronisé'),
      'error' => ('⚠', 'Erreur'),
      'draft' => ('✎', 'Brouillon'),
      _ => ('○', 'En attente'),
    };
    final err = status == 'error';
    final color = err
        ? Theme.of(context).colorScheme.error
        : (status == 'synced'
            ? T.savane
            : Theme.of(context).colorScheme.onSurfaceVariant);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color, width: err ? 2 : 1),
      ),
      child: Text('$sym $label',
          style: TextStyle(
              color: color, fontWeight: FontWeight.w700, fontSize: 11)),
    );
  }
}

enum BannerKind { info, warn, error }

class InfoBanner extends StatelessWidget {
  const InfoBanner(this.text, {super.key, this.kind = BannerKind.info});
  final String text;
  final BannerKind kind;
  @override
  Widget build(BuildContext context) {
    final dark = isDark(context);
    final (bg, fg, icon) = switch (kind) {
      BannerKind.info => (
          dark ? const Color(0xFF163636) : T.infoBg,
          dark ? const Color(0xFF8FD3D1) : T.teal,
          Icons.info_outline
        ),
      BannerKind.warn => (
          dark ? const Color(0xFF3A2F17) : T.warnBg,
          dark ? const Color(0xFFF0D8A0) : T.ink,
          Icons.warning_amber_outlined
        ),
      BannerKind.error => (
          dark ? const Color(0xFF3A1C19) : T.errorBg,
          dark ? T.errorLight : T.error,
          Icons.error_outline
        ),
    };
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border:
            kind == BannerKind.error ? Border.all(color: fg, width: 2) : null,
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: fg, size: 20),
        const SizedBox(width: 8),
        Expanded(
            child: Text(text,
                style: TextStyle(color: fg, fontWeight: FontWeight.w500))),
      ]),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState(
      {super.key,
      required this.icon,
      required this.title,
      required this.message,
      this.action});
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(title,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: 16), action!],
          ]),
        ),
      );
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

/// Champ de formulaire avec erreur en rouge sous le champ (maquette H5).
class LabeledField extends StatelessWidget {
  const LabeledField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.keyboard,
    this.validator,
    this.obscure = false,
    this.maxLines = 1,
  });
  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboard;
  final String? Function(String?)? validator;
  final bool obscure;
  final int maxLines;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            keyboardType: keyboard,
            obscureText: obscure,
            maxLines: maxLines,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ]),
      );
}

/// Cadre commun du workflow : barre de progression (8 etapes, 6 en saisie manuelle),
/// bouton "Quitter" (dialogue a 3 choix), actions en bas. La barre de navigation est absente.
class StepScaffold extends ConsumerWidget {
  const StepScaffold({
    super.key,
    required this.consultationId,
    required this.stage,
    required this.title,
    required this.body,
    this.bottom = const [],
  });
  final String consultationId;
  final String stage;
  final String title;
  final Widget body;
  final List<Widget> bottom;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.watch(consultationProvider(consultationId)).value;
    final stages = stagesFor(c?.mode ?? 'voice');
    final idx = stages.indexOf(stage) + 1;
    return Scaffold(
      appBar: suraAppBar(context, '$title ($idx/${stages.length})', actions: [
        TextButton(
          onPressed: () => _quit(context, ref),
          child: const Text('Quitter',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        ),
      ]),
      body: SafeArea(
        child: Column(children: [
          Row(children: [
            for (var i = 1; i <= stages.length; i++)
              Expanded(
                  child: Container(
                      height: 4,
                      margin: const EdgeInsets.only(right: 2),
                      color: i <= idx ? T.ambre : Colors.black12)),
          ]),
          Expanded(
              child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16), child: body)),
          if (bottom.isNotEmpty)
            Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Column(children: bottom)),
        ]),
      ),
    );
  }

  void _quit(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('Quitter la consultation ?'),
        content:
            const Text('Vos réponses sont déjà sauvegardées sur l’appareil.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(d),
              child: const Text('Continuer')),
          TextButton(
            onPressed: () {
              Navigator.pop(d);
              context.go('/home');
            },
            child: const Text('Enregistrer le brouillon et quitter'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(d);
              await ref
                  .read(consultationServiceProvider)
                  .abandon(consultationId);
              if (context.mounted) context.go('/home');
            },
            child: const Text('Abandonner'),
          ),
        ],
      ),
    );
  }
}
