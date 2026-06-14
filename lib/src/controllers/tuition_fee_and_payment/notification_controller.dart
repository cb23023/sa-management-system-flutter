import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/tuition_fee_and_payment/notification.dart';
import '../../models/tuition_fee_and_payment/payment_transactions.dart';
import '../../models/tuition_fee_and_payment/tuition_fees.dart';

// SRS REQ-304 to REQ-307 and SDD NotificationController:
// manages payment notices, Treasury verification, and academic access control.
class NotificationController {
  NotificationController({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<TuitionNotification>> getNotificationStream(
    String uid, {
    String? matricId,
  }) {
    // Combines saved Firestore notices with generated payment state notices so
    // students can see pending/verified payment updates required by the SRS.
    return _firestore
        .collection('payment_transactions')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          final transactionDocs = snapshot.docs
              .map(PaymentTransaction.fromDoc)
              .where(
                (transaction) =>
                    _matchesTransaction(transaction, uid, matricId),
              )
              .toList();
          final verifiedTransaction = _latestVerifiedTransaction(
            transactionDocs,
          );
          final pendingTransaction = _latestPendingTransaction(transactionDocs);

          final notificationSnapshot = await _firestore
              .collection('notifications')
              .where('module', isEqualTo: 'tuition')
              .get();
          final notifications = notificationSnapshot.docs
              .map(TuitionNotification.fromDoc)
              .where(
                (notification) =>
                    _matchesUser(notification.userId, uid, matricId),
              )
              .toList();
          final hasVerifiedNotice = notifications.any(
            (notification) =>
                notification.title.trim().toLowerCase() == 'payment verified',
          );
          if (verifiedTransaction != null && !hasVerifiedNotice) {
            notifications.add(
              TuitionNotification(
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
              ),
            );
          }
          final hasPendingNotice = notifications.any(
            (notification) =>
                notification.title.trim().toLowerCase() ==
                'pending treasury verification',
          );
          if (pendingTransaction != null &&
              verifiedTransaction == null &&
              !hasPendingNotice) {
            notifications.add(
              TuitionNotification(
                id: 'generated-pending-${pendingTransaction.id}',
                userId: uid,
                title: 'Pending Treasury verification',
                message:
                    'Your payment of RM ${pendingTransaction.amount.toStringAsFixed(2)} has been submitted and is waiting for Treasury verification.',
                type: 'warning',
                module: 'tuition',
                isRead: false,
                createdAt: pendingTransaction.updatedAt.isNotEmpty
                    ? pendingTransaction.updatedAt
                    : pendingTransaction.createdAt,
              ),
            );
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
    // Treasury verification updates the transaction, clears outstanding fees,
    // restores academic access, and creates the digital payment notification.
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
      'accessStatus': 'Active',
      'blockedReason': '',
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
    // Rejected payments return the fee record to unpaid status and notify the
    // student to resubmit valid payment details.
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
      'accessStatus': 'Active',
      'blockedReason': '',
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
    // Implements the Week 5 academic access restriction described in SRS/SDD.
    final now = DateTime.now().toIso8601String();
    final reason = fee.blockedReason.isNotEmpty
        ? fee.blockedReason
        : 'Payment not completed before Week ${fee.dueWeek} deadline.';
    await _firestore.collection('tuition_fees').doc(fee.id).update({
      'isBlocked': true,
      'accessStatus': 'Blocked',
      'blockedReason': reason,
      'updatedAt': now,
    });
    await sendNotification(
      userId: fee.id,
      title: 'Academic access blocked',
      message: 'Your academic access has been blocked by treasury. $reason',
      type: 'danger',
    );
  }

  Future<void> unblockStudent(TuitionFees fee) async {
    // Restores access after payment settlement or Treasury approval.
    final now = DateTime.now().toIso8601String();
    await _firestore.collection('tuition_fees').doc(fee.id).update({
      'isBlocked': false,
      'accessStatus': 'Active',
      'blockedReason': '',
      'updatedAt': now,
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
    return _firestore
        .collection('tuition_fees')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(TuitionFees.fromDoc).toList());
  }

  Stream<List<PaymentTransaction>> getAllTransactionsStream() {
    return _firestore
        .collection('payment_transactions')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(PaymentTransaction.fromDoc).toList(),
        );
  }

  Stream<List<PaymentTransaction>> getPendingTransactionsStream() {
    return getAllTransactionsStream().map(
      (transactions) =>
          transactions.where((transaction) => transaction.isPending).toList(),
    );
  }

  Stream<List<TuitionFees>> getUnpaidStudentsStream() {
    // Feeds the Treasury Access Control page with unpaid, pending, or blocked
    // students who require payment follow-up before academic access is allowed.
    return _firestore.collection('tuition_fees').snapshots().asyncMap((
      snapshot,
    ) async {
      final fees = snapshot.docs.map(TuitionFees.fromDoc).toList();
      final transactionSnapshot = await _firestore
          .collection('payment_transactions')
          .orderBy('createdAt', descending: true)
          .get();
      final transactions = transactionSnapshot.docs
          .map(PaymentTransaction.fromDoc)
          .toList();

      return fees.where((fee) {
        final status = fee.paymentStatus.trim().toLowerCase();
        final accessStatus = fee.accessStatus.trim().toLowerCase();
        final dueDate = _parseDueDate(fee.dueDate);
        final isPastWeekFiveDeadline =
            dueDate != null && DateTime.now().isAfter(dueDate);
        final requiresAccessReview =
            isPastWeekFiveDeadline && status != 'paid' && status != 'verified';
        final isExplicitlyBlocked = fee.isBlocked || accessStatus == 'blocked';

        if (isExplicitlyBlocked || status == 'unpaid') {
          return true;
        }

        final hasVerifiedPayment = transactions.any(
          (transaction) =>
              transaction.isVerified &&
              (transaction.studentId == fee.id ||
                  transaction.studentId == fee.studentId ||
                  (fee.matricId.isNotEmpty &&
                      transaction.matricId == fee.matricId)),
        );
        if (hasVerifiedPayment) return false;

        return status == 'pending' || requiresAccessReview;
      }).toList();
    });
  }

  Future<DocumentReference<Map<String, dynamic>>?> _findTuitionFeeReference(
    PaymentTransaction transaction,
  ) async {
    // Matches a transaction back to the student's fee document by uid first,
    // then matric ID as a fallback for imported or seeded records.
    if (transaction.studentId.isNotEmpty) {
      final byStudentId = _firestore
          .collection('tuition_fees')
          .doc(transaction.studentId);
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
    // The newest verified transaction is used to show successful payment status
    // and generated receipt notices.
    for (final transaction in transactions) {
      if (transaction.isVerified) return transaction;
    }
    return null;
  }

  PaymentTransaction? _latestPendingTransaction(
    List<PaymentTransaction> transactions,
  ) {
    // The newest pending transaction is used to show "waiting for Treasury"
    // feedback after the student submits payment.
    for (final transaction in transactions) {
      if (transaction.isPending) return transaction;
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
    return userId == uid ||
        (matric != null && matric.isNotEmpty && userId == matric);
  }

  DateTime? _parseDueDate(String value) {
    // Parses seed/prototype due date text such as "28 Apr 2026" for Week 5
    // access review logic.
    final parts = value.trim().split(RegExp(r'\s+'));
    if (parts.length != 3) return null;

    final day = int.tryParse(parts[0]);
    final year = int.tryParse(parts[2]);
    const months = {
      'jan': 1,
      'feb': 2,
      'mar': 3,
      'apr': 4,
      'may': 5,
      'jun': 6,
      'jul': 7,
      'aug': 8,
      'sep': 9,
      'oct': 10,
      'nov': 11,
      'dec': 12,
    };
    final monthText = parts[1].toLowerCase();
    if (monthText.length < 3) return null;
    final month = months[monthText.substring(0, 3)];
    if (day == null || month == null || year == null) return null;

    return DateTime(year, month, day, 23, 59, 59);
  }
}
