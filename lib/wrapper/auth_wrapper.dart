import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uniplanner/providers/auth_provider.dart' as auth_provider;
import 'package:uniplanner/features/home/home_screen.dart';
import 'package:uniplanner/features/auth/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uniplanner/providers/user_provider.dart';
import 'package:uniplanner/providers/finanzas_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:uniplanner/core/utils/google_token_helper.dart';
import 'package:uniplanner/providers/GoogleAuthProvider.dart' as local_google_auth_provider;
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _biometricChecked = false;
  bool _biometricPassed = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricLock();
  }

  Future<void> _checkBiometricLock() async {
    final prefs = await SharedPreferences.getInstance();
    final biometricEnabled = prefs.getBool('biometricLockEnabled') ?? false;

    if (biometricEnabled) {
      final localAuth = LocalAuthentication();
      final canCheck = await localAuth.canCheckBiometrics && await localAuth.isDeviceSupported();
      if (canCheck) {
        final didAuthenticate = await localAuth.authenticate(
          localizedReason: 'Desbloquea la app con tu huella digital',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );
        setState(() {
          _biometricPassed = didAuthenticate;
          _biometricChecked = true;
        });
        return;
      }
    }
    setState(() {
      _biometricPassed = true; // No se requiere biometría
      _biometricChecked = true;
    });
  }

  Future<void> _loadUserData(BuildContext context, String userId) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (userDoc.exists) {
      final data = userDoc.data()!;
      File? userImage;
      if (data['avatarBase64'] != null) {
        final bytes = base64Decode(data['avatarBase64']);
        final tempDir = Directory.systemTemp;
        userImage = File('${tempDir.path}/avatar_${DateTime.now().millisecondsSinceEpoch}.png');
        userImage.writeAsBytesSync(bytes);
      }
      Provider.of<UserProvider>(context, listen: false).setUserData(
        userName: data['displayName']?.split(' ').first.toUpperCase() ?? 'USUARIO',
        emoji: data['avatarEmoji'] ?? '👤',
        userImage: userImage,
        userId: userId,
      );
    }

    // --- Cargar finanzas ---
    final finanzasProvider = Provider.of<FinanzasProvider>(context, listen: false);
    final transactions = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .orderBy('date', descending: true)
        .limit(100)
        .get();

    double newBalance = 0;
    final List<Map<String, dynamic>> movimientos = [];

    for (final doc in transactions.docs) {
      final data = doc.data();
      final amount = data['amount'] as double;
      final isIncome = data['isIncome'] as bool;

      if (isIncome) {
        newBalance += amount;
      } else {
        newBalance -= amount;
      }

      movimientos.add({...data, 'id': doc.id});
    }

    finanzasProvider.setBalance(newBalance);
    finanzasProvider.setMovimientos(movimientos);

    // Cargar accessToken de Google
    await initializeGoogleToken(context);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<auth_provider.AuthProvider>(context);

    if (!_biometricChecked) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_biometricPassed) {
      return const Scaffold(
        body: Center(child: Text('Autenticación biométrica requerida para acceder')),
      );
    }

    if (!authProvider.initialAuthCheckComplete) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (authProvider.user != null) {
      return FutureBuilder(
        future: _loadUserData(context, authProvider.user!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return const HomeScreen();
          }
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      );
    } else {
      return const LoginScreen();
    }
  }
}

// ...dentro de tu lógica de inicialización, por ejemplo en initState o en un FutureBuilder:
Future<void> initializeGoogleToken(BuildContext context) async {
  final token = await loadGoogleAccessToken();
  if (token != null) {
    Provider.of<local_google_auth_provider.GoogleAuthProvider>(context, listen: false).setAccessToken(token);
  }
}