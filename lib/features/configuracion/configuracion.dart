import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uniplanner/core/utils/notification_helper.dart';
import '../../providers/theme_provider.dart';
import '../../shared_widgets/general/configuracion_menu_item.dart';
import '../home/home_screen.dart';
import '../../shared_widgets/general/app_routes.dart';
import 'dart:async';
import 'package:uniplanner/providers/GoogleAuthProvider.dart' as local_auth_provider;

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
  String _lastLoginStatus = 'Cargando...';
  StreamSubscription<DocumentSnapshot>? _userDataSubscription;

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
      // Cancelar todos los streams antes de cerrar sesión
      _userDataSubscription?.cancel();

      await _auth.signOut();
      Provider.of<local_auth_provider.GoogleAuthProvider>(context, listen: false).clearAccessToken();
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

      // Cargar imagen desde Base64 si existe
      final imageBase64 = data?['avatarBase64'];
      if (imageBase64 != null && imageBase64 is String) {
        setState(() {
          _userImage = _base64ToImage(imageBase64);
        });
      }

      // Calcular estado de actividad
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
      // Convertir a Base64
      final base64Image = await _imageToBase64(image);
      if (base64Image == null) return;

      // Verificar tamaño (Firestore limita documentos a 1MB)
      if (base64Image.length > 900000) {
        // ~900KB dejando espacio para otros campos
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('La imagen es demasiado grande (máx. ~900KB)')),
        );
        return;
      }

      setState(() => _userImage = image);

      // Actualizar Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'avatarBase64': base64Image,
        'avatarEmoji': null, // Limpiar emoji
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
      // Actualizar Firestore
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

  Future<void> _updateUsername(String newName) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Actualizar en Firebase Auth
      await user.updateDisplayName(newName);

      // Actualizar en Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'displayName': newName,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      setState(() => _userName = newName);
    } catch (e) {
      debugPrint('Error al actualizar nombre: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar nombre: $e')),
      );
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
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                  tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
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
          description: 'Usuario',
          onTap: () {
            TextEditingController controller =
                TextEditingController(text: _userName);
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Editar nombre de usuario'),
                  content: TextField(
                    controller: controller,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () async {
                        try {
                          await _updateUsername(controller.text);
                          Navigator.pop(context);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error al actualizar: $e')),
                          );
                        }
                      },
                      child: const Text('Guardar'),
                    ),
                  ],
                );
              },
            );
          },
        ),
        ConfiguracionMenuItem(
          icon: Icons.notifications_active_outlined,
          title: 'Probar notificación',
          description: 'Envía una notificación de prueba',
          onTap: () async {
            await flutterLocalNotificationsPlugin.show(
              9999,
              'Notificación de prueba',
              '¡Esto es una notificación local!',
              const NotificationDetails(
                android: AndroidNotificationDetails(
                  'tareas_channel',
                  'Tareas y eventos',
                  channelDescription: 'Notificaciones de tareas y eventos',
                  importance: Importance.max,
                  priority: Priority.high,
                ),
              ),
            );
          },
        ),
        ConfiguracionMenuItem(
          icon: Icons.schedule,
          title: 'Programar notificación',
          description: 'Notificación',
          onTap: () async {
            final scheduledDate = DateTime.now().add(const Duration(minutes: 2));
            await scheduleNotification(
              context: context,
              id: 10001,
              title: 'Notificación programada',
              body: '¡Esto es una notificación programada para dentro de 2 minuto!',
              scheduledDate: scheduledDate,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notificación programada para dentro de 2 minuto')),
            );
          },
        ),
      ],
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
