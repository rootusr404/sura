import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/config.dart';
import '../auth/auth_service.dart';
import 'profile_model.dart';

/// Profil : copie LOCALE (consultable hors ligne) + envoi vers agents/{uid} des que possible.
class ProfileService {
  static String _key(String uid) => 'agent_profile_$uid';
  static String _dirty(String uid) => 'agent_profile_dirty_$uid';

  static Future<AgentProfile> load(String uid) async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_key(uid));
    if (raw != null) {
      return AgentProfile.fromMap(jsonDecode(raw) as Map<String, dynamic>);
    }
    // Pas de copie locale (nouvel appareil, ancien compte) : on tente de recuperer le profil en ligne.
    if (kUseFirebase) {
      try {
        final d = await FirebaseFirestore.instance
            .collection('agents')
            .doc(uid)
            .get()
            .timeout(const Duration(seconds: 5));
        final m = d.data();
        if (m != null && '${m['fullName'] ?? ''}'.isNotEmpty) {
          final prof = AgentProfile.fromMap(m);
          await p.setString(_key(uid), jsonEncode(prof.toMap()));
          return prof;
        }
      } catch (_) {}
    }
    final email = kUseFirebase
        ? (FirebaseAuth.instance.currentUser?.email ?? '')
        : (await const FlutterSecureStorage().read(key: 'demo_user') ?? '');
    return AgentProfile(email: email);
  }

  static Future<void> save(String uid, AgentProfile prof) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_key(uid), jsonEncode(prof.toMap()));
    if (kUseFirebase) {
      await p.setBool(_dirty(uid), true);
      unawaited(pushIfDirty(uid));
    }
  }

  /// Appele apres chaque modification et par la synchronisation (retour du reseau).
  static Future<void> pushIfDirty(String uid) async {
    if (!kUseFirebase) return;
    final p = await SharedPreferences.getInstance();
    if (p.getBool(_dirty(uid)) != true) return;
    final raw = p.getString(_key(uid));
    if (raw == null) return;
    final prof = AgentProfile.fromMap(jsonDecode(raw) as Map<String, dynamic>);
    try {
      await FirebaseFirestore.instance.collection('agents').doc(uid).set({
        ...prof.toMap(),
        'agentCode': agentCode(uid),
        'profileUpdatedAt': FieldValue.serverTimestamp()
      }, SetOptions(merge: true)).timeout(const Duration(seconds: 15));
      await p.setBool(_dirty(uid), false);
    } catch (_) {
      // Reste "a envoyer" : nouvelle tentative au prochain retour du reseau.
    }
  }
}

final profileProvider = FutureProvider.autoDispose<AgentProfile>((ref) async {
  final uid = ref.watch(agentIdProvider);
  return ProfileService.load(uid);
});
