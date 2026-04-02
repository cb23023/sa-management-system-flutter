import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class ModuleCardData {
  const ModuleCardData({
    required this.code,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.foreground,
    required this.background,
    required this.enabled,
    required this.icon,
  });

  final String code;
  final String title;
  final String subtitle;
  final String status;
  final Color foreground;
  final Color background;
  final bool enabled;
  final IconData icon;
}

class ModuleCard extends StatelessWidget {
  const ModuleCard({super.key, required this.data, required this.onTap});

  final ModuleCardData data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: data.enabled ? 1 : 0.84,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: data.background),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.cardShadow,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -24,
                  right: -24,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: data.background,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 18,
                  right: 18,
                  child: Icon(
                    data.icon,
                    size: 54,
                    color: data.foreground.withValues(alpha: 0.08),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              data.foreground,
                              data.foreground.withValues(alpha: 0.76),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: data.foreground.withValues(alpha: 0.18),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Icon(data.icon, color: Colors.white, size: 24),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        data.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Text(
                          data.subtitle,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.25,
                            color: AppColors.textMuted,
                            height: 1.5,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: data.background,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Open',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: data.foreground,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.arrow_outward_rounded,
                            color: data.foreground,
                            size: 18,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
