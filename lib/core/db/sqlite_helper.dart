import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

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
      version: 3, // Incrementamos la versión por los cambios
      onCreate: (db, version) async {
        // Crear tabla de usuarios
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL,
            email TEXT NOT NULL,
            password TEXT NOT NULL
          )
        ''');

        // Crear tabla de eventos
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

        // Crear tabla de tareas (modificada)
        await db.execute('''
          CREATE TABLE tasks(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            dueDate TEXT NOT NULL,
            dueTime TEXT NOT NULL,
            description TEXT,
            isCompleted INTEGER DEFAULT 0,  -- 0 para false, 1 para true
            userId INTEGER,
            FOREIGN KEY (userId) REFERENCES users(id)
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          // Migración para la nueva estructura de tareas
          await db.execute('''
            CREATE TABLE tasks_new(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL,
              dueDate TEXT NOT NULL,
              dueTime TEXT NOT NULL,
              description TEXT,
              isCompleted INTEGER DEFAULT 0,
              userId INTEGER,
              FOREIGN KEY (userId) REFERENCES users(id)
            )
          ''');

          // Migrar datos de la tabla antigua a la nueva
          await db.execute('''
            INSERT INTO tasks_new (id, title, dueDate, dueTime, description, isCompleted, userId)
            SELECT id, title, dueDate, time, description, 
                   CASE WHEN status = 'completed' THEN 1 ELSE 0 END, 
                   userId 
            FROM tasks
          ''');

          // Eliminar tabla antigua
          await db.execute('DROP TABLE tasks');

          // Renombrar tabla nueva
          await db.execute('ALTER TABLE tasks_new RENAME TO tasks');
        }
      },
    );
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
  Future<int> addTask(
    String title,
    String dueDate,
    String dueTime,
    String description,
    int userId,
  ) async {
    final db = await database;
    return await db.insert('tasks', {
      'title': title,
      'dueDate': dueDate,
      'dueTime': dueTime,
      'description': description ?? '',
      'isCompleted': 0, // Por defecto no completada
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
}
