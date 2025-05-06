import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uniplanner/providers/auth_provider.dart' as LocalAuthProvider;

class EmailVerificationScreen extends StatefulWidget {
  final User user;
  const EmailVerificationScreen({super.key, required this.user});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  late Timer _verificationTimer;
  bool _isLoading = false;
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    _startVerificationCheck();
    _checkInitialVerificationStatus();
  }

  Future<void> _checkInitialVerificationStatus() async {
    User? refreshedUser = FirebaseAuth.instance.currentUser;
    await refreshedUser?.reload();
    refreshedUser = FirebaseAuth.instance.currentUser;

    if (mounted) {
      setState(() {
        _isVerified = refreshedUser?.emailVerified ?? false;
      });
    }

    if (refreshedUser?.emailVerified == true) {
      _proceedAfterVerification(refreshedUser!);
    }
  }

  void _startVerificationCheck() {
    _verificationTimer =
        Timer.periodic(const Duration(seconds: 3), (timer) async {
      User? refreshedUser = FirebaseAuth.instance.currentUser;
      await refreshedUser?.reload();
      refreshedUser = FirebaseAuth.instance.currentUser;

      if (mounted) {
        setState(() {
          _isVerified = refreshedUser?.emailVerified ?? false;
        });
      }

      if (refreshedUser?.emailVerified == true) {
        timer.cancel();
        _proceedAfterVerification(refreshedUser!);
      }
    });
  }

  Future<void> _proceedAfterVerification(User verifiedUser) async {
    try {
      final authProvider =
          Provider.of<LocalAuthProvider.AuthProvider>(context, listen: false);

      authProvider.setUser(verifiedUser); // Método nuevo en el provider

      await authProvider.saveUserDataAfterVerification();

      if (mounted) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _resendVerificationEmail() async {
    setState(() => _isLoading = true);
    try {
      await widget.user.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Correo de verificación reenviado')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _verificationTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verificación de Correo')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.mark_email_unread,
              size: 80,
              color: Colors.orange,
            ),
            const SizedBox(height: 20),
            const Text(
              'Verifica tu correo electrónico',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'Hemos enviado un enlace de verificación a ${widget.user.email}. '
              'Por favor revisa tu bandeja de entrada y haz clic en el enlace.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              'La página se actualizará automáticamente cuando verifiques tu correo.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _resendVerificationEmail,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Reenviar correo de verificación'),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                  if (mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/login',
                      (route) => false,
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Error al cerrar sesión: ${e.toString()}')),
                    );
                  }
                }
              },
              child: const Text('Cambiar de cuenta'),
            ),
          ],
        ),
      ),
    );
  }
}
