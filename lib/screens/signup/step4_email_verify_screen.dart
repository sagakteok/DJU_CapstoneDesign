// step4_email_verify_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/signup_state.dart';
import '../../services/auth_service.dart';

class SignupStep4EmailVerifyScreen extends StatefulWidget {
  const SignupStep4EmailVerifyScreen({super.key}); // 생성자에서 signupState 제거

  @override
  State<SignupStep4EmailVerifyScreen> createState() =>
      _SignupStep4EmailVerifyScreenState();
}

class _SignupStep4EmailVerifyScreenState
    extends State<SignupStep4EmailVerifyScreen> {
  late SignupState signupState; // Provider에서 가져올 변수

  final _emailCodeController = TextEditingController();
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isLoading = false;

  final AuthService _authService = AuthService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Provider에서 signupState 가져오기
    signupState = Provider.of<SignupState>(context, listen: false);
  }

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
    final email = signupState.email.trim(); // widget.signupState → signupState
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이메일이 비어있습니다.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final sendResult = await _authService.sendEmailVerification(email);
      if (sendResult['success'] == true) {
        _startCountdown();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이메일 인증번호가 발송되었습니다.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(sendResult['message'] ?? '인증번호 발송 실패')),
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
    final email = signupState.email.trim();
    final code = _emailCodeController.text.trim();
    if (email.isEmpty || code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이메일과 인증번호를 입력해주세요.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await _authService.verifyEmailCode(email, code);
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이메일 인증 완료! 다음 단계로 이동합니다.')),
        );
        Navigator.pushNamed(
          context,
          '/signup/step5',
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
      String hintText, {
        bool obscure = false,
        TextInputType keyboardType = TextInputType.text,
        bool showTimer = false,
      }) {
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
              obscureText: obscure,
              keyboardType: keyboardType,
            ),
            if (showTimer && _remainingSeconds > 0)
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
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = MediaQuery.of(context).size.width * 0.85;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;
    final isKeyboardVisible = bottomInset > 0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        flexibleSpace: Container(color: Colors.white),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.02),
            SizedBox(
              width: screenWidth * 0.88,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '이메일 인증',
                    style: TextStyle(
                      fontSize: 27,
                      fontFamily: 'VitroPride',
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '본인이 입력한 이메일 주소에서 인증을 완료해주세요.',
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'SpoqaHanSansNeo',
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF000000),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 60, bottom: 60),
                child: SizedBox(
                  width: buttonWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      buildTextField('인증번호', _emailCodeController, '인증번호를 입력해주세요.', showTimer: true),
                      SizedBox(
                        height: 52,
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : _sendEmailCode,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF50A12E), width: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
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
                    backgroundColor: const Color(0xFF50A12E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    '인증 완료',
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