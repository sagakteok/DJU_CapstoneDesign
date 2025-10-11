import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class EmailEditScreen extends StatefulWidget {
  const EmailEditScreen({super.key});

  @override
  State<EmailEditScreen> createState() => _EmailEditScreenState();
}

class _EmailEditScreenState extends State<EmailEditScreen> {
  final _emailController = TextEditingController();
  final _emailCodeController = TextEditingController();
  Timer? _timer;
  int _remainingSeconds = 0;
  final AuthService _authService = AuthService();
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
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이메일을 입력해주세요.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // 이메일 변경 호출 제거 → 인증만 진행
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
    final email = _emailController.text.trim();
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
        // 인증 성공 시 이메일 변경 처리
        final updateResult = await _authService.updateEmail(email);
        if (updateResult['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('이메일 인증 및 변경이 완료되었습니다.')),
          );
          Navigator.pushReplacementNamed(context, '/auth_edit/UserInfoEditComplete');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(updateResult['message'] ?? '이메일 변경 실패')),
          );
        }
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
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
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
                    '이메일 수정',
                    style: TextStyle(
                      fontSize: 27,
                      fontFamily: 'VitroPride',
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '새로운 이메일을 설정해보세요.',
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
                padding: const EdgeInsets.only(top: 80, bottom: 60),
                child: SizedBox(
                  width: buttonWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      buildTextField('이메일', _emailController, '이메일을 입력해주세요.', keyboardType: TextInputType.emailAddress, showTimer: false),
                      buildTextField('이메일 인증번호', _emailCodeController, '인증번호를 입력해주세요.', showTimer: true),
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
                    '변경 완료',
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