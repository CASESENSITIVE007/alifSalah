import 'package:flutter/material.dart';

import '../../l10n/app_lang.dart';
import '../../services/auth_service.dart';
import '../../theme.dart';

/// Phone-number OTP login (Firebase Auth) with an English/Urdu switch.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  String _countryCode = '+91';
  String? _verificationId;
  bool _busy = false;
  String? _error;

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.length < 7) {
      setState(() => _error = AppLang.t('invalid_phone'));
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    await AuthService.sendOtp(
      phoneNumber: '$_countryCode$phone',
      onCodeSent: (id) => setState(() {
        _verificationId = id;
        _busy = false;
      }),
      onError: (msg) => setState(() {
        _error = msg;
        _busy = false;
      }),
      onAutoVerified: () {},
    );
  }

  Future<void> _verify() async {
    if (_verificationId == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await AuthService.verifyOtp(_verificationId!, _otpController.text.trim());
      // AuthGate reacts to the auth state change.
    } catch (e) {
      setState(() {
        _error = AppLang.t('invalid_code');
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Rebuilds instantly when the language toggles.
    return ValueListenableBuilder<String>(
      valueListenable: AppLang.code,
      builder: (context, langCode, _) => _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    final awaitingOtp = _verificationId != null;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              const Icon(Icons.mosque, size: 80, color: AppTheme.deepGreen),
              const SizedBox(height: 12),
              const Text('Alif-Salah',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.deepGreen)),
              const Text('Your Masjid, in your pocket',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 48),
              if (!awaitingOtp) ...[
                Row(
                  children: [
                    SizedBox(
                      width: 90,
                      child: TextFormField(
                        initialValue: _countryCode,
                        onChanged: (v) => _countryCode = v.trim(),
                        keyboardType: TextInputType.phone,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration:
                            const InputDecoration(hintText: 'Phone number'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _busy ? null : _sendOtp,
                  child: _busy
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Send OTP'),
                ),
              ] else ...[
                Text('Enter the 6-digit code sent to\n$_countryCode${_phoneController.text}',
                    textAlign: TextAlign.center),
                const SizedBox(height: 16),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  style: const TextStyle(fontSize: 24, letterSpacing: 12),
                  decoration: const InputDecoration(counterText: ''),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _busy ? null : _verify,
                  child: _busy
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Verify & Continue'),
                ),
                TextButton(
                  onPressed:
                      _busy ? null : () => setState(() => _verificationId = null),
                  child: const Text('Change number'),
                ),
              ],
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(_error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
