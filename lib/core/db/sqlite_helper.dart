import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';

class SQLiteHelper {
  static Database? _database;

  // Obtener la instancia de la base de datos
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB();
    return _database!;
  }

  // Inicializar la base de datos
  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'uniplanner.db');
    return openDatabase(
      path,
      version: 5, // Incrementé la versión por los cambios
      onCreate: (db, version) async {
        await _createTables(db);
        await _insertDefaultCategories(db);
      },
    );
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        email TEXT NOT NULL,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_avatars (
        userId INTEGER PRIMARY KEY,
        emoji TEXT,
        imagePath TEXT,
        FOREIGN KEY (userId) REFERENCES users(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE events(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        date TEXT NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT NOT NULL,
        description TEXT NOT NULL,
        userId INTEGER,
        FOREIGN KEY (userId) REFERENCES users(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        dueDate TEXT NOT NULL,
        dueTime TEXT NOT NULL,
        description TEXT,
        isCompleted INTEGER DEFAULT 0,
        listName TEXT DEFAULT 'Ideas',
        userId INTEGER,
        FOREIGN KEY (userId) REFERENCES users(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS task_lists (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        userId INTEGER NOT NULL,
        UNIQUE(name, userId),
        FOREIGN KEY (userId) REFERENCES users(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        isIncome INTEGER NOT NULL,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        userId INTEGER,
        FOREIGN KEY (userId) REFERENCES users(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        iconCode INTEGER NOT NULL,
        isIncome INTEGER NOT NULL,
        userId INTEGER,
        FOREIGN KEY (userId) REFERENCES users(id)
      )
    ''');
    await db.execute('''
  CREATE TABLE courses(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    label TEXT,
    userId INTEGER NOT NULL,
    FOREIGN KEY (userId) REFERENCES users(id)
  )
''');

    await db.execute('''
  CREATE TABLE grades(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    courseId INTEGER NOT NULL,
    type TEXT NOT NULL, -- 'homework', 'self_eval', 'partial', 'final'
    period INTEGER NOT NULL, -- 1, 2, 3
    value REAL NOT NULL,
    weight REAL NOT NULL,
    createdAt TEXT NOT NULL,
    FOREIGN KEY (courseId) REFERENCES courses(id)
  )
''');
  }

  Future<void> _insertDefaultCategories(Database db) async {
    final defaultCategories = [
      // Gastos (isIncome = 0)
      _buildCategory('Comida', Icons.restaurant, false),
      _buildCategory('Transporte', Icons.directions_car, false),
      _buildCategory('Vivienda', Icons.home, false),
      _buildCategory('Servicios', Icons.bolt, false),
      _buildCategory('Salud', Icons.medical_services, false),
      _buildCategory('Educación', Icons.school, false),
      _buildCategory('Entretenimiento', Icons.movie, false),
      _buildCategory('Ropa', Icons.checkroom, false),
      _buildCategory('Cuidado personal', Icons.spa, false),
      _buildCategory('Regalos', Icons.card_giftcard, false),
      _buildCategory('Viajes', Icons.flight, false),
      _buildCategory('Seguros', Icons.security, false),
      _buildCategory('Deudas', Icons.money_off, false),
      _buildCategory('Otros gastos', Icons.miscellaneous_services, false),

      // Ingresos (isIncome = 1)
      _buildCategory('Salario', Icons.work, true),
      _buildCategory('Regalo', Icons.card_giftcard, true),
      _buildCategory('Freelance', Icons.computer, true),
      _buildCategory('Inversiones', Icons.trending_up, true),
      _buildCategory('Ventas', Icons.sell, true),
      _buildCategory('Alquileres', Icons.house, true),
      _buildCategory('Premios', Icons.emoji_events, true),
      _buildCategory('Becas', Icons.school, true),
      _buildCategory('Préstamos', Icons.account_balance, true),
      _buildCategory('Donaciones', Icons.volunteer_activism, true),
      _buildCategory('Reembolsos', Icons.receipt, true),
      _buildCategory('Intereses', Icons.account_balance_wallet, true),
      _buildCategory('Herencia', Icons.account_balance, true),
      _buildCategory('Otros ingresos', Icons.attach_money, true),
    ];

    for (var category in defaultCategories) {
      await db.insert('categories', category,
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  Map<String, dynamic> _buildCategory(
      String name, IconData icon, bool isIncome) {
    return {
      'name': name,
      'iconCode': icon.codePoint,
      'isIncome': isIncome ? 1 : 0,
      'userId': null // Categorías globales
    };
  }

  // Registrar un nuevo usuario
  Future<int> registerUser(
      String username, String email, String password) async {
    final db = await database;
    var result = await db.insert('users', {
      'username': username,
      'email': email,
      'password': password,
    });
    return result;
  }

  // Verificar si las credenciales son correctas
  Future<bool> loginUser(String email, String password) async {
    final db = await database;
    var result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return result.isNotEmpty;
  }

  // Obtener un usuario por email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// Guardar avatar (emoji o imagen) para un usuario
  Future<void> saveUserAvatar({
    required int userId,
    String? emoji,
    String? imagePath,
  }) async {
    final db = await database;

    // Primero verificar si ya existe un registro
    final existing = await db.query(
      'user_avatars',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    if (existing.isEmpty) {
      // Insertar nuevo registro
      await db.insert('user_avatars', {
        'userId': userId,
        'emoji': emoji,
        'imagePath': imagePath,
      });
    } else {
      // Actualizar registro existente
      await db.update(
        'user_avatars',
        {
          'emoji': emoji,
          'imagePath': imagePath,
        },
        where: 'userId = ?',
        whereArgs: [userId],
      );
    }
  }

  /// Obtener avatar de un usuario
  Future<Map<String, dynamic>?> getUserAvatar(int userId) async {
    final db = await database;
    final result = await db.query(
      'user_avatars',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Agregar evento para el usuario logueado
  Future<int> addEvent(String title, String date, String startTime,
      String endTime, String description, int userId) async {
    final db = await database;
    return await db.insert('events', {
      'title': title,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'description': description,
      'userId': userId,
    });
  }

  // Obtener todos los eventos
  Future<List<Map<String, dynamic>>> getEvents() async {
    final db = await database;
    return await db.query('events');
  }

  // Obtener eventos de un día específico
  Future<List<Map<String, dynamic>>> getEventsForDay(String date,
      {int? userId}) async {
    final db = await database;
    if (userId != null) {
      return await db.query(
        'events',
        where: 'date = ? AND userId = ?',
        whereArgs: [date, userId],
      );
    } else {
      return await db.query(
        'events',
        where: 'date = ?',
        whereArgs: [date],
      );
    }
  }

  // Obtener eventos de un usuario específico
  Future<List<Map<String, dynamic>>> getUserEvents(int userId) async {
    final db = await database;
    return await db.query(
      'events',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  // Eliminar un evento
  Future<int> deleteEvent(int id) async {
    final db = await database;
    return await db.delete(
      'events',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Agregar tarea para el usuario logueado
  // En SQLiteHelper
  Future<int> addTask(
    String title,
    String dueDate,
    String dueTime,
    String description,
    String listName, // Nuevo parámetro
    int userId,
  ) async {
    final db = await database;
    return await db.insert('tasks', {
      'title': title,
      'dueDate': dueDate,
      'dueTime': dueTime,
      'description': description ?? '',
      'isCompleted': 0,
      'listName': listName, // Agregar listName
      'userId': userId,
    });
  }

  // Obtener todas las tareas
  Future<List<Map<String, dynamic>>> getTasks() async {
    final db = await database;
    return await db.query('tasks');
  }

  // Obtener tareas de un día específico
  Future<List<Map<String, dynamic>>> getTasksForDay(String date,
      {int? userId}) async {
    final db = await database;
    if (userId != null) {
      return await db.query(
        'tasks',
        where: 'dueDate = ? AND userId = ?',
        whereArgs: [date, userId],
      );
    } else {
      return await db.query(
        'tasks',
        where: 'dueDate = ?',
        whereArgs: [date],
      );
    }
  }

  // Obtener tareas de un usuario específico
  Future<List<Map<String, dynamic>>> getUserTasks(int userId) async {
    final db = await database;
    return await db.query(
      'tasks',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  Future<int> updateUsername(int userId, String newUsername) async {
    final db = await database;
    return await db.update(
      'users',
      {'username': newUsername},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // Actualizar estado de completado de una tarea
  Future<int> updateTaskCompletion(int taskId, bool isCompleted) async {
    final db = await database;
    return await db.update(
      'tasks',
      {'isCompleted': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  // Eliminar una tarea
  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Método para actualizar un evento
  Future<int> updateEvent(
    int id,
    String title,
    String date,
    String startTime,
    String endTime,
    String description,
  ) async {
    final db = await database;
    return await db.update(
      'events',
      {
        'title': title,
        'date': date,
        'startTime': startTime,
        'endTime': endTime,
        'description': description,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Método para actualizar una tarea
  Future<int> updateTask(
    int id,
    String title,
    String dueDate,
    String dueTime,
    String description,
    bool isCompleted,
    String listName, // Nuevo parámetro
  ) async {
    final db = await database;
    return await db.update(
      'tasks',
      {
        'title': title,
        'dueDate': dueDate,
        'dueTime': dueTime,
        'description': description,
        'isCompleted': isCompleted ? 1 : 0,
        'listName': listName, // Actualizar listName
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

// Método para obtener un evento por ID
  Future<Map<String, dynamic>?> getEventById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'events',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

// Método para obtener una tarea por ID
  Future<Map<String, dynamic>?> getTaskById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Obtener eventos y tareas de un día específico (combinados)
  Future<List<Map<String, dynamic>>> getDayItems(String date) async {
    final db = await database;

    // Obtener eventos
    final events = await db.query(
      'events',
      where: 'date = ?',
      whereArgs: [date],
    );

    // Obtener tareas
    final tasks = await db.query(
      'tasks',
      where: 'dueDate = ?',
      whereArgs: [date],
    );

    // Combinar resultados (añadiendo un campo 'type' para diferenciarlos)
    final combined = [
      ...tasks.map((e) => {...e, 'type': 'task'}),
      ...events.map((e) => {...e, 'type': 'event'}),
    ];

    return combined;
  }

  // En SQLiteHelper
  Future<List<Map<String, dynamic>>> getTasksForList(
      String listName, int userId) async {
    final db = await database;
    return await db.query(
      'tasks',
      where: 'listName = ? AND userId = ?',
      whereArgs: [listName, userId],
    );
  }

  Future<int> updateTaskList(int taskId, String listName) async {
    final db = await database;
    return await db.update(
      'tasks',
      {'listName': listName},
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  // Método para renombrar una lista de tareas
  Future<int> renameTaskList(String oldName, String newName, int userId) async {
    final db = await database;
    return await db.update(
      'tasks',
      {'listName': newName},
      where: 'listName = ? AND userId = ?',
      whereArgs: [oldName, userId],
    );
  }

  // Método para verificar si una lista está vacía
  Future<bool> isListEmpty(String listName, int userId) async {
    final db = await database;
    final result = await db.query(
      'tasks',
      where: 'listName = ? AND userId = ?',
      whereArgs: [listName, userId],
      limit: 1,
    );
    return result.isEmpty;
  }

  // Método para eliminar una lista de tareas

  /// Obtener listas de tareas de un usuario
  Future<List<String>> getUserTaskLists(int userId) async {
    final db = await database;
    final result = await db.query(
      'task_lists',
      where: 'userId = ?',
      whereArgs: [userId],
      columns: ['name'],
    );
    return result.map((e) => e['name'] as String).toList();
  }

  /// Agregar una nueva lista para un usuario
  Future<int> addTaskList(String name, int userId) async {
    final db = await database;
    return await db.insert(
      'task_lists',
      {'name': name, 'userId': userId},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// Eliminar una lista de tareas
  Future<int> deleteTaskList(String name, int userId) async {
    final db = await database;
    return await db.delete(
      'task_lists',
      where: 'name = ? AND userId = ?',
      whereArgs: [name, userId],
    );
  }

  /// Verificar si una lista está vacía
  Future<bool> isTaskListEmpty(String name, int userId) async {
    final db = await database;
    final result = await db.query(
      'tasks',
      where: 'listName = ? AND userId = ?',
      whereArgs: [name, userId],
      limit: 1,
    );
    return result.isEmpty;
  }

  // ==================== MÉTODOS PARA TRANSACCIONES ====================

  /// Agrega una nueva transacción
  Future<int> addTransaction({
    required double amount,
    required String description,
    required String category,
    required bool isIncome,
    required DateTime date,
    required int userId,
  }) async {
    final db = await database;
    return await db.insert('transactions', {
      'amount': amount,
      'description': description,
      'category': category,
      'isIncome': isIncome ? 1 : 0,
      'date': _formatDate(date),
      'time': _formatTime(date),
      'userId': userId,
    });
  }

  /// Obtiene todas las transacciones de un usuario
  Future<List<Map<String, dynamic>>> getUserTransactions(int userId) async {
    final db = await database;
    return await db.query(
      'transactions',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC, time DESC',
    );
  }

  /// Obtiene transacciones por periodo (día, semana, mes, año)
  Future<List<Map<String, dynamic>>> getTransactionsByPeriod({
    required String period,
    required int userId,
    DateTime? startDate,
  }) async {
    final db = await database;
    final now = startDate ?? DateTime.now();
    String whereClause = 'userId = ?';
    List<dynamic> whereArgs = [userId];

    switch (period.toLowerCase()) {
      case 'día':
        whereClause += ' AND date = ?';
        whereArgs.add(_formatDate(now));
        break;
      case 'semana':
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        whereClause += ' AND date BETWEEN ? AND ?';
        whereArgs.addAll([_formatDate(startOfWeek), _formatDate(endOfWeek)]);
        break;
      case 'mes':
        final firstDay = DateTime(now.year, now.month, 1);
        final lastDay = DateTime(now.year, now.month + 1, 0);
        whereClause += ' AND date BETWEEN ? AND ?';
        whereArgs.addAll([_formatDate(firstDay), _formatDate(lastDay)]);
        break;
      case 'año':
        final firstDay = DateTime(now.year, 1, 1);
        final lastDay = DateTime(now.year, 12, 31);
        whereClause += ' AND date BETWEEN ? AND ?';
        whereArgs.addAll([_formatDate(firstDay), _formatDate(lastDay)]);
        break;
    }

    return await db.query(
      'transactions',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'date DESC, time DESC',
    );
  }

  /// Obtiene el balance total de un usuario
  Future<double> getBalance(int userId) async {
    final db = await database;
    final transactions = await db.query(
      'transactions',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    return transactions.fold<double>(0, (sum, transaction) {
      final amount = transaction['amount'] as double;
      return transaction['isIncome'] == 1 ? sum + amount : sum - amount;
    });
  }

  /// Actualiza una transacción existente
  Future<int> updateTransaction({
    required int id,
    required double amount,
    required String description,
    required String category,
    required bool isIncome,
    required DateTime date,
  }) async {
    final db = await database;
    return await db.update(
      'transactions',
      {
        'amount': amount,
        'description': description,
        'category': category,
        'isIncome': isIncome ? 1 : 0,
        'date': _formatDate(date),
        'time': _formatTime(date),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Elimina una transacción
  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Obtiene una transacción por su ID
  Future<Map<String, dynamic>?> getTransactionById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // ==================== MÉTODOS PARA CATEGORÍAS ====================

  /// Agrega una nueva categoría personalizada
  Future<int> addCategory({
    required String name,
    required IconData icon,
    required bool isIncome,
    required int userId,
  }) async {
    final db = await database;
    return await db.insert('categories', {
      'name': name,
      'iconCode': icon.codePoint,
      'isIncome': isIncome ? 1 : 0,
      'userId': userId,
    });
  }

  /// Obtiene todas las categorías de un usuario
  Future<List<Map<String, dynamic>>> getUserCategories(int userId) async {
    final db = await database;
    return await db.query(
      'categories',
      where: 'userId = ? OR userId IS NULL', // Categorías globales y personales
      whereArgs: [userId],
    );
  }

  /// Obtiene categorías por tipo (ingreso/gasto)
  Future<List<Map<String, dynamic>>> getCategoriesByType({
    required bool isIncome,
    required String userId,
  }) async {
    final db = await database;
    return await db.query(
      'categories',
      where: '(userId = ? OR userId IS NULL) AND isIncome = ?',
      whereArgs: [userId, isIncome ? 1 : 0],
    );
  }

  /// Actualiza una categoría existente
  Future<int> updateCategory({
    required int id,
    required String name,
    required IconData icon,
    required bool isIncome,
  }) async {
    final db = await database;
    return await db.update(
      'categories',
      {
        'name': name,
        'iconCode': icon.codePoint,
        'isIncome': isIncome ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Elimina una categoría (solo si no está en uso)
  Future<int> deleteCategory(int id) async {
    final db = await database;
    // Verificar si la categoría está en uso
    final transactions = await db.query(
      'transactions',
      where: 'category = (SELECT name FROM categories WHERE id = ?)',
      whereArgs: [id],
      limit: 1,
    );

    if (transactions.isNotEmpty) {
      throw Exception('No se puede eliminar una categoría en uso');
    }

    return await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== HELPERS ====================

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Métodos para cursos
  Future<int> addCourse(String name, String label, int userId) async {
    final db = await database;
    return await db.insert('courses', {
      'name': name,
      'label': label,
      'userId': userId,
    });
  }

  Future<List<Map<String, dynamic>>> getUserCourses(int userId) async {
    final db = await database;
    return await db.query(
      'courses',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'name ASC',
    );
  }

  Future<int> updateCourse(int id, String name, String label) async {
    final db = await database;
    return await db.update(
      'courses',
      {
        'name': name,
        'label': label,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteCourse(int id) async {
    final db = await database;
    await db.delete(
      'grades',
      where: 'courseId = ?',
      whereArgs: [id],
    );
    return await db.delete(
      'courses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

// Métodos para notas
  Future<int> addGrade({
    required int courseId,
    required String type,
    required int period,
    required double value,
    required double weight,
  }) async {
    final db = await database;
    return await db.insert('grades', {
      'courseId': courseId,
      'type': type,
      'period': period,
      'value': value,
      'weight': weight,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getCourseGrades(int courseId) async {
    final db = await database;
    return await db.query(
      'grades',
      where: 'courseId = ?',
      whereArgs: [courseId],
      orderBy: 'period ASC, type ASC',
    );
  }

  Future<int> updateGrade({
    required int id,
    required double value,
    required double weight,
  }) async {
    final db = await database;
    return await db.update(
      'grades',
      {
        'value': value,
        'weight': weight,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteGrade(int id) async {
    final db = await database;
    return await db.delete(
      'grades',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

// Método para calcular el promedio de un curso
  Future<Map<String, dynamic>> calculateCourseAverage(int courseId) async {
    final db = await database;
    final grades = await db.query(
      'grades',
      where: 'courseId = ?',
      whereArgs: [courseId],
    );

    // Organizar las notas por periodo
    final Map<int, Map<String, List<double>>> periodGrades = {};

    for (var grade in grades) {
      final period = grade['period'] as int;
      final type = grade['type'] as String;
      final value = grade['value'] as double;
      final weight = grade['weight'] as double;

      if (!periodGrades.containsKey(period)) {
        periodGrades[period] = {
          'homework': [],
          'self_eval': [],
          'partial': [],
        };
      }

      if (type == 'homework' || type == 'self_eval' || type == 'partial') {
        periodGrades[period]![type]!.add(value * weight);
      }
    }

    // Calcular promedio por periodo
    final Map<int, double> periodAverages = {};
    for (var period in periodGrades.keys) {
      final periodData = periodGrades[period]!;

      // Calcular promedio de tareas (30%)
      final homeworkAvg = periodData['homework']!.isEmpty
          ? 0
          : (periodData['homework']!.reduce((a, b) => a + b) /
              periodData['homework']!.length);

      // Autoevaluación (10%)
      final selfEvalAvg =
          periodData['self_eval']!.isEmpty ? 0 : periodData['self_eval']!.first;

      // Parcial (60%)
      final partialAvg =
          periodData['partial']!.isEmpty ? 0 : periodData['partial']!.first;

      // Promedio del periodo
      periodAverages[period] =
          homeworkAvg * 0.3 + selfEvalAvg * 0.1 + partialAvg * 0.6;
    }

    // Calcular promedio final (33%, 33%, 34%)
    double finalAverage = 0;
    if (periodAverages.containsKey(1)) {
      finalAverage += periodAverages[1]! * 0.33;
    }
    if (periodAverages.containsKey(2)) {
      finalAverage += periodAverages[2]! * 0.33;
    }
    if (periodAverages.containsKey(3)) {
      finalAverage += periodAverages[3]! * 0.34;
    }

    // Buscar si existe nota final manual
    final finalGrade = grades.firstWhere(
      (g) => g['type'] == 'final',
      orElse: () => {'value': finalAverage},
    );

    return {
      'periodAverages': periodAverages,
      'finalAverage': finalGrade['value'] as double,
    };
  }
}
