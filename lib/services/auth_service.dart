import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authChanges => _auth.authStateChanges();

  Future<void> register(String nama, String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    await cred.user!.updateDisplayName(nama);
    await _db.collection('users').doc(cred.user!.uid).set({
      'nama': nama,
      'email': email,
      'poin': 0,
      'role': 'warga',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> login(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<void> logout() => _auth.signOut();

  Stream<AppUser?> userStream(String uid) =>
      _db.collection('users').doc(uid).snapshots().map(
          (s) => s.exists ? AppUser.fromMap(uid, s.data()!) : null);
}
