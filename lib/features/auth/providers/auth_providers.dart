import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/firebase_auth_service.dart';
import '../services/pin_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/foundation.dart';

class PinSession extends ChangeNotifier {
  bool _isUnlocked = false;

  bool get isUnlocked => _isUnlocked;

  void unlock() {
    _isUnlocked = true;
    notifyListeners();
  }

  void lock() {
    _isUnlocked = false;
    notifyListeners();
  }
}

final pinSessionProvider = Provider<PinSession>((ref) {
  final session = PinSession();
  ref.onDispose(session.dispose);
  return session;
});

final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) => FirebaseAuthService());

final pinServiceProvider = Provider<PinService>((ref) => PinService());
final currentAgentIdProvider = Provider<String?>((ref) => FirebaseAuth.instance.currentUser?.uid);
