class ActivityModel {
  const ActivityModel({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.venue,
    required this.hours,
    required this.creditValue,
    required this.capacity,
    required this.availableSlots,
    required this.status,
  });

  final String id;
  final String title;
  final String category;
  final String date;
  final String venue;
  final int hours;
  final int creditValue;
  final int capacity;
  final int availableSlots;
  final String status;

  factory ActivityModel.fromMap(String id, Map<String, dynamic> data) {
    return ActivityModel(
      id: id,
      title: (data['title'] ?? data['name'] ?? id).toString(),
      category: (data['category'] ?? 'Co-Curriculum').toString(),
      date: (data['date'] ?? '').toString(),
      venue: (data['venue'] ?? '').toString(),
      hours: ((data['hours'] as num?)?.toInt() ?? 0),
      creditValue:
          ((data['creditValue'] ?? data['cats']) as num?)?.toInt() ?? 0,
      capacity: ((data['capacity'] as num?)?.toInt() ?? 0),
      availableSlots: ((data['availableSlots'] as num?)?.toInt() ?? 0),
      status: (data['status'] ?? 'Draft').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'date': date,
      'venue': venue,
      'hours': hours,
      'creditValue': creditValue,
      'capacity': capacity,
      'availableSlots': availableSlots,
      'status': status,
    };
  }
}
