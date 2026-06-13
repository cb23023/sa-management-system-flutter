import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class PaymentTransaction {
  const PaymentTransaction({
    required this.id,
    required this.reference,
    required this.studentId,
    required this.studentName,
    required this.matricId,
    required this.semester,
    required this.amount,
    required this.referenceNo,
    required this.paymentMethod,
    required this.bank,
    required this.accountOrCard,
    required this.bankRef,
    required this.status,
    required this.verifiedBy,
    required this.remarks,
    required this.module,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final DocumentReference reference;
  final String studentId;
  final String studentName;
  final String matricId;
  final String semester;
  final double amount;
  final String referenceNo;
  final String paymentMethod;
  final String bank;
  final String accountOrCard;
  final String bankRef;
  final String status;
  final String verifiedBy;
  final String remarks;
  final String module;
  final String createdAt;
  final String updatedAt;

  String get normalizedStatus => status.trim().toLowerCase();

  bool get isVerified => normalizedStatus == 'verified';
  bool get isPending => normalizedStatus == 'pending';
  bool get isRejected => normalizedStatus == 'rejected';

  Color get statusColor {
    if (isVerified) return AppColors.success;
    if (isRejected) return AppColors.danger;
    return AppColors.warning;
  }

  String get formattedDate => formatDate(createdAt);

  factory PaymentTransaction.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return PaymentTransaction(
      id: doc.id,
      reference: doc.reference,
      studentId: (data['studentId'] ?? '').toString(),
      studentName: (data['studentName'] ?? '').toString(),
      matricId: (data['matricId'] ?? '').toString(),
      semester: (data['semester'] ?? '').toString(),
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      referenceNo: (data['referenceNo'] ?? '-').toString(),
      paymentMethod: (data['paymentMethod'] ?? '-').toString(),
      bank: (data['bank'] ?? '').toString(),
      accountOrCard: (data['accountOrCard'] ?? '').toString(),
      bankRef: (data['bankRef'] ?? '-').toString(),
      status: (data['status'] ?? 'Pending').toString(),
      verifiedBy: (data['verifiedBy'] ?? '').toString(),
      remarks: (data['remarks'] ?? '').toString(),
      module: (data['module'] ?? 'tuition').toString(),
      createdAt: (data['createdAt'] ?? '').toString(),
      updatedAt: (data['updatedAt'] ?? '').toString(),
    );
  }

  static String formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '-';
    try {
      final dt = DateTime.parse(iso);
      const months = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month]} ${dt.year}';
    } catch (_) {
      return iso;
    }
  }
}
