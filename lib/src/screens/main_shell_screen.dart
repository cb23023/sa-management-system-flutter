import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';
import 'attendance/attendance_screen.dart';
import 'co_curriculum_activity_and_credit_claim/co_curriculum_module_page.dart';
import 'open_registration_and_subject_registration/open_registration_and_subject_registration_screen.dart';
import 'tuition_fee_and_payment/tuition_fee_module.dart';
import '../theme/app_colors.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/module_card.dart';
import '../widgets/phone_frame.dart';

CoCurriculumRole? _coCurriculumRoleForUser(String role) {
  switch (role.trim().toLowerCase()) {
    case 'pusat_adab':
    case 'pusat adab':
      return CoCurriculumRole.pusatAdab;
    case 'lecturer':
      return CoCurriculumRole.lecturer;
    case 'student':
      return CoCurriculumRole.student;
    default:
      return null;
  }
}

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({
    super.key,
    required this.user,
    required this.onLogout,
  });

  final AppUser user;
  final Future<void> Function() onLogout;

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      _HomeTab(user: widget.user),
      _NoticesTab(user: widget.user),
      _ProfileTab(user: widget.user),
    ];

    return Scaffold(
      body: SafeArea(
        child: PhoneFrame(
          child: Container(
            color: AppColors.softBackground,
            child: Column(
              children: [
                Expanded(child: pages[_currentIndex.clamp(0, 2)]),
                AppBottomNav(
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    if (index == 3) {
                      widget.onLogout();
                      return;
                    }
                    setState(() => _currentIndex = index);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final coCurriculumRole = _coCurriculumRoleForUser(user.role);

    final modules = [
      (
        const ModuleCardData(
          code: 'M1',
          title: 'Open Registration and Subject Registration',
          subtitle:
              'View available subjects and register based on programme, prerequisites, and credit limits.',
          status: '',
          foreground: AppColors.studentBlue,
          background: AppColors.infoSoft,
          enabled: true,
          icon: Icons.menu_book_rounded,
        ),
        OpenRegistrationAndSubjectRegistrationScreen(user: user),
      ),
      (
        ModuleCardData(
          code: 'M2',
          title: 'Co Curriculum Activity and Credit Claim',
          subtitle: coCurriculumRole == null
              ? 'Available only for Student, Lecturer, and Pusat Adab accounts.'
              : 'Join approved activities and submit credit claims with validated attendance records.',
          status: '',
          foreground: AppColors.treasuryTeal,
          background: AppColors.tealSoft,
          enabled: coCurriculumRole != null,
          icon: Icons.groups_rounded,
        ),
        coCurriculumRole == null
            ? null
            : CoCurriculumModulePage(
                role: coCurriculumRole,
                userName: user.fullName,
                userUid: user.uid,
              ),
      ),
      (
        const ModuleCardData(
          code: 'M3',
          title: 'Tuition Fee and Payment',
          subtitle:
              'View tuition fees, make payments, and track receipts and reminders.',
          status: '',
          foreground: AppColors.sunsetOrange,
          background: AppColors.yellowSoft,
          enabled: true,
          icon: Icons.account_balance_wallet_rounded,
        ),
        TuitionFeeModule(user: user),
      ),
      (
        const ModuleCardData(
          code: 'M4',
          title: 'Attendance',
          subtitle:
              'Check in to sessions and keep attendance records accurate, reliable, and secure.',
          status: '',
          foreground: AppColors.violet,
          background: AppColors.purpleSoft,
          enabled: true,
          icon: Icons.fact_check_rounded,
        ),
        const AttendanceScreen(),
      ),
    ];

    return _DashboardPage(
      pageTitle: 'Home',
      fillBody: true,
      body: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final crossAxisCount = width >= 680 ? 4 : 2;
                const spacing = 16.0;

                return GridView.builder(
                  itemCount: modules.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: spacing,
                    mainAxisSpacing: spacing,
                    mainAxisExtent: 220,
                  ),
                  itemBuilder: (context, index) {
                    final item = modules[index];
                    return ModuleCard(
                      data: item.$1,
                      onTap: item.$2 == null
                          ? null
                          : () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => item.$2!),
                              );
                            },
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _NoticesTab extends StatelessWidget {
  const _NoticesTab({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return _DashboardPage(
      pageTitle: 'Notices',
      body: [
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('notifications')
              .where('userId', isEqualTo: user.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const _ActionTile(
                icon: Icons.error_outline,
                title: 'Unable to load notices',
                subtitle: 'Please try again later.',
              );
            }

            final docs = snapshot.data?.docs.toList() ?? [];
            docs.sort((a, b) {
              final aDate = _parseShellDate(a.data()['createdAt']);
              final bDate = _parseShellDate(b.data()['createdAt']);
              if (aDate == null && bDate == null) return 0;
              if (aDate == null) return 1;
              if (bDate == null) return -1;
              return bDate.compareTo(aDate);
            });

            if (docs.isEmpty) {
              return const _ActionTile(
                icon: Icons.notifications_none_rounded,
                title: 'No notices yet',
                subtitle:
                    'Module updates and claim decisions will appear here.',
              );
            }

            return Column(
              children: List.generate(docs.length, (index) {
                final data = docs[index].data();
                final type = (data['type'] ?? 'info').toString();
                final createdAt = _parseShellDate(data['createdAt']);
                final destination = _noticeDestination(data, user);
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == docs.length - 1 ? 0 : 14,
                  ),
                  child: _NoticeCard(
                    icon: _noticeIcon(type),
                    color: _noticeColor(type),
                    background: _noticeBackground(type),
                    tag: createdAt == null
                        ? _noticeTag(type)
                        : '${_noticeTag(type)} - ${_displayShellDate(createdAt)}',
                    title: (data['title'] ?? 'Notice').toString(),
                    message: (data['message'] ?? '').toString(),
                    onTap: destination == null
                        ? null
                        : () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => destination),
                            ),
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return _DashboardPage(
      pageTitle: 'Profile',
      body: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: _ProfileDetailCard(user: user),
          ),
        ),
      ],
    );
  }
}

class _DashboardPage extends StatelessWidget {
  const _DashboardPage({
    required this.pageTitle,
    required this.body,
    this.fillBody = false,
  });

  final String pageTitle;
  final List<Widget> body;
  final bool fillBody;

  @override
  Widget build(BuildContext context) {
    if (fillBody) {
      return Column(
        children: [
          _PageHeader(pageTitle: pageTitle),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: body,
            ),
          ),
        ],
      );
    }

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          elevation: 0,
          expandedHeight: 76,
          collapsedHeight: 76,
          toolbarHeight: 76,
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.studentBlue,
          surfaceTintColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.darkSurface,
                  AppColors.studentBlue,
                  AppColors.treasuryTeal,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
          titleSpacing: 16,
          title: Row(
            children: [
              Image.asset('assets/images/logo-sams.png', width: 38, height: 38),
              const SizedBox(width: 12),
              Text(
                pageTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: body,
            ),
          ),
        ),
      ],
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.pageTitle});

  final String pageTitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.darkSurface,
            AppColors.studentBlue,
            AppColors.treasuryTeal,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        children: [
          Image.asset('assets/images/logo-sams.png', width: 38, height: 38),
          const SizedBox(width: 12),
          Text(
            pageTitle,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({
    required this.icon,
    required this.color,
    required this.background,
    required this.tag,
    required this.title,
    required this.message,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final Color background;
  final String tag;
  final String title;
  final String message;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textMuted,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}

String _formatRole(String role) {
  switch (role.trim().toLowerCase()) {
    case 'student':
      return 'Student';
    case 'lecturer':
      return 'Lecturer';
    case 'faculty_registrar':
      return 'Faculty Registrar';
    case 'pusat_adab':
      return 'Pusat Adab';
    case 'treasury':
      return 'Treasury';
    default:
      return role.replaceAll('_', ' ').split(' ').map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}').join(' ');
  }
}

Widget? _noticeDestination(Map<String, dynamic> data, AppUser user) {
  final module = (data['module'] ?? '').toString().toLowerCase().trim();
  switch (module) {
    case 'tuition':
      return TuitionFeeModule(user: user);
    case 'attendance':
      return const AttendanceScreen();
    case 'registration':
      return OpenRegistrationAndSubjectRegistrationScreen(user: user);
    case 'module2':
    case 'co_curriculum':
      final role = _coCurriculumRoleForUser(user.role);
      if (role == null) return null;
      return CoCurriculumModulePage(
        role: role,
        userName: user.fullName,
        userUid: user.uid,
      );
    default:
      return null;
  }
}

DateTime? _parseShellDate(dynamic value) {
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

String _displayShellDate(DateTime date) {
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

String _noticeTag(String type) {
  switch (type.trim().toLowerCase()) {
    case 'success':
      return 'Success';
    case 'warning':
    case 'danger':
      return 'Alert';
    default:
      return 'Update';
  }
}

IconData _noticeIcon(String type) {
  switch (type.trim().toLowerCase()) {
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

Color _noticeColor(String type) {
  switch (type.trim().toLowerCase()) {
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

Color _noticeBackground(String type) {
  switch (type.trim().toLowerCase()) {
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

class _ProfileDetailCard extends StatelessWidget {
  const _ProfileDetailCard({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 58,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.darkSurface, AppColors.studentBlue, AppColors.treasuryTeal],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -20),
            child: CircleAvatar(
              radius: 34,
              backgroundColor: const Color(0xFFFFD59E),
              child: Text(
                user.avatarInitials,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -10),
            child: Column(
              children: [
                Text(
                  user.fullName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  user.email,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _ProfileInfoRow(
            label: 'ID',
            value: user.identifier.isEmpty ? 'Not set' : user.identifier,
            icon: Icons.badge_outlined,
          ),
          _ProfileInfoRow(
            label: 'Semester',
            value: user.semester.isEmpty ? 'Not set' : user.semester,
            icon: Icons.calendar_today_outlined,
          ),
          _ProfileInfoRow(
            label: 'Role',
            value: _formatRole(user.role),
            icon: Icons.work_outline_rounded,
          ),
          _ProfileInfoRow(
            label: 'Faculty',
            value: user.faculty.isEmpty ? 'Not set' : user.faculty,
            icon: Icons.account_balance_outlined,
          ),
          _ProfileInfoRow(
            label: 'Programme',
            value: user.programme.isEmpty ? 'Not set' : user.programme,
            icon: Icons.school_outlined,
          ),
          _ProfileInfoRow(
            label: 'Status',
            value: user.accountStatus,
            icon: Icons.verified_user_outlined,
            pill: true,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({
    required this.label,
    required this.value,
    required this.icon,
    this.pill = false,
    this.isLast = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool pill;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 86,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSoft,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Icon(icon, size: 16, color: AppColors.textMuted),
                const SizedBox(width: 8),
                Expanded(
                  child: pill
                      ? Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.successSoft,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              value,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.success,
                              ),
                            ),
                          ),
                        )
                      : Text(
                          value,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w600,
                            height: 1.45,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.infoSoft,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: AppColors.studentBlue, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textMuted,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
