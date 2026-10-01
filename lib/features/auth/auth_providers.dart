import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sura/domain/contracts/auth_service.dart';
import 'package:sura/domain/fakes/fake_services.dart';

// PROPRIÉTAIRE : Membre 4 (S-02). Remplacer par FirebaseAuthService.
final authServiceProvider = Provider<AuthService>((ref) => FakeAuthService());

/// Identifiant de l'agent connecté, utilisé pour créer patients/consultations.
/// Membre 4 : le dériver de l'utilisateur authentifié.
final currentAgentIdProvider = Provider<String>(
  (ref) => FakeAuthService.user.id,
);
