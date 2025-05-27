import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseFinanzasHelper {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obtener el ID del usuario actual
  String? get currentUserId => _auth.currentUser?.uid;

  Stream<QuerySnapshot> getTransactionsStream({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final userId = currentUserId;
    if (userId == null) throw Exception('Usuario no autenticado');

    // Usa los parámetros recibidos, si no existen usa un rango muy amplio
    final rangeStart = startDate ?? DateTime(2000);
    final rangeEnd = endDate ?? DateTime.now();

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(rangeStart))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(rangeEnd))
        .orderBy('date', descending: true)
        .snapshots();
  }
  
  // Añadir una nueva transacción
  Future<void> addTransaction({
    required double amount,
    required String description,
    required String category,
    required bool isIncome,
    required DateTime date,
  }) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Usuario no autenticado');

    await _firestore.collection('users').doc(userId).collection('transactions').add({
      'amount': amount,
      'description': description,
      'category': category,
      'isIncome': isIncome,
      'date': Timestamp.fromDate(date),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Actualizar una transacción
  Future<void> updateTransaction({
    required String transactionId,
    required double amount,
    required String description,
    required String category,
    required bool isIncome,
    required DateTime date,
  }) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Usuario no autenticado');

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .doc(transactionId)
        .update({
      'amount': amount,
      'description': description,
      'category': category,
      'isIncome': isIncome,
      'date': Timestamp.fromDate(date),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Eliminar una transacción
  Future<void> deleteTransaction(String transactionId) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Usuario no autenticado');

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .doc(transactionId)
        .delete();
  }

  // Obtener transacciones por período
  Future<List<Map<String, dynamic>>> getTransactionsByPeriod({
    required String period,
    DateTime? startDate,
  }) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Usuario no autenticado');

    DateTime rangeStart;
    DateTime rangeEnd = DateTime.now();

    switch (period) {
      case 'Día':
        rangeStart = DateTime(rangeEnd.year, rangeEnd.month, rangeEnd.day);
        break;
      case 'Semana':
        rangeStart = rangeEnd.subtract(const Duration(days: 7));
        break;
      case 'Mes':
        rangeStart = DateTime(rangeEnd.year, rangeEnd.month, 1);
        break;
      case 'Año':
        rangeStart = DateTime(rangeEnd.year, 1, 1);
        break;
      default:
        rangeStart = startDate ?? DateTime(2000);
    }

    final querySnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(rangeStart))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(rangeEnd))
        .orderBy('date', descending: true)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'amount': data['amount'],
        'description': data['description'],
        'category': data['category'],
        'isIncome': data['isIncome'],
        'date': (data['date'] as Timestamp).toDate(),
      };
    }).toList();
  }

  // Obtener el balance total
  Future<double> getBalance() async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Usuario no autenticado');

    final querySnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .get();

    double balance = 0.0;
    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final amount = data['amount'] as double;
      if (data['isIncome'] as bool) {
        balance += amount;
      } else {
        balance -= amount;
      }
    }

    return balance;
  }
}