import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'theme.dart';
import 'widgets.dart';

/// Barre du bas : Accueil, Patients, Consulter (＋ central), Paramètres.
/// Visible uniquement sur les 4 onglets racines (masquee pendant le workflow).
/// Hauteur fixe de 80 : le bouton rond (54) + son libelle tiennent sans debordement.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.location, required this.child});
  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = isDark(context);
    final primary = Theme.of(context).colorScheme.primary;
    final sel = location.startsWith('/patients')
        ? 1
        : (location.startsWith('/settings') ? 3 : 0);

    Widget item(IconData icon, String label, int i, String route) => Expanded(
          child: InkWell(
            onTap: () => context.go(route),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(icon, color: sel == i ? primary : Colors.grey),
                const SizedBox(height: 2),
                Text(label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: sel == i ? FontWeight.w800 : FontWeight.w500,
                      color: sel == i ? primary : Colors.grey,
                    )),
              ]),
            ),
          ),
        );

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
              top: BorderSide(
                  color: dark
                      ? const Color(0xFF33474A)
                      : const Color(0xFFE3E5E2))),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 80,
            child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              item(Icons.monitor_heart_outlined, 'Accueil', 0, '/home'),
              item(Icons.groups_outlined, 'Patients', 1, '/patients'),
              Expanded(
                child: InkWell(
                  onTap: () => context.push('/consult/select'),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: const BoxDecoration(
                                color: T.teal, shape: BoxShape.circle),
                            child: const Icon(Icons.add,
                                color: Colors.white, size: 30),
                          ),
                          const SizedBox(height: 2),
                          const Text('Consulter',
                              style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w700)),
                        ]),
                  ),
                ),
              ),
              item(Icons.tune, 'Paramètres', 3, '/settings'),
            ]),
          ),
        ),
      ),
    );
  }
}
