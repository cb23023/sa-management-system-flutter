import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class TuitionFees {
  const TuitionFees({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.matricId,
    required this.semester,
    required this.programme,
    required this.programFee,
    required this.otherFee,
    required this.outstandingAmount,
    required this.paymentStatus,
    required this.isBlocked,
    required this.dueDate,
    required this.updatedAt,
  });

  final String id;
  final String studentId;
  final String studentName;
  final String matricId;
  final String semester;
  final String programme;
  final double programFee;
  final double otherFee;
  final double outstandingAmount;
  final String paymentStatus;
  final bool isBlocked;
  final String dueDate;
  final String updatedAt;

  double get totalFee => programFee + otherFee;
  bool get isAccessBlocked => isBlocked;

  Color get statusColor {
    if (paymentStatus == 'Paid' || paymentStatus == 'Verified') {
      return AppColors.success;
    }
    if (paymentStatus == 'Pending') return AppColors.warning;
    return AppColors.danger;
  }

  factory TuitionFees.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return TuitionFees(
      id: doc.id,
      studentId: (data['studentId'] ?? doc.id).toString(),
      studentName: (data['studentName'] ?? '').toString(),
      matricId: (data['matricId'] ?? '').toString(),
      semester: (data['semester'] ?? '').toString(),
      programme: (data['programme'] ?? '').toString(),
      programFee: (data['programFee'] as num?)?.toDouble() ?? 0.0,
      otherFee: (data['otherFee'] as num?)?.toDouble() ?? 0.0,
      outstandingAmount:
          (data['outstandingAmount'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: (data['paymentStatus'] ?? 'Unpaid').toString(),
      isBlocked: (data['isBlocked'] as bool?) ?? false,
      dueDate: (data['dueDate'] ?? '').toString(),
      updatedAt: (data['updatedAt'] ?? '').toString(),
    );
  }

  TuitionFees copyWith({
    double? outstandingAmount,
    String? paymentStatus,
    bool? isBlocked,
    String? dueDate,
    String? updatedAt,
  }) {
    return TuitionFees(
      id: id,
      studentId: studentId,
      studentName: studentName,
      matricId: matricId,
      semester: semester,
      programme: programme,
      programFee: programFee,
      otherFee: otherFee,
      outstandingAmount: outstandingAmount ?? this.outstandingAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      isBlocked: isBlocked ?? this.isBlocked,
      dueDate: dueDate ?? this.dueDate,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
