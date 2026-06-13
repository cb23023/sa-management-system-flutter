import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../theme/app_colors.dart';
import '../../models/app_user.dart';
import '../../controllers/attendance/attendance_controller.dart';
import '../../controllers/attendance/location_controller.dart';
import '../../models/attendance/attendance_session_model.dart';
import '../../services/attendance/qr_service.dart';
import '../../widgets/attendance/attendance_widgets.dart';

// ── Lecturer: manage sessions & QR ───────────────────────────────────────────

class AttendanceManagementScreen extends StatefulWidget {
  const AttendanceManagementScreen({required this.currentUser, super.key});

  final AppUser? currentUser;

  @override
  State<AttendanceManagementScreen> createState() =>
      _AttendanceManagementScreenState();
}

class _AttendanceManagementScreenState
    extends State<AttendanceManagementScreen> {
  late final AttendanceController _controller;
  late final LocationController _locationController;
  late final Future<List<AttendanceOption>> _coCurriculumOptionsFuture;
  late final Future<List<AttendanceOption>> _academicSubjectOptionsFuture;

  final _sessionNameController = TextEditingController(text: 'Session 1');
  final _dateController = TextEditingController(text: '2026-04-06');
  final _timeController = TextEditingController(text: '09:00 - 11:00');
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AttendanceController(currentUser: widget.currentUser);
    _locationController = LocationController();
    _coCurriculumOptionsFuture = _controller.loadCoCurriculumOptions();
    _academicSubjectOptionsFuture =
        _controller.loadAcademicSubjectOptions();
  }

  @override
  void dispose() {
    _controller.dispose();
    _locationController.dispose();
    _sessionNameController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _fillLocation() async {
    final error = await _locationController.fillCurrentLocation();
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    setState(() {
      _latitudeController.text =
          _locationController.currentLatitude!.toStringAsFixed(6);
      _longitudeController.text =
          _locationController.currentLongitude!.toStringAsFixed(6);
    });
  }

  Future<void> _createSession(List<AttendanceOption> options) async {
    final latitude = double.tryParse(_latitudeController.text.trim());
    final longitude = double.tryParse(_longitudeController.text.trim());
    if (latitude == null || longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Set lecturer location first.')),
      );
      return;
    }
    _controller.setPendingSessionName(_sessionNameController.text.trim());
    _controller.setPendingDate(_dateController.text.trim());
    _controller.setPendingTime(_timeController.text.trim());
    _controller.setPendingLocation(latitude, longitude);

    await _controller.createSession(options);
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Attendance session created.')));
  }

  Widget _buildOptionSelector(List<AttendanceOption> options) {
    if (options.isEmpty) {
      return AttMessageCard(
        message: _controller.selectedCategory == AttendanceCategory.module
            ? 'No co-curriculum activity assigned to this lecturer yet.'
            : 'No academic subject assigned to this lecturer yet.',
      );
    }
    _controller.selectedOptionId ??= options.first.id;
    return DropdownButtonFormField<String>(
      isExpanded: true,
      itemHeight: 64,
      initialValue: options.any((o) => o.id == _controller.selectedOptionId)
          ? _controller.selectedOptionId
          : options.first.id,
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        labelText: _controller.selectedCategory == AttendanceCategory.module
            ? 'Co-Curriculum Activity'
            : 'Academic Subject',
      ),
      items: options
          .map(
            (o) => DropdownMenuItem(
              value: o.id,
              child: _AttendanceOptionLabel(option: o),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value == null) return;
        setState(() => _controller.selectedOptionId = value);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AttendanceOption>>(
      future: _controller.selectedCategory == AttendanceCategory.module
          ? _coCurriculumOptionsFuture
          : _academicSubjectOptionsFuture,
      builder: (context, optionSnapshot) {
        final options = optionSnapshot.data ?? const <AttendanceOption>[];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AttSectionHeader(
              'Manage Attendance',
              'Create a session, then share QR or code.',
            ),
            const SizedBox(height: 12),
            AttSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<AttendanceCategory>(
                    initialValue: _controller.selectedCategory,
                    decoration: const InputDecoration(labelText: 'Manage For'),
                    items: AttendanceCategory.values
                        .map(
                          (c) => DropdownMenuItem(
                            value: c,
                            child: Text(c.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _controller.selectedCategory = value;
                        _controller.selectedOptionId = null;
                        _controller.previewSession = null;
                        _controller.qrSaved = false;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildOptionSelector(options),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _sessionNameController,
                    decoration: const InputDecoration(labelText: 'Session'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _dateController,
                    decoration: const InputDecoration(labelText: 'Date'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _timeController,
                    decoration: const InputDecoration(labelText: 'Time'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _latitudeController,
                          decoration:
                              const InputDecoration(labelText: 'Latitude'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _longitudeController,
                          decoration:
                              const InputDecoration(labelText: 'Longitude'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: _fillLocation,
                      icon: const Icon(Icons.place_outlined),
                      label: const Text('Use Current Location'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Valid within 100 meters',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton.icon(
                      onPressed: _controller.saving || options.isEmpty
                          ? null
                          : () => _createSession(options),
                      icon: const Icon(Icons.qr_code_2_rounded),
                      label: Text(
                        _controller.saving
                            ? 'Saving...'
                            : 'Generate QR & Code',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_controller.previewSession != null) ...[
              const SizedBox(height: 16),
              AttQrPreviewCard(
                session: _controller.previewSession!,
                saved: _controller.qrSaved,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          setState(() => _controller.qrSaved = false),
                      icon: const Icon(Icons.visibility_outlined),
                      label: const Text('Preview'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() => _controller.qrSaved = true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('QR ready to share.')),
                        );
                      },
                      icon: const Icon(Icons.share_outlined),
                      label: const Text('Share'),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            FutureBuilder<List<AttendanceSession>>(
              future: _controller.loadSessionsForLecturer(),
              builder: (context, sessionSnapshot) {
                final sessions = sessionSnapshot.data ?? const [];
                if (sessions.isEmpty) return const SizedBox.shrink();
                return AttSurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recent Sessions',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...sessions.take(3).map(
                            (session) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: AttStatusRow(
                                session.subject,
                                '${session.sessionName} | ${session.date} | Code ${session.classCode}',
                                session.category.label,
                                AppColors.violet,
                                AppColors.purpleSoft,
                              ),
                            ),
                          ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

// ── Student: check in ─────────────────────────────────────────────────────────

class _AttendanceOptionLabel extends StatelessWidget {
  const _AttendanceOptionLabel({required this.option});

  final AttendanceOption option;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          option.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          option.subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class StudentCheckInScreen extends StatefulWidget {
  const StudentCheckInScreen({required this.currentUser, super.key});

  final AppUser? currentUser;

  @override
  State<StudentCheckInScreen> createState() => _StudentCheckInScreenState();
}

class _StudentCheckInScreenState extends State<StudentCheckInScreen> {
  late final AttendanceController _controller;
  late final LocationController _locationController;
  late final QrService _qrService;
  final _classCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AttendanceController(currentUser: widget.currentUser);
    _locationController = LocationController();
    _qrService = QrService();
  }

  @override
  void dispose() {
    _controller.dispose();
    _locationController.dispose();
    _qrService.dispose();
    _classCodeController.dispose();
    super.dispose();
  }

  Future<void> _showDialog({required String title, required String message}) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _scanQr() async {
    final scanned = await Navigator.of(context).push<ScannedSessionData>(
      MaterialPageRoute(builder: (_) => const StudentQrScannerPage()),
    );
    if (!mounted) return;
    if (scanned == null) {
      _controller.setStatusMessage('QR code was not detected. Please try again.');
      await _showDialog(
        title: 'QR Code Not Detected',
        message: 'The system could not detect a valid attendance QR code. Please try scanning again.',
      );
      return;
    }
    final session = await _controller.loadSessionById(scanned.sessionId);
    if (!mounted) return;
    if (session == null) {
      final inactive =
          await _controller.isSessionInactiveById(scanned.sessionId);
      if (!mounted) return;
      _controller.setStatusMessage(
        inactive
            ? 'Attendance session is inactive.'
            : 'QR scanned, but no active Firebase session was found.',
      );
      await _showDialog(
        title: inactive ? 'Attendance Session Not Active' : 'QR Code Not Detected',
        message: inactive
            ? 'The attendance session is not active, so the submission cannot proceed.'
            : 'The QR code was read, but no valid attendance session could be matched.',
      );
      return;
    }
    setState(() {
      _controller.applySession(
        session,
        message: 'QR scanned. Code filled in automatically.',
        scannedViaQr: true,
      );
      _classCodeController.text = session.classCode;
    });
  }

  Future<void> _scanFromGallery() async {
    try {
      final raw = await _qrService.scanFromGallery();
      if (!mounted) return;
      if (raw == null || raw.trim().isEmpty) {
        _controller.setStatusMessage(
            'No valid attendance QR found in the selected image.');
        await _showDialog(
          title: 'QR Code Not Detected',
          message: 'The system could not detect a valid attendance QR code from the selected image.',
        );
        return;
      }
      final session = await _controller.loadSessionFromQrRaw(raw);
      if (!mounted) return;
      if (session == null) {
        final parsed = ScannedSessionData.fromPayload(raw);
        final inactive = parsed != null
            ? await _controller.isSessionInactiveById(parsed.sessionId)
            : await _controller.isSessionInactiveByCode(raw);
        if (!mounted) return;
        _controller.setStatusMessage(
          inactive
              ? 'Attendance session is inactive.'
              : 'QR was read, but no matching attendance session was found.',
        );
        await _showDialog(
          title: inactive
              ? 'Attendance Session Not Active'
              : 'QR Code Not Detected',
          message: inactive
              ? 'The attendance session is not active, so the submission cannot proceed.'
              : 'The QR code was detected, but no matching active session was found.',
        );
        return;
      }
      setState(() {
        _controller.applySession(
          session,
          message: 'QR imported. Code filled in automatically.',
          scannedViaQr: true,
        );
        _classCodeController.text = session.classCode;
      });
    } catch (_) {
      if (!mounted) return;
      _controller.setStatusMessage('Unable to scan QR from gallery right now.');
      await _showDialog(
        title: 'QR Code Not Detected',
        message: 'The system could not detect a valid attendance QR code right now.',
      );
    }
  }

  Future<void> _findByCode() async {
    final code = _classCodeController.text.trim();
    if (code.isEmpty) {
      setState(
        () => _controller.statusMessage = 'Enter the attendance code first.',
      );
      return;
    }
    final session = await _controller.loadSessionByCode(code);
    if (!mounted) return;
    if (session == null) {
      final inactive = await _controller.isSessionInactiveByCode(code);
      if (!mounted) return;
      setState(() {
        _controller.statusMessage = inactive
            ? 'Attendance session is inactive.'
            : 'Attendance code not found.';
      });
      await _showDialog(
        title: inactive ? 'Attendance Session Not Active' : 'Invalid Class Code',
        message: inactive
            ? 'The attendance session is not active, so the submission cannot proceed.'
            : 'The class code is invalid or expired.',
      );
      return;
    }
    setState(() {
      _controller.applySession(
        session,
        message: 'Attendance session found. Code filled in automatically.',
        scannedViaQr: false,
      );
      _classCodeController.text = session.classCode;
    });
  }

  Future<void> _checkLocation() async {
    await _locationController.checkGeolocation(_controller.scannedSession);
    if (!mounted) return;
    setState(() {
      _controller.identityVerified = _locationController.identityVerified;
    });
    if (!_locationController.gpsVerified &&
        _controller.scannedSession != null) {
      await _showDialog(
        title: 'Student Outside Valid Location',
        message:
            'You are outside the allowed ${_controller.scannedSession!.allowedRadiusMeters.toStringAsFixed(0)}m range for attendance submission.',
      );
    }
  }

  Future<void> _submit() async {
    final validCode = _controller.scannedSession != null &&
        _classCodeController.text.trim().toUpperCase() ==
            _controller.scannedSession!.classCode.toUpperCase();

    if (_controller.scannedSession == null) {
      setState(() {
        _controller.statusMessage =
            'Complete scan/code, identity, location, and active session.';
      });
      return;
    }
    if (!validCode) {
      setState(
        () => _controller.statusMessage =
            'The class code is invalid or expired.',
      );
      await _showDialog(
        title: 'Invalid Class Code',
        message: 'The class code is invalid or expired.',
      );
      return;
    }
    if (!_controller.identityVerified || !_locationController.gpsVerified) {
      setState(() {
        _controller.statusMessage =
            'Complete scan/code, identity, location, and active session.';
      });
      if (!_locationController.gpsVerified) {
        await _showDialog(
          title: 'Student Outside Valid Location',
          message:
              'Your current location is outside the allowed attendance range.',
        );
      }
      return;
    }
    if (!_controller.sessionActive) {
      setState(
          () => _controller.statusMessage = 'Attendance session is inactive.');
      await _showDialog(
        title: 'Attendance Session Not Active',
        message: 'The attendance session is not active.',
      );
      return;
    }

    try {
      await _controller.submitAttendance();
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Attendance submitted.')));
    } catch (_) {
      if (!mounted) return;
      setState(() {});
      await _showDialog(
        title: 'System Error During Submission',
        message: 'The system failed to save attendance. Please retry.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AttSectionHeader(
          'Check In',
          'Use QR or code to submit your attendance.',
        ),
        const SizedBox(height: 12),
        AttSurfaceCard(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _scanQr,
                        icon: const Icon(Icons.qr_code_scanner_rounded),
                        label: Text(
                          _controller.qrScanned ? 'Scan Again' : 'Scan QR',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _scanFromGallery,
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('From Device'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _classCodeController,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _findByCode(),
                decoration:
                    const InputDecoration(labelText: 'Attendance Code'),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: _findByCode,
                  icon: const Icon(Icons.search_rounded),
                  label: const Text('Use Code'),
                ),
              ),
              if (_controller.scannedSession != null) ...[
                const SizedBox(height: 14),
                AttScannedSessionCard(session: _controller.scannedSession!),
              ],
              const SizedBox(height: 12),
              SwitchListTile(
                value: _controller.identityVerified,
                onChanged: (v) =>
                    setState(() => _controller.identityVerified = v),
                contentPadding: EdgeInsets.zero,
                title: const Text('Identity verified'),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: _checkLocation,
                  icon: const Icon(Icons.my_location_rounded),
                  label: const Text('Check Location'),
                ),
              ),
              const SizedBox(height: 8),
              AttMessageCard(message: _locationController.locationMessage),
              const SizedBox(height: 8),
              SwitchListTile(
                value: _controller.sessionActive,
                onChanged: (v) =>
                    setState(() => _controller.sessionActive = v),
                contentPadding: EdgeInsets.zero,
                title: const Text('Session active'),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: _controller.submitting ? null : _submit,
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: Text(
                    _controller.submitting ? 'Submitting...' : 'Submit',
                  ),
                ),
              ),
              const SizedBox(height: 14),
              AttMessageCard(message: _controller.statusMessage),
            ],
          ),
        ),
      ],
    );
  }
}

// ── QR scanner page ───────────────────────────────────────────────────────────

class StudentQrScannerPage extends StatefulWidget {
  const StudentQrScannerPage({super.key});

  @override
  State<StudentQrScannerPage> createState() => _StudentQrScannerPageState();
}

class _StudentQrScannerPageState extends State<StudentQrScannerPage> {
  bool _handled = false;

  void _handleBarcode(BarcodeCapture capture) {
    if (_handled) return;
    final raw = capture.barcodes.first.rawValue;
    if (raw == null) return;

    final session = ScannedSessionData.fromPayload(raw);
    if (session == null) return;

    _handled = true;
    Navigator.of(context).pop(session);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Scan Attendance QR'),
      ),
      body: Stack(
        children: [
          MobileScanner(onDetect: _handleBarcode),
          Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          const Positioned(
            left: 24,
            right: 24,
            bottom: 40,
            child: Text(
              'Point the camera at the lecturer QR code to open the attendance verification form.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
