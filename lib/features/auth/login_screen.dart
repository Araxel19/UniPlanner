import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:uniplanner/core/utils/google_token_helper.dart';
import '../../shared_widgets/general/app_routes.dart';
import 'package:uniplanner/providers/auth_provider.dart' as local_auth;
import 'package:uniplanner/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uniplanner/providers/user_provider.dart';
import 'package:uniplanner/providers/GoogleAuthProvider.dart'
    as local_google_auth;
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoading = false; // NUEVO

  final AuthService _authService = AuthService();

  void _handleLogin() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true); // NUEVO
      final email = _emailController.text.trim().toLowerCase();
      final password = _passwordController.text;

      final authProvider =
          Provider.of<local_auth.AuthProvider>(context, listen: false);
      await authProvider.login(email, password);

      if (authProvider.user != null && authProvider.errorMessage == null) {
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
              userName: data['displayName']?.split(' ').first.toUpperCase() ??
                  'USUARIO',
              emoji: data['avatarEmoji'] ?? '👤',
              userImage: data['avatarBase64'] != null
                  ? _base64ToImage(data['avatarBase64'])
                  : null,
              userId: user.uid,
            );
            // Aquí puedes hacer lo mismo con los otros providers (finanzas, notas, etc.)
          }
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      } else if (authProvider.errorMessage != null) {
        _showTopSnackBar(authProvider.errorMessage!);
      }
      setState(() => _isLoading = false); // NUEVO
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final backgroundColor = Theme.of(context).colorScheme.background;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Fondo degradado adaptado al tema
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF232526), const Color(0xFF414345)]
                    : [const Color(0xFFEDE7F6), const Color.fromARGB(255, 199, 192, 194)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/uniplannerlogo.png',
                        height: 90,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Bienvenido',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Inicia sesión para continuar',
                        style: TextStyle(
                          fontSize: 15,
                          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'Correo',
                          prefixIcon: const Icon(Icons.email),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF2A2D37) : Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingrese su correo';
                          }
                          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!emailRegex.hasMatch(value)) {
                            return 'Correo inválido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: 'Contraseña',
                          prefixIcon: const Icon(Icons.lock),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF2A2D37) : Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingrese su contraseña';
                          }
                          if (value.length < 8) {
                            return 'Mínimo 8 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Continuar', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: Divider()),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text('o'),
                          ),
                          Expanded(child: Divider()),
                        ],
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
                            backgroundColor: isDark ? const Color(0xFF232526) : Colors.white,
                            foregroundColor: isDark ? Colors.white : Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: primaryColor),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () async {
                            final GoogleSignInResult result =
                                await signInWithGoogle();
                            final user = result.user;
                            final accessToken = result.accessToken;

                            if (user != null && accessToken != null) {
                              Provider.of<
                                          local_google_auth
                                          .GoogleAuthProvider>(context,
                                      listen: false)
                                  .setAccessToken(accessToken);
                              await saveGoogleAccessToken(accessToken);

                              final userDoc = await FirebaseFirestore
                                  .instance
                                  .collection('users')
                                  .doc(user.uid)
                                  .get();

                              if (userDoc.exists) {
                                final data = userDoc.data()!;
                                Provider.of<UserProvider>(context,
                                        listen: false)
                                    .setUserData(
                                  userName: data['displayName']
                                          ?.split(' ')
                                          .first
                                          .toUpperCase() ??
                                      'USUARIO',
                                  emoji: data['avatarEmoji'] ?? '👤',
                                  userImage: data['avatarBase64'] != null
                                      ? _base64ToImage(data['avatarBase64'])
                                      : null,
                                  userId: user.uid,
                                );
                              }
                              Navigator.pushReplacementNamed(
                                  context, AppRoutes.home);
                            } else {
                              _showTopSnackBar(
                                  'Error al iniciar sesión con Google');
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.pushNamed(context, AppRoutes.register),
                          child: Text(
                            '¿No tienes cuenta? Crear una cuenta',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
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
  if (googleUser == null)
    return GoogleSignInResult(user: null, accessToken: null);

  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  final accessToken = googleAuth.accessToken;

  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  final userCredential = await _auth.signInWithCredential(credential);

  return GoogleSignInResult(
      user: userCredential.user, accessToken: accessToken);
}
