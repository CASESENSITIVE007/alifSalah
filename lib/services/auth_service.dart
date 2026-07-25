import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/models.dart';

/// Phone-OTP authentication + the current user's profile document.
class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static User? get currentUser => _auth.currentUser;
  static Stream<User?> get authState => _auth.authStateChanges();

  static Stream<AppUser?> get profileStream {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);
    return _db.collection('users').doc(user.uid).snapshots().map(
        (doc) => doc.exists ? AppUser.fromDoc(doc) : null);
  }

  /// Starts phone verification. [onCodeSent] receives the verificationId.
  static Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String message) onError,
    required void Function() onAutoVerified,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (credential) async {
        await _auth.signInWithCredential(credential);
        onAutoVerified();
      },
      verificationFailed: (e) => onError(e.message ?? 'Verification failed'),
      codeSent: (verificationId, _) => onCodeSent(verificationId),
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  static Future<UserCredential> verifyOtp(
      String verificationId, String smsCode) {
    final credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: smsCode);
    return _auth.signInWithCredential(credential);
  }

  static Future<bool> hasProfile() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    final doc = await _db.collection('users').doc(user.uid).get();
    return doc.exists;
  }

  static Future<void> createProfile({
    required String name,
    required UserRole role,
  }) async {
    final user = _auth.currentUser!;
    await _db.collection('users').doc(user.uid).set(AppUser(
          uid: user.uid,
          name: name,
          phone: user.phoneNumber ?? '',
          role: role,
          joinedMasjidIds: const [],
        ).toMap());
  }

  static Future<void> setAdhaanAlerts(bool enabled) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _db
        .collection('users')
        .doc(user.uid)
        .update({'adhaanAlertsEnabled': enabled});
  }

  static Future<void> signOut() => _auth.signOut();
}
