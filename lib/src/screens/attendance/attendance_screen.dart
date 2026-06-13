import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../global/module_shell_screen.dart';
import 'attendance_dashboard.dart';
import 'attendance_management.dart';
import 'attendance_record.dart';
import 'history.dart';
import 'report.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late final Future<AppUser?> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = AuthService().getCurrentAppUser();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppUser?>(
      future: _userFuture,
      builder: (context, snapshot) {
        final user = snapshot.data;
        final config = _AttendanceRoleConfig.forRole(
          user?.role.toLowerCase() ?? 'user',
          currentUser: user,
        );
        return ModuleShellScreen(
          title: 'Attendance',
          subtitle: config.subtitle,
          icon: config.icon,
          accent: AppColors.violet,
          softAccent: AppColors.purpleSoft,
          tabs: config.tabs,
        );
      },
    );
  }
}

class _AttendanceRoleConfig {
  const _AttendanceRoleConfig({
    required this.subtitle,
    required this.icon,
    required this.tabs,
  });

  final String subtitle;
  final IconData icon;
  final List<ModuleTabItem> tabs;

  static _AttendanceRoleConfig forRole(String role, {AppUser? currentUser}) {
    switch (role) {
      case 'student':
        return _AttendanceRoleConfig(
          subtitle: '',
          icon: Icons.badge_rounded,
          tabs: [
            ModuleTabItem(
              label: 'Check In',
              icon: Icons.qr_code_scanner_rounded,
              content: StudentCheckInScreen(currentUser: currentUser),
            ),
            ModuleTabItem(
              label: 'History',
              icon: Icons.history_rounded,
              content: AttendanceHistoryScreen(currentUser: currentUser),
            ),
          ],
        );

      case 'lecturer':
        return _AttendanceRoleConfig(
          subtitle:
              'Manage module or academic attendance, publish QR and codes, and update records.',
          icon: Icons.co_present_rounded,
          tabs: [
            ModuleTabItem(
              label: 'Manage',
              icon: Icons.event_available_outlined,
              content: AttendanceManagementScreen(currentUser: currentUser),
            ),
            ModuleTabItem(
              label: 'Records',
              icon: Icons.fact_check_outlined,
              content: AttendanceRecordScreen(currentUser: currentUser),
            ),
          ],
        );

      case 'pusat_adab':
        return const _AttendanceRoleConfig(
          subtitle:
              'Retrieve attendance data, review student records, and generate attendance reports for download.',
          icon: Icons.groups_rounded,
          tabs: [
            ModuleTabItem(
              label: 'Dashboard',
              icon: Icons.dashboard_outlined,
              content: AttendanceDashboardScreen(),
            ),
            ModuleTabItem(
              label: 'Records',
              icon: Icons.folder_open_outlined,
              content: PusatAdabRecordScreen(),
            ),
            ModuleTabItem(
              label: 'Report',
              icon: Icons.assessment_outlined,
              content: AttendanceReportScreen(),
            ),
            ModuleTabItem(
              label: 'Exit',
              icon: Icons.logout_rounded,
              content: _ExitTab(
                title: 'Leave Pusat Adab attendance',
                description:
                    'Return to the main dashboard after reviewing records and downloading the required report.',
              ),
            ),
          ],
        );

      default:
        return const _AttendanceRoleConfig(
          subtitle:
              'View attendance module updates, published records, and current operational alerts.',
          icon: Icons.fact_check_rounded,
          tabs: [
            ModuleTabItem(
              label: 'Dashboard',
              icon: Icons.dashboard_outlined,
              content: _GeneralDashboardTab(),
            ),
            ModuleTabItem(
              label: 'Records',
              icon: Icons.folder_open_outlined,
              content: _GeneralRecordTab(),
            ),
            ModuleTabItem(
              label: 'Alerts',
              icon: Icons.notifications_outlined,
              content: _GeneralAlertTab(),
            ),
            ModuleTabItem(
              label: 'Exit',
              icon: Icons.logout_rounded,
              content: _ExitTab(
                title: 'Leave attendance',
                description:
                    'Use the back button in the header whenever you are ready to return to the main SAMS dashboard.',
              ),
            ),
          ],
        );
    }
  }
}

// ── General role tabs (read-only, static) ─────────────────────────────────────

class _GeneralDashboardTab extends StatelessWidget {
  const _GeneralDashboardTab();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeroCard(
          badge: 'User',
          title: 'Attendance records are available for review.',
          description:
              'This general view highlights published attendance information and module alerts for non-module actors.',
          leftValue: '12',
          leftLabel: 'Published sessions',
          rightValue: '02',
          rightLabel: 'Alerts',
        ),
      ],
    );
  }
}

class _GeneralRecordTab extends StatelessWidget {
  const _GeneralRecordTab();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          'Published Records',
          'Visible attendance summaries for general users.',
        ),
        SizedBox(height: 12),
        _SurfaceCard(
          child: Column(
            children: [
              _StatusRow(
                'Database Systems',
                'Closed session with finalised lecturer record',
                'Closed',
                AppColors.success,
                AppColors.successSoft,
              ),
              SizedBox(height: 12),
              _StatusRow(
                'Leadership Camp Briefing',
                'Validation notes are still being updated',
                'Updating',
                AppColors.warning,
                AppColors.warningSoft,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GeneralAlertTab extends StatelessWidget {
  const _GeneralAlertTab();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          'Operational Alerts',
          'Current attendance module alerts that may require coordination.',
        ),
        SizedBox(height: 12),
        _SurfaceCard(
          child: Column(
            children: [
              _ActionTile(
                'Venue mismatch detected',
                '07 records',
                'Several entries require manual review before session closure.',
                Icons.warning_amber_rounded,
                AppColors.warning,
                AppColors.warningSoft,
              ),
              SizedBox(height: 12),
              _ActionTile(
                'Attendance health stable',
                'Most sessions normal',
                'Current attendance patterns do not show high-risk movement.',
                Icons.health_and_safety_outlined,
                AppColors.success,
                AppColors.successSoft,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ExitTab extends StatelessWidget {
  const _ExitTab({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Row(
        children: [
          const _IconBox(
            icon: Icons.logout_rounded,
            color: AppColors.violet,
            background: AppColors.purpleSoft,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
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

// ── Private UI atoms ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title, this.subtitle);

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12.5,
            color: AppColors.textMuted,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
      child: child,
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({
    required this.icon,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: color, size: 22),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.text,
    required this.color,
    required this.background,
  });

  final String text;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile(
    this.title,
    this.value,
    this.description,
    this.icon,
    this.color,
    this.background,
  );

  final String title;
  final String value;
  final String description;
  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _IconBox(icon: icon, color: color, background: background),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textMuted,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow(
      this.title, this.detail, this.status, this.color, this.background);

  final String title;
  final String detail;
  final String status;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.grayOne,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  detail,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _Pill(text: status, color: color, background: background),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.badge,
    required this.title,
    required this.description,
    required this.leftValue,
    required this.leftLabel,
    required this.rightValue,
    required this.rightLabel,
  });

  final String badge;
  final String title;
  final String description;
  final String leftValue;
  final String leftLabel;
  final String rightValue;
  final String rightLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.darkSurfaceAlt, AppColors.violet],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Pill(
            text: badge,
            color: Colors.white,
            background: const Color(0x29FFFFFF),
          ),
          const SizedBox(height: 14),
          const Icon(Icons.fact_check_rounded, color: Colors.white, size: 28),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontSize: 21,
              height: 1.25,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              height: 1.55,
              color: Color(0xFFE9E8FF),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _HeroMetric(value: leftValue, label: leftLabel),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HeroMetric(value: rightValue, label: rightLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              color: Color(0xFFE9E8FF),
            ),
          ),
        ],
      ),
    );
  }
}
