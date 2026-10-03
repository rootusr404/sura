import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sura/core/connectivity_provider.dart';
import 'package:sura/core/theme/sura_colors.dart';

/// Coque de navigation : Accueil | Patients | [Consulter] | Paramètres.
class ShellScaffold extends ConsumerWidget {
  const ShellScaffold({super.key, required this.shell});
  final StatefulNavigationShell shell;

  void _go(int branch) =>
      shell.goBranch(branch, initialLocation: branch == shell.currentIndex);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(isOnlineProvider).value ?? true;
    return Scaffold(
      body: Column(
        children: [
          if (!online)
            Container(
              width: double.infinity,
              color: SuraColors.slateLight,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 6,
                bottom: 6,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_off, size: 16, color: SuraColors.slate),
                  SizedBox(width: 6),
                  Text(
                    'Mode hors ligne — vos données restent sur l\'appareil',
                    style: TextStyle(fontSize: 12, color: SuraColors.slate),
                  ),
                ],
              ),
            ),
          Expanded(child: shell),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: SuraColors.surface,
            border: Border(top: BorderSide(color: SuraColors.border)),
          ),
          height: 68,
          child: Row(
            children: [
              _item(
                Icons.home_outlined,
                Icons.home,
                'Accueil',
                shell.currentIndex == 0,
                () => _go(0),
              ),
              _item(
                Icons.people_outline,
                Icons.people,
                'Patients',
                shell.currentIndex == 1,
                () => _go(1),
              ),
              Expanded(
                child: Center(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(110, 48),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onPressed: () => context.push('/consultation/new'),
                    icon: const Icon(Icons.mic),
                    label: const Text('Consulter'),
                  ),
                ),
              ),
              _item(
                Icons.settings_outlined,
                Icons.settings,
                'Paramètres',
                shell.currentIndex == 2,
                () => _go(2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(
    IconData icon,
    IconData activeIcon,
    String label,
    bool active,
    VoidCallback onTap,
  ) {
    final color = active ? SuraColors.teal : SuraColors.inkSoft;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(active ? activeIcon : icon, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
