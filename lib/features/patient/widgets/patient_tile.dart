import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sura/domain/models/records.dart';
import '../../../core/theme/sura_colors.dart';
import '../../../core/widgets/status_chip.dart';

class PatientTile extends StatelessWidget {
  const PatientTile({super.key, required this.patient});
  final PatientRecord patient;

  @override
  Widget build(BuildContext context) {
    final p = patient;
    final initials =
        '${p.firstName.isEmpty ? '' : p.firstName[0]}${p.lastName.isEmpty ? '' : p.lastName[0]}'
            .toUpperCase();
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/patients/${p.id}'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: SuraColors.tealLight,
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: SuraColors.tealDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${p.firstName} ${p.lastName}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${p.ageYears} ans · ${p.sex == 'F' ? 'Femme' : 'Homme'} · ${p.village}',
                      style: const TextStyle(color: SuraColors.inkSoft),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      p.id,
                      style: const TextStyle(
                        fontSize: 12,
                        color: SuraColors.inkSoft,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              StatusChip(state: p.syncState),
            ],
          ),
        ),
      ),
    );
  }
}
