import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/sura_colors.dart';
import 'patient_providers.dart';
import 'widgets/patient_tile.dart';

class PatientsScreen extends ConsumerStatefulWidget {
  const PatientsScreen({super.key});
  @override
  ConsumerState<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends ConsumerState<PatientsScreen> {
  late final TextEditingController _search;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(text: ref.read(patientSearchQueryProvider));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patients = ref.watch(filteredPatientsProvider);
    final query = ref.watch(patientSearchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patients'),
        actions: [
          IconButton(
            tooltip: 'Scanner un QR',
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => context.push('/patients/scan'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/patients/new'),
        icon: const Icon(Icons.person_add_alt),
        label: const Text('Nouveau patient'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _search,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Nom, village ou identifiant SUR-…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _search.clear();
                          ref.read(patientSearchQueryProvider.notifier).set('');
                        },
                      ),
              ),
              onChanged: (v) =>
                  ref.read(patientSearchQueryProvider.notifier).set(v),
            ),
          ),
          Expanded(
            child: patients.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text('Erreur de lecture locale : $e')),
              data: (list) {
                if (list.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        query.isEmpty
                            ? 'Aucun patient pour le moment.\nAppuyez sur « Nouveau patient ».'
                            : 'Aucun résultat pour « $query ».',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: SuraColors.inkSoft),
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => PatientTile(patient: list[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
