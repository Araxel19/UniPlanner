import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get user => _auth.authStateChanges();

  Future<User?> registerWithEmailAndPassword(
      String email, String password, String username) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await result.user?.updateDisplayName(username);
      await sendVerificationEmail(); // Envía verificación automáticamente al registrar
      return result.user;
    } catch (e) {
      print("Error en registro: $e");
      return null;
    }
  }

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Verificar si el correo está verificado antes de permitir login
      if (result.user != null && !result.user!.emailVerified) {
        await sendVerificationEmail();
        throw Exception('Por favor verifica tu correo electrónico antes de iniciar sesión');
      }
      
      return result.user;
    } catch (e) {
      print("Error en login: $e");
      rethrow; // Relanzamos la excepción para manejarla en la UI
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> sendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<bool> verifyEmail() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    
    // Recargar el usuario para obtener el estado más reciente de verificación
    await user.reload();
    final updatedUser = _auth.currentUser;
    
    return updatedUser?.emailVerified ?? false;
  }

  // Método para verificar si el email está verificado
  bool isEmailVerified() {
    return _auth.currentUser?.emailVerified ?? false;
  }
}