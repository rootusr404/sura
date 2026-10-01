class AuthUser {
  const AuthUser({required this.id, required this.email});
  final String id;
  final String email;
}

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Propriétaire : Membre 4 (S-02). Implémentation finale : Firebase Auth.
/// R13 : le mot de passe n'est jamais stocké en clair. R14 : 1ère connexion en ligne.
abstract class AuthService {
  Future<AuthUser?> currentUser();
  Future<AuthUser> register({required String email, required String password});
  Future<AuthUser> signIn({required String email, required String password});
  Future<void> sendPasswordReset(String email);
  Future<void> signOut();
}
