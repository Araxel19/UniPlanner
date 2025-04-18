import 'package:flutter/material.dart';
import '../../core/db/sqlite_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared_widgets/general/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final SQLiteHelper _dbHelper = SQLiteHelper();

  void _handleLogin() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      final email = _emailController.text;
      final password = _passwordController.text;

      bool isLoggedIn = await _dbHelper.loginUser(email, password);

      if (isLoggedIn) {
        final user = await _dbHelper.getUserByEmail(email);

        if (user != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('username', user['username']);
          // Añade esta línea para guardar el userId:
          await prefs.setInt(
              'userId', user['id']); // Asegúrate que sea 'id' y no otro nombre

          print('Usuario logueado - ID: ${user['id']}'); // Para debug

          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Credenciales incorrectas')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false, // Evita el parpadeo al abrir teclado
        body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child:
                SafeArea(child: LayoutBuilder(builder: (context, constraints) {
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
                            'assets/images/uniplanner.jpeg',
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
                            obscureText: true,
                            decoration: const InputDecoration(
                              hintText: 'Contraseña',
                              prefixIcon: Icon(Icons.lock),
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
            }))));
  }
}
