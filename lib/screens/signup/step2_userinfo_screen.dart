import 'dart:async';
import 'package:flutter/material.dart';

class SignupStep2UserInfoScreen extends StatefulWidget {
  const SignupStep2UserInfoScreen({super.key});

  @override
  State<SignupStep2UserInfoScreen> createState() => _SignupStep2UserInfoScreenState();
}

class _SignupStep2UserInfoScreenState extends State<SignupStep2UserInfoScreen> {
  final _nameController = TextEditingController();
  final _birthController = TextEditingController();
  final _phoneController = TextEditingController();
  final _authCodeController = TextEditingController();

  Timer? _timer;
  int _remainingSeconds = 0;

  void _sendAuthCode() {
    setState(() {
      _remainingSeconds = 420; // 7 minutes
    });
    _startTimer();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('인증번호가 발송되었습니다.')),
    );
  }

  void _startTimer() {
    _timer?.cancel();
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

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _nextStep() {
    Navigator.pushNamed(context, '/signup/step3');
  }

  @override
  Widget build(BuildContext context) {
    final buttonWidth = MediaQuery.of(context).size.width * 0.85;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = bottomInset > 0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: false,
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
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '기본 정보 확인',
                    style: TextStyle(
                      fontSize: 27,
                      fontFamily: 'VitroPride',
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '가입을 진행하기 이전에',
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'SpoqaHanSansNeo',
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF000000),
                    ),
                  ),
                  Text(
                    '연락처 등 정보를 확인해주세요.',
                    style: TextStyle(
                      fontSize: 13,
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
                      _buildLabel('이름'),
                      _buildTextField(_nameController, '이름을 입력해주세요.'),
                      const SizedBox(height: 15),
                      _buildLabel('생년월일'),
                      _buildTextField(_birthController, '예: 19990101'),
                      const SizedBox(height: 15),
                      _buildLabel('전화번호'),
                      _buildTextField(_phoneController, '예: 01012345678', isPhone: true),
                      const SizedBox(height: 15),
                      _buildLabel('전화번호 인증번호'),
                      Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          _buildTextField(_authCodeController, '인증번호를 입력해주세요.'),
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
                      SizedBox(
                        height: 52,
                        child: OutlinedButton(
                          onPressed: _sendAuthCode,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF50A12E)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            backgroundColor: Colors.white,
                          ),
                          child: const Text(
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
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF50A12E),
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    '다음 단계로 이동',
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF525252),
        fontWeight: FontWeight.w400,
        fontSize: 10,
        fontFamily: 'SpoqaHanSansNeo',
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText, {bool isPhone = false}) {
    return TextField(
      controller: controller,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      style: const TextStyle(
        color: Color(0xFF000000),
        fontSize: 13,
        fontFamily: 'SpoqaHanSansNeo',
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        hintText: hintText,
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
      ),
    );
  }
}