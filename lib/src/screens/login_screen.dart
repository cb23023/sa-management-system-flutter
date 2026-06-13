import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../widgets/phone_frame.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.onLogin,
    required this.authService,
  });

  final ValueChanged<AppUser> onLogin;
  final AuthService authService;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const _savedCredentialsKey = 'saved_login_credentials_v1';
  final _emailController = TextEditingController(text: 'student@demo.sa');
  final _passwordController = TextEditingController(text: 'student123');
  List<_SavedCredential> _savedCredentials = const [];
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final encodedCredentials =
          preferences.getStringList(_savedCredentialsKey) ?? const [];
      final savedCredentials = encodedCredentials
          .map(_SavedCredential.fromStorage)
          .toList();

      if (!mounted) {
        return;
      }

      setState(() {
        _savedCredentials = savedCredentials;
      });
    } on MissingPluginException {
      if (!mounted) {
        return;
      }

      setState(() {
        _savedCredentials = const [];
      });
    }
  }

  Future<void> _saveCredential({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final updatedCredentials = [
      _SavedCredential(email: normalizedEmail, password: password),
      ..._savedCredentials.where(
        (credential) => credential.email != normalizedEmail,
      ),
    ];
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setStringList(
        _savedCredentialsKey,
        updatedCredentials.map((credential) => credential.toStorage()).toList(),
      );
    } on MissingPluginException {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _savedCredentials = updatedCredentials;
    });
  }

  Future<void> _removeCredential(String email) async {
    final updatedCredentials = _savedCredentials
        .where((credential) => credential.email != email)
        .toList();
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setStringList(
        _savedCredentialsKey,
        updatedCredentials.map((credential) => credential.toStorage()).toList(),
      );
    } on MissingPluginException {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _savedCredentials = updatedCredentials;
    });
  }

  void _applySavedCredential(_SavedCredential credential) {
    _emailController.text = credential.email;
    _passwordController.text = credential.password;
    setState(() {
      _errorMessage = null;
    });
  }

  bool _hasSavedCredential({
    required String email,
    required String password,
  }) {
    final normalizedEmail = email.trim().toLowerCase();
    return _savedCredentials.any(
      (credential) =>
          credential.email == normalizedEmail &&
          credential.password == password,
    );
  }

  Future<void> _promptToSaveCredential({
    required String email,
    required String password,
  }) async {
    if (_hasSavedCredential(email: email, password: password) || !mounted) {
      return;
    }

    final shouldSave =
        await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Save password?'),
              content: Text(
                'Save login for ${email.trim().toLowerCase()} on this device?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Not now'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldSave) {
      return;
    }

    await _saveCredential(email: email, password: password);
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await widget.authService.signIn(
        email: email,
        password: password,
      );

      if (!mounted) {
        return;
      }

      await _promptToSaveCredential(email: email, password: password);

      if (!mounted) {
        return;
      }

      widget.onLogin(user);
    } on FirebaseAuthException catch (error) {
      setState(() {
        _errorMessage = _mapAuthError(error);
      });
    } catch (error) {
      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _mapAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-credential':
      case 'invalid-login-credentials':
        return 'Invalid email or password.';
      case 'user-not-found':
        return 'No account found for this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-email':
        return 'Invalid email format.';
      case 'network-request-failed':
        return 'Network connection failed.';
      case 'configuration-not-found':
        return 'Firebase Auth is not fully configured.';
      default:
        return error.message ?? 'Login failed.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 980;

    return Scaffold(
      body: SafeArea(
        child: PhoneFrame(
          child: isWide
              ? Row(
                  children: [
                    const Expanded(flex: 11, child: _WideBrandPanel()),
                    Expanded(
                      flex: 8,
                      child: Container(
                        color: AppColors.softBackground,
                        child: Center(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(40),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 420),
                              child: _LoginCard(
                                emailController: _emailController,
                                passwordController: _passwordController,
                                savedCredentials: _savedCredentials,
                                isLoading: _isLoading,
                                obscurePassword: _obscurePassword,
                                errorMessage: _errorMessage,
                                onSelectSavedCredential: _applySavedCredential,
                                onRemoveSavedCredential: _removeCredential,
                                onTogglePassword: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                onLogin: _handleLogin,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : _MobileLoginLayout(
                  emailController: _emailController,
                  passwordController: _passwordController,
                  savedCredentials: _savedCredentials,
                  isLoading: _isLoading,
                  obscurePassword: _obscurePassword,
                  errorMessage: _errorMessage,
                  onSelectSavedCredential: _applySavedCredential,
                  onRemoveSavedCredential: _removeCredential,
                  onTogglePassword: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  onLogin: _handleLogin,
                ),
        ),
      ),
    );
  }
}

class _WideBrandPanel extends StatelessWidget {
  const _WideBrandPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.darkSurface, AppColors.studentBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo-sams.png',
              width: 240,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            const Text(
              'SA Management System',
              style: TextStyle(
                color: Colors.white,
                fontSize: 38,
                fontWeight: FontWeight.w800,
                height: 1.05,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Sign in to continue.',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileLoginLayout extends StatelessWidget {
  const _MobileLoginLayout({
    required this.emailController,
    required this.passwordController,
    required this.savedCredentials,
    required this.isLoading,
    required this.obscurePassword,
    required this.errorMessage,
    required this.onSelectSavedCredential,
    required this.onRemoveSavedCredential,
    required this.onTogglePassword,
    required this.onLogin,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final List<_SavedCredential> savedCredentials;
  final bool isLoading;
  final bool obscurePassword;
  final String? errorMessage;
  final ValueChanged<_SavedCredential> onSelectSavedCredential;
  final ValueChanged<String> onRemoveSavedCredential;
  final VoidCallback onTogglePassword;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.darkSurface, AppColors.studentBlue],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Image.asset(
                'assets/images/logo-sams.png',
                width: 150,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Sign In',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Sign in to continue.',
              style: TextStyle(fontSize: 13, color: Colors.white70),
            ),
            const SizedBox(height: 20),
            _LoginCard(
              emailController: emailController,
              passwordController: passwordController,
              savedCredentials: savedCredentials,
              isLoading: isLoading,
              obscurePassword: obscurePassword,
              errorMessage: errorMessage,
              onSelectSavedCredential: onSelectSavedCredential,
              onRemoveSavedCredential: onRemoveSavedCredential,
              onTogglePassword: onTogglePassword,
              onLogin: onLogin,
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.emailController,
    required this.passwordController,
    required this.savedCredentials,
    required this.isLoading,
    required this.obscurePassword,
    required this.errorMessage,
    required this.onSelectSavedCredential,
    required this.onRemoveSavedCredential,
    required this.onTogglePassword,
    required this.onLogin,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final List<_SavedCredential> savedCredentials;
  final bool isLoading;
  final bool obscurePassword;
  final String? errorMessage;
  final ValueChanged<_SavedCredential> onSelectSavedCredential;
  final ValueChanged<String> onRemoveSavedCredential;
  final VoidCallback onTogglePassword;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const _FieldLabel('Email'),
          const SizedBox(height: 8),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Email',
              prefixIcon: Icon(Icons.alternate_email_rounded),
            ),
          ),
          const SizedBox(height: 16),
          const _FieldLabel('Password'),
          const SizedBox(height: 8),
          TextField(
            controller: passwordController,
            obscureText: obscurePassword,
            decoration: InputDecoration(
              hintText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                onPressed: onTogglePassword,
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              ),
            ),
          ),
          if (savedCredentials.isNotEmpty) ...[
            const SizedBox(height: 16),
            const _FieldLabel('Saved Login'),
            const SizedBox(height: 8),
            _SavedCredentialPicker(
              credentials: savedCredentials,
              onSelect: onSelectSavedCredential,
              onRemove: onRemoveSavedCredential,
            ),
          ],
          if (errorMessage != null) ...[
            const SizedBox(height: 14),
            _ErrorCard(message: errorMessage!),
          ],
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: isLoading ? null : onLogin,
            child: Text(isLoading ? 'Signing In...' : 'Sign In'),
          ),
          const SizedBox(height: 14),
          const Text(
            'student@demo.sa / student123',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _SavedCredentialPicker extends StatelessWidget {
  const _SavedCredentialPicker({
    required this.credentials,
    required this.onSelect,
    required this.onRemove,
  });

  final List<_SavedCredential> credentials;
  final ValueChanged<_SavedCredential> onSelect;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.softBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: credentials.asMap().entries.map((entry) {
          final index = entry.key;
          final credential = entry.value;
          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 2,
                ),
                leading: const Icon(
                  Icons.key_rounded,
                  color: AppColors.studentBlue,
                ),
                title: Text(
                  credential.email,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: const Text(
                  'Tap to fill email and password',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textMuted,
                  ),
                ),
                onTap: () => onSelect(credential),
                trailing: IconButton(
                  onPressed: () => onRemove(credential.email),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.textMuted,
                  ),
                  tooltip: 'Remove saved login',
                ),
              ),
              if (index < credentials.length - 1)
                const Divider(height: 1, color: AppColors.border),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11.5,
        color: AppColors.textMuted,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.dangerSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF2C2C2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 18,
            color: AppColors.danger,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 11.5,
                color: AppColors.danger,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedCredential {
  const _SavedCredential({required this.email, required this.password});

  factory _SavedCredential.fromStorage(String value) {
    final decoded = jsonDecode(value) as Map<String, dynamic>;
    return _SavedCredential(
      email: (decoded['email'] ?? '').toString(),
      password: (decoded['password'] ?? '').toString(),
    );
  }

  final String email;
  final String password;

  String toStorage() {
    return jsonEncode({'email': email, 'password': password});
  }
}
