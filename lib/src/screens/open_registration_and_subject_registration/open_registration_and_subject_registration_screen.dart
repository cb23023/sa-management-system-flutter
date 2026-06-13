import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/app_user.dart';
import '../../theme/app_colors.dart';
import '../../modules/module_shell_screen.dart';
import '../../models/open_registration_and_subject_registration/course.dart';
import '../../models/open_registration_and_subject_registration/registration.dart';
import '../../controllers/open_registration_and_subject_registration/course_controller.dart';
import '../../controllers/open_registration_and_subject_registration/registration_controller.dart';
import '../../controllers/open_registration_and_subject_registration/notification_controller.dart';

class OpenRegistrationAndSubjectRegistrationScreen extends StatefulWidget {
  const OpenRegistrationAndSubjectRegistrationScreen({
    super.key,
    required this.user,
  });

  final AppUser user;

  @override
  State<OpenRegistrationAndSubjectRegistrationScreen> createState() =>
      _OpenRegistrationAndSubjectRegistrationScreenState();
}

class _OpenRegistrationAndSubjectRegistrationScreenState
    extends State<OpenRegistrationAndSubjectRegistrationScreen> {
  UserRole get _userRole {
    final rawRole = widget.user.role.toLowerCase().trim();

    if (rawRole == 'registrar' || rawRole == 'faculty' || rawRole == 'faculty_registrar' ||
        rawRole == 'registration' || rawRole == 'staff' || rawRole.contains('registrar') || rawRole.contains('faculty')) {
      return UserRole.registrar;
    }

    if (rawRole == 'lecturer') {
      return UserRole.lecturer;
    }

    if (rawRole == 'student') {
      return UserRole.student;
    }

    debugPrint('Unknown role: ${widget.user.role}, defaulting to student');
    return UserRole.student;
  }

  final _courses = <Course>[
    Course(
      code: 'BCI1023',
      name: 'Programming Techniques',
      credits: 3,
      schedule: 'Mon 10:00–12:00 (DK1)',
      instructor: 'Dr. Ahmad Malik',
      capacity: 40,
      enrolled: 0,
      sections: {
        '01': ['01A', '01B'],
        '02': ['02A', '02B'],
      },
      sessionDetails: {
        '01': CourseSessionDetail(sectionCode: '01', type: 'Lecture', day: 'Mon', time: '10:00–12:00', location: 'DK1'),
        '01A': CourseSessionDetail(sectionCode: '01A', type: 'Lab', day: 'Tue', time: '14:00–16:00', location: 'Makmal Komputer 1'),
        '01B': CourseSessionDetail(sectionCode: '01B', type: 'Lab', day: 'Wed', time: '08:00–10:00', location: 'Makmal Komputer 2'),
        '02': CourseSessionDetail(sectionCode: '02', type: 'Lecture', day: 'Thu', time: '10:00–12:00', location: 'DK1'),
        '02A': CourseSessionDetail(sectionCode: '02A', type: 'Lab', day: 'Fri', time: '14:00–16:00', location: 'Makmal Komputer 1'),
        '02B': CourseSessionDetail(sectionCode: '02B', type: 'Lab', day: 'Fri', time: '08:00–10:00', location: 'Makmal Komputer 2'),
      },
    ),
    Course(
      code: 'BCI1143',
      name: 'Problem Solving',
      credits: 3,
      schedule: 'Tue 10:00–12:00 (DK2)',
      instructor: 'Dr. Siti Aisyah',
      capacity: 40,
      enrolled: 0,
      sections: {
        '01': ['01A', '01B', '01C'],
      },
      sessionDetails: {
        '01': CourseSessionDetail(sectionCode: '01', type: 'Lecture', day: 'Tue', time: '10:00–12:00', location: 'DK2'),
        '01A': CourseSessionDetail(sectionCode: '01A', type: 'Tutorial', day: 'Thu', time: '14:00–15:00', location: 'Bilik Tutorial 1'),
        '01B': CourseSessionDetail(sectionCode: '01B', type: 'Tutorial', day: 'Thu', time: '15:00–16:00', location: 'Bilik Tutorial 2'),
        '01C': CourseSessionDetail(sectionCode: '01C', type: 'Tutorial', day: 'Fri', time: '10:00–11:00', location: 'Bilik Tutorial 3'),
      },
    ),
    Course(
      code: 'BCI1033',
      name: 'Programming Techniques',
      credits: 3,
      schedule: 'Mon 08:00-10:00 (DK1)',
      instructor: 'Dr. Syed Anwar',
      capacity: 40,
      enrolled: 0,
      sections: {
        '08A': ['08P'],
        '08B': ['08P'],
      },
      sessionDetails: {
        '08A': CourseSessionDetail(sectionCode: '08A', type: 'Lecture', day: 'Mon', time: '08:00–10:00', location: 'DK1'),
        '08B': CourseSessionDetail(sectionCode: '08B', type: 'Lecture', day: 'Tue', time: '10:00–12:00', location: 'DK2'),
        '08P': CourseSessionDetail(sectionCode: '08P', type: 'Lab', day: 'Wed', time: '12:00–14:00', location: 'Makmal Komputer 2'),
      },
    ),
    Course(
      code: 'BCI1093',
      name: 'Data Structure & Algorithms',
      credits: 4,
      schedule: 'Tue 10:00-12:00 (DK2)',
      instructor: 'Dr. Dina Hirzi',
      capacity: 45,
      enrolled: 0,
      sections: {
        '09': ['09P'],
        '10': ['10P'],
        '11': ['11P'],
      },
      sessionDetails: {
        '09': CourseSessionDetail(sectionCode: '09', type: 'Lecture', day: 'Mon', time: '08:00–10:00', location: 'DK1'),
        '09P': CourseSessionDetail(sectionCode: '09P', type: 'Lab', day: 'Tue', time: '10:00–12:00', location: 'Makmal Komputer 1'),
        '10': CourseSessionDetail(sectionCode: '10', type: 'Lecture', day: 'Tue', time: '10:00–12:00', location: 'DK2'),
        '10P': CourseSessionDetail(sectionCode: '10P', type: 'Lab', day: 'Wed', time: '12:00–14:00', location: 'Makmal Komputer 2'),
        '11': CourseSessionDetail(sectionCode: '11', type: 'Lecture', day: 'Wed', time: '12:00–14:00', location: 'DK3'),
        '11P': CourseSessionDetail(sectionCode: '11P', type: 'Lab', day: 'Thu', time: '14:00–16:00', location: 'Makmal Komputer 3'),
      },
    ),
    Course(
      code: 'BCI2033',
      name: 'Data Structure & Algorithms',
      credits: 4,
      schedule: 'Tue 10:00-12:00 (DK2)',
      instructor: 'Dr. Rizal Mansor',
      capacity: 40,
      enrolled: 0,
      sections: {
        '01': ['01A'],
      },
      sessionDetails: {
        '01': CourseSessionDetail(sectionCode: '01', type: 'Lecture', day: 'Mon', time: '08:00–10:00', location: 'DK1'),
        '01A': CourseSessionDetail(sectionCode: '01A', type: 'Tutorial', day: 'Tue', time: '10:00–12:00', location: 'Bilik Tutorial 1'),
      },
    ),
    Course(
      code: 'BCI2313',
      name: 'Algorithm & Complexity',
      credits: 3,
      schedule: 'Wed 12:00-14:00 (DK3)',
      instructor: 'Dr. Nor Azlan',
      capacity: 40,
      enrolled: 0,
      sections: {
        '01': ['01A'],
      },
      sessionDetails: {
        '01': CourseSessionDetail(sectionCode: '01', type: 'Lecture', day: 'Mon', time: '08:00–10:00', location: 'DK1'),
        '01A': CourseSessionDetail(sectionCode: '01A', type: 'Tutorial', day: 'Tue', time: '10:00–12:00', location: 'Bilik Tutorial 1'),
      },
    ),
    Course(
      code: 'BCI2323',
      name: 'Web Development',
      credits: 3,
      schedule: 'Thu 14:00-16:00 (DK4)',
      instructor: 'Dr. Mei Lin',
      capacity: 35,
      enrolled: 0,
      sections: {
        '01': ['01A'],
      },
      sessionDetails: {
        '01': CourseSessionDetail(sectionCode: '01', type: 'Lecture', day: 'Mon', time: '08:00–10:00', location: 'DK1'),
        '01A': CourseSessionDetail(sectionCode: '01A', type: 'Tutorial', day: 'Tue', time: '10:00–12:00', location: 'Bilik Tutorial 1'),
      },
    ),
    Course(
      code: 'BCI2353',
      name: 'Algorithm & Complexity',
      credits: 3,
      schedule: 'Tue 10:00-12:00 (DK2)',
      instructor: 'Dr. Faizah Rahman',
      capacity: 40,
      enrolled: 0,
      sections: {
        '01': ['01A'],
      },
      sessionDetails: {
        '01': CourseSessionDetail(sectionCode: '01', type: 'Lecture', day: 'Mon', time: '08:00–10:00', location: 'DK1'),
        '01A': CourseSessionDetail(sectionCode: '01A', type: 'Tutorial', day: 'Tue', time: '10:00–12:00', location: 'Bilik Tutorial 1'),
      },
    ),
    Course(
      code: 'BCI3302',
      name: 'Project Management & Professional Practice',
      credits: 3,
      schedule: 'Tue 10:00-12:00 (DK2)',
      instructor: 'Dr. Azmi Hashim',
      capacity: 35,
      enrolled: 0,
      sections: {
        '01': ['01A'],
      },
      sessionDetails: {
        '01': CourseSessionDetail(sectionCode: '01', type: 'Lecture', day: 'Mon', time: '08:00–10:00', location: 'DK1'),
        '01A': CourseSessionDetail(sectionCode: '01A', type: 'Tutorial', day: 'Tue', time: '10:00–12:00', location: 'Bilik Tutorial 1'),
      },
    ),
    Course(
      code: 'BCI3313',
      name: 'IoT Data Integration',
      credits: 3,
      schedule: 'Thu 14:00-16:00 (DK4)',
      instructor: 'Dr. Hani Iskandar',
      capacity: 30,
      enrolled: 0,
      sections: {
        '01': ['01A'],
      },
      sessionDetails: {
        '01': CourseSessionDetail(sectionCode: '01', type: 'Lecture', day: 'Mon', time: '08:00–10:00', location: 'DK1'),
        '01A': CourseSessionDetail(sectionCode: '01A', type: 'Tutorial', day: 'Tue', time: '10:00–12:00', location: 'Bilik Tutorial 1'),
      },
    ),
    Course(
      code: 'BCI3323',
      name: 'IoT Application Development',
      credits: 3,
      schedule: 'Fri 16:00-18:00 (DK5)',
      instructor: 'Dr. Nadia Safi',
      capacity: 30,
      enrolled: 0,
      sections: {
        '01': ['01A'],
      },
      sessionDetails: {
        '01': CourseSessionDetail(sectionCode: '01', type: 'Lecture', day: 'Mon', time: '08:00–10:00', location: 'DK1'),
        '01A': CourseSessionDetail(sectionCode: '01A', type: 'Tutorial', day: 'Tue', time: '10:00–12:00', location: 'Bilik Tutorial 1'),
      },
    ),
    Course(
      code: 'BCI3333',
      name: 'Machine Learning Applications',
      credits: 4,
      schedule: 'Mon 08:00-10:00 (DK1)',
      instructor: 'Dr. Kamal Idris',
      capacity: 35,
      enrolled: 0,
      sections: {
        '01': ['01A', '01B'],
      },
      sessionDetails: {
        '01': CourseSessionDetail(sectionCode: '01', type: 'Lecture', day: 'Mon', time: '08:00–10:00', location: 'DK1'),
        '01A': CourseSessionDetail(sectionCode: '01A', type: 'Tutorial', day: 'Tue', time: '10:00–12:00', location: 'Bilik Tutorial 1'),
        '01B': CourseSessionDetail(sectionCode: '01B', type: 'Tutorial', day: 'Wed', time: '12:00–14:00', location: 'Bilik Tutorial 2'),
      },
    ),
    Course(
      code: 'BCI3353',
      name: 'Blockchain Technology',
      credits: 3,
      schedule: 'Wed 12:00-14:00 (DK3)',
      instructor: 'Dr. Laila Omar',
      capacity: 30,
      enrolled: 0,
      sections: {
        '01': ['01A'],
      },
      sessionDetails: {
        '01': CourseSessionDetail(sectionCode: '01', type: 'Lecture', day: 'Mon', time: '08:00–10:00', location: 'DK1'),
        '01A': CourseSessionDetail(sectionCode: '01A', type: 'Tutorial', day: 'Tue', time: '10:00–12:00', location: 'Bilik Tutorial 1'),
      },
    ),
    Course(
      code: 'BCI3363',
      name: 'Mobile Application Development',
      credits: 4,
      schedule: 'Thu 14:00-16:00 (DK4)',
      instructor: 'Dr. Aina Roslan',
      capacity: 35,
      enrolled: 0,
      sections: {
        '01': ['01A', '01B'],
      },
      sessionDetails: {
        '01': CourseSessionDetail(sectionCode: '01', type: 'Lecture', day: 'Mon', time: '08:00–10:00', location: 'DK1'),
        '01A': CourseSessionDetail(sectionCode: '01A', type: 'Tutorial', day: 'Tue', time: '10:00–12:00', location: 'Bilik Tutorial 1'),
        '01B': CourseSessionDetail(sectionCode: '01B', type: 'Tutorial', day: 'Wed', time: '12:00–14:00', location: 'Bilik Tutorial 2'),
      },
    ),
    Course(
      code: 'BCN1083',
      name: 'Data Communication & Networking',
      credits: 3,
      schedule: 'Wed 10:00–12:00 (DK3)',
      instructor: 'Prof. Zaki Hassan',
      capacity: 40,
      enrolled: 0,
      sections: {
        '01': ['01A', '01B'],
      },
      sessionDetails: {
        '01': CourseSessionDetail(sectionCode: '01', type: 'Lecture', day: 'Wed', time: '10:00–12:00', location: 'DK3'),
        '01A': CourseSessionDetail(sectionCode: '01A', type: 'Lab', day: 'Fri', time: '08:00–10:00', location: 'Network Lab'),
        '01B': CourseSessionDetail(sectionCode: '01B', type: 'Lab', day: 'Fri', time: '10:00–12:00', location: 'Network Lab'),
      },
    ),
    Course(
      code: 'BCN2053',
      name: 'Operating Systems',
      credits: 4,
      schedule: 'Mon 08:00–10:00 (DK4)',
      instructor: 'Prof. Nurul Farah',
      capacity: 40,
      enrolled: 0,
      sections: {
        '01': ['01A', '01B'],
        '02': ['02A', '02B'],
      },
      sessionDetails: {
        '01': CourseSessionDetail(sectionCode: '01', type: 'Lecture', day: 'Mon', time: '08:00–10:00', location: 'DK4'),
        '01A': CourseSessionDetail(sectionCode: '01A', type: 'Lab', day: 'Tue', time: '10:00–12:00', location: 'Makmal Komputer 3'),
        '01B': CourseSessionDetail(sectionCode: '01B', type: 'Lab', day: 'Wed', time: '14:00–16:00', location: 'Makmal Komputer 3'),
        '02': CourseSessionDetail(sectionCode: '02', type: 'Lecture', day: 'Thu', time: '08:00–10:00', location: 'DK4'),
        '02A': CourseSessionDetail(sectionCode: '02A', type: 'Lab', day: 'Fri', time: '10:00–12:00', location: 'Makmal Komputer 3'),
        '02B': CourseSessionDetail(sectionCode: '02B', type: 'Lab', day: 'Fri', time: '14:00–16:00', location: 'Makmal Komputer 3'),
      },
    ),
    Course(
      code: 'BCN2173',
      name: 'Operating Systems',
      credits: 4,
      schedule: 'Tue 10:00-12:00 (DK2)',
      instructor: 'Prof. Iqram Hakim',
      capacity: 40,
      enrolled: 0,
      sections: {
        '01': ['01A'],
      },
      sessionDetails: {
        '01': CourseSessionDetail(sectionCode: '01', type: 'Lecture', day: 'Mon', time: '08:00–10:00', location: 'DK1'),
        '01A': CourseSessionDetail(sectionCode: '01A', type: 'Tutorial', day: 'Tue', time: '10:00–12:00', location: 'Bilik Tutorial 1'),
      },
    ),
    Course(
      code: 'BCN3173',
      name: 'Embedded System Application & Design',
      credits: 4,
      schedule: 'Wed 12:00-14:00 (DK3)',
      instructor: 'Prof. Mona Yasmin',
      capacity: 35,
      enrolled: 0,
      sections: {
        '01': ['01A'],
      },
      sessionDetails: {
        '01': CourseSessionDetail(sectionCode: '01', type: 'Lecture', day: 'Mon', time: '08:00–10:00', location: 'DK1'),
        '01A': CourseSessionDetail(sectionCode: '01A', type: 'Tutorial', day: 'Tue', time: '10:00–12:00', location: 'Bilik Tutorial 1'),
      },
    ),
    Course(
      code: 'BCN3243',
      name: 'Cloud Computing Technology',
      credits: 3,
      schedule: 'Mon 08:00-10:00 (DK1)',
      instructor: 'Prof. Farzana Azmi',
      capacity: 30,
      enrolled: 0,
      sections: {
        '01': ['01A'],
      },
      sessionDetails: {
        '01': CourseSessionDetail(sectionCode: '01', type: 'Lecture', day: 'Mon', time: '08:00–10:00', location: 'DK1'),
        '01A': CourseSessionDetail(sectionCode: '01A', type: 'Tutorial', day: 'Tue', time: '10:00–12:00', location: 'Bilik Tutorial 1'),
      },
    ),
    Course(
      code: 'BCN3273',
      name: 'Distributed & Parallel Computing',
      credits: 3,
      schedule: 'Mon 10:00–12:00 (DK7)',
      instructor: 'Prof. Syahir Rahman',
      capacity: 30,
      enrolled: 0,
      sections: {
        '07A': ['07P'],
        '07B': [],
      },
      sessionDetails: {
        '07A': CourseSessionDetail(sectionCode: '07A', type: 'Lecture', day: 'Mon', time: '10:00–12:00', location: 'DK7'),
        '07B': CourseSessionDetail(sectionCode: '07B', type: 'Lecture', day: 'Wed', time: '10:00–12:00', location: 'DK7'),
        '07P': CourseSessionDetail(sectionCode: '07P', type: 'Lab', day: 'Fri', time: '14:00–16:00', location: 'Makmal Komputer 6'),
      },
    ),
    Course(
      code: 'BCM2073',
      name: 'Modeling & Simulation',
      credits: 3,
      schedule: 'Fri 16:00-18:00 (DK5)',
      instructor: 'Ms. Natasha Karim',
      capacity: 30,
      enrolled: 0,
      sections: {
        '01': ['01A'],
      },
      sessionDetails: {
        '01': CourseSessionDetail(sectionCode: '01', type: 'Lecture', day: 'Mon', time: '08:00–10:00', location: 'DK1'),
        '01A': CourseSessionDetail(sectionCode: '01A', type: 'Tutorial', day: 'Tue', time: '10:00–12:00', location: 'Bilik Tutorial 1'),
      },
    ),
    Course(
      code: 'BCM2113',
      name: '3D Modelling',
      credits: 3,
      schedule: 'Fri 16:00-18:00 (DK5)',
      instructor: 'Ms. Bella Chong',
      capacity: 30,
      enrolled: 0,
      sections: {
        '01': ['01A'],
      },
      sessionDetails: {
        '01': CourseSessionDetail(sectionCode: '01', type: 'Lecture', day: 'Mon', time: '08:00–10:00', location: 'DK1'),
        '01A': CourseSessionDetail(sectionCode: '01A', type: 'Tutorial', day: 'Tue', time: '10:00–12:00', location: 'Bilik Tutorial 1'),
      },
    ),
    Course(
      code: 'BCM2123',
      name: '3D Digital Animation',
      credits: 3,
      schedule: 'Mon 08:00-10:00 (DK1)',
      instructor: 'Ms. Hana Tan',
      capacity: 30,
      enrolled: 0,
      sections: {
        '01': ['01A'],
      },
      sessionDetails: {
        '01': CourseSessionDetail(sectionCode: '01', type: 'Lecture', day: 'Mon', time: '08:00–10:00', location: 'DK1'),
        '01A': CourseSessionDetail(sectionCode: '01A', type: 'Tutorial', day: 'Tue', time: '10:00–12:00', location: 'Bilik Tutorial 1'),
      },
    ),
    Course(
      code: 'BCM2133',
      name: 'Computer Graphics',
      credits: 3,
      schedule: 'Tue 10:00-12:00 (DK2)',
      instructor: 'Ms. Sarah Mei',
      capacity: 35,
      enrolled: 0,
      sections: {
        '01': ['01A'],
      },
      sessionDetails: {
        '01': CourseSessionDetail(sectionCode: '01', type: 'Lecture', day: 'Mon', time: '08:00–10:00', location: 'DK1'),
        '01A': CourseSessionDetail(sectionCode: '01A', type: 'Tutorial', day: 'Tue', time: '10:00–12:00', location: 'Bilik Tutorial 1'),
      },
    ),
    Course(
      code: 'BCM3203',
      name: 'Computer Game Programming II',
      credits: 4,
      schedule: 'Mon 08:00-10:00 (DK1)',
      instructor: 'Mr. Jason Lee',
      capacity: 30,
      enrolled: 0,
      sections: {
        '01': ['01A'],
      },
      sessionDetails: {
        '01': CourseSessionDetail(sectionCode: '01', type: 'Lecture', day: 'Mon', time: '08:00–10:00', location: 'DK1'),
        '01A': CourseSessionDetail(sectionCode: '01A', type: 'Tutorial', day: 'Tue', time: '10:00–12:00', location: 'Bilik Tutorial 1'),
      },
    ),
    Course(
      code: 'BCM3243',
      name: 'Multimedia Development Workshop',
      credits: 3,
      schedule: 'Fri 16:00-18:00 (DK5)',
      instructor: 'Ms. Nadia Teh',
      capacity: 30,
      enrolled: 0,
      sections: {
        '01': ['01A'],
      },
      sessionDetails: {
        '01': CourseSessionDetail(sectionCode: '01', type: 'Lecture', day: 'Mon', time: '08:00–10:00', location: 'DK1'),
        '01A': CourseSessionDetail(sectionCode: '01A', type: 'Tutorial', day: 'Tue', time: '10:00–12:00', location: 'Bilik Tutorial 1'),
      },
    ),
    Course(
      code: 'BCM3253',
      name: 'Data Analytics & Visualization',
      credits: 3,
      schedule: 'Mon 08:00-10:00 (DK1)',
      instructor: 'Mr. Amir Khan',
      capacity: 35,
      enrolled: 0,
      sections: {
        '01': ['01A'],
      },
      sessionDetails: {
        '01': CourseSessionDetail(sectionCode: '01', type: 'Lecture', day: 'Mon', time: '08:00–10:00', location: 'DK1'),
        '01A': CourseSessionDetail(sectionCode: '01A', type: 'Tutorial', day: 'Tue', time: '10:00–12:00', location: 'Bilik Tutorial 1'),
      },
    ),
    Course(
      code: 'BCM3263',
      name: 'Augmented Reality',
      credits: 3,
      schedule: 'Tue 10:00–12:00 (DK8)',
      instructor: 'Ms. Shiela Wong',
      capacity: 30,
      enrolled: 0,
      sections: {
        '01': ['01A', '01B'],
      },
      sessionDetails: {
        '01': CourseSessionDetail(sectionCode: '01', type: 'Lecture', day: 'Tue', time: '10:00–12:00', location: 'DK8'),
        '01A': CourseSessionDetail(sectionCode: '01A', type: 'Lab', day: 'Thu', time: '10:00–12:00', location: 'AR Lab'),
        '01B': CourseSessionDetail(sectionCode: '01B', type: 'Lab', day: 'Fri', time: '10:00–12:00', location: 'AR Lab'),
      },
    ),
    Course(
      code: 'BCM3283',
      name: 'Fundamental of Game Development',
      credits: 3,
      schedule: 'Thu 10:00–12:00 (DK9)',
      instructor: 'Mr. Daniel Chee',
      capacity: 30,
      enrolled: 0,
      sections: {
        '02': ['02A', '02B'],
      },
      sessionDetails: {
        '02': CourseSessionDetail(sectionCode: '02', type: 'Lecture', day: 'Thu', time: '10:00–12:00', location: 'DK9'),
        '02A': CourseSessionDetail(sectionCode: '02A', type: 'Lab', day: 'Fri', time: '10:00–12:00', location: 'Game Lab'),
        '02B': CourseSessionDetail(sectionCode: '02B', type: 'Lab', day: 'Fri', time: '14:00–16:00', location: 'Game Lab'),
      },
    ),
    Course(
      code: 'BCM3293',
      name: 'Game Programming & Development',
      credits: 4,
      schedule: 'Wed 08:00–10:00 (DK10)',
      instructor: 'Mr. Keon Lim',
      capacity: 30,
      enrolled: 0,
      sections: {
        '03': ['03A'],
      },
      sessionDetails: {
        '03': CourseSessionDetail(sectionCode: '03', type: 'Lecture', day: 'Wed', time: '08:00–10:00', location: 'DK10'),
        '03A': CourseSessionDetail(sectionCode: '03A', type: 'Lab', day: 'Thu', time: '14:00–16:00', location: 'Game Lab'),
      },
    ),
    Course(
      code: 'BCM3313',
      name: 'Data Analytics & Visualization',
      credits: 3,
      schedule: 'Wed 12:00-14:00 (DK3)',
      instructor: 'Ms. Aishah Zain',
      capacity: 35,
      enrolled: 0,
      sections: {
        '01': ['01A', '01B'],
      },
      sessionDetails: {
        '01': CourseSessionDetail(sectionCode: '01', type: 'Lecture', day: 'Mon', time: '08:00–10:00', location: 'DK1'),
        '01A': CourseSessionDetail(sectionCode: '01A', type: 'Tutorial', day: 'Tue', time: '10:00–12:00', location: 'Bilik Tutorial 1'),
        '01B': CourseSessionDetail(sectionCode: '01B', type: 'Tutorial', day: 'Wed', time: '12:00–14:00', location: 'Bilik Tutorial 2'),
      },
    ),
    Course(
      code: 'BCM3323',
      name: 'Augmented Reality',
      credits: 3,
      schedule: 'Thu 14:00-16:00 (DK4)',
      instructor: 'Mr. Darren Khoo',
      capacity: 30,
      enrolled: 0,
      sections: {
        '01': ['01A'],
      },
      sessionDetails: {
        '01': CourseSessionDetail(sectionCode: '01', type: 'Lecture', day: 'Mon', time: '08:00–10:00', location: 'DK1'),
        '01A': CourseSessionDetail(sectionCode: '01A', type: 'Tutorial', day: 'Tue', time: '10:00–12:00', location: 'Bilik Tutorial 1'),
      },
    ),
    Course(
      code: 'BCS2143',
      name: 'Object Oriented Programming',
      credits: 3,
      schedule: 'Mon 14:00–16:00 (DK5)',
      instructor: 'Dr. Priya Menon',
      capacity: 40,
      enrolled: 0,
      sections: {
        '01': ['01A'],
      },
      sessionDetails: {
        '01': CourseSessionDetail(sectionCode: '01', type: 'Lecture', day: 'Mon', time: '14:00–16:00', location: 'DK5'),
        '01A': CourseSessionDetail(sectionCode: '01A', type: 'Lab', day: 'Wed', time: '14:00–16:00', location: 'Makmal Komputer 4'),
      },
    ),
    Course(
      code: 'BCS2213',
      name: 'Formal Method',
      credits: 3,
      schedule: 'Tue 10:00-12:00 (DK2)',
      instructor: 'Dr. Qasim Nordin',
      capacity: 35,
      enrolled: 0,
      sections: {
        '01': ['01A'],
      },
      sessionDetails: {
        '01': CourseSessionDetail(sectionCode: '01', type: 'Lecture', day: 'Mon', time: '08:00–10:00', location: 'DK1'),
        '01A': CourseSessionDetail(sectionCode: '01A', type: 'Tutorial', day: 'Tue', time: '10:00–12:00', location: 'Bilik Tutorial 1'),
      },
    ),
    Course(
      code: 'BCS2233',
      name: 'Software Requirement Workshop',
      credits: 3,
      schedule: 'Thu 14:00-16:00 (DK4)',
      instructor: 'Dr. Rina Aziz',
      capacity: 35,
      enrolled: 0,
      sections: {
        '01': ['01A'],
      },
      sessionDetails: {
        '01': CourseSessionDetail(sectionCode: '01', type: 'Lecture', day: 'Mon', time: '08:00–10:00', location: 'DK1'),
        '01A': CourseSessionDetail(sectionCode: '01A', type: 'Tutorial', day: 'Tue', time: '10:00–12:00', location: 'Bilik Tutorial 1'),
      },
    ),
    Course(
      code: 'BCS2313',
      name: 'Artificial Intelligence Techniques',
      credits: 3,
      schedule: 'Wed 12:00-14:00 (DK3)',
      instructor: 'Dr. Samuel Tan',
      capacity: 35,
      enrolled: 0,
      sections: {
        '01': ['01A'],
      },
      sessionDetails: {
        '01': CourseSessionDetail(sectionCode: '01', type: 'Lecture', day: 'Mon', time: '08:00–10:00', location: 'DK1'),
        '01A': CourseSessionDetail(sectionCode: '01A', type: 'Tutorial', day: 'Tue', time: '10:00–12:00', location: 'Bilik Tutorial 1'),
      },
    ),
    Course(
      code: 'BCS2343',
      name: 'Software Design Workshop',
      credits: 3,
      schedule: 'Mon 08:00-10:00 (DK1)',
      instructor: 'Dr. Tara Mohd',
      capacity: 35,
      enrolled: 0,
      sections: {
        '01': ['01A'],
      },
      sessionDetails: {
        '01': CourseSessionDetail(sectionCode: '01', type: 'Lecture', day: 'Mon', time: '08:00–10:00', location: 'DK1'),
        '01A': CourseSessionDetail(sectionCode: '01A', type: 'Tutorial', day: 'Tue', time: '10:00–12:00', location: 'Bilik Tutorial 1'),
      },
    ),
    Course(
      code: 'BCS3143',
      name: 'Software Project Management',
      credits: 3,
      schedule: 'Fri 16:00-18:00 (DK5)',
      instructor: 'Dr. Rizka Putri',
      capacity: 35,
      enrolled: 0,
      sections: {
        '01': ['01A'],
      },
      sessionDetails: {
        '01': CourseSessionDetail(sectionCode: '01', type: 'Lecture', day: 'Mon', time: '08:00–10:00', location: 'DK1'),
        '01A': CourseSessionDetail(sectionCode: '01A', type: 'Tutorial', day: 'Tue', time: '10:00–12:00', location: 'Bilik Tutorial 1'),
      },
    ),
    Course(
      code: 'BCS3153',
      name: 'Software Evolution & Maintenance',
      credits: 3,
      schedule: 'Mon 08:00-10:00 (DK1)',
      instructor: 'Dr. Syed Firdaus',
      capacity: 35,
      enrolled: 0,
      sections: {
        '01': ['01A'],
      },
      sessionDetails: {
        '01': CourseSessionDetail(sectionCode: '01', type: 'Lecture', day: 'Mon', time: '08:00–10:00', location: 'DK1'),
        '01A': CourseSessionDetail(sectionCode: '01A', type: 'Tutorial', day: 'Tue', time: '10:00–12:00', location: 'Bilik Tutorial 1'),
      },
    ),
    Course(
      code: 'BCS3263',
      name: 'Software Quality Assurance',
      credits: 3,
      schedule: 'Tue 14:00–16:00 (DK6)',
      instructor: 'Dr. Aina Hamid',
      capacity: 30,
      enrolled: 0,
      sections: {
        '06A': ['06P'],
        '06B': [],
      },
      sessionDetails: {
        '06A': CourseSessionDetail(sectionCode: '06A', type: 'Lecture', day: 'Tue', time: '14:00–16:00', location: 'DK6'),
        '06B': CourseSessionDetail(sectionCode: '06B', type: 'Lecture', day: 'Thu', time: '14:00–16:00', location: 'DK6'),
        '06P': CourseSessionDetail(sectionCode: '06P', type: 'Lab', day: 'Fri', time: '08:00–10:00', location: 'Makmal Komputer 5'),
      },
    ),
    Course(
      code: 'BCS3423',
      name: 'Integrated Business Processing (SAP)',
      credits: 3,
      schedule: 'Mon 08:00-10:00 (DK1)',
      instructor: 'Dr. Nabilah Omar',
      capacity: 30,
      enrolled: 0,
      sections: {
        '01': ['01A'],
      },
      sessionDetails: {
        '01': CourseSessionDetail(sectionCode: '01', type: 'Lecture', day: 'Mon', time: '08:00–10:00', location: 'DK1'),
        '01A': CourseSessionDetail(sectionCode: '01A', type: 'Tutorial', day: 'Tue', time: '10:00–12:00', location: 'Bilik Tutorial 1'),
      },
    ),
    Course(
      code: 'BCY1013',
      name: 'Cyber Law & Security Policy',
      credits: 3,
      schedule: 'Tue 08:00–10:00 (DK11)',
      instructor: 'Dr. Umar Hakim',
      capacity: 35,
      enrolled: 0,
      sections: {
        '01': ['01A'],
      },
      sessionDetails: {
        '01': CourseSessionDetail(sectionCode: '01', type: 'Lecture', day: 'Tue', time: '08:00–10:00', location: 'DK11'),
      },
    ),
  ];


  final _registeredCourseCodes = <String>{};
  final _registeredSubjects = <RegisteredSubject>[];
  Course? _selectedCourse;
  Course? _selectedCourseForAssignment;
  String? _selectedSection;
  String? _selectedLab;
  String? _selectedAssignmentSection;
  AppUser? _selectedLecturer;
  final _lecturerUsers = <AppUser>[];
  bool _registrationOpen = true;
  String _registrationPeriodDocId = 'reg-period-001';
  final _approvalRequests = <RegistrationRequest>[];
  final NotificationService _notificationService = NotificationService();

  // Faculty management state
  DateTime _registrationStartDate = DateTime.now();
  DateTime _registrationEndDate = DateTime.now().add(const Duration(days: 30));
  bool _isEditingPeriod = false;

  @override
  void initState() {
    super.initState();
    _selectedCourse = _courses.first;
    _selectedCourseForAssignment = _courses.first;
    _selectedAssignmentSection = _courses.first.sections.keys.isNotEmpty
        ? _courses.first.sections.keys.first
        : null;
    _fetchLecturers();
    _loadCustomCoursesFromFirestore();
    _loadRegistrationPeriod();
    if (_userRole == UserRole.student) {
      _loadStudentRegistrations();
    }
  }

  Future<void> _loadCustomCoursesFromFirestore() async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('subjects')
          .get();

      if (!mounted) return;

      // Find max sequential number and collect sub-custom-* docs to migrate
      int maxNum = 0;
      final docsToMigrate = <String>[];
      for (final doc in snapshot.docs) {
        final match = RegExp(r'^sub-(\d+)$').firstMatch(doc.id);
        if (match != null) {
          final n = int.tryParse(match.group(1)!) ?? 0;
          if (n > maxNum) maxNum = n;
        } else if (doc.id.startsWith('sub-custom-')) {
          docsToMigrate.add(doc.id);
        }
      }

      // Migrate sub-custom-* to sub-NNN and standardize fields
      if (docsToMigrate.isNotEmpty) {
        // Fetch all offerings once so we can migrate them too
        final offeringsSnap = await FirebaseFirestore.instance
            .collection('subject_offerings')
            .get();

        for (final oldSubId in docsToMigrate) {
          maxNum += 1;
          final newSubId = 'sub-${maxNum.toString().padLeft(3, '0')}';
          final oldDoc = snapshot.docs.firstWhere((d) => d.id == oldSubId);
          final data = oldDoc.data();

          // Create subject with new sequential ID
          await FirebaseFirestore.instance.collection('subjects').doc(newSubId).set({
            'id': newSubId,
            'subjectCode': (data['subjectCode'] ?? '').toString(),
            'subjectName': (data['subjectName'] ?? '').toString(),
            'creditHour': (data['creditHour'] as num?)?.toInt() ?? 3,
            'faculty': (data['faculty'] ?? 'Faculty of Computing').toString(),
            'prerequisites': <String>[],
          });
          await FirebaseFirestore.instance.collection('subjects').doc(oldSubId).delete();

          // Migrate any offerings that reference the old subject ID
          // Old format: off-sub-custom-{code}-{section}
          // New format: off-sub-NNN-{section}
          for (final offeringDoc in offeringsSnap.docs) {
            if (offeringDoc.id.startsWith('off-$oldSubId-')) {
              final section = offeringDoc.id.substring('off-$oldSubId-'.length);
              final newOfferingId = 'off-$newSubId-$section';
              final ofData = offeringDoc.data();
              await FirebaseFirestore.instance
                  .collection('subject_offerings')
                  .doc(newOfferingId)
                  .set({...ofData, 'id': newOfferingId, 'subjectId': newSubId});
              await offeringDoc.reference.delete();
            }
          }
        }

        // Re-fetch after migration
        snapshot = await FirebaseFirestore.instance.collection('subjects').get();
        if (!mounted) return;
      }

      final existingCodes = _courses.map((c) => c.code).toSet();
      final assignmentsByCode = <String, Map<String, String>>{};
      final customCourses = <Course>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final code = (data['subjectCode'] ?? '').toString();
        if (code.isEmpty) continue;

        final rawAssignments = data['assignedLecturersBySection'];
        if (rawAssignments is Map) {
          assignmentsByCode[code] = rawAssignments.map(
            (k, v) => MapEntry(k.toString(), v.toString()),
          );
        }

        if (!existingCodes.contains(code)) {
          customCourses.add(Course(
            code: code,
            name: (data['subjectName'] ?? code).toString(),
            credits: (data['creditHour'] as num?)?.toInt() ?? 3,
            schedule: 'Schedule TBD',
            instructor: 'TBD',
            capacity: 30,
            enrolled: 0,
            sections: {'01': ['01A']},
            sessionDetails: {
              '01': CourseSessionDetail(sectionCode: '01', type: 'Lecture', day: 'TBD', time: 'TBD', location: 'TBD'),
              '01A': CourseSessionDetail(sectionCode: '01A', type: 'Tutorial', day: 'TBD', time: 'TBD', location: 'TBD'),
            },
          ));
        }
      }

      // Also load from subject_offerings for assignment data
      final offeringSnapshot = await FirebaseFirestore.instance
          .collection('subject_offerings')
          .get();
      for (final doc in offeringSnapshot.docs) {
        final data = doc.data();
        final code = (data['subjectCode'] ?? '').toString();
        final section = (data['section'] ?? '').toString();
        final lecturerName = (data['lecturerName'] ?? '').toString();
        if (code.isEmpty || section.isEmpty || lecturerName.isEmpty) continue;
        assignmentsByCode.putIfAbsent(code, () => {});
        assignmentsByCode[code]![section] = lecturerName;
      }

      if (!mounted) return;
      setState(() {
        _courses.addAll(customCourses);
        for (final course in _courses) {
          final persisted = assignmentsByCode[course.code];
          if (persisted != null) {
            course.assignedLecturersBySection
              ..clear()
              ..addAll(persisted);
          }
        }
      });
    } catch (e) {
      debugPrint('Failed to load courses from Firestore: $e');
    }
  }

  Future<void> _loadRegistrationPeriod() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('registration_periods')
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        if (!mounted) return;
        setState(() {
          _registrationPeriodDocId = snapshot.docs.first.id;
          _registrationOpen = data['isOpen'] ?? true;
          if (data['startDate'] != null) {
            _registrationStartDate = DateTime.tryParse(data['startDate'].toString()) ?? _registrationStartDate;
          }
          if (data['endDate'] != null) {
            _registrationEndDate = DateTime.tryParse(data['endDate'].toString()) ?? _registrationEndDate;
          }
        });
      }
    } catch (e) {
      debugPrint('Failed to load registration period: $e');
    }
  }

  Future<void> _loadStudentRegistrations() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('subject_registrations')
          .where('studentId', isEqualTo: widget.user.uid)
          .get();
      if (!mounted) return;
      final loaded = <RegisteredSubject>[];
      final codes = <String>{};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (data['status'] == 'dropped') continue;
        final code = data['subjectCode']?.toString() ?? '';
        if (code.isEmpty) continue;
        loaded.add(RegisteredSubject(
          courseCode: code,
          courseName: data['subjectName']?.toString() ?? '',
          section: data['section']?.toString() ?? '',
          lab: data['lab']?.toString() ?? '',
          status: _mapDbStatus(data['status']?.toString() ?? 'registered'),
        ));
        codes.add(code);
        final matches = _courses.where((c) => c.code == code);
        if (matches.isNotEmpty) matches.first.enrolled += 1;
      }
      setState(() {
        _registeredSubjects.addAll(loaded);
        _registeredCourseCodes.addAll(codes);
      });
    } catch (e) {
      debugPrint('Failed to load student registrations: $e');
    }
  }

  String _mapDbStatus(String dbStatus) {
    switch (dbStatus) {
      case 'notified': return 'Notified';
      case 'confirmed': return 'Confirmed';
      default: return 'Registered';
    }
  }

  String _buildStudentRegistrationDocId(String studentId, String subjectCode, String section) {
    final s = section.replaceAll(RegExp(r'[^A-Za-z0-9]'), '_');
    return 'subreg-$studentId-$subjectCode-$s';
  }

  List<String> getSectionsByCourse(String courseCode) =>
      CourseController.getSectionsByCourse(_courses, courseCode);

  List<String> get _availableSections =>
      getSectionsByCourse(_selectedCourse?.code ?? '');

  List<String> get _availableLabs =>
      _selectedCourse?.sections[_selectedSection] ?? <String>[];

  List<String> get _availableAssignmentSections =>
      getSectionsByCourse(_selectedCourseForAssignment?.code ?? '');

  void _selectCourse(Course? course) {
    setState(() {
      _selectedCourse = course;
      _selectedSection = null;
      _selectedLab = null;
    });
  }

  void _selectSection(String? section) {
    setState(() {
      _selectedSection = section;
      _selectedLab = null;
    });
  }

  void _selectLab(String? lab) {
    setState(() {
      _selectedLab = lab;
    });
  }

  void _selectCourseForAssignment(Course? course) {
    setState(() {
      _selectedCourseForAssignment = course;
      _selectedAssignmentSection =
          course != null && course.sections.isNotEmpty ? course.sections.keys.first : null;
    });
  }

  void _selectAssignmentSection(String? section) {
    setState(() {
      _selectedAssignmentSection = section;
    });
  }

  Future<void> _notifyAllLecturers() async {
    final toNotify = _registeredSubjects.where((s) => s.status == 'Registered').toList();

    setState(() {
      for (final subject in toNotify) {
        subject.status = 'Notified';
        _notificationService.addNotification(RegistrationRequest(
          studentName: widget.user.fullName,
          courseCode: subject.courseCode,
          courseName: subject.courseName,
          section: subject.section,
          lab: subject.lab,
          status: 'Notified',
        ));
      }
    });

    try {
      for (final subject in toNotify) {
        final docId = _buildStudentRegistrationDocId(widget.user.uid, subject.courseCode, subject.section);
        await FirebaseFirestore.instance
            .collection('subject_registrations')
            .doc(docId)
            .set({'status': 'notified', 'notifiedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Failed to update notification status in Firestore: $e');
    }

    _showSnackbar('All subjects notified to lecturers for confirmation');
  }

  Map<String, List<RegistrationRequest>> _groupNotificationsByStudent() {
    final grouped = <String, List<RegistrationRequest>>{};
    for (final notification in _notificationService.notifications) {
      if (!grouped.containsKey(notification.studentName)) {
        grouped[notification.studentName] = [];
      }
      grouped[notification.studentName]!.add(notification);
    }
    return grouped;
  }

  Future<void> _confirmAllStudentSubjects(String studentName) async {
    final toConfirm = _notificationService.notifications
        .where((n) => n.studentName == studentName && n.status == 'Notified')
        .toList();

    setState(() {
      for (final notification in toConfirm) {
        _notificationService.updateNotificationStatus(studentName, notification.courseCode, 'Confirmed');
        final registeredSubject = _registeredSubjects.firstWhere(
          (subject) =>
              subject.courseCode == notification.courseCode &&
              subject.section == notification.section &&
              subject.lab == notification.lab,
          orElse: () => RegisteredSubject(courseCode: '', courseName: '', section: '', lab: ''),
        );
        if (registeredSubject.courseCode.isNotEmpty) {
          registeredSubject.status = 'Confirmed';
        }
      }
    });

    try {
      for (final notification in toConfirm) {
        final snapshot = await FirebaseFirestore.instance
            .collection('subject_registrations')
            .where('studentName', isEqualTo: studentName)
            .where('subjectCode', isEqualTo: notification.courseCode)
            .limit(1)
            .get();
        if (snapshot.docs.isNotEmpty) {
          await snapshot.docs.first.reference.update({
            'status': 'confirmed',
            'confirmedAt': FieldValue.serverTimestamp(),
            'confirmedBy': widget.user.uid,
          });
        }
      }
    } catch (e) {
      debugPrint('Failed to save confirmation to Firestore: $e');
    }

    _showSnackbar('All registrations confirmed for $studentName');
  }

  // PACK-110: registration_controller
  Future<List<Map<String, dynamic>>> getRegistrationsByLecturer(String lecturerId) =>
      RegistrationController.getRegistrationsByLecturer(lecturerId);

  // PACK-111: notification_controller
  Future<void> sendStatusUpdate(String studentId, String status) =>
      NotificationController.sendStatusUpdate(studentId, status);

  List<RegistrationRequest> getNotificationsByUser(String userId) =>
      NotificationController.getNotificationsByUser(_notificationService, userId);

  void markNotificationRead(String notifId) =>
      NotificationController.markNotificationRead(notifId);

  void clearUserNotifications(String userId) =>
      NotificationController.clearUserNotifications(_notificationService, userId);

  // Faculty management methods
  Future<void> _toggleRegistrationPeriod() async {
    final newStatus = !_registrationOpen;
    setState(() => _registrationOpen = newStatus);
    try {
      await FirebaseFirestore.instance
          .collection('registration_periods')
          .doc(_registrationPeriodDocId)
          .set({'isOpen': newStatus, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Failed to update registration status: $e');
    }
    _showSnackbar('Registration period ${newStatus ? 'opened' : 'closed'}');
  }

  Future<void> _updateRegistrationPeriod(DateTime start, DateTime end) async {
    setState(() {
      _registrationStartDate = start;
      _registrationEndDate = end;
      _isEditingPeriod = false;
    });
    try {
      await FirebaseFirestore.instance
          .collection('registration_periods')
          .doc(_registrationPeriodDocId)
          .set({
        'startDate': start.toIso8601String().split('T')[0],
        'endDate': end.toIso8601String().split('T')[0],
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Failed to update registration period dates: $e');
    }
    _showSnackbar('Registration period updated');
  }

  Future<void> _openAddCourseDialog() async {
    final formKey = GlobalKey<FormState>();
    var courseCode = '';
    var courseName = '';
    var creditsText = '';
    var capacityText = '';

    final newCourse = await showDialog<Course>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add New Course'),
              content: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Form(
                    key: formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Enter the course information below. A default section 01 and tutorial/lab 01A will be created automatically.',
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          onChanged: (value) => courseCode = value,
                          textCapitalization: TextCapitalization.characters,
                          decoration: const InputDecoration(
                            labelText: 'Course Code',
                            border: OutlineInputBorder(),
                            hintText: 'BCI1233',
                          ),
                          validator: (value) {
                            final normalizedCode = value?.trim().toUpperCase() ?? '';
                            if (normalizedCode.isEmpty) {
                              return 'Enter the course code';
                            }
                            if (_courses.any(
                              (course) => course.code.toUpperCase() == normalizedCode,
                            )) {
                              return 'Course code already exists';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          onChanged: (value) => courseName = value,
                          decoration: const InputDecoration(
                            labelText: 'Course Name',
                            border: OutlineInputBorder(),
                            hintText: 'Database Systems',
                          ),
                          validator: (value) {
                            if ((value?.trim().isEmpty ?? true)) {
                              return 'Enter the course name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          onChanged: (value) => creditsText = value,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: const InputDecoration(
                            labelText: 'Credit',
                            border: OutlineInputBorder(),
                            hintText: '3',
                          ),
                          validator: (value) {
                            final credits = int.tryParse(value?.trim() ?? '');
                            if (credits == null || credits <= 0) {
                              return 'Enter a valid credit value';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          onChanged: (value) => capacityText = value,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: const InputDecoration(
                            labelText: 'Capacity',
                            border: OutlineInputBorder(),
                            hintText: '40',
                          ),
                          validator: (value) {
                            final capacity = int.tryParse(value?.trim() ?? '');
                            if (capacity == null || capacity <= 0) {
                              return 'Enter a valid capacity';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    if (!(formKey.currentState?.validate() ?? false)) {
                      return;
                    }

                    Navigator.of(dialogContext).pop(
                      _buildCourseFromDialog(
                        code: courseCode.trim().toUpperCase(),
                        name: courseName.trim(),
                        credits: int.parse(creditsText.trim()),
                        capacity: int.parse(capacityText.trim()),
                        instructor: 'TBD',
                      ),
                    );
                  },
                  child: const Text('Add Course'),
                ),
              ],
            );
          },
        );
      },
    );

    if (newCourse == null || !mounted) {
      return;
    }

    setState(() {
      _courses.add(newCourse);
      _selectedCourseForAssignment = newCourse;
      _selectedAssignmentSection = newCourse.sections.keys.first;
      _selectedCourse ??= newCourse;
    });

    try {
      final allDocs = await FirebaseFirestore.instance.collection('subjects').get();
      int maxNum = 0;
      for (final doc in allDocs.docs) {
        final match = RegExp(r'^sub-(\d+)$').firstMatch(doc.id);
        if (match != null) {
          final n = int.tryParse(match.group(1)!) ?? 0;
          if (n > maxNum) maxNum = n;
        }
      }
      final docId = 'sub-${(maxNum + 1).toString().padLeft(3, '0')}';
      await FirebaseFirestore.instance
          .collection('subjects')
          .doc(docId)
          .set({
        'id': docId,
        'subjectCode': newCourse.code,
        'subjectName': newCourse.name,
        'creditHour': newCourse.credits,
        'faculty': 'Faculty of Computing',
        'prerequisites': <String>[],
      });
    } catch (e) {
      debugPrint('Failed to save new course to Firestore: $e');
    }

    _showSnackbar('Added ${newCourse.code}');
  }

  Course _buildCourseFromDialog({
    required String code,
    required String name,
    required int credits,
    required int capacity,
    required String instructor,
  }) {
    return Course(
      code: code,
      name: name,
      credits: credits,
      schedule: 'Schedule TBD',
      instructor: instructor,
      capacity: capacity,
      enrolled: 0,
      sections: {
        '01': ['01A'],
      },
      sessionDetails: {
        '01': CourseSessionDetail(
          sectionCode: '01',
          type: 'Lecture',
          day: 'TBD',
          time: 'TBD',
          location: 'TBD',
        ),
        '01A': CourseSessionDetail(
          sectionCode: '01A',
          type: 'Tutorial',
          day: 'TBD',
          time: 'TBD',
          location: 'TBD',
        ),
      },
    );
  }

  Future<void> _removeCourse(Course course) async {
    setState(() {
      _courses.remove(course);
      _registeredCourseCodes.remove(course.code);
      _registeredSubjects.removeWhere((s) => s.courseCode == course.code);

      if (_selectedCourse == course) {
        _selectedCourse = _courses.isNotEmpty ? _courses.first : null;
        _selectedSection = null;
        _selectedLab = null;
      }

      if (_selectedCourseForAssignment == course) {
        _selectedCourseForAssignment = _courses.isNotEmpty ? _courses.first : null;
        _selectedAssignmentSection =
            _selectedCourseForAssignment != null &&
                    _selectedCourseForAssignment!.sections.isNotEmpty
                ? _selectedCourseForAssignment!.sections.keys.first
                : null;
      }
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('subjects')
          .where('subjectCode', isEqualTo: course.code)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.delete();
      }
    } catch (e) {
      debugPrint('Failed to delete course from Firestore: $e');
    }

    _showSnackbar('Course removed');
  }

  Future<void> _fetchLecturers() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'lecturer')
          .get();

      final lecturers = snapshot.docs
          .map((doc) => AppUser.fromMap(doc.data()))
          .where((user) => user.role.toLowerCase().trim() == 'lecturer')
          .toList();

      setState(() {
        _lecturerUsers.clear();
        _lecturerUsers.addAll(lecturers);
        _selectedLecturer = _lecturerUsers.isNotEmpty ? _lecturerUsers.first : null;
      });
    } catch (e) {
      debugPrint('Failed to fetch lecturers: $e');
    }
  }

  Future<void> updateCourse(DocumentReference subjectRef, String section, AppUser lecturer) =>
      CourseController.updateCourse(subjectRef, section, lecturer);

  Future<void> _assignSelectedCourseToLecturer() async {
    if (_selectedCourseForAssignment == null ||
        _selectedLecturer == null ||
        _selectedAssignmentSection == null) {
      _showSnackbar('Please select a course, section, and lecturer');
      return;
    }

    final course = _selectedCourseForAssignment!;
    final section = _selectedAssignmentSection!;
    final lecturer = _selectedLecturer!;

    try {
      final subjectQuery = await FirebaseFirestore.instance
          .collection('subjects')
          .where('subjectCode', isEqualTo: course.code)
          .limit(1)
          .get();

      if (subjectQuery.docs.isEmpty) {
        _showSnackbar('No Firebase subject found for ${course.code}');
        return;
      }

      final subjectRef = subjectQuery.docs.first.reference;
      final subjectData = subjectQuery.docs.first.data();
      final subjectId =
          (subjectData['id'] ?? subjectQuery.docs.first.id).toString();
      final sessionDetail = course.sessionDetails[section];
      final offeringRef = FirebaseFirestore.instance
          .collection('subject_offerings')
          .doc(_buildOfferingDocumentId(subjectId, section));

      await updateCourse(subjectRef, section, lecturer);

      await offeringRef.set({
        'id': _buildOfferingDocumentId(subjectId, section),
        'subjectId': subjectId,
        'subjectCode': course.code,
        'subjectName': course.name,
        'section': section,
        'lecturerId': lecturer.uid,
        'lecturerName': lecturer.fullName,
        'schedule': sessionDetail == null
            ? course.schedule
            : '${sessionDetail.day} ${sessionDetail.time}',
        'location': sessionDetail?.location ?? '',
        'sessionType': sessionDetail?.type ?? '',
        'semester': widget.user.semester,
        'year': DateTime.now().year,
        'seats': course.capacity,
        'seatsTaken': course.enrolled,
        'status': 'active',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) {
        return;
      }

      setState(() {
        course.assignedLecturersBySection[section] = lecturer.fullName;
      });

      _showSnackbar(
        'Assigned ${course.code} section $section to ${lecturer.fullName}',
      );
    } catch (e) {
      debugPrint('Failed to assign lecturer to section: $e');
      _showSnackbar('Failed to save assignment to Firebase');
    }
  }

  String _buildOfferingDocumentId(String subjectId, String section) {
    final normalizedSection = section.replaceAll(RegExp(r'[^A-Za-z0-9]'), '_');
    return 'off-$subjectId-$normalizedSection';
  }

  List<Widget> _buildAssignedSectionCards(Course course) {
    if (course.assignedLecturersBySection.isEmpty) {
      return [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.grayOne,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text('No section assigned yet.'),
        ),
      ];
    }

    final entries = course.assignedLecturersBySection.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return entries.map((entry) {
      final detail = course.sessionDetails[entry.key];
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.infoSoft,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Section ${entry.key}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text('Lecturer: ${entry.value}'),
            if (detail != null) ...[
              const SizedBox(height: 4),
              Text(
                '${detail.type} • ${detail.day} ${detail.time} • ${detail.location}',
                style: const TextStyle(color: AppColors.textMuted),
              ),
            ],
          ],
        ),
      );
    }).toList();
  }

  Future<void> _registerSelectedCourse() async {
    if (!_registrationOpen) {
      _showSnackbar('Registration is closed');
      return;
    }
    if (_selectedCourse == null || _selectedSection == null || _selectedLab == null) {
      _showSnackbar('Please select course, section, and tutorial/lab.');
      return;
    }
    final course = _selectedCourse!;
    if (_registeredCourseCodes.contains(course.code) ||
        _registeredSubjects.any((entry) => entry.courseCode == course.code)) {
      _showSnackbar('You already registered ${course.code}');
      return;
    }
    final clashCourseCode = _findScheduleClashCourseCode(course, _selectedSection!, _selectedLab!);
    if (clashCourseCode != null) {
      _showSnackbar('Cannot register ${course.code}: it clashes with registered subject $clashCourseCode.');
      return;
    }
    if (course.isFull) {
      _showSnackbar('${course.code} is full');
      return;
    }
    if (course.requiresApproval) {
      setState(() {
        _approvalRequests.add(RegistrationRequest(
          studentName: widget.user.fullName,
          courseCode: course.code,
          courseName: course.name,
        ));
      });
      _showSnackbar('Approval request sent for ${course.code}');
      return;
    }
    setState(() {
      _registeredSubjects.add(RegisteredSubject(
        courseCode: course.code,
        courseName: course.name,
        section: _selectedSection!,
        lab: _selectedLab!,
      ));
      _registeredCourseCodes.add(course.code);
      course.enrolled += 1;
    });

    try {
      final docId = _buildStudentRegistrationDocId(widget.user.uid, course.code, _selectedSection!);
      await FirebaseFirestore.instance
          .collection('subject_registrations')
          .doc(docId)
          .set({
        'id': docId,
        'studentId': widget.user.uid,
        'studentName': widget.user.fullName,
        'subjectCode': course.code,
        'subjectName': course.name,
        'section': _selectedSection!,
        'lab': _selectedLab!,
        'semester': widget.user.semester,
        'status': 'registered',
        'registeredAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Failed to save registration to Firestore: $e');
    }

    _showSnackbar('Added ${course.code} (${_selectedSection!} / ${_selectedLab!})');
  }

  void _dropCourse(Course course) {
    if (!_registeredCourseCodes.contains(course.code)) {
      _showSnackbar('${course.code} is not registered');
      return;
    }

    setState(() {
      _registeredCourseCodes.remove(course.code);
      course.enrolled = (course.enrolled - 1).clamp(0, course.capacity);
    });
    _showSnackbar('Dropped ${course.code}');
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String? _findScheduleClashCourseCode(Course newCourse, String section, String lab) {
    final newDetails = _buildScheduleDetails(newCourse, section, lab);
    for (final registered in _registeredSubjects) {
      Course? registeredCourse;
      try {
        registeredCourse = _courses.firstWhere((course) => course.code == registered.courseCode);
      } catch (_) {
        registeredCourse = null;
      }
      if (registeredCourse == null) {
        continue;
      }
      final registeredDetails = _buildScheduleDetails(registeredCourse, registered.section, registered.lab);
      for (final newDetail in newDetails) {
        for (final registeredDetail in registeredDetails) {
          if (_sessionDetailsClash(newDetail, registeredDetail)) {
            return registered.courseCode;
          }
        }
      }
    }
    return null;
  }

  List<CourseSessionDetail> _buildScheduleDetails(Course course, String section, String lab) {
    final details = <CourseSessionDetail>[];
    final sectionDetail = course.sessionDetails[section];
    if (sectionDetail != null) {
      details.add(sectionDetail);
    }
    final labDetail = course.sessionDetails[lab];
    if (labDetail != null) {
      details.add(labDetail);
    }
    return details;
  }

  bool _sessionDetailsClash(CourseSessionDetail a, CourseSessionDetail b) {
    if (a.day != b.day) {
      return false;
    }
    final aRange = _parseTimeRange(a.time);
    final bRange = _parseTimeRange(b.time);
    if (aRange == null || bRange == null) {
      return false;
    }
    return aRange[0] < bRange[1] && bRange[0] < aRange[1];
  }

  List<Duration>? _parseTimeRange(String time) {
    final cleaned = time.replaceAll('–', '-').replaceAll('—', '-');
    final parts = cleaned.split('-');
    if (parts.length != 2) {
      return null;
    }
    final start = _parseTimeOfDay(parts[0].trim());
    final end = _parseTimeOfDay(parts[1].trim());
    if (start == null || end == null) {
      return null;
    }
    return [start, end];
  }

  Duration? _parseTimeOfDay(String value) {
    final parts = value.split(':');
    if (parts.length != 2) {
      return null;
    }
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) {
      return null;
    }
    return Duration(hours: hour, minutes: minute);
  }

  String _inferCourseCatalogType(String sectionCode) {
    if (sectionCode.endsWith('P')) {
      return 'Lab';
    }
    if (RegExp(r'[A-Z]\$').hasMatch(sectionCode)) {
      return 'Tutorial';
    }
    return 'Lecture';
  }

  Widget _buildSelectedScheduleSummary() {
    final course = _selectedCourse;
    final sectionCode = _selectedSection;
    if (course == null || sectionCode == null) {
      return const SizedBox.shrink();
    }

    final sectionDetails = course.sessionDetails[sectionCode];
    final labDetails = _selectedLab != null ? course.sessionDetails[_selectedLab!] : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grayOne,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Selected course schedule', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          if (sectionDetails != null)
            Text('${sectionDetails.type}: ${sectionDetails.day} ${sectionDetails.time} @ ${sectionDetails.location}'),
          if (labDetails != null) ...[
            const SizedBox(height: 4),
            Text('${labDetails.type}: ${labDetails.day} ${labDetails.time} @ ${labDetails.location}'),
          ],
        ],
      ),
    );
  }

  List<DataRow> _buildCourseCatalogRows() {
    final rows = <DataRow>[];
    for (final course in _courses) {
      if (course.sessionDetails.isNotEmpty) {
        for (final sectionCode in course.sessionDetails.keys) {
          final details = course.sessionDetails[sectionCode];
          rows.add(DataRow(cells: [
            DataCell(Text(course.code)),
            DataCell(Text(course.name)),
            DataCell(Text('${course.credits}')),
            DataCell(Text(sectionCode)),
            DataCell(Text(details?.type ?? 'N/A')),
            DataCell(Text(details?.day ?? 'N/A')),
            DataCell(Text(details?.time ?? 'N/A')),
            DataCell(Text(details?.location ?? 'N/A')),
          ]));
        }
      } else {
        for (final lectureSection in course.sections.entries) {
          rows.add(DataRow(cells: [
            DataCell(Text(course.code)),
            DataCell(Text(course.name)),
            DataCell(Text('${course.credits}')),
            DataCell(Text(lectureSection.key)),
            const DataCell(Text('Lecture')),
            const DataCell(Text('N/A')),
            const DataCell(Text('N/A')),
            const DataCell(Text('N/A')),
          ]));
          for (final labCode in lectureSection.value) {
            rows.add(DataRow(cells: [
              DataCell(Text(course.code)),
              DataCell(Text(course.name)),
              DataCell(Text('${course.credits}')),
              DataCell(Text(labCode)),
              DataCell(Text(_inferCourseCatalogType(labCode))),
              const DataCell(Text('N/A')),
              const DataCell(Text('N/A')),
              const DataCell(Text('N/A')),
            ]));
          }
        }
      }
    }
    return rows;
  }

  List<ModuleTabItem> _buildTabs() {
    debugPrint('Building tabs for role: $_userRole (raw: ${widget.user.role})');
    if (_userRole == UserRole.student) {
      debugPrint('Showing student interface');
      return [
        ModuleTabItem(
          label: 'Courses Registration',
          icon: Icons.library_books_outlined,
          description: 'Select and register for available subjects this semester. Choose your course, section, and tutorial/lab slot.',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Choose your subject from the course catalog', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<Course>(
                      isExpanded: true,
                      initialValue: _selectedCourse ?? _courses.first,
                      decoration: const InputDecoration(
                        labelText: 'Course / Subject',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: _courses
                          .map((course) => DropdownMenuItem<Course>(
                                value: course,
                                child: Text('${course.code} • ${course.name}'),
                              ))
                          .toList(),
                      selectedItemBuilder: (context) => _courses
                          .map(
                            (course) => Text(
                              '${course.code} - ${course.name}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                          .toList(),
                      onChanged: (course) => _selectCourse(course),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _selectedSection,
                      decoration: const InputDecoration(
                        labelText: 'Section',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: _availableSections
                          .map((section) => DropdownMenuItem<String>(
                                value: section,
                                child: Text(section),
                              ))
                          .toList(),
                      onChanged: _availableSections.isEmpty ? null : _selectSection,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _selectedLab,
                      decoration: const InputDecoration(
                        labelText: 'Tutorial / Lab',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: _availableLabs
                          .map((lab) => DropdownMenuItem<String>(
                                value: lab,
                                child: Text(lab),
                              ))
                          .toList(),
                      onChanged: _availableLabs.isEmpty ? null : _selectLab,
                    ),
                    const SizedBox(height: 12),
                    if (_selectedCourse != null && _selectedSection != null)
                      _buildSelectedScheduleSummary(),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _registrationOpen ? _registerSelectedCourse : null,
                      child: const Text('Register'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text('Registered subjects', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              if (_registeredSubjects.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.grayOne,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text('No subjects registered yet.'),
                )
              else
                ..._registeredSubjects.map((entry) => Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text('${entry.courseCode} • ${entry.courseName}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Section ${entry.section} · Lab ${entry.lab}'),
                            Text('Status: ${entry.status}', style: TextStyle(
                              color: entry.status == 'Registered' ? Colors.orange :
                                     entry.status == 'Notified' ? Colors.blue :
                                     Colors.green,
                              fontWeight: FontWeight.w500,
                            )),
                          ],
                        ),
                        trailing: FilledButton(
                          onPressed: _registrationOpen
                              ? () async {
                                  final course = _courses.firstWhere((c) => c.code == entry.courseCode);
                                  _dropCourse(course);
                                  setState(() {
                                    _registeredSubjects.remove(entry);
                                  });
                                  try {
                                    final docId = _buildStudentRegistrationDocId(widget.user.uid, entry.courseCode, entry.section);
                                    await FirebaseFirestore.instance
                                        .collection('subject_registrations')
                                        .doc(docId)
                                        .set({'status': 'dropped', 'droppedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
                                  } catch (e) {
                                    debugPrint('Failed to update drop status in Firestore: $e');
                                  }
                                }
                              : null,
                          style: FilledButton.styleFrom(backgroundColor: Colors.red),
                          child: const Text('Drop'),
                        ),
                      ),
                    )),
                if (_registeredSubjects.isNotEmpty && !_registeredSubjects.any((s) => s.status == 'Notified'))
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: FilledButton(
                      onPressed: _notifyAllLecturers,
                      child: const Text('Notify Lecturers - Registration Complete'),
                    ),
                  ),
            ],
          ),
        ),
        ModuleTabItem(
          label: 'Course Catalog',
          icon: Icons.list,
          description: 'Browse all available courses with their sections, schedule, day, time, and location.',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Available Courses', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Code', style: TextStyle(fontWeight: FontWeight.w700))),
                    DataColumn(label: Text('Course Name', style: TextStyle(fontWeight: FontWeight.w700))),
                    DataColumn(label: Text('Credits', style: TextStyle(fontWeight: FontWeight.w700))),
                    DataColumn(label: Text('Section', style: TextStyle(fontWeight: FontWeight.w700))),
                    DataColumn(label: Text('Type', style: TextStyle(fontWeight: FontWeight.w700))),
                    DataColumn(label: Text('Day', style: TextStyle(fontWeight: FontWeight.w700))),
                    DataColumn(label: Text('Time', style: TextStyle(fontWeight: FontWeight.w700))),
                    DataColumn(label: Text('Location', style: TextStyle(fontWeight: FontWeight.w700))),
                  ],
                  rows: _buildCourseCatalogRows(),
                ),
              ),
            ],
          ),
        ),
      ];
    }

    if (_userRole == UserRole.registrar) {
      debugPrint('Showing registrar interface for role: $_userRole, raw role: ${widget.user.role}');
      return [
        ModuleTabItem(
          label: 'Manage Registration Period',
          icon: Icons.calendar_today,
          description: 'Open or close the registration window and set the start and end dates for the current semester registration period.',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Registration Period Management', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              _InfoCard(
                label: 'Current Status',
                value: _registrationOpen ? 'Open' : 'Closed',
                icon: _registrationOpen ? Icons.lock_open : Icons.lock,
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Registration Period', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      Text('Start: ${_registrationStartDate.toString().split(' ')[0]}'),
                      Text('End: ${_registrationEndDate.toString().split(' ')[0]}'),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          FilledButton(
                            onPressed: _toggleRegistrationPeriod,
                            child: Text(_registrationOpen ? 'Close Registration' : 'Open Registration'),
                          ),
                          OutlinedButton(
                            onPressed: () => setState(() => _isEditingPeriod = !_isEditingPeriod),
                            child: const Text('Edit Period'),
                          ),
                        ],
                      ),
                      if (_isEditingPeriod) ...[
                        const SizedBox(height: 16),
                        const Text('Edit Registration Period:', style: TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.calendar_today, size: 16),
                                onPressed: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: _registrationStartDate,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2030),
                                    helpText: 'Select Start Date',
                                  );
                                  if (picked != null) {
                                    await _updateRegistrationPeriod(picked, _registrationEndDate);
                                  }
                                },
                                label: Text('Start: ${_registrationStartDate.toString().split(' ')[0]}'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.calendar_today, size: 16),
                                onPressed: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: _registrationEndDate,
                                    firstDate: _registrationStartDate,
                                    lastDate: DateTime(2030),
                                    helpText: 'Select End Date',
                                  );
                                  if (picked != null) {
                                    await _updateRegistrationPeriod(_registrationStartDate, picked);
                                  }
                                },
                                label: Text('End: ${_registrationEndDate.toString().split(' ')[0]}'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            TextButton(
                              onPressed: () => _updateRegistrationPeriod(
                                DateTime.now(),
                                DateTime.now().add(const Duration(days: 30)),
                              ),
                              child: const Text('Next 30 Days'),
                            ),
                            TextButton(
                              onPressed: () => _updateRegistrationPeriod(
                                _registrationStartDate,
                                _registrationEndDate.add(const Duration(days: 7)),
                              ),
                              child: const Text('Extend +7 Days'),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        ModuleTabItem(
          label: 'Manage Course Catalog',
          icon: Icons.library_books,
          description: 'Add or remove courses from the catalog and assign lecturers to specific course sections.',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Course Catalog Management', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              _InfoCard(label: 'Total Courses', value: '${_courses.length}', icon: Icons.menu_book),
              const SizedBox(height: 16),
              Row(
                children: [
                  FilledButton.icon(
                    onPressed: _openAddCourseDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add New Course'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Assign Subject to Lecturer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              if (_lecturerUsers.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.grayOne,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'No lecturers loaded yet. Please ensure lecturer accounts exist in the user database.',
                  ),
                )
              else ...[
                DropdownButtonFormField<Course>(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Choose Course',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: _selectedCourseForAssignment,
                  items: _courses.map((course) {
                    return DropdownMenuItem<Course>(
                      value: course,
                      child: Text(
                        '${course.code} - ${course.name}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  selectedItemBuilder: (context) => _courses
                      .map(
                        (course) => Text(
                          '${course.code} - ${course.name}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                      .toList(),
                  onChanged: _selectCourseForAssignment,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Choose Section',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: _selectedAssignmentSection,
                  items: _availableAssignmentSections.map((section) {
                    return DropdownMenuItem<String>(
                      value: section,
                      child: Text('Section $section'),
                    );
                  }).toList(),
                  onChanged: _selectAssignmentSection,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<AppUser>(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Choose Lecturer',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: _selectedLecturer,
                  items: _lecturerUsers.map((lecturer) {
                    return DropdownMenuItem<AppUser>(
                      value: lecturer,
                      child: Text(
                        lecturer.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  selectedItemBuilder: (context) => _lecturerUsers
                      .map(
                        (lecturer) => Text(
                          lecturer.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                      .toList(),
                  onChanged: (lecturer) => setState(() => _selectedLecturer = lecturer),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _assignSelectedCourseToLecturer,
                  child: const Text('Assign Lecturer'),
                ),
              ],
              const SizedBox(height: 16),
              const Text('Current Courses:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              ..._courses.map((course) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${course.code} - ${course.name}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${course.credits} credits • Capacity: ${course.capacity} • Enrolled: ${course.enrolled}',
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Default Instructor: ${course.instructor}',
                                      style: const TextStyle(
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeCourse(course),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Section Assignments',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          ..._buildAssignedSectionCards(course),
                        ],
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ];
    }

    debugPrint('Showing lecturer interface');
    return [
      ModuleTabItem(
        label: 'Lecturer',
        icon: Icons.person_outline,
        description: 'Review student registration notifications and confirm subject registrations submitted by students.',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoCard(
              label: 'Pending Confirmations',
              value: '${_notificationService.notifications.where((n) => n.status == 'Notified').length}',
              icon: Icons.how_to_reg_outlined,
            ),
            _InfoCard(
              label: 'Confirmed Registrations',
              value: '${_notificationService.notifications.where((n) => n.status == 'Confirmed').length}',
              icon: Icons.group_outlined,
            ),
            _InfoCard(
              label: 'Total Student Notifications',
              value: '${_notificationService.notifications.length}',
              icon: Icons.notifications_outlined,
            ),
            const SizedBox(height: 20),
            const Text('Student Notifications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            if (_notificationService.notifications.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.grayOne,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text('No notifications from students yet.'),
              )
            else
              ..._groupNotificationsByStudent().entries.map((entry) => Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.person, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text(
                                'Student: ${entry.key}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              const Spacer(),
                              if (entry.value.every((n) => n.status == 'Confirmed'))
                                const Icon(Icons.check_circle, color: Colors.green)
                              else
                                FilledButton(
                                  onPressed: () => _confirmAllStudentSubjects(entry.key),
                                  child: const Text('Confirm All'),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text('Registered Subjects:', style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          ...entry.value.map((notification) => Padding(
                                padding: const EdgeInsets.only(left: 16, bottom: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${notification.courseCode} • ${notification.courseName} (Section ${notification.section} • Lab ${notification.lab})',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: notification.status == 'Notified' ? Colors.blue.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        notification.status,
                                        style: TextStyle(
                                          color: notification.status == 'Notified' ? Colors.blue : Colors.green,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  )),
          ],
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Building screen for user: ${widget.user.fullName}, role: ${widget.user.role}');
    return ModuleShellScreen(
      title: 'Open Registration and Subject Registration',
      subtitle: '',
      icon: Icons.menu_book_rounded,
      accent: AppColors.studentBlue,
      softAccent: AppColors.infoSoft,
      tabs: _buildTabs(),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.studentBlue),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 18)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension SpaceExt on num {
  Widget get height => SizedBox(height: toDouble());
}
