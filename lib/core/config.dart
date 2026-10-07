/// Passer a true APRES `flutterfire configure` (voir README, etape 3).
/// A false : mode demo (connexion et synchronisation simulees, tout fonctionne hors ligne).
const bool kUseFirebase = true;

/// Decision d'equipe ouverte : envoyer la transcription corrigee a Firestore ?
/// L'audio n'est envoye qu'en MODE CONNECTE facultatif (voir plus bas).
const bool kUploadTranscript = false;

/// Passer a true UNIQUEMENT si le chiffrement SQLCipher de la base est reellement active.
const bool kDbEncrypted = false;

/// true = reconnaissance vocale reelle (Vosk, modele dans assets/models). false = texte de demonstration.
const bool kUseRealStt = true;

/// MODE CONNECTE (transcription distante, facultatif). Cle fournie a la compilation, JAMAIS dans le depot :
///   flutter run --dart-define=RODIUM_KEY=rd_sk_...   (optionnel : --dart-define=RODIUM_STT_MODEL=openai/gpt-4o-transcribe)
const String kRodiumKey = String.fromEnvironment('RODIUM_KEY');
const String kRodiumBase = 'https://api.rodiumai.io/v1';
const String kCloudSttModel = String.fromEnvironment('RODIUM_STT_MODEL',
    defaultValue: 'openai/gpt-4o-mini-transcribe');
