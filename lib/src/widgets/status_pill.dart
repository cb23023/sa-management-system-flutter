import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

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

class StatusPalette {
  static const successFg = AppColors.success;
  static const successBg = AppColors.successSoft;
  static const infoFg = AppColors.studentBlue;
  static const infoBg = AppColors.infoSoft;
  static const warningFg = AppColors.warning;
  static const warningBg = AppColors.warningSoft;
  static const dangerFg = AppColors.danger;
  static const dangerBg = AppColors.dangerSoft;
  static const tealFg = AppColors.treasuryTeal;
  static const tealBg = AppColors.tealSoft;
}
