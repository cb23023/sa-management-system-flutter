import 'package:flutter/material.dart';

import 'models/app_user.dart';
import 'screens/global/login_screen.dart';
import 'screens/global/main_shell_screen.dart';
import 'services/auth_service.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';
import 'widgets/phone_frame.dart';

class SaManagementSystemApp extends StatefulWidget {
  const SaManagementSystemApp({super.key});

  @override
  State<SaManagementSystemApp> createState() => _SaManagementSystemAppState();
}

class _SaManagementSystemAppState extends State<SaManagementSystemApp> {
  final AuthService _authService = AuthService();
  AppUser? _currentUser;
  bool _isInitializing = true;
  String? _startupError;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SA Management System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    if (_isInitializing) {
      return const Scaffold(
        body: SafeArea(
          child: PhoneFrame(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Loading SA Management System...',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (_startupError != null) {
      return Scaffold(
        body: SafeArea(
          child: PhoneFrame(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 520),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    _startupError!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textDark,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (_currentUser == null) {
      return LoginScreen(onLogin: _handleLogin, authService: _authService);
    }

    return MainShellScreen(user: _currentUser!, onLogout: _handleLogout);
  }

  Future<void> _restoreSession() async {
    try {
      final user = await _authService.getCurrentAppUser();
      if (!mounted) {
        return;
      }
      setState(() {
        _currentUser = user;
        _isInitializing = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _startupError = error.toString();
        _isInitializing = false;
      });
    }
  }

  void _handleLogin(AppUser user) {
    setState(() => _currentUser = user);
  }

  Future<void> _handleLogout() async {
    await _authService.signOut();
    if (!mounted) {
      return;
    }
    setState(() => _currentUser = null);
  }
}
