import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print('Sign Up Error: $e');
      return null;
    }
  }
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      return null;
    }
  }
  Future<void> signOut() async {
    await _auth.signOut();
  }
  Future<bool> isLoggedIN() async {
    if(_auth.currentUser != null && _auth.currentUser!.emailVerified) {
      return true;
    }
    return false;
  }
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
