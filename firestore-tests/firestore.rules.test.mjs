// Tests des règles Firestore de SŪRA (version « rescue »), exécutés contre l'émulateur local.
// Projet fictif « demo-sura » : aucun accès au projet réel, données fictives.
// Les documents reproduisent exactement ce que l'application écrit :
//   - lib/features/sync/sync_service.dart (patients, consultations, avec merge: true)
//   - lib/features/auth/auth_service.dart (inscription)
//   - lib/features/profile/profile_service.dart (profil)
import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, it } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  serverTimestamp,
  setDoc,
} from 'firebase/firestore';

const A = 'agent-a';
const B = 'agent-b';
let env;

const iso = () => new Date().toISOString();
const MERGE = { merge: true };

const patient = (overrides = {}) => ({
  id: 'SUR-TEST-0001',
  familyName: 'Ba',
  firstName: 'Aïssatou',
  ageYears: 28,
  ageRecordedAt: iso(),
  sex: 'F',
  village: 'Village-Test-A',
  createdBy: A,
  createdAt: iso(),
  syncedAt: serverTimestamp(),
  ...overrides,
});

const consultation = (overrides = {}) => ({
  id: 'c1',
  patientId: 'SUR-TEST-0001',
  agentId: A,
  mode: 'voice',
  consent: 'granted',
  consentAt: iso(),
  structured: '{"motif":"Fièvre","symptoms":["Fièvre"],"temperature":39.4}',
  urgencyProposed: 1,
  urgencyFinal: 1,
  reasons: '["Fièvre à 39,4 °C","Fièvre depuis 3 jours"]',
  validatedAt: iso(),
  createdAt: iso(),
  syncedAt: serverTimestamp(),
  ...overrides,
});

// Écriture faite par AuthService à l'inscription.
const signup = (overrides = {}) => ({
  email: 'agent.test@exemple.test',
  createdAt: serverTimestamp(),
  ...overrides,
});

// Écriture faite par ProfileService.pushIfDirty (fusionnée avec la précédente).
const profile = (overrides = {}) => ({
  fullName: 'Agent Test',
  phone: '',
  region: 'Region-Test',
  healthPost: 'Poste-Test',
  role: 'Agent de santé communautaire',
  email: 'agent.test@exemple.test',
  confidentialityAcceptedAt: null,
  agentCode: 'AGT-ABC123',
  profileUpdatedAt: serverTimestamp(),
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
  it('le propriétaire envoie son patient (merge), puis le met à jour', async () => {
    const d = db(A);
    await assertSucceeds(setDoc(patientRef(d), patient(), MERGE));
    await assertSucceeds(setDoc(patientRef(d), patient({ village: 'Autre' }), MERGE));
    await assertSucceeds(getDoc(patientRef(d)));
  });

  it('le propriétaire envoie sa consultation (merge)', async () => {
    const d = db(A);
    await assertSucceeds(setDoc(consultRef(d), consultation(), MERGE));
    await assertSucceeds(getDoc(consultRef(d)));
  });

  it('la restauration liste ses patients et ses consultations', async () => {
    await seed(`agents/${A}/patients/SUR-TEST-0001`, { ...patient(), syncedAt: new Date() });
    const d = db(A);
    await assertSucceeds(getDocs(collection(d, `agents/${A}/patients`)));
    await assertSucceeds(getDocs(collection(d, `agents/${A}/consultations`)));
  });

  it('un autre agent ne peut ni lire, ni lister, ni écrire', async () => {
    await seed(`agents/${A}/patients/SUR-TEST-0001`, { ...patient(), syncedAt: new Date() });
    const b = db(B);
    await assertFails(getDoc(patientRef(b, A)));
    await assertFails(getDocs(collection(b, `agents/${A}/patients`)));
    await assertFails(setDoc(patientRef(b, A), patient(), MERGE));
    await assertFails(setDoc(consultRef(b, A), consultation(), MERGE));
  });

  it('sans connexion, tout est refusé', async () => {
    const d = db(null);
    await assertFails(getDoc(patientRef(d)));
    await assertFails(setDoc(patientRef(d), patient(), MERGE));
  });

  it('une collection inconnue est refusée', async () => {
    await assertFails(setDoc(doc(db(A), 'autre/x'), { a: 1 }));
    await assertFails(getDocs(collection(db(A), 'agents')));
  });

  it('une sous-collection non prévue sous un agent est refusée', async () => {
    const d = db(A);
    await assertFails(setDoc(doc(d, `agents/${A}/secrets/s1`), { a: 1 }));
    await assertFails(setDoc(doc(d, `agents/${A}/patients/SUR-TEST-0001/audio/a1`), { a: 1 }));
  });
});

describe('profil agent', () => {
  it('l\'inscription puis l\'enregistrement du profil (fusion) sont acceptés', async () => {
    const d = db(A);
    await assertSucceeds(setDoc(profileRef(d), signup(), MERGE));
    await assertSucceeds(setDoc(profileRef(d), profile(), MERGE));
    await assertSucceeds(getDoc(profileRef(d)));
  });

  it('l\'acceptation de l\'engagement de confidentialité (date en texte) est acceptée', async () => {
    const d = db(A);
    await assertSucceeds(setDoc(profileRef(d), signup(), MERGE));
    await assertSucceeds(
      setDoc(profileRef(d), profile({ confidentialityAcceptedAt: iso() }), MERGE),
    );
  });

  it('un autre agent ne peut pas lire ni écrire ce profil', async () => {
    await seed(`agents/${A}`, { email: 'a@exemple.test' });
    await assertFails(getDoc(profileRef(db(B), A)));
    await assertFails(setDoc(profileRef(db(B), A), signup(), MERGE));
  });

  it('un champ inconnu (ex. droits administrateur) est refusé', async () => {
    await assertFails(setDoc(profileRef(db(A)), signup({ isAdmin: true }), MERGE));
    await assertFails(setDoc(profileRef(db(A)), profile({ role_admin: true }), MERGE));
  });

  it('les champs du profil doivent être des textes de taille raisonnable', async () => {
    await assertFails(setDoc(profileRef(db(A)), profile({ fullName: 42 }), MERGE));
    await assertFails(setDoc(profileRef(db(A)), profile({ fullName: 'x'.repeat(5000) }), MERGE));
  });

  it('le profil ne peut pas être supprimé', async () => {
    await seed(`agents/${A}`, { email: 'a@exemple.test' });
    await assertFails(deleteDoc(profileRef(db(A))));
  });
});

describe('patients : contenu validé', () => {
  it('un champ inconnu (ex. chemin audio) est refusé', async () => {
    await assertFails(setDoc(patientRef(db(A)), patient({ audioPath: '/data/a.wav' }), MERGE));
  });

  it('createdBy doit être celui du compte connecté', async () => {
    await assertFails(setDoc(patientRef(db(A)), patient({ createdBy: B }), MERGE));
  });

  it('id doit correspondre au chemin du document', async () => {
    await assertFails(setDoc(patientRef(db(A)), patient({ id: 'SUR-AUTRE-0002' }), MERGE));
  });

  it('le sexe doit être F, M ou O', async () => {
    await assertSucceeds(setDoc(patientRef(db(A), A, 'p-m'), patient({ id: 'p-m', sex: 'M' }), MERGE));
    await assertSucceeds(setDoc(patientRef(db(A), A, 'p-o'), patient({ id: 'p-o', sex: 'O' }), MERGE));
    await assertFails(setDoc(patientRef(db(A)), patient({ sex: 'X' }), MERGE));
  });

  it('l\'âge doit être un entier raisonnable', async () => {
    await assertFails(setDoc(patientRef(db(A)), patient({ ageYears: -1 }), MERGE));
    await assertFails(setDoc(patientRef(db(A)), patient({ ageYears: '28' }), MERGE));
    await assertFails(setDoc(patientRef(db(A)), patient({ ageYears: 200 }), MERGE));
  });

  it('un village vide est accepté (champ facultatif dans l\'application)', async () => {
    await assertSucceeds(setDoc(patientRef(db(A)), patient({ village: '' }), MERGE));
  });

  it('un patient ne peut pas être supprimé', async () => {
    await seed(`agents/${A}/patients/SUR-TEST-0001`, { id: 'SUR-TEST-0001' });
    await assertFails(deleteDoc(patientRef(db(A))));
  });
});

describe('consultations : contenu validé', () => {
  it('un champ inconnu (ex. audio) est refusé', async () => {
    await assertFails(setDoc(consultRef(db(A)), consultation({ audio: 'AAAA' }), MERGE));
    await assertFails(setDoc(consultRef(db(A)), consultation({ audioPath: '/a.wav' }), MERGE));
  });

  it('agentId doit être celui du compte connecté', async () => {
    await assertFails(setDoc(consultRef(db(A)), consultation({ agentId: B }), MERGE));
  });

  it('id doit correspondre au chemin du document', async () => {
    await assertFails(setDoc(consultRef(db(A)), consultation({ id: 'autre' }), MERGE));
  });

  it('le mode, le consentement et les niveaux d\'urgence doivent être connus', async () => {
    await assertFails(setDoc(consultRef(db(A)), consultation({ mode: 'hacked' }), MERGE));
    await assertFails(setDoc(consultRef(db(A)), consultation({ consent: 'peut-etre' }), MERGE));
    await assertFails(setDoc(consultRef(db(A)), consultation({ urgencyFinal: 9 }), MERGE));
    await assertFails(setDoc(consultRef(db(A)), consultation({ urgencyProposed: 'high' }), MERGE));
  });

  it('une saisie manuelle sans consentement ni niveau (valeurs nulles) est acceptée', async () => {
    await assertSucceeds(
      setDoc(
        consultRef(db(A)),
        consultation({
          mode: 'manual',
          consent: null,
          consentAt: null,
          urgencyProposed: null,
          urgencyFinal: null,
          validatedAt: null,
        }),
        MERGE,
      ),
    );
  });

  it('une transcription facultative est acceptée, mais pas démesurée', async () => {
    await assertSucceeds(
      setDoc(consultRef(db(A)), consultation({ transcript: 'Elle a de la fièvre.' }), MERGE),
    );
    await assertFails(
      setDoc(consultRef(db(A), A, 'c2'), consultation({ id: 'c2', transcript: 'x'.repeat(50001) }), MERGE),
    );
  });

  it('les textes structurés doivent avoir une taille raisonnable', async () => {
    await assertFails(
      setDoc(consultRef(db(A)), consultation({ structured: 'x'.repeat(200001) }), MERGE),
    );
  });

  it('une consultation ne peut pas être supprimée', async () => {
    await seed(`agents/${A}/consultations/c1`, { id: 'c1' });
    await assertFails(deleteDoc(consultRef(db(A))));
  });
});
