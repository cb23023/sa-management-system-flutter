class CreditClaimModel {
  const CreditClaimModel({
    required this.id,
    required this.studentId,
    required this.activityIds,
    required this.claimStatus,
    required this.totalHours,
    required this.totalCats,
    required this.averageMark,
    required this.remarks,
    required this.rejectionReason,
  });

  final String id;
  final String studentId;
  final List<String> activityIds;
  final String claimStatus;
  final int totalHours;
  final int totalCats;
  final int averageMark;
  final String remarks;
  final String rejectionReason;

  factory CreditClaimModel.fromMap(String id, Map<String, dynamic> data) {
    final rawActivityIds = data['activityIds'];
    return CreditClaimModel(
      id: id,
      studentId: (data['studentId'] ?? '').toString(),
      activityIds: rawActivityIds is Iterable
          ? rawActivityIds.map((item) => item.toString()).toList()
          : <String>[],
      claimStatus: (data['claimStatus'] ?? 'pending').toString(),
      totalHours: ((data['totalHours'] as num?)?.toInt() ?? 0),
      totalCats: ((data['totalCats'] as num?)?.toInt() ?? 0),
      averageMark: ((data['averageMark'] as num?)?.toInt() ?? 0),
      remarks: (data['remarks'] ?? '').toString(),
      rejectionReason: (data['rejectionReason'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'activityIds': activityIds,
      'claimStatus': claimStatus,
      'totalHours': totalHours,
      'totalCats': totalCats,
      'averageMark': averageMark,
      'remarks': remarks,
      'rejectionReason': rejectionReason,
    };
  }
}
