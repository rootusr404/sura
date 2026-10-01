import 'package:flutter/material.dart';
import '../models/enums.dart';
import '../theme/sura_colors.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.state});
  final SyncState state;

  @override
  Widget build(BuildContext context) {
    final (label, icon, bg, fg, borderColor) = switch (state) {
      SyncState.offline => (
        'Hors ligne',
        Icons.cloud_off,
        SuraColors.slateLight,
        SuraColors.slate,
        SuraColors.slate,
      ),
      SyncState.pending => (
        'En attente',
        Icons.schedule,
        SuraColors.amberLight,
        SuraColors.ink,
        SuraColors.amberDark,
      ),
      SyncState.syncing => (
        'Synchronisation…',
        Icons.sync,
        SuraColors.tealLight,
        SuraColors.tealDark,
        SuraColors.teal,
      ),
      SyncState.synced => (
        'Synchronisé',
        Icons.cloud_done_outlined,
        SuraColors.greenLight,
        SuraColors.green,
        SuraColors.green,
      ),
      SyncState.error => (
        'Échec',
        Icons.error_outline,
        Colors.white,
        SuraColors.ink,
        SuraColors.ink,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: borderColor,
          width: state == SyncState.error ? 2 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
