import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Small status indicator pill with color customization
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    required this.foreground,
    required this.background,
    this.compact = false,
  });

  final String label;
  final Color foreground;
  final Color background;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: compact ? 9 : 10,
          fontWeight: FontWeight.w700,
          color: foreground,
          height: 1.1,
        ),
      ),
    );
  }
}

/// Standard status color palette
class StatusPalette {
  static const Color successFg = AppColors.success;
  static const Color successBg = AppColors.successSoft;
  static const Color infoFg = AppColors.studentBlue;
  static const Color infoBg = AppColors.infoSoft;
  static const Color warningFg = AppColors.warning;
  static const Color warningBg = AppColors.warningSoft;
  static const Color dangerFg = AppColors.danger;
  static const Color dangerBg = AppColors.dangerSoft;
  static const Color tealFg = AppColors.treasuryTeal;
  static const Color tealBg = AppColors.tealSoft;
}
