// Tests des règles Firestore de SŪRA (S-05), exécutés contre l'émulateur local.
// Projet fictif « demo-sura » : aucun accès au projet réel, données fictives.
// Les documents ci-dessous reproduisent exactement ce que l'application envoie
// (voir lib/features/sync/firestore_sync_remote_store.dart), valeurs nulles comprises.
import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, it } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  Timestamp,
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  runTransaction,
  serverTimestamp,
  setDoc,
} from 'firebase/firestore';

const A = 'agent-a';
const B = 'agent-b';
let env;

const now = () => Timestamp.now();

const patient = (overrides = {}) => ({
  id: 'SUR-TEST-0001',
  lastName: 'Ba',
  firstName: 'Aïssatou',
  ageYears: 28,
  ageRecordedAt: now(),
  sex: 'F',
  village: 'Village-Test-A',
  phone: null,
  createdByAgentId: A,
  createdAt: now(),
  updatedAt: now(),
  ...overrides,
});

const consultation = (overrides = {}) => ({
  id: 'c1',
  patientId: 'SUR-TEST-0001',
  agentId: A,
  status: 'saved',
  step: 'saved',
  consent: 'granted',
  consentAt: now(),
  transcriptRaw: 'Elle a de la fièvre depuis 3 jours.',
  transcriptEdited: null,
  structured: { chiefComplaint: 'Fièvre', symptoms: ['fièvre'] },
  missing: [{ code: 'allergies', label: 'Les allergies', hint: null }],
  urgencyProposal: { level: 'moderate', reasons: ['Fièvre depuis 3 jours'] },
  urgencyFinal: 'moderate',
  urgencyOverrideReason: null,
  checklist: { transcript: true, structured: true },
  createdAt: now(),
  updatedAt: now(),
  validatedAt: now(),
  ...overrides,
});

const profile = (overrides = {}) => ({
  agent_id: A,
  email: 'agent.test@exemple.test',
  prenom: 'Test',
  nom: 'Agent',
  telephone_professionnel: '',
  region: 'Region-Test',
  district: 'District-Test',
  poste_de_sante: 'Poste-Test',
  role_clinique: 'ASC',
  created_at: now(),
  ...overrides,
});

const db = (uid) =>
  uid ? env.authenticatedContext(uid).firestore() : env.unauthenticatedContext().firestore();
const patientRef = (d, uid = A, id = 'SUR-TEST-0001') => doc(d, `agents/${uid}/patients/${id}`);
const consultRef = (d, uid = A, id = 'c1') => doc(d, `agents/${uid}/consultations/${id}`);
const profileRef = (d, uid = A) => doc(d, `agents/${uid}`);

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-sura',
    firestore: { rules: readFileSync('./firestore.rules', 'utf8') },
  });
});
after(async () => env?.cleanup());
beforeEach(async () => env.clearFirestore());

const seed = (path, data) =>
  env.withSecurityRulesDisabled((ctx) => setDoc(doc(ctx.firestore(), path), data));

describe('accès : chaque agent ne voit que ses données', () => {
  it('le propriétaire crée, lit et met à jour son patient', async () => {
    const d = db(A);
    await assertSucceeds(setDoc(patientRef(d), patient()));
    await assertSucceeds(getDoc(patientRef(d)));
    await assertSucceeds(setDoc(patientRef(d), patient({ village: 'Autre-Village' })));
  });

  it('le propriétaire crée et lit sa consultation', async () => {
    const d = db(A);
    await assertSucceeds(setDoc(consultRef(d), consultation()));
    await assertSucceeds(getDoc(consultRef(d)));
  });

  it('une transaction lecture puis écriture, comme la synchronisation, réussit', async () => {
    const d = db(A);
    await assertSucceeds(
      runTransaction(d, async (tx) => {
        await tx.get(patientRef(d));
        tx.set(patientRef(d), patient());
      }),
    );
  });

  it('lire un patient absent de son propre chemin est autorisé', async () => {
    await assertSucceeds(getDoc(patientRef(db(A), A, 'absent')));
  });

  it('un autre agent ne peut ni lire ni écrire', async () => {
    await seed(`agents/${A}/patients/SUR-TEST-0001`, patient());
    const b = db(B);
    await assertFails(getDoc(patientRef(b, A)));
    await assertFails(setDoc(patientRef(b, A), patient()));
    await assertFails(getDoc(consultRef(b, A)));
    await assertFails(setDoc(consultRef(b, A), consultation()));
  });

  it('un agent liste ses patients mais pas ceux d\'un autre', async () => {
    await assertSucceeds(getDocs(collection(db(A), `agents/${A}/patients`)));
    await assertFails(getDocs(collection(db(B), `agents/${A}/patients`)));
  });

  it('sans connexion, tout est refusé', async () => {
    const d = db(null);
    await assertFails(getDoc(patientRef(d)));
    await assertFails(setDoc(patientRef(d), patient()));
  });

  it('une collection inconnue ou une sous-collection plus profonde est refusée', async () => {
    const d = db(A);
    await assertFails(setDoc(doc(d, 'autre/x'), { a: 1 }));
    await assertFails(setDoc(doc(d, `agents/${A}/patients/p1/audio/a1`), { a: 1 }));
    await assertFails(getDocs(collection(d, 'agents')));
  });
});

describe('profil agent', () => {
  it('le propriétaire crée et lit son profil', async () => {
    const d = db(A);
    await assertSucceeds(setDoc(profileRef(d), profile()));
    await assertSucceeds(getDoc(profileRef(d)));
  });

  it('l\'inscription réelle (horodatage créé par le serveur) est acceptée', async () => {
    await assertSucceeds(
      setDoc(profileRef(db(A)), profile({ created_at: serverTimestamp() })),
    );
  });

  it('un autre agent ne peut pas le lire ni l\'écrire', async () => {
    await seed(`agents/${A}`, profile());
    await assertFails(getDoc(profileRef(db(B), A)));
    await assertFails(setDoc(profileRef(db(B), A), profile()));
  });

  it('un champ inconnu (ex. droits administrateur) est refusé', async () => {
    await assertFails(setDoc(profileRef(db(A)), profile({ isAdmin: true })));
  });

  it('agent_id doit être l\'identifiant du compte connecté', async () => {
    await assertFails(setDoc(profileRef(db(A)), profile({ agent_id: B })));
  });

  it('le profil ne peut pas être supprimé', async () => {
    await seed(`agents/${A}`, profile());
    await assertFails(deleteDoc(profileRef(db(A))));
  });
});

describe('patients : contenu validé', () => {
  it('un téléphone renseigné (chaîne) est accepté', async () => {
    await assertSucceeds(setDoc(patientRef(db(A)), patient({ phone: '+000 00 00 00 00' })));
  });

  it('un champ inconnu (ex. chemin audio) est refusé', async () => {
    await assertFails(setDoc(patientRef(db(A)), patient({ audioPath: '/data/a.wav' })));
  });

  it('createdByAgentId doit être celui du compte connecté', async () => {
    await assertFails(setDoc(patientRef(db(A)), patient({ createdByAgentId: B })));
  });

  it('id doit correspondre au chemin du document', async () => {
    await assertFails(setDoc(patientRef(db(A)), patient({ id: 'SUR-AUTRE-0002' })));
  });

  it('le sexe doit être F ou M', async () => {
    await assertFails(setDoc(patientRef(db(A)), patient({ sex: 'X' })));
  });

  it('l\'âge doit être un entier raisonnable', async () => {
    await assertFails(setDoc(patientRef(db(A)), patient({ ageYears: -1 })));
    await assertFails(setDoc(patientRef(db(A)), patient({ ageYears: '28' })));
    await assertFails(setDoc(patientRef(db(A)), patient({ ageYears: 200 })));
  });

  it('un patient ne peut pas être supprimé', async () => {
    await seed(`agents/${A}/patients/SUR-TEST-0001`, patient());
    await assertFails(deleteDoc(patientRef(db(A))));
  });
});

describe('consultations : contenu validé', () => {
  it('un champ inconnu (ex. audio) est refusé', async () => {
    await assertFails(setDoc(consultRef(db(A)), consultation({ audio: 'AAAA' })));
    await assertFails(setDoc(consultRef(db(A)), consultation({ audioPath: '/a.wav' })));
  });

  it('agentId doit être celui du compte connecté', async () => {
    await assertFails(setDoc(consultRef(db(A)), consultation({ agentId: B })));
  });

  it('id doit correspondre au chemin du document', async () => {
    await assertFails(setDoc(consultRef(db(A)), consultation({ id: 'autre' })));
  });

  it('le statut et le niveau d\'urgence doivent être connus', async () => {
    await assertFails(setDoc(consultRef(db(A)), consultation({ status: 'hacked' })));
    await assertFails(setDoc(consultRef(db(A)), consultation({ urgencyFinal: 'critical' })));
    await assertFails(setDoc(consultRef(db(A)), consultation({ consent: 'peut-etre' })));
  });

  it('une transcription démesurée est refusée', async () => {
    await assertFails(
      setDoc(consultRef(db(A)), consultation({ transcriptRaw: 'x'.repeat(50001) })),
    );
  });

  it('une consultation brouillon avec valeurs nulles est acceptée', async () => {
    await assertSucceeds(
      setDoc(
        consultRef(db(A)),
        consultation({
          status: 'draft',
          consent: null,
          consentAt: null,
          transcriptRaw: null,
          structured: null,
          urgencyProposal: null,
          urgencyFinal: null,
          validatedAt: null,
        }),
      ),
    );
  });

  it('une consultation ne peut pas être supprimée', async () => {
    await seed(`agents/${A}/consultations/c1`, consultation());
    await assertFails(deleteDoc(consultRef(db(A))));
  });
});
