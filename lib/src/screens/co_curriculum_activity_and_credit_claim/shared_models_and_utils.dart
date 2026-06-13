part of 'co_curriculum_module_page.dart';

class _ActivityOption {
  const _ActivityOption({
    required this.title,
    required this.category,
    required this.description,
    required this.defaultVenue,
    required this.defaultLecturer,
    required this.defaultHours,
    required this.defaultCats,
    required this.defaultCapacity,
  });

  final String title;
  final String category;
  final String description;
  final String defaultVenue;
  final String defaultLecturer;
  final int defaultHours;
  final int defaultCats;
  final int defaultCapacity;
}

const List<_ActivityOption> _activityOptions = [
  _ActivityOption(
    title: 'Chess',
    category: 'Academic / Skills / Digital',
    description:
        'Structured strategy session focused on decision making, planning, and discipline.',
    defaultVenue: 'Seminar Hall',
    defaultLecturer: 'Dr. Nabilah Hassan',
    defaultHours: 8,
    defaultCats: 2,
    defaultCapacity: 30,
  ),
  _ActivityOption(
    title: 'Creative Arts',
    category: 'Academic / Skills / Digital',
    description:
        'Creative expression activity for collaborative art, presentation, and appreciation.',
    defaultVenue: 'Arts Studio',
    defaultLecturer: 'Pn. Salina Omar',
    defaultHours: 8,
    defaultCats: 2,
    defaultCapacity: 30,
  ),
  _ActivityOption(
    title: '3D Design and Printing',
    category: 'Academic / Skills / Digital',
    description:
        'Hands-on design workflow involving 3D modelling and print preparation.',
    defaultVenue: 'Innovation Lab',
    defaultLecturer: 'Ts. Amir Fikri',
    defaultHours: 8,
    defaultCats: 2,
    defaultCapacity: 24,
  ),
  _ActivityOption(
    title: 'Edit like a Pro with Canva',
    category: 'Academic / Skills / Digital',
    description:
        'Digital editing activity for poster, social media, and communication design skills.',
    defaultVenue: 'Digital Studio',
    defaultLecturer: 'Pn. Huda Zainal',
    defaultHours: 8,
    defaultCats: 2,
    defaultCapacity: 35,
  ),
  _ActivityOption(
    title: 'Digital Citizenship',
    category: 'Academic / Skills / Digital',
    description:
        'Activity on safe online engagement, digital ethics, and responsible participation.',
    defaultVenue: 'Lecture Room 2',
    defaultLecturer: 'Dr. Farah Nadia',
    defaultHours: 8,
    defaultCats: 2,
    defaultCapacity: 40,
  ),
  _ActivityOption(
    title: 'Click Wisely',
    category: 'Academic / Skills / Digital',
    description:
        'Awareness-based activity on cyber hygiene and informed digital behaviour.',
    defaultVenue: 'Lecture Room 3',
    defaultLecturer: 'Dr. Farah Nadia',
    defaultHours: 8,
    defaultCats: 2,
    defaultCapacity: 40,
  ),
  _ActivityOption(
    title: 'Outstanding Presentation',
    category: 'Academic / Skills / Digital',
    description:
        'Communication activity that strengthens presentation confidence and structure.',
    defaultVenue: 'Auditorium 1',
    defaultLecturer: 'Dr. Nurul Iman',
    defaultHours: 8,
    defaultCats: 2,
    defaultCapacity: 28,
  ),
  _ActivityOption(
    title: 'Proofreading',
    category: 'Academic / Skills / Digital',
    description:
        'Language support activity focused on grammar, editing, and document review.',
    defaultVenue: 'Language Lab',
    defaultLecturer: 'Pn. Zulaikha Rahman',
    defaultHours: 8,
    defaultCats: 2,
    defaultCapacity: 26,
  ),
  _ActivityOption(
    title: 'Fitness',
    category: 'Sports / Physical',
    description:
        'Physical wellness activity designed to improve stamina, movement, and endurance.',
    defaultVenue: 'Sports Complex',
    defaultLecturer: 'Encik Hafiz Roslan',
    defaultHours: 8,
    defaultCats: 2,
    defaultCapacity: 35,
  ),
  _ActivityOption(
    title: 'Kayak',
    category: 'Sports / Physical',
    description:
        'Outdoor skill activity focused on paddling technique, coordination, and safety.',
    defaultVenue: 'Lake Training Centre',
    defaultLecturer: 'Encik Danial Rizal',
    defaultHours: 8,
    defaultCats: 2,
    defaultCapacity: 22,
  ),
  _ActivityOption(
    title: 'Golf',
    category: 'Sports / Physical',
    description:
        'Precision sports activity covering basic swing, posture, and etiquette.',
    defaultVenue: 'Golf Practice Range',
    defaultLecturer: 'Encik Firdaus Hamid',
    defaultHours: 8,
    defaultCats: 2,
    defaultCapacity: 20,
  ),
  _ActivityOption(
    title: 'Archery',
    category: 'Sports / Physical',
    description:
        'Technical outdoor activity focused on aim, control, and range discipline.',
    defaultVenue: 'Archery Range',
    defaultLecturer: 'Encik Azrul Hakim',
    defaultHours: 8,
    defaultCats: 2,
    defaultCapacity: 24,
  ),
  _ActivityOption(
    title: 'Futsal',
    category: 'Sports / Physical',
    description:
        'Team-based sports activity that develops coordination, strategy, and fitness.',
    defaultVenue: 'Indoor Court',
    defaultLecturer: 'Encik Hafiz Roslan',
    defaultHours: 8,
    defaultCats: 2,
    defaultCapacity: 24,
  ),
  _ActivityOption(
    title: 'Grooming and Etiquette',
    category: 'Soft Skills / Development',
    description:
        'Professional development activity focused on conduct, image, and workplace etiquette.',
    defaultVenue: 'Seminar Room B',
    defaultLecturer: 'Pn. Aisyah Karim',
    defaultHours: 8,
    defaultCats: 2,
    defaultCapacity: 30,
  ),
  _ActivityOption(
    title: 'Event Management',
    category: 'Soft Skills / Development',
    description:
        'Leadership and coordination activity covering planning, execution, and teamwork.',
    defaultVenue: 'Convention Hall',
    defaultLecturer: 'Dr. Zulhilmi Saad',
    defaultHours: 8,
    defaultCats: 2,
    defaultCapacity: 30,
  ),
  _ActivityOption(
    title: 'Psychological First Aid',
    category: 'Mental / Health',
    description:
        'Support-focused activity on early response, empathy, and wellbeing awareness.',
    defaultVenue: 'Counselling Room',
    defaultLecturer: 'Dr. Siti Hajar',
    defaultHours: 8,
    defaultCats: 2,
    defaultCapacity: 25,
  ),
  _ActivityOption(
    title: 'Mental Health',
    category: 'Mental / Health',
    description:
        'Awareness activity that builds resilience, reflection, and healthy coping practices.',
    defaultVenue: 'Student Support Centre',
    defaultLecturer: 'Dr. Siti Hajar',
    defaultHours: 8,
    defaultCats: 2,
    defaultCapacity: 35,
  ),
  _ActivityOption(
    title: 'Iqra',
    category: 'Religious / Spiritual',
    description:
        'Religious learning activity focused on guided recitation and foundational reading.',
    defaultVenue: 'Islamic Centre Room 1',
    defaultLecturer: 'Ustazah Nur Afiqah',
    defaultHours: 8,
    defaultCats: 2,
    defaultCapacity: 25,
  ),
  _ActivityOption(
    title: 'Tauhid',
    category: 'Religious / Spiritual',
    description:
        'Religious enrichment activity focused on faith understanding and reflective learning.',
    defaultVenue: 'Islamic Centre Room 2',
    defaultLecturer: 'Ustaz Ahmad Faiz',
    defaultHours: 8,
    defaultCats: 2,
    defaultCapacity: 25,
  ),
  _ActivityOption(
    title: 'Al-Fatihah',
    category: 'Religious / Spiritual',
    description:
        'Spiritual learning activity centred on recitation accuracy and meaning appreciation.',
    defaultVenue: 'Islamic Centre Room 3',
    defaultLecturer: 'Ustaz Ahmad Faiz',
    defaultHours: 8,
    defaultCats: 2,
    defaultCapacity: 25,
  ),
];

String _displayDate(DateTime date) {
  const months = [
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
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

String _formatTime(TimeOfDay time) {
  final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final minute = time.minute.toString().padLeft(2, '0');
  final suffix = time.period == DayPeriod.am ? 'AM' : 'PM';
  return '$hour:$minute $suffix';
}

DateTime? _parseStoredDate(String? sessionDate, String? displayDate) {
  if (sessionDate != null && sessionDate.isNotEmpty) {
    final parts = sessionDate.split('-');
    if (parts.length == 3) {
      final year = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final day = int.tryParse(parts[2]);
      if (year != null && month != null && day != null) {
        return DateTime(year, month, day);
      }
    }
  }

  if (displayDate != null && displayDate.isNotEmpty) {
    final match = RegExp(
      r'^(\d{1,2})\s([A-Za-z]{3})\s(\d{4})$',
    ).firstMatch(displayDate.trim());
    if (match != null) {
      const monthMap = {
        'Jan': 1,
        'Feb': 2,
        'Mar': 3,
        'Apr': 4,
        'May': 5,
        'Jun': 6,
        'Jul': 7,
        'Aug': 8,
        'Sep': 9,
        'Oct': 10,
        'Nov': 11,
        'Dec': 12,
      };
      final day = int.tryParse(match.group(1) ?? '');
      final month = monthMap[match.group(2)];
      final year = int.tryParse(match.group(3) ?? '');
      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    }
  }

  return null;
}

TimeOfDay? _parseStoredTime(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }
  final match = RegExp(
    r'^(\d{1,2}):(\d{2})\s(AM|PM)$',
  ).firstMatch(value.trim());
  if (match == null) {
    return null;
  }
  final hour12 = int.tryParse(match.group(1) ?? '');
  final minute = int.tryParse(match.group(2) ?? '');
  final period = match.group(3);
  if (hour12 == null || minute == null || period == null) {
    return null;
  }

  var hour24 = hour12 % 12;
  if (period == 'PM') {
    hour24 += 12;
  }
  return TimeOfDay(hour: hour24, minute: minute);
}

DateTime? _parseDynamicDate(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is Timestamp) {
    return value.toDate();
  }
  if (value is DateTime) {
    return value;
  }
  final text = value.toString().trim();
  if (text.isEmpty) {
    return null;
  }
  return DateTime.tryParse(text);
}

String _moduleNotificationTag(String type) {
  switch (_safeLower(type)) {
    case 'success':
      return 'Success';
    case 'warning':
    case 'danger':
      return 'Alert';
    default:
      return 'Update';
  }
}

IconData _moduleNotificationIcon(String type) {
  switch (_safeLower(type)) {
    case 'success':
      return Icons.verified_outlined;
    case 'warning':
      return Icons.report_gmailerrorred_outlined;
    case 'danger':
      return Icons.error_outline;
    default:
      return Icons.notifications_active_outlined;
  }
}

Color _moduleNotificationColor(String type) {
  switch (_safeLower(type)) {
    case 'success':
      return AppColors.success;
    case 'warning':
      return AppColors.warning;
    case 'danger':
      return AppColors.danger;
    default:
      return AppColors.studentBlue;
  }
}

Color _moduleNotificationBackground(String type) {
  switch (_safeLower(type)) {
    case 'success':
      return AppColors.successSoft;
    case 'warning':
      return AppColors.warningSoft;
    case 'danger':
      return AppColors.dangerSoft;
    default:
      return AppColors.infoSoft;
  }
}

String _attendanceActivityId(Map<String, dynamic> data) {
  return (data['activityId'] ?? '').toString();
}

String _attendanceStatusText(Map<String, dynamic> data) {
  return (data['status'] ?? '').toString();
}

bool _isAttendancePresent(Map<String, dynamic> data) {
  final status = _safeLower(_attendanceStatusText(data));
  return status == 'present';
}

String _safeLower(dynamic value) {
  if (value == null) {
    return '';
  }
  return value.toString().toLowerCase();
}

String _userDisplayName(
  Map<String, dynamic>? userData, {
  String fallback = '',
}) {
  if (userData == null) {
    return fallback;
  }
  return (userData['fullName'] ??
          userData['name'] ??
          userData['email'] ??
          fallback)
      .toString();
}

String? _requiredField(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Required';
  }
  return null;
}

String? _numberField(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Required';
  }
  if (int.tryParse(value.trim()) == null) {
    return 'Enter number';
  }
  return null;
}
