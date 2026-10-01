import 'package:flutter/material.dart';

/// Écran provisoire. Le propriétaire REMPLACE le contenu du fichier
/// (même nom de classe, même chemin) : le routeur n'a pas à changer.
class DevPlaceholder extends StatelessWidget {
  const DevPlaceholder({
    super.key,
    required this.title,
    required this.task,
    required this.owner,
    this.children = const [],
  });
  final String title;
  final String task;
  final String owner;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Écran à construire — tâche $task ($owner)',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ...children,
          ],
        ),
      ),
    ),
  );
}
