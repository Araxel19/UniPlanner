import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Obtener el ID del usuario actual
  String? get currentUserId => _auth.currentUser?.uid;

  CollectionReference _userCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('data');
  }

  Future<void> saveUserData(String uid, Map<String, dynamic> data) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .set(data, SetOptions(merge: true));
  }

  // ========== Operaciones de Cursos ==========

  Future<void> addCourse(String name, {String label = ''}) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Usuario no autenticado');

    await _firestore.collection('users').doc(userId).collection('courses').add({
      'name': name,
      'label': label,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> getUserCourses() async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Usuario no autenticado');

    final querySnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('courses')
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'name': data['name'] as String,
        'label':
            data['label'] as String? ?? '',
      };
    }).toList();
  }

  Future<void> updateCourse(String courseId, String name,
      {String label = ''}) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Usuario no autenticado');

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('courses')
        .doc(courseId)
        .update({
      'name': name,
      'label': label,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteCourse(String courseId) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Usuario no autenticado');

    // Primero eliminamos todas las notas asociadas al curso
    final gradesSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('grades')
        .where('courseId', isEqualTo: courseId)
        .get();

    final batch = _firestore.batch();
    for (var doc in gradesSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // Luego eliminamos el curso
    batch.delete(
      _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .doc(courseId),
    );

    await batch.commit();
  }

  // ========== Operaciones de Notas ==========

  Future<void> addGrade({
    required String courseId,
    required String type,
    required int period,
    required double value,
    double weight = 1.0,
  }) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Usuario no autenticado');

    await _firestore.collection('users').doc(userId).collection('grades').add({
      'courseId': courseId,
      'type': type,
      'period': period,
      'value': value,
      'weight': weight,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> getCourseGrades(String courseId) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Usuario no autenticado');

    final querySnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('grades')
        .where('courseId', isEqualTo: courseId)
        .orderBy('period')
        .orderBy('type')
        .get();

    return querySnapshot.docs.map((doc) {
      return {
        'id': doc.id,
        'courseId': doc['courseId'] as String,
        'type': doc['type'] as String,
        'period': doc['period'] as int,
        'value': doc['value'] as double,
        'weight': doc['weight'] as double,
      };
    }).toList();
  }

  Future<void> updateGrade({
    required String gradeId,
    required double value,
    double weight = 1.0,
  }) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Usuario no autenticado');

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('grades')
        .doc(gradeId)
        .update({
      'value': value,
      'weight': weight,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteGrade(String gradeId) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Usuario no autenticado');

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('grades')
        .doc(gradeId)
        .delete();
  }

  // Método para calcular promedios
  Future<Map<String, dynamic>> calculateCourseAverage(String courseId) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Usuario no autenticado');

    final grades = await getCourseGrades(courseId);

    // Organizar notas por período y tipo
    final Map<int, Map<String, List<double>>> periodGrades = {
      1: {'homework': [], 'self_eval': [], 'partial': []},
      2: {'homework': [], 'self_eval': [], 'partial': []},
      3: {'homework': [], 'self_eval': [], 'partial': []},
    };

    for (var grade in grades) {
      final period = grade['period'] as int;
      final type = grade['type'] as String;
      final value = grade['value'] as double;

      if (periodGrades.containsKey(period) &&
          periodGrades[period]!.containsKey(type)) {
        periodGrades[period]![type]!.add(value);
      }
    }

    // Calcular promedios por período
    final Map<int, double> periodAverages = {};
    double finalAverage = 0.0;

    for (var period in periodGrades.keys) {
      final homeworkAvg = _calculateAverage(periodGrades[period]!['homework']!);
      final selfEvalAvg =
          _calculateAverage(periodGrades[period]!['self_eval']!);
      final partialAvg = _calculateAverage(periodGrades[period]!['partial']!);

      // Pesos: Trabajos 30%, Autoevaluación 10%, Parcial 60%
      final periodAverage =
          (homeworkAvg * 0.3) + (selfEvalAvg * 0.1) + (partialAvg * 0.6);

      periodAverages[period] = periodAverage;
      finalAverage += periodAverage;
    }

    // Calcular promedio final (promedio de los 3 períodos)
    finalAverage =
        periodAverages.isNotEmpty ? finalAverage / periodAverages.length : 0.0;

    return {
      'periodAverages': periodAverages,
      'finalAverage': finalAverage,
    };
  }

  double _calculateAverage(List<double> grades) {
    if (grades.isEmpty) return 0.0;
    return grades.reduce((a, b) => a + b) / grades.length;
  }
}
