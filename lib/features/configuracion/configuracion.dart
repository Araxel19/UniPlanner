import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../shared_widgets/general/configuracion_menu_item.dart';
import '../home/home_screen.dart';
import '../../core/db/sqlite_helper.dart';

class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({Key? key}) : super(key: key);

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('username') ?? 'username';
    });
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
              _buildTabBar(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
          color: theme.appBarTheme.backgroundColor ??
              theme.colorScheme.surface),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(21, 12, 21, 12),
      child: Image.asset(
        'assets/images/logo.jpg',
        width: 54,
        height: 54 / 2.57,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color:
            theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface,
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
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/user_avatar.png',
              width: 32,
              height: 32,
              fit: BoxFit.contain,
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
                          // Actualizar en SharedPreferences
                          await prefs.setString('username', controller.text);
                          // Actualizar en la base de datos
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
