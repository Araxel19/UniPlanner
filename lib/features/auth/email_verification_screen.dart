import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uniplanner/providers/auth_provider.dart' as LocalAuthProvider;
import 'package:uniplanner/shared_widgets/general/app_routes.dart'; // Importa AppRoutes

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
      
      // Cambio clave: Usamos reloadUser() en lugar de setUser()
      await authProvider.reloadUser();
      await authProvider.saveUserDataAfterVerification();

      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.login, // Usamos la constante de AppRoutes
          (route) => false,
        );
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
      appBar: AppBar(
        title: const Text('Verificación de Correo'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.mark_email_unread_outlined,
              size: 80,
              color: Colors.orange,
            ),
            const SizedBox(height: 24),
            Text(
              'Verifica tu correo electrónico',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'Hemos enviado un enlace de verificación a:',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.user.email ?? '',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              'Por favor revisa tu bandeja de entrada y haz clic en el enlace de verificación.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Esta pantalla se actualizará automáticamente cuando completes la verificación.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _resendVerificationEmail,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('REENVIAR CORREO DE VERIFICACIÓN'),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                  if (mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRoutes.login,
                      (route) => false,
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al cerrar sesión: ${e.toString()}'),
                      ),
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