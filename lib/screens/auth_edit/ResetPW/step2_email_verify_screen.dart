// lib/screens/auth_edit/ResetPW/step2_email_verify_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import './step3_resetpw_screen.dart';

class ResetPWStep2EmailVerifyScreen extends StatefulWidget {
  final String email; // 필수 email 전달

  const ResetPWStep2EmailVerifyScreen({super.key, required this.email});

  @override
  State<ResetPWStep2EmailVerifyScreen> createState() =>
      _ResetPWStep2EmailVerifyScreenState();
}

class _ResetPWStep2EmailVerifyScreenState
    extends State<ResetPWStep2EmailVerifyScreen> {
  final _emailCodeController = TextEditingController();
  final AuthService _authService = AuthService(); // 이메일 전송/검증 서비스
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isLoading = false;

  void _startCountdown() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = 420; // 7분
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds == 0) {
        timer.cancel();
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  Future<void> _sendEmailCode() async {
    setState(() => _isLoading = true);
    try {
      final result = await _authService.sendEmailVerification(widget.email);
      if (result['success'] == true) {
        _startCountdown();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이메일 인증번호가 발송되었습니다.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? '인증번호 발송 실패')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류 발생: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyCode() async {
    final code = _emailCodeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('인증번호를 입력해주세요.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await _authService.verifyEmailCode(widget.email, code);
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이메일 인증 완료! 다음 단계로 이동합니다.')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPWStep3ResetPWScreen(email: widget.email),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? '인증번호 검증 실패')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류 발생: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ===== 기존 스타일/레이아웃 그대로 =====
  final _labelStyle = const TextStyle(
    color: Color(0xFF525252),
    fontWeight: FontWeight.w400,
    fontSize: 10,
    fontFamily: 'SpoqaHanSansNeo',
  );

  final _textStyle = const TextStyle(
    color: Color(0xFF000000),
    fontSize: 13,
    fontFamily: 'SpoqaHanSansNeo',
    fontWeight: FontWeight.w400,
  );

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  InputDecoration buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFFD6E1D1),
        fontSize: 13,
        fontFamily: 'SpoqaHanSansNeo',
        fontWeight: FontWeight.w400,
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFD6E1D1)),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFD6E1D1), width: 1.5),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller,
      String hintText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle),
        Stack(
          alignment: Alignment.centerRight,
          children: [
            TextField(
              controller: controller,
              style: _textStyle,
              decoration: buildInputDecoration(hintText),
            ),
            if (_remainingSeconds > 0)
              Padding(
                padding: EdgeInsets.zero,
                child: Text(
                  _formatTime(_remainingSeconds),
                  style: const TextStyle(
                    color: Color(0xFFCD0505),
                    fontSize: 13,
                    fontFamily: 'SpoqaHanSansNeo',
                    fontWeight: FontWeight.w200,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buttonWidth = MediaQuery.of(context).size.width * 0.85;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = bottomInset > 0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        flexibleSpace: Container(color: Colors.white),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 10),
            SizedBox(
              width: buttonWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '이메일 인증',
                    style: TextStyle(
                      fontSize: 27,
                      fontFamily: 'VitroPride',
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '본인이 입력한 이메일 주소에서',
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'SpoqaHanSansNeo',
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF000000),
                    ),
                  ),
                  const Text(
                    '인증을 완료해주세요.',
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'SpoqaHanSansNeo',
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF000000),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '인증 대상 이메일: ${widget.email}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'SpoqaHanSansNeo',
                      fontWeight: FontWeight.w400,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 40, bottom: 60),
                child: SizedBox(
                  width: buttonWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      buildTextField(
                          '이메일 인증번호', _emailCodeController, '인증번호를 입력해주세요.'),
                      SizedBox(
                        height: 52,
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : _sendEmailCode,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF50A12E), width: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            backgroundColor: Colors.white,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Color(0xFF50A12E))
                              : const Text(
                            '인증번호 보내기',
                            style: TextStyle(
                              color: Color(0xFF50A12E),
                              fontSize: 14,
                              fontFamily: 'SpoqaHanSansNeo',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      if (isKeyboardVisible) const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: SizedBox(
                width: buttonWidth,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyCode,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: const Color(0xFF50A12E),
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    '인증 완료하기',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'SpoqaHanSansNeo',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}