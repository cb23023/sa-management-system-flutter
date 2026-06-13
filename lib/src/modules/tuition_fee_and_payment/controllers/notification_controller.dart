import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/notification.dart';
import '../models/payment_transactions.dart';
import '../models/tuition_fees.dart';

class NotificationController {
  NotificationController({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<TuitionNotification>> getNotificationStream(
    String uid, {
    String? matricId,
  }) {
    return _firestore
        .collection('payment_transactions')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final transactionDocs = snapshot.docs
          .map(PaymentTransaction.fromDoc)
          .where((transaction) => _matchesTransaction(transaction, uid, matricId))
          .toList();
      final verifiedTransaction = _latestVerifiedTransaction(transactionDocs);

      final notificationSnapshot = await _firestore
          .collection('notifications')
          .where('module', isEqualTo: 'tuition')
          .get();
      final notifications = notificationSnapshot.docs
          .map(TuitionNotification.fromDoc)
          .where((notification) => _matchesUser(notification.userId, uid, matricId))
          .toList();
      final hasVerifiedNotice = notifications.any(
        (notification) =>
            notification.title.trim().toLowerCase() == 'payment verified',
      );
      if (verifiedTransaction != null && !hasVerifiedNotice) {
        notifications.add(TuitionNotification(
          id: 'generated-${verifiedTransaction.id}',
          userId: uid,
          title: 'Payment verified',
          message:
              'Your payment of RM ${verifiedTransaction.amount.toStringAsFixed(2)} has been verified by treasury.',
          type: 'success',
          module: 'tuition',
          isRead: false,
          createdAt: verifiedTransaction.updatedAt.isNotEmpty
              ? verifiedTransaction.updatedAt
              : verifiedTransaction.createdAt,
        ));
      }
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return notifications;
    });
  }

  Future<void> sendNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
  }) {
    return _firestore.collection('notifications').add({
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'module': 'tuition',
      'isRead': false,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> verifyPayment(
    PaymentTransaction transaction,
    String remarks, {
    String treasuryId = 'treasury',
  }) async {
    final feeRef = await _findTuitionFeeReference(transaction);
    if (feeRef == null) {
      throw StateError('Student tuition fee record not found.');
    }

    final now = DateTime.now().toIso8601String();
    final notificationRef = _firestore.collection('notifications').doc();
    final batch = _firestore.batch();
    batch.update(transaction.reference, {
      'studentId': feeRef.id,
      'status': 'Verified',
      'verifiedBy': treasuryId,
      'remarks': remarks.trim(),
      'updatedAt': now,
    });
    batch.update(feeRef, {
      'paymentStatus': 'Paid',
      'outstandingAmount': 0,
      'isBlocked': false,
      'updatedAt': now,
    });
    batch.set(notificationRef, {
      'userId': feeRef.id,
      'title': 'Payment verified',
      'message':
          'Your payment of RM ${transaction.amount.toStringAsFixed(2)} has been verified by treasury.',
      'type': 'success',
      'module': 'tuition',
      'isRead': false,
      'createdAt': now,
    });
    await batch.commit();
  }

  Future<void> rejectPayment(
    PaymentTransaction transaction,
    String remarks, {
    String treasuryId = 'treasury',
  }) async {
    final feeRef = await _findTuitionFeeReference(transaction);
    if (feeRef == null) {
      throw StateError('Student tuition fee record not found.');
    }

    final now = DateTime.now().toIso8601String();
    final notificationRef = _firestore.collection('notifications').doc();
    final batch = _firestore.batch();
    batch.update(transaction.reference, {
      'studentId': feeRef.id,
      'status': 'Rejected',
      'verifiedBy': treasuryId,
      'remarks': remarks.trim(),
      'updatedAt': now,
    });
    batch.update(feeRef, {
      'paymentStatus': 'Unpaid',
      'updatedAt': now,
    });
    batch.set(notificationRef, {
      'userId': feeRef.id,
      'title': 'Payment rejected by treasury',
      'message':
          'Your payment was rejected. Reason: ${remarks.trim().isEmpty ? 'Please contact treasury.' : remarks.trim()}',
      'type': 'danger',
      'module': 'tuition',
      'isRead': false,
      'createdAt': now,
    });
    await batch.commit();
  }

  Future<void> blockStudent(TuitionFees fee) async {
    await _firestore.collection('tuition_fees').doc(fee.id).update({
      'isBlocked': true,
    });
    await sendNotification(
      userId: fee.id,
      title: 'Academic access blocked',
      message:
          'Your academic access has been blocked by treasury. Please settle your outstanding fee.',
      type: 'danger',
    );
  }

  Future<void> unblockStudent(TuitionFees fee) async {
    await _firestore.collection('tuition_fees').doc(fee.id).update({
      'isBlocked': false,
    });
    await sendNotification(
      userId: fee.id,
      title: 'Academic access restored',
      message:
          'Your academic access has been restored. You can now register for classes and access records.',
      type: 'success',
    );
  }

  Stream<List<TuitionFees>> getAllTuitionFeesStream() {
    return _firestore.collection('tuition_fees').snapshots().map(
          (snapshot) => snapshot.docs.map(TuitionFees.fromDoc).toList(),
        );
  }

  Stream<List<PaymentTransaction>> getAllTransactionsStream() {
    return _firestore
        .collection('payment_transactions')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(PaymentTransaction.fromDoc).toList());
  }

  Stream<List<PaymentTransaction>> getPendingTransactionsStream() {
    return getAllTransactionsStream().map(
      (transactions) =>
          transactions.where((transaction) => transaction.isPending).toList(),
    );
  }

  Stream<List<TuitionFees>> getUnpaidStudentsStream() {
    return _firestore
        .collection('tuition_fees')
        .snapshots()
        .asyncMap((snapshot) async {
      final fees = snapshot.docs.map(TuitionFees.fromDoc).toList();
      final transactionSnapshot = await _firestore
          .collection('payment_transactions')
          .orderBy('createdAt', descending: true)
          .get();
      final transactions =
          transactionSnapshot.docs.map(PaymentTransaction.fromDoc).toList();

      return fees.where((fee) {
        final hasVerifiedPayment = transactions.any(
          (transaction) =>
              transaction.isVerified &&
              (transaction.studentId == fee.id ||
                  transaction.studentId == fee.studentId ||
                  (fee.matricId.isNotEmpty &&
                      transaction.matricId == fee.matricId)),
        );
        if (hasVerifiedPayment) return false;

        final status = fee.paymentStatus.trim().toLowerCase();
        return status == 'unpaid' || status == 'pending';
      }).toList();
    });
  }

  Future<DocumentReference<Map<String, dynamic>>?> _findTuitionFeeReference(
    PaymentTransaction transaction,
  ) async {
    if (transaction.studentId.isNotEmpty) {
      final byStudentId =
          _firestore.collection('tuition_fees').doc(transaction.studentId);
      final doc = await byStudentId.get();
      if (doc.exists) return byStudentId;
    }

    if (transaction.matricId.isEmpty) return null;
    final byMatric = await _firestore
        .collection('tuition_fees')
        .where('matricId', isEqualTo: transaction.matricId)
        .limit(1)
        .get();
    if (byMatric.docs.isEmpty) return null;
    return byMatric.docs.first.reference;
  }

  PaymentTransaction? _latestVerifiedTransaction(
    List<PaymentTransaction> transactions,
  ) {
    for (final transaction in transactions) {
      if (transaction.isVerified) return transaction;
    }
    return null;
  }

  bool _matchesTransaction(
    PaymentTransaction transaction,
    String uid,
    String? matricId,
  ) {
    final matric = matricId?.trim();
    return transaction.studentId == uid ||
        (matric != null && matric.isNotEmpty && transaction.matricId == matric);
  }

  bool _matchesUser(String userId, String uid, String? matricId) {
    final matric = matricId?.trim();
    return userId == uid || (matric != null && matric.isNotEmpty && userId == matric);
  }
}
