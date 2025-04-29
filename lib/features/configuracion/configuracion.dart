import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/theme_provider.dart';
import '../../shared_widgets/general/configuracion_menu_item.dart';
import '../home/home_screen.dart';
import '../../core/db/sqlite_helper.dart';
import '../../shared_widgets/general/app_routes.dart';

class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({Key? key}) : super(key: key);

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  String _userName = '';
  File? _userImage;
  String _selectedEmoji = '👤';
  int? _userId;
  final ImagePicker _picker = ImagePicker();
  final SQLiteHelper _dbHelper = SQLiteHelper();

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
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('username') ?? 'username';
      _userId = prefs.getInt('userId');
    });

    if (_userId != null) {
      await _loadUserAvatar();
    }
  }

  Future<void> _loadUserAvatar() async {
    if (_userId == null) return;

    final avatar = await _dbHelper.getUserAvatar(_userId!);
    if (avatar == null) return;

    setState(() {
      _selectedEmoji = avatar['emoji'] ?? '👤';
      final imagePath = avatar['imagePath'];
      if (imagePath != null && File(imagePath).existsSync()) {
        _userImage = File(imagePath);
      }
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && _userId != null) {
      await _saveImage(pickedFile.path);
    }
  }

  Future<void> _saveImage(String imagePath) async {
    if (_userId == null) return;

    await _dbHelper.saveUserAvatar(
      userId: _userId!,
      imagePath: imagePath,
      emoji: null, // Limpiar emoji al guardar imagen
    );

    setState(() {
      _userImage = File(imagePath);
      _selectedEmoji = '👤';
    });
  }

  Future<void> _saveSelectedEmoji(String emoji) async {
    if (_userId == null) return;

    await _dbHelper.saveUserAvatar(
      userId: _userId!,
      emoji: emoji,
      imagePath: null, // Limpiar imagen al guardar emoji
    );

    setState(() {
      _selectedEmoji = emoji;
      _userImage = null;
    });
  }

  Future<void> _showAvatarSelectionModal() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      isScrollControlled: true, // Esto evita el overflow
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
                          color: Theme.of(context).colorScheme.surfaceVariant,
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
                  tileColor: Theme.of(context).colorScheme.surfaceVariant,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  void _logout(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
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
              backgroundColor: theme.colorScheme.surfaceVariant,
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
                  'Active 5m ago',
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
            final prefs = await SharedPreferences.getInstance();
            bool isDark = prefs.getBool('isDarkTheme') ?? false;

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
                                await prefs.setBool('isDarkTheme', value);
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
                                await prefs.setBool('isDarkTheme', value);
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
          onTap: () async {
            final prefs = await SharedPreferences.getInstance();
            final userId = prefs.getInt('userId');
            if (userId == null) return;

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
                        final dbHelper = SQLiteHelper();
                        try {
                          await prefs.setString('username', controller.text);
                          await dbHelper.updateUsername(
                              userId, controller.text);
                          setState(() {
                            _userName = controller.text;
                          });
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
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context, ThemeData theme) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () => _logout(context),
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
}
