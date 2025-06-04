import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:uniplanner/core/utils/notification_helper.dart';
import '../../providers/theme_provider.dart';
import '../../shared_widgets/general/configuracion_menu_item.dart';
import '../home/home_screen.dart';
import '../../shared_widgets/general/app_routes.dart';
import 'dart:async';
import 'package:uniplanner/providers/GoogleAuthProvider.dart'
    as local_auth_provider;

class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({Key? key}) : super(key: key);

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  String _userName = '';
  File? _userImage;
  String _selectedEmoji = '👤';
  final ImagePicker _picker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LocalAuthentication _localAuth = LocalAuthentication();
  String _lastLoginStatus = 'Cargando...';
  StreamSubscription<DocumentSnapshot>? _userDataSubscription;
  bool _isBiometricSetupChecked = false;
  bool _biometricLockEnabled = false;

  final List<String> predefinedAvatars = [
    '😀',
    '😎',
    '🧑‍💻',
    '👩‍🎓',
    '🦊',
    '🐱',
    '🐶',
    '🦁',
    '👾',
    '🤖',
    '👻',
    '🦄',
    '🐵',
    '🐧',
    '🐙',
    '🦉'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadThemePreference();
    _userDataSubscription?.cancel();

    // Verificar configuración biométrica al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBiometricSetup();
    });
  }

  @override
  void dispose() {
    _userDataSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadThemePreference() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    if (userDoc.exists) {
      final themePreference = userDoc.data()?['themePreference'];
      if (themePreference != null) {
        final themeProvider =
            Provider.of<ThemeProvider>(context, listen: false);
        themeProvider.toggleTheme(themePreference == 'dark');
      }
    }
  }

  // Verificar la configuración del dispositivo al inicio
  Future<void> _checkBiometricSetup() async {
    try {
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();

      if (!isAvailable || !isDeviceSupported) {
        debugPrint('Biometría no disponible en este dispositivo');
        setState(() {
          _isBiometricSetupChecked = true;
        });
        return;
      }

      final List<BiometricType> availableBiometrics =
          await _localAuth.getAvailableBiometrics();

      if (availableBiometrics.isEmpty) {
        debugPrint('No hay métodos biométricos configurados');
      } else {
        debugPrint('Métodos biométricos disponibles: $availableBiometrics');
      }

      setState(() {
        _isBiometricSetupChecked = true;
      });
    } catch (e) {
      debugPrint('Error verificando configuración biométrica: $e');
      setState(() {
        _isBiometricSetupChecked = true;
      });
    }
  }

  // Verificar disponibilidad de autenticación biométrica con mejor manejo de errores
  Future<bool> _isBiometricAvailable() async {
    try {
      // Verificar si el contexto aún está montado
      if (!mounted) return false;

      final bool isAvailable = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();

      if (!isAvailable || !isDeviceSupported) {
        return false;
      }

      final List<BiometricType> availableBiometrics =
          await _localAuth.getAvailableBiometrics();

      return availableBiometrics.isNotEmpty;
    } catch (e) {
      debugPrint('Error verificando biometría: $e');
      return false;
    }
  }

  // Autenticar con biometría con mejor manejo de errores y contexto
  Future<bool> _authenticateWithBiometrics() async {
    try {
      // Verificar que el widget esté montado antes de continuar
      if (!mounted) return false;

      // Esperar un frame para asegurar que el contexto esté disponible
      await Future.delayed(const Duration(milliseconds: 100));

      if (!mounted) return false;

      final bool isAvailable = await _isBiometricAvailable();

      if (!isAvailable) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'La autenticación biométrica no está disponible o configurada en este dispositivo'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return false;
      }

      // Usar un contexto más específico para la autenticación
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason:
            'Verifica tu identidad para acceder a la configuración de usuario',
        authMessages: const [
          AndroidAuthMessages(
            signInTitle: 'Autenticación requerida',
            cancelButton: 'Cancelar',
            deviceCredentialsRequiredTitle: 'Credenciales requeridas',
            deviceCredentialsSetupDescription:
                'Configura tu método de autenticación en la configuración del dispositivo',
            goToSettingsButton: 'Ir a configuración',
            goToSettingsDescription:
                'Configura tu huella dactilar, reconocimiento facial o PIN en la configuración del dispositivo',
          ),
        ],
        options: const AuthenticationOptions(
          biometricOnly: false, // Permitir PIN/patrón como alternativa
          stickyAuth: true,
          sensitiveTransaction: false,
        ),
      );

      return didAuthenticate;
    } catch (e) {
      debugPrint('Error en autenticación biométrica: $e');

      if (!mounted) return false;

      // Manejar errores específicos
      String errorMessage = 'Error en la autenticación';

      if (e.toString().contains('UserCancel')) {
        // Usuario canceló la autenticación
        return false;
      } else if (e.toString().contains('NotAvailable')) {
        errorMessage = 'Autenticación biométrica no disponible';
      } else if (e.toString().contains('NotEnrolled')) {
        errorMessage =
            'No hay métodos de autenticación configurados. Ve a Configuración del dispositivo para configurar huella dactilar, reconocimiento facial o PIN.';
      } else if (e.toString().contains('no_fragment_activity')) {
        errorMessage =
            'Error de configuración de la aplicación. Por favor, reinicia la aplicación.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          action: e.toString().contains('NotEnrolled')
              ? SnackBarAction(
                  label: 'Configurar',
                  onPressed: () {
                    // Aquí podrías abrir la configuración del sistema
                    // O mostrar instrucciones adicionales
                  },
                )
              : null,
        ),
      );
      return false;
    }
  }

  // Función alternativa para mostrar diálogo sin autenticación biométrica
  Future<void> _showUserConfigDialogWithPassword() async {
    final passwordController = TextEditingController();
    bool isVerifying = false;
    bool obscurePassword = true;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.lock_outline),
              SizedBox(width: 8),
              Text('Verificación requerida'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Ingresa tu contraseña actual para continuar:'),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                enabled: !isVerifying,
                decoration: InputDecoration(
                  labelText: 'Contraseña actual',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(obscurePassword
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                  border: const OutlineInputBorder(),
                ),
                onSubmitted: isVerifying
                    ? null
                    : (_) async {
                        // Verificar contraseña al presionar Enter
                        if (passwordController.text.isNotEmpty) {
                          setState(() => isVerifying = true);
                          final verified = await _verifyCurrentPassword(
                              passwordController.text);
                          if (verified && context.mounted) {
                            Navigator.of(context).pop(true);
                          } else {
                            setState(() => isVerifying = false);
                          }
                        }
                      },
              ),
              if (isVerifying) ...[
                const SizedBox(height: 16),
                const CircularProgressIndicator(),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed:
                  isVerifying ? null : () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: isVerifying || passwordController.text.isEmpty
                  ? null
                  : () async {
                      setState(() => isVerifying = true);
                      final verified =
                          await _verifyCurrentPassword(passwordController.text);
                      if (verified && context.mounted) {
                        Navigator.of(context).pop(true);
                      } else {
                        setState(() => isVerifying = false);
                      }
                    },
              child: const Text('Verificar'),
            ),
          ],
        ),
      ),
    );

    passwordController.dispose();

    if (result == true && mounted) {
      showDialog(
        context: context,
        builder: (context) => _UserConfigDialog(
          currentUserName: _userName,
          onUserUpdated: _loadUserData,
          firestore: _firestore,
          auth: _auth,
        ),
      );
    }
  }

  // Verificar contraseña actual
  Future<bool> _verifyCurrentPassword(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) return false;

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
      return true;
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Contraseña incorrecta';
        if (e.toString().contains('wrong-password')) {
          errorMessage = 'La contraseña es incorrecta';
        } else if (e.toString().contains('too-many-requests')) {
          errorMessage = 'Demasiados intentos. Intenta más tarde.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }

  // Mostrar diálogo de configuración de usuario con múltiples opciones de autenticación
  Future<void> _showUserConfigDialog() async {
    if (!_isBiometricSetupChecked) {
      // Esperar a que se complete la verificación inicial
      await Future.delayed(const Duration(milliseconds: 500));
    }

    // Intentar primero autenticación biométrica
    final biometricAvailable = await _isBiometricAvailable();

    if (biometricAvailable) {
      final biometricAuth = await _authenticateWithBiometrics();
      if (biometricAuth && mounted) {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
            child: _UserConfigDialog(
              currentUserName: _userName,
              onUserUpdated: _loadUserData,
              firestore: _firestore,
              auth: _auth,
            ),
          ),
        );
        return;
      }

      // Si falló la biométrica, ofrecer alternativa
      if (mounted) {
        final shouldTryPassword = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Autenticación alternativa'),
            content: const Text(
                '¿Deseas usar tu contraseña en lugar de la autenticación biométrica?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Usar contraseña'),
              ),
            ],
          ),
        );

        if (shouldTryPassword == true) {
          await _showUserConfigDialogWithPassword();
        }
      }
    } else {
      // Si no hay biometría disponible, usar contraseña directamente
      await _showUserConfigDialogWithPassword();
    }
  }

  // Convertir imagen a Base64
  Future<String?> _imageToBase64(File? image) async {
    if (image == null) return null;
    final bytes = await image.readAsBytes();
    return base64Encode(bytes);
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

  Future<void> _logout(BuildContext context) async {
    try {
      _userDataSubscription?.cancel();
      await _auth.signOut();
      Provider.of<local_auth_provider.GoogleAuthProvider>(context,
              listen: false)
          .clearAccessToken();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cerrar sesión: $e')),
        );
      }
    }
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userDoc = await _firestore.collection('users').doc(user.uid).get();

    if (userDoc.exists) {
      final data = userDoc.data();

      setState(() {
        _userName = data?['displayName'] ?? 'Usuario';
        _selectedEmoji = data?['avatarEmoji'] ?? '👤';
      });

      final imageBase64 = data?['avatarBase64'];
      if (imageBase64 != null && imageBase64 is String) {
        setState(() {
          _userImage = _base64ToImage(imageBase64);
        });
      }

      final Timestamp? lastLoginTimestamp = data?['lastLogin'];
      if (lastLoginTimestamp != null) {
        final lastLogin = lastLoginTimestamp.toDate();
        final diff = DateTime.now().difference(lastLogin);
        String status;

        if (diff.inMinutes < 1) {
          status = 'Activo hace un momento';
        } else if (diff.inMinutes < 60) {
          status = 'Activo hace ${diff.inMinutes} min';
        } else if (diff.inHours < 24) {
          status = 'Activo hace ${diff.inHours} h';
        } else {
          status = 'Activo hace ${diff.inDays} d';
        }

        setState(() {
          _lastLoginStatus = status;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      await _uploadImage(File(pickedFile.path));
    }
  }

  Future<void> _uploadImage(File image) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final base64Image = await _imageToBase64(image);
      if (base64Image == null) return;

      if (base64Image.length > 900000) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('La imagen es demasiado grande (máx. ~900KB)')),
        );
        return;
      }

      setState(() => _userImage = image);

      await _firestore.collection('users').doc(user.uid).update({
        'avatarBase64': base64Image,
        'avatarEmoji': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      setState(() => _selectedEmoji = '👤');
    } catch (e) {
      debugPrint('Error al subir imagen: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar avatar: $e')),
      );
    }
  }

  Future<void> _saveSelectedEmoji(String emoji) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'avatarBase64': null,
        'avatarEmoji': emoji,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _selectedEmoji = emoji;
        _userImage = null;
      });
    } catch (e) {
      debugPrint('Error al guardar emoji: $e');
    }
  }

  Future<String> getLastLoginStatus(String userId) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (!doc.exists) return 'Desconocido';

    final Timestamp timestamp = doc['lastLogin'];
    final DateTime lastLogin = timestamp.toDate();
    final Duration diff = DateTime.now().difference(lastLogin);

    if (diff.inMinutes < 1) {
      return 'Activo hace un momento';
    } else if (diff.inMinutes < 60) {
      return 'Activo hace ${diff.inMinutes} min';
    } else if (diff.inHours < 24) {
      return 'Activo hace ${diff.inHours} h';
    } else {
      return 'Activo hace ${diff.inDays} d';
    }
  }

  Future<void> _showAvatarSelectionModal() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  'Seleccionar avatar',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: predefinedAvatars.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        _saveSelectedEmoji(predefinedAvatars[index]);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Avatar seleccionado')),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Center(
                          child: Text(
                            predefinedAvatars[index],
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.image),
                  title: const Text('Elegir foto de galería'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage();
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  tileColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            children: [
              _buildStatusBar(theme),
              _buildHeader(context, theme),
              _buildMenu(theme),
              const Spacer(),
              _buildLogoutButton(context, theme),
              _buildTabBar(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, ThemeData theme) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () async => await _logout(context),
        icon: Icon(Icons.logout, color: theme.colorScheme.onPrimary),
        label: Text(
          'Cerrar sesión',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 5,
          shadowColor: theme.shadowColor.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildStatusBar(ThemeData theme) {
    return const SizedBox.shrink();
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 75, 8),
      child: Row(
        children: [
          IconButton(
            icon:
                Icon(Icons.arrow_back, size: 24, color: theme.iconTheme.color),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _showAvatarSelectionModal,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              child: _userImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(
                        _userImage!,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Text(
                      _selectedEmoji,
                      style: const TextStyle(fontSize: 24),
                    ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userName,
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  _lastLoginStatus,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenu(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuHeader(theme),
          _buildDivider(theme),
          _buildMenuItems(),
        ],
      ),
    );
  }

  Widget _buildMenuHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bienvenido a la',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          ),
          Text(
            'Configuración',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        thickness: 1,
        color: theme.dividerColor,
      ),
    );
  }

  Widget _buildMenuItems() {
    return Column(
      children: [
        ConfiguracionMenuItem(
          icon: Icons.color_lens_outlined,
          title: 'Temas',
          description: 'Color',
          onTap: () async {
            final themeProvider =
                Provider.of<ThemeProvider>(context, listen: false);
            final user = _auth.currentUser;
            if (user == null) return;

            final userDoc =
                await _firestore.collection('users').doc(user.uid).get();
            bool isDark = userDoc.data()?['themePreference'] == 'dark';

            showDialog(
              context: context,
              builder: (context) {
                return StatefulBuilder(
                  builder: (context, setState) {
                    return AlertDialog(
                      title: const Text('Selecciona un tema'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RadioListTile<bool>(
                            title: const Text('Claro'),
                            value: false,
                            groupValue: isDark,
                            onChanged: (value) async {
                              if (value != null) {
                                setState(() => isDark = value);
                                themeProvider.toggleTheme(value);
                                await _firestore
                                    .collection('users')
                                    .doc(user.uid)
                                    .update({
                                  'themePreference': value ? 'dark' : 'light',
                                });
                                Navigator.pop(context);
                              }
                            },
                          ),
                          RadioListTile<bool>(
                            title: const Text('Oscuro'),
                            value: true,
                            groupValue: isDark,
                            onChanged: (value) async {
                              if (value != null) {
                                setState(() => isDark = value);
                                themeProvider.toggleTheme(value);
                                await _firestore
                                    .collection('users')
                                    .doc(user.uid)
                                    .update({
                                  'themePreference': value ? 'dark' : 'light',
                                });
                                Navigator.pop(context);
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
        ConfiguracionMenuItem(
          icon: Icons.person_outline,
          title: 'Configuración de usuario',
          description: 'Usuario y contraseña',
          onTap: _showUserConfigDialog,
        ),
      ],
    );
  }
}

// Widget separado para el diálogo de configuración de usuario
class _UserConfigDialog extends StatefulWidget {
  final String currentUserName;
  final VoidCallback onUserUpdated;
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  const _UserConfigDialog({
    required this.currentUserName,
    required this.onUserUpdated,
    required this.firestore,
    required this.auth,
  });

  @override
  State<_UserConfigDialog> createState() => _UserConfigDialogState();
}

class _UserConfigDialogState extends State<_UserConfigDialog> {
  late TextEditingController _nameController;
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;
  bool _isChangingPassword = false;
  bool _isLoading = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentUserName);
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updateUserName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || name.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre debe tener al menos 3 caracteres')),
      );
      return;
    }
    if (name.length > 30) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre no puede tener más de 30 caracteres')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = widget.auth.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      await user.updateDisplayName(name);
      await widget.firestore.collection('users').doc(user.uid).update({
        'displayName': name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      widget.onUserUpdated();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nombre actualizado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar nombre: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updatePassword() async {
    if (_newPasswordController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('La contraseña debe tener al menos 8 caracteres')),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = widget.auth.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPasswordController.text,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(_newPasswordController.text);

      await widget.firestore.collection('users').doc(user.uid).update({
        'passwordUpdatedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        setState(() => _isChangingPassword = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contraseña actualizada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Error al actualizar contraseña';
        if (e.toString().contains('wrong-password')) {
          errorMessage = 'La contraseña actual es incorrecta';
        } else if (e.toString().contains('weak-password')) {
          errorMessage = 'La nueva contraseña es muy débil';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 340,
        maxWidth: 420, 
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Configuración de usuario',
                    style: theme.textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Nombre de usuario',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              maxLength: 30,
              decoration: InputDecoration(
                labelText: 'Nombre (mínimo 3, máximo 30)',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: theme.colorScheme.surfaceVariant,
                counterText: '',
              ),
              enabled: !_isLoading,
            ),
            const SizedBox(height: 12),
            Divider(color: theme.dividerColor),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Checkbox(
                    value: _isChangingPassword,
                    onChanged: _isLoading
                        ? null
                        : (value) {
                            setState(() {
                              _isChangingPassword = value ?? false;
                              if (!_isChangingPassword) {
                                _currentPasswordController.clear();
                                _newPasswordController.clear();
                                _confirmPasswordController.clear();
                              }
                            });
                          },
                  ),
                  const Text('Cambiar contraseña'),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _isChangingPassword
                  ? Column(
                      key: const ValueKey('passwordFields'),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          'Cambio de contraseña',
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _currentPasswordController,
                          obscureText: _obscureCurrentPassword,
                          decoration: InputDecoration(
                            labelText: 'Contraseña actual',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_obscureCurrentPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  _obscureCurrentPassword = !_obscureCurrentPassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: theme.colorScheme.surfaceVariant,
                          ),
                          enabled: !_isLoading,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _newPasswordController,
                          obscureText: _obscureNewPassword,
                          decoration: InputDecoration(
                            labelText: 'Nueva contraseña (mínimo 8)',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(_obscureNewPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  _obscureNewPassword = !_obscureNewPassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: theme.colorScheme.surfaceVariant,
                            helperText: 'Mínimo 8 caracteres',
                          ),
                          enabled: !_isLoading,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            labelText: 'Confirmar nueva contraseña',
                            prefixIcon: const Icon(Icons.lock_reset),
                            suffixIcon: IconButton(
                              icon: Icon(_obscureConfirmPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: theme.colorScheme.surfaceVariant,
                          ),
                          enabled: !_isLoading,
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
            if (_isLoading) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          if (_nameController.text.trim() != widget.currentUserName) {
                            await _updateUserName();
                          }
                          if (_isChangingPassword) {
                            await _updatePassword();
                          } else if (_nameController.text.trim() != widget.currentUserName) {
                            Navigator.pop(context);
                          }
                          if (_isChangingPassword &&
                              _currentPasswordController.text.isEmpty &&
                              _newPasswordController.text.isEmpty &&
                              _confirmPasswordController.text.isEmpty) {
                            Navigator.pop(context);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Guardar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildTabBar(ThemeData theme) {
  return Container(
    decoration: BoxDecoration(
      color: theme.cardColor,
      boxShadow: [
        BoxShadow(
          color: theme.shadowColor.withOpacity(0.1),
          blurRadius: 4,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Center(
      child: Container(
        width: 134,
        height: 5,
        decoration: BoxDecoration(
          color: theme.primaryColorDark,
          borderRadius: BorderRadius.circular(100),
        ),
      ),
    ),
  );
}
