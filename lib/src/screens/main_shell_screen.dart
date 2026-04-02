import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../modules/attendance/attendance_screen.dart';
import '../modules/co_curriculum_activity_and_credit_claim/co_curriculum_activity_and_credit_claim_screen.dart';
import '../modules/open_registration_and_subject_registration/open_registration_and_subject_registration_screen.dart';
import '../modules/tuition_fee_and_payment/tuition_fee_and_payment_screen.dart';
import '../services/seed_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/module_card.dart';
import '../widgets/phone_frame.dart';

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
      const _NoticesTab(),
      _ProfileTab(user: widget.user),
      _SettingsTab(onLogout: widget.onLogout),
    ];

    return Scaffold(
      body: SafeArea(
        child: PhoneFrame(
          child: Container(
            color: AppColors.softBackground,
            child: Column(
              children: [
                Expanded(child: pages[_currentIndex]),
                AppBottomNav(
                  currentIndex: _currentIndex,
                  onTap: (index) => setState(() => _currentIndex = index),
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
        const OpenRegistrationAndSubjectRegistrationScreen(),
      ),
      (
        const ModuleCardData(
          code: 'M2',
          title: 'Co Curriculum Activity and Credit Claim',
          subtitle:
              'Join approved activities and submit credit claims with validated attendance records.',
          status: '',
          foreground: AppColors.treasuryTeal,
          background: AppColors.tealSoft,
          enabled: true,
          icon: Icons.groups_rounded,
        ),
        const CoCurriculumActivityAndCreditClaimScreen(),
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
        const TuitionFeeAndPaymentScreen(),
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
                final height = constraints.maxHeight;
                final crossAxisCount = width >= 680 ? 4 : 2;
                final spacing = 16.0;
                final rows = (modules.length / crossAxisCount).ceil();
                final totalSpacing = spacing * (rows - 1);
                final itemHeight = (height - totalSpacing).clamp(150.0, 260.0);

                return GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: modules.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: spacing,
                    mainAxisSpacing: spacing,
                    mainAxisExtent: itemHeight,
                  ),
                  itemBuilder: (context, index) {
                    final item = modules[index];
                    return ModuleCard(
                      data: item.$1,
                      onTap: () {
                        Navigator.of(
                          context,
                        ).push(MaterialPageRoute(builder: (_) => item.$2));
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
  const _NoticesTab();

  @override
  Widget build(BuildContext context) {
    return const _DashboardPage(
      pageTitle: 'Notices',
      body: [
        _NoticeCard(
          icon: Icons.campaign_outlined,
          color: AppColors.studentBlue,
          background: AppColors.infoSoft,
          tag: 'Update',
          title: 'Open registration is now available',
          message:
              'Students can proceed to Open Registration and Subject Registration for subject selection.',
        ),
        SizedBox(height: 14),
        _NoticeCard(
          icon: Icons.event_available_outlined,
          color: AppColors.treasuryTeal,
          background: AppColors.tealSoft,
          tag: 'Update',
          title: 'Co-curriculum claims are active',
          message:
              'Activity registration and credit claim submission are available now.',
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

class _SettingsTab extends StatefulWidget {
  const _SettingsTab({required this.onLogout});

  final Future<void> Function() onLogout;

  @override
  State<_SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<_SettingsTab> {
  final SeedService _seedService = SeedService();
  bool _isSeeding = false;

  Future<void> _handleSeed() async {
    setState(() => _isSeeding = true);

    try {
      final summary = await _seedService.seedDemoData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Firestore seeded: ${summary.collectionCount} collections, ${summary.documentCount} documents.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Seed failed: $error')));
    } finally {
      if (mounted) setState(() => _isSeeding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _DashboardPage(
      pageTitle: 'Settings',
      body: [
        const _ActionTile(
          icon: Icons.palette_outlined,
          title: 'Theme',
          subtitle: 'SAMS color palette is active.',
        ),
        const SizedBox(height: 14),
        const _ActionTile(
          icon: Icons.security_outlined,
          title: 'Authentication',
          subtitle: 'Firebase Authentication is enabled.',
        ),
        const SizedBox(height: 14),
        const _ActionTile(
          icon: Icons.cloud_upload_outlined,
          title: 'Seed Demo Firestore',
          subtitle: 'Generate demo data automatically.',
        ),
        const SizedBox(height: 18),
        ElevatedButton.icon(
          onPressed: _isSeeding ? null : _handleSeed,
          icon: Icon(
            _isSeeding ? Icons.hourglass_top_rounded : Icons.upload_rounded,
          ),
          label: Text(
            _isSeeding ? 'Seeding Firestore...' : 'Seed Firestore Data',
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () async => widget.onLogout(),
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Logout'),
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
  });

  final IconData icon;
  final Color color;
  final Color background;
  final String tag;
  final String title;
  final String message;

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
    );
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
              color: const Color(0xFFF9EEDA),
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
            value: user.role.replaceAll('_', ' '),
            icon: Icons.work_outline_rounded,
          ),
          _ProfileInfoRow(
            label: 'Status',
            value: user.accountStatus,
            icon: Icons.verified_user_outlined,
            pill: true,
          ),
          _ProfileInfoRow(
            label: 'Initials',
            value: user.avatarInitials,
            icon: Icons.person_outline_rounded,
          ),
          _ProfileInfoRow(
            label: 'UID',
            value: user.uid.isEmpty ? 'Not set' : user.uid,
            icon: Icons.fingerprint_rounded,
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
