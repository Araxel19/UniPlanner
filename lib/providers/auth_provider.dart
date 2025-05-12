import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uniplanner/core/db/firestore_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  bool _emailSent = false;
  bool _initialAuthCheckComplete = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get emailSent => _emailSent;
  bool get initialAuthCheckComplete => _initialAuthCheckComplete;

  AuthProvider() {
    // Escuchar cambios en el estado de autenticación
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _user = user;
      _initialAuthCheckComplete = true;
      notifyListeners();
    });
  }

  Future<void> login(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final authResult = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      _user = authResult.user;

      if (_user != null && !_user!.emailVerified) {
        await _resendVerificationEmail();
        throw 'Por favor verifica tu correo electrónico antes de iniciar sesión';
      }

      // Guardar datos del usuario en Firestore si es necesario
      if (_user != null) {
        await FirestoreService().saveUserData(_user!.uid, {
          'lastLogin': DateTime.now(),
          'email': _user!.email,
          'displayName': _user!.displayName,
        });
      }
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getErrorMessage(e.code);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String email, String password, String username) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _emailSent = false;
      notifyListeners();

      // 1. Crear usuario en Firebase Auth
      final authResult =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      _user = authResult.user;

      // 2. Actualizar display name (espera a que complete)
      await _user?.updateDisplayName(username);

      // 3. Enviar email de verificación (con await)
      await _user?.sendEmailVerification();
      _emailSent = true;

      // 4. Notificar cambios antes de salir
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getErrorMessage(e.code);
      notifyListeners();
      throw Exception(_errorMessage);
    } catch (e) {
      _errorMessage = 'Error en el registro: ${e.toString()}';
      notifyListeners();
      throw Exception(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveUserDataAfterVerification() async {
    try {
      // 1. Recargar usuario para obtener último estado
      await _user?.reload();

      // 2. Verificar que el email está confirmado
      if (_user == null || !_user!.emailVerified) {
        throw Exception('El email no ha sido verificado aún');
      }

      // 3. Guardar datos en Firestore
      await FirestoreService().saveUserData(_user!.uid, {
        'email': _user!.email,
        'displayName': _user!.displayName ?? 'Usuario',
        'createdAt': DateTime.now(),
        'emailVerified': true,
        'lastLogin': DateTime.now(),
        'themePreference': 'light',
      });

      // 4. Actualizar estado local
      _errorMessage = null;
      notifyListeners();
    } on FirebaseException catch (e) {
      _errorMessage = 'Error de Firebase: ${e.message}';
      notifyListeners();
      rethrow;
    } catch (e) {
      _errorMessage = 'Error inesperado: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _resendVerificationEmail() async {
    try {
      if (_user != null && !_user!.emailVerified) {
        await _user!.sendEmailVerification();
        _emailSent = true;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error al enviar el correo de verificación';
    }
  }

  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      await FirebaseAuth.instance.signOut();
      _user = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Error al cerrar sesión';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reloadUser() async {
    try {
      await _user?.reload();
      _user = FirebaseAuth.instance.currentUser;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al actualizar los datos del usuario';
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
      _emailSent = true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getErrorMessage(e.code);
    } catch (e) {
      _errorMessage = 'Error al enviar el correo de recuperación';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Usuario no encontrado';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'email-already-in-use':
        return 'El correo ya está en uso';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres';
      case 'invalid-email':
        return 'Correo electrónico inválido';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde';
      case 'operation-not-allowed':
        return 'Operación no permitida';
      case 'network-request-failed':
        return 'Error de conexión. Verifica tu internet';
      default:
        return 'Ocurrió un error inesperado';
    }
  }
}