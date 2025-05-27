import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:uniplanner/core/utils/google_token_helper.dart';
import '../../shared_widgets/general/app_routes.dart';
import 'package:uniplanner/providers/auth_provider.dart' as local_auth;
import 'package:uniplanner/services/auth_service.dart'; // Ajusta el nombre de tu proyecto
import 'package:flutter/material.dart';
import 'package:uniplanner/services/biometric_auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uniplanner/providers/user_provider.dart';
import 'package:uniplanner/providers/GoogleAuthProvider.dart' as local_google_auth;
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

Future<void> _guardarAccesoBiometricoPermitido() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('biometrico_activado', true);
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  final AuthService _authService = AuthService();
  final BiometricAuthService _biometricService = BiometricAuthService();

  void _handleLogin() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim().toLowerCase();
      final password = _passwordController.text;

      final authProvider = Provider.of<local_auth.AuthProvider>(context, listen: false);
      await authProvider.login(email, password);

      if (authProvider.user != null && authProvider.errorMessage == null) {
        await _guardarAccesoBiometricoPermitido(); // ← Guarda que el usuario activó huella

        // Aquí comienza la nueva lógica
        final user = authProvider.user; // o el user de Google
        if (user != null) {
          // Obtén los datos del usuario desde Firestore
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (userDoc.exists) {
            final data = userDoc.data()!;
            // Guarda los datos en el provider
            Provider.of<UserProvider>(context, listen: false).setUserData(
              userName: data['displayName']?.split(' ').first.toUpperCase() ?? 'USUARIO',
              emoji: data['avatarEmoji'] ?? '👤',
              userImage: data['avatarBase64'] != null ? _base64ToImage(data['avatarBase64']) : null,
              userId: user.uid,
            );
            // Aquí puedes hacer lo mismo con los otros providers (finanzas, notas, etc.)
          }
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      } else if (authProvider.errorMessage != null) {
        _showTopSnackBar(authProvider.errorMessage!);
      }
    }
  }

  // Convertir Base64 a imagen
  File? _base64ToImage(String? base64String) {
    if (base64String == null) return null;
    try {
      final bytes = base64Decode(base64String);
      final tempDir = Directory.systemTemp;
      final file = File(
          '${tempDir.path}/avatar_${DateTime.now().millisecondsSinceEpoch}.png');
      file.writeAsBytesSync(bytes);
      return file;
    } catch (e) {
      debugPrint('Error al convertir Base64 a imagen: $e');
      return null;
    }
  }

  void _showTopSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 100,
          left: 20,
          right: 20,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          Image.asset(
                            'assets/images/uniplannerlogo.png',
                            height: 138,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 60),
                          const Text(
                            'Iniciar sesión',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 36),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              hintText: 'Correo',
                              prefixIcon: Icon(Icons.email),
                            ),
                            validator: (value) =>
                                value!.isEmpty ? 'Ingrese su correo' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: 'Contraseña',
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) =>
                                value!.isEmpty ? 'Ingrese su contraseña' : null,
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text('Continuar'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: Image.asset(
                                'assets/images/google_logo.png',
                                height: 24,
                              ),
                              label: const Text('Iniciar sesión con Google'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                              onPressed: () async {
                                final GoogleSignInResult result = await signInWithGoogle();
                                final user = result.user;
                                final accessToken = result.accessToken;

                                if (user != null && accessToken != null) {
                                  // Guarda el accessToken en el Provider
                                  Provider.of<local_google_auth.GoogleAuthProvider>(context, listen: false)
                                      .setAccessToken(accessToken);
                                  await saveGoogleAccessToken(accessToken);

                                  // Obtén los datos del usuario desde Firestore
                                  final userDoc = await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(user.uid)
                                      .get();

                                  if (userDoc.exists) {
                                    final data = userDoc.data()!;
                                    Provider.of<UserProvider>(context, listen: false).setUserData(
                                      userName: data['displayName']?.split(' ').first.toUpperCase() ?? 'USUARIO',
                                      emoji: data['avatarEmoji'] ?? '👤',
                                      userImage: data['avatarBase64'] != null ? _base64ToImage(data['avatarBase64']) : null,
                                      userId: user.uid,
                                    );
                                  }
                                  Navigator.pushReplacementNamed(context, AppRoutes.home);
                                } else {
                                  _showTopSnackBar('Error al iniciar sesión con Google');
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.fingerprint),
                              label: const Text('Iniciar con huella'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[900],
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              onPressed: () async {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                final biometricoActivado =
                                    prefs.getBool('biometrico_activado') ??
                                        false;

                                if (!biometricoActivado) {
                                  _showTopSnackBar(
                                      'Primero inicia sesión con correo y contraseña');
                                  return;
                                }

                                bool isAuthenticated = await _biometricService
                                    .authenticateWithBiometrics();
                                if (isAuthenticated) {
                                  Navigator.pushReplacementNamed(
                                      context, AppRoutes.home);
                                } else {
                                  _showTopSnackBar(
                                      'No se pudo autenticar con huella');
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () => Navigator.pushNamed(
                                context, AppRoutes.register),
                            child: const Text('Crear cuenta nueva'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class GoogleSignInResult {
  final User? user;
  final String? accessToken;
  GoogleSignInResult({this.user, this.accessToken});
}

// Define the GoogleSignIn instance
final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: [
    'email',
    'https://www.googleapis.com/auth/calendar.readonly',
  ],
);
final FirebaseAuth _auth = FirebaseAuth.instance;

Future<GoogleSignInResult> signInWithGoogle() async {
  final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
  if (googleUser == null) return GoogleSignInResult(user: null, accessToken: null);

  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  final accessToken = googleAuth.accessToken;

  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  final userCredential = await _auth.signInWithCredential(credential);

  return GoogleSignInResult(user: userCredential.user, accessToken: accessToken);
}
