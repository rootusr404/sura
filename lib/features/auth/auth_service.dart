import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/config.dart';

enum PinResult { ok, wrong, locked }

/// Firebase Auth n'est utilise qu'a la premiere connexion (R14). Ensuite : PIN local.
/// Le mot de passe n'est JAMAIS stocke (R13) ; on ne stocke que l'empreinte salee du PIN.
class AuthService {
  final _s = const FlutterSecureStorage();

  Future<bool> isLoggedIn() async => kUseFirebase
      ? FirebaseAuth.instance.currentUser != null
      : (await _s.read(key: 'demo_user')) != null;

  String get agentId => kUseFirebase
      ? (FirebaseAuth.instance.currentUser?.uid ?? 'unknown')
      : 'demo-agent';

  Future<void> signIn(String email, String password) async {
    if (kUseFirebase) {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } else {
      await _s.write(key: 'demo_user', value: email);
    }
  }

  Future<void> signUp(String email, String password) async {
    if (kUseFirebase) {
      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await FirebaseFirestore.instance
          .collection('agents')
          .doc(cred.user!.uid)
          .set({'email': email, 'createdAt': FieldValue.serverTimestamp()});
    } else {
      await _s.write(key: 'demo_user', value: email);
    }
  }

  Future<void> resetPassword(String email) async {
    if (kUseFirebase) {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    }
  }

  Future<void> signOut() async {
    if (kUseFirebase) {
      await FirebaseAuth.instance.signOut();
    } else {
      await _s.delete(key: 'demo_user');
    }
  }

  // ---- PIN local (6 chiffres)
  String _hash(String salt, String pin) =>
      sha256.convert(utf8.encode('$salt:$pin')).toString();

  Future<bool> hasPin() async => (await _s.read(key: 'pin_hash')) != null;

  Future<void> setPin(String pin) async {
    final salt = List.generate(16, (_) => Random.secure().nextInt(256))
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
    await _s.write(key: 'pin_salt', value: salt);
    await _s.write(key: 'pin_hash', value: _hash(salt, pin));
    await _s.write(key: 'pin_fails', value: '0');
  }

  Future<PinResult> verifyPin(String pin) async {
    final until =
        int.tryParse(await _s.read(key: 'pin_locked_until') ?? '') ?? 0;
    if (DateTime.now().millisecondsSinceEpoch < until) return PinResult.locked;
    final salt = await _s.read(key: 'pin_salt') ?? '';
    final h = await _s.read(key: 'pin_hash');
    if (h == _hash(salt, pin)) {
      await _s.write(key: 'pin_fails', value: '0');
      return PinResult.ok;
    }
    final fails =
        (int.tryParse(await _s.read(key: 'pin_fails') ?? '0') ?? 0) + 1;
    await _s.write(key: 'pin_fails', value: '$fails');
    if (fails >= 5) {
      // Verrouillage progressif (valeurs a valider en equipe) : 30 s, 60 s, 120 s...
      final secs = 30 * (1 << (fails - 5).clamp(0, 6).toInt());
      await _s.write(
        key: 'pin_locked_until',
        value: '${DateTime.now().millisecondsSinceEpoch + secs * 1000}',
      );
      return PinResult.locked;
    }
    return PinResult.wrong;
  }
}

class Session {
  const Session(
      {this.ready = false,
      this.loggedIn = false,
      this.hasPin = false,
      this.unlocked = false});
  final bool ready;
  final bool loggedIn;
  final bool hasPin;
  final bool unlocked;

  Session copy({bool? loggedIn, bool? hasPin, bool? unlocked}) => Session(
        ready: true,
        loggedIn: loggedIn ?? this.loggedIn,
        hasPin: hasPin ?? this.hasPin,
        unlocked: unlocked ?? this.unlocked,
      );
}

class SessionNotifier extends Notifier<Session> {
  AuthService get _a => ref.read(authProvider);

  @override
  Session build() {
    Future.microtask(_init);
    return const Session();
  }

  Future<void> _init() async {
    state = Session(
        ready: true,
        loggedIn: await _a.isLoggedIn(),
        hasPin: await _a.hasPin());
  }

  Future<void> loggedIn() async =>
      state = state.copy(loggedIn: true, hasPin: await _a.hasPin());
  void unlock() => state = state.copy(unlocked: true);
  void lock() => state = state.copy(unlocked: false);
  void pinSet() => state = state.copy(hasPin: true, unlocked: true);
  Future<void> logout() async {
    await _a.signOut();
    state = state.copy(loggedIn: false, unlocked: false);
  }
}

final authProvider = Provider<AuthService>((ref) => AuthService());
final sessionProvider =
    NotifierProvider<SessionNotifier, Session>(SessionNotifier.new);

final agentIdProvider = Provider<String>((ref) {
  ref.watch(sessionProvider);
  return ref.read(authProvider).agentId;
});
