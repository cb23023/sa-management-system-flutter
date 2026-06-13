import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class ModuleTabItem {
  const ModuleTabItem({
    required this.label,
    required this.icon,
    required this.content,
    this.badgeBuilder,
  });

  final String label;
  final IconData icon;
  final Widget content;
  final WidgetBuilder? badgeBuilder;
}

class ModuleShellScreen extends StatefulWidget {
  const ModuleShellScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.softAccent,
    required this.tabs,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final Color softAccent;
  final List<ModuleTabItem> tabs;

  @override
  State<ModuleShellScreen> createState() => _ModuleShellScreenState();
}

class ModuleShellScope extends InheritedWidget {
  const ModuleShellScope({
    super.key,
    required this.goToTab,
    required this.goToTabLabel,
    required super.child,
  });

  final void Function(int index) goToTab;
  final void Function(String label) goToTabLabel;

  static ModuleShellScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ModuleShellScope>();
  }

  @override
  bool updateShouldNotify(ModuleShellScope oldWidget) => false;
}

class _ModuleShellScreenState extends State<ModuleShellScreen> {
  int _currentIndex = 0;

  void _goToTab(int index) {
    if (index < 0 || index >= widget.tabs.length) {
      return;
    }
    setState(() => _currentIndex = index);
  }

  void _goToTabLabel(String label) {
    final index = widget.tabs.indexWhere(
      (tab) => tab.label.trim().toLowerCase() == label.trim().toLowerCase(),
    );
    if (index >= 0) {
      _goToTab(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTab = widget.tabs[_currentIndex];

    return ModuleShellScope(
      goToTab: _goToTab,
      goToTabLabel: _goToTabLabel,
      child: Scaffold(
        backgroundColor: AppColors.softBackground,
        body: SafeArea(
          child: Column(
            children: [
              Container(
              height: 76,
              padding: const EdgeInsets.symmetric(horizontal: 8),
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
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                    ),
                  ),
                  Image.asset(
                    'assets/images/logo-sams.png',
                    width: 34,
                    height: 34,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
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
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: widget.softAccent,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              widget.icon,
                              color: widget.accent,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentTab.label,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  widget.subtitle,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textMuted,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    currentTab.content,
                  ],
                ),
              ),
            ),
            Container(
              color: AppColors.softBackground,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground.withValues(alpha: 0.98),
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
                  child: Row(
                    children: List.generate(widget.tabs.length, (index) {
                      final item = widget.tabs[index];
                      final selected = index == _currentIndex;
                      return Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () => _goToTab(index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                gradient: selected
                                    ? LinearGradient(
                                        colors: [
                                          widget.accent,
                                          widget.accent.withValues(alpha: 0.72),
                                        ],
                                      )
                                    : null,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Icon(
                                        item.icon,
                                        size: 18,
                                        color: selected
                                            ? Colors.white
                                            : AppColors.textMuted,
                                      ),
                                      if (item.badgeBuilder != null)
                                        Positioned(
                                          right: -10,
                                          top: -8,
                                          child: item.badgeBuilder!(context),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    item.label,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: selected
                                          ? FontWeight.w700
                                          : FontWeight.w600,
                                      color: selected
                                          ? Colors.white
                                          : AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}
