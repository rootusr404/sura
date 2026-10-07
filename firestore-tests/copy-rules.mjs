// Copie les règles réelles (../firestore.rules) dans ce dossier avant chaque test :
// l'émulateur exige que le fichier soit dans le dossier du projet de test.
import { copyFileSync } from 'node:fs';
copyFileSync('../firestore.rules', './firestore.rules');
