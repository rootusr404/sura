import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  FirebaseAuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String region,
    required String district,
    required String healthPost,
    required String clinicalRole,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw StateError('Le compte a été créé sans identifiant utilisateur.');
    }

    await _firestore.collection('agents').doc(user.uid).set({
      'agent_id': user.uid,
      'email': email.trim(),
      'prenom': firstName.trim(),
      'nom': lastName.trim(),
      'telephone_professionnel': phone.trim(),
      'region': region.trim(),
      'district': district.trim(),
      'poste_de_sante': healthPost.trim(),
      'role_clinique': clinicalRole.trim(),
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> login({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
  }

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
