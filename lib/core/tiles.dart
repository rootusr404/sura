import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/database.dart';
import '../data/providers.dart';
import '../domain/models.dart';
import 'format.dart';
import 'widgets.dart';

/// Ligne de consultation : un brouillon se reprend, une consultation enregistree s'ouvre.
class ConsultationTile extends ConsumerWidget {
  const ConsultationTile(this.c, {super.key});
  final Consultation c;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patients = ref.watch(allPatientsProvider).value ?? const <Patient>[];
    final p = patients.where((x) => x.id == c.patientId).firstOrNull;
    final name = p == null ? 'Patient' : '${p.firstName} ${p.familyName}';
    final s = Structured.decode(c.structuredJson);
    final draft = c.status == 'draft';
    return SuraCard(
      onTap: () => draft
          ? context.push('/consult/${c.id}/${c.stage}')
          : context.push('/consultations/${c.id}'),
      child: Row(children: [
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.w800)),
            Text(draft ? 'Brouillon · reprendre' : (s.motif ?? 'Consultation')),
            Text(fmtWhen(c.createdAt), style: const TextStyle(fontSize: 12)),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          if (c.urgencyFinal != null)
            UrgencyBadge(Urgency.values[c.urgencyFinal!]),
          const SizedBox(height: 4),
          SyncChip(draft ? 'draft' : c.syncStatus),
        ]),
      ]),
    );
  }
}

class PatientHeader extends ConsumerWidget {
  const PatientHeader(this.patientId, {super.key});
  final String patientId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(patientProvider(patientId)).value;
    if (p == null) return const SizedBox.shrink();
    return SuraCard(
      child: Row(children: [
        CircleAvatar(
            child: Text('${p.firstName[0]}${p.familyName[0]}'.toUpperCase())),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${p.firstName} ${p.familyName}',
              style:
                  const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          Text(
              '${p.ageYears} ans · ${p.sex == 'F' ? 'Femme' : (p.sex == 'M' ? 'Homme' : 'Autre')} · ${p.id}',
              style: const TextStyle(fontSize: 12)),
        ]),
      ]),
    );
  }
}
