import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../models/tuition_fee_and_payment/payment_transactions.dart';

class ReceiptController {
  ReceiptController({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<PaymentTransaction?> getReceiptStream(String uid, {String? matricId}) {
    return _firestore
        .collection('payment_transactions')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final transactions = snapshot.docs
          .map(PaymentTransaction.fromDoc)
          .where((transaction) => _matchesStudent(transaction, uid, matricId))
          .toList();
      if (transactions.isEmpty) return null;
      final verified = transactions.where((transaction) => transaction.isVerified);
      return verified.isEmpty ? null : verified.first;
    });
  }

  Stream<List<PaymentTransaction>> getAllReceiptsStream(
    String uid, {
    String? matricId,
  }) {
    return _firestore
        .collection('payment_transactions')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map(PaymentTransaction.fromDoc)
            .where((transaction) => _matchesStudent(transaction, uid, matricId))
            .toList());
  }

  Future<void> exportReceiptPdf(PaymentTransaction transaction) async {
    if (!transaction.isVerified) {
      throw StateError('Receipt is only available for verified payments.');
    }

    final document = pw.Document();
    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'SA Management System',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                'Tuition Fee Payment Receipt',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 24),
              pw.Divider(),
              _pdfRow('Student name', transaction.studentName),
              _pdfRow('Matric ID', transaction.matricId),
              _pdfRow('Reference number', transaction.referenceNo),
              _pdfRow(
                'Amount',
                'RM ${transaction.amount.toStringAsFixed(2)}',
              ),
              _pdfRow('Payment date', transaction.formattedDate),
              _pdfRow('Payment method', transaction.paymentMethod),
              _pdfRow('Payment status', transaction.status),
              pw.Divider(),
              pw.SizedBox(height: 16),
              pw.Text(
                'This receipt was generated electronically by SA Management System.',
                style: const pw.TextStyle(fontSize: 10),
              ),
            ],
          );
        },
      ),
    );

    final bytes = await document.save();
    final reference = transaction.referenceNo.replaceAll(
      RegExp(r'[^A-Za-z0-9_-]'),
      '-',
    );
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'receipt-$reference.pdf',
    );
  }

  pw.Widget _pdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 150,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(child: pw.Text(value.isEmpty ? '-' : value)),
        ],
      ),
    );
  }

  bool _matchesStudent(
    PaymentTransaction transaction,
    String uid,
    String? matricId,
  ) {
    final matric = matricId?.trim();
    return transaction.studentId == uid ||
        (matric != null && matric.isNotEmpty && transaction.matricId == matric);
  }
}
