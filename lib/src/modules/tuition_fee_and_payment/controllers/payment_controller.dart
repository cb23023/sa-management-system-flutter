import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/app_user.dart';
import '../models/tuition_fees.dart';

class PaymentController {
  PaymentController({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const validBanks = [
    'Maybank',
    'CIMB Bank',
    'Public Bank',
    'Hong Leong Bank',
    'RHB Bank',
    'Bank Islam',
    'AmBank',
    'UOB Malaysia',
  ];

  Stream<TuitionFees?> getTuitionFeeStream(String uid, {String? matricId}) {
    return _firestore
        .collection('tuition_fees')
        .doc(uid)
        .snapshots()
        .asyncMap((doc) async {
      final fee = doc.exists
          ? TuitionFees.fromDoc(doc)
          : await _findTuitionFee(uid, matricId: matricId);
      if (fee == null) return null;

      final verifiedTransaction =
          await _findLatestTransaction(uid, matricId: matricId, verifiedOnly: true);
      if (verifiedTransaction == null) return fee;

      return fee.copyWith(
        outstandingAmount: 0,
        paymentStatus: 'Paid',
        isBlocked: false,
        dueDate: '',
      );
    });
  }

  String? validatePaymentForm(String? method, String? bank, String account) {
    final accountText = account.trim();
    if (accountText.isEmpty) {
      return 'Please enter ${method == 'Online Transfer' ? 'account' : 'card'} number.';
    }
    if (method == 'Online Transfer') {
      if (bank == null) return 'Please select a bank.';
      if (!RegExp(r'^[0-9]{8,20}$').hasMatch(accountText)) {
        return 'Please enter a valid account number (8-20 digits).';
      }
    } else if (!RegExp(r'^[0-9]{12,19}$').hasMatch(accountText)) {
      return 'Please enter a valid card number (12-19 digits).';
    }
    return null;
  }

  String generateReferenceNo([DateTime? dateTime]) {
    final now = dateTime ?? DateTime.now();
    return 'TXN-${now.year}-${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch % 10000}';
  }

  Future<void> submitPayment({
    required AppUser? user,
    required double amount,
    required String? method,
    required String? bank,
    required String account,
  }) async {
    final now = DateTime.now();
    await _firestore.collection('payment_transactions').add({
      'studentId': user?.uid ?? '',
      'studentName': user?.fullName ?? '',
      'matricId': user?.identifier ?? '',
      'semester': user?.semester ?? '',
      'amount': amount,
      'referenceNo': generateReferenceNo(now),
      'paymentMethod': method,
      'bank': method == 'Online Transfer' ? bank : null,
      'accountOrCard': account.trim(),
      'bankRef': 'IB-${now.millisecondsSinceEpoch}',
      'status': 'Pending',
      'verifiedBy': '',
      'createdAt': now.toIso8601String(),
      'module': 'tuition',
    });

    if (user != null) {
      await _firestore
          .collection('tuition_fees')
          .doc(user.uid)
          .update({'paymentStatus': 'Pending'});
    }
  }

  Future<TuitionFees?> _findTuitionFee(String uid, {String? matricId}) async {
    final byUid = await _firestore.collection('tuition_fees').doc(uid).get();
    if (byUid.exists) return TuitionFees.fromDoc(byUid);

    final matric = matricId?.trim();
    if (matric == null || matric.isEmpty) return null;

    final byMatric = await _firestore
        .collection('tuition_fees')
        .where('matricId', isEqualTo: matric)
        .limit(1)
        .get();
    if (byMatric.docs.isEmpty) return null;
    return TuitionFees.fromDoc(byMatric.docs.first);
  }

  Future<QueryDocumentSnapshot<Map<String, dynamic>>?> _findLatestTransaction(
    String uid, {
    String? matricId,
    bool verifiedOnly = false,
  }) async {
    final snapshot = await _firestore
        .collection('payment_transactions')
        .orderBy('createdAt', descending: true)
        .get();
    final matric = matricId?.trim();
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final transactionUid = (data['studentId'] ?? '').toString();
      final transactionMatric = (data['matricId'] ?? '').toString();
      final status = (data['status'] ?? '').toString().trim().toLowerCase();
      final sameStudent = transactionUid == uid ||
          (matric != null && matric.isNotEmpty && transactionMatric == matric);
      if (!sameStudent) continue;
      if (verifiedOnly && status != 'verified') continue;
      return doc;
    }
    return null;
  }
}
