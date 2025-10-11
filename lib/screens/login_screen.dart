import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  final _authService = AuthService();

  Future<void> _login() async {
    setState(() => _isLoading = true);

    try {
      final response = await _authService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      setState(() => _isLoading = false);

      // 안전하게 Map으로 변환
      final result = response is Map<String, dynamic> ? response : <String, dynamic>{};

      if (result['token'] != null) {
        Navigator.pushReplacementNamed(context, '/home');
      } else if (result['message'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'].toString())),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인 실패')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('에러 발생: $e')),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  static const labelTextStyle = TextStyle(
    color: Color(0xFF525252),
    fontWeight: FontWeight.w400,
    fontSize: 10,
    fontFamily: 'SpoqaHanSansNeo',
  );

  static const inputTextStyle = TextStyle(
    color: Color(0xFF000000),
    fontSize: 13,
    fontFamily: 'SpoqaHanSansNeo',
    fontWeight: FontWeight.w400,
  );

  static const hintTextStyle = TextStyle(
    color: Color(0xFFD6E1D1),
    fontSize: 13,
    fontFamily: 'SpoqaHanSansNeo',
    fontWeight: FontWeight.w400,
  );

  InputDecoration buildInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: hintTextStyle,
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFD6E1D1)),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFD6E1D1), width: 1.5),
      ),
    );
  }

  Widget buildLabel(String text) {
    return Text(text, style: labelTextStyle);
  }

  Widget buildTextField(
      TextEditingController controller,
      String hintText, {
        bool obscureText = false,
        TextInputType? keyboardType,
      }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: inputTextStyle,
      decoration: buildInputDecoration(hintText),
    );
  }

  Widget buildSocialButton({
    required String label,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    final buttonWidth = MediaQuery.of(context).size.width * 0.85;
    return SizedBox(
      width: buttonWidth,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: backgroundColor,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontFamily: 'SpoqaHanSansNeo',
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
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
            Navigator.pushReplacementNamed(context, '/appstart');
          },
        ),
        flexibleSpace: Container(
          color: Colors.white,
        ),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.02),
            SizedBox(
              width: screenWidth * 0.88,
              child: const Text(
                '로그인',
                style: TextStyle(
                  fontSize: 27,
                  fontFamily: 'VitroPride',
                  color: Color(0xFF1E1E1E),
                ),
                textAlign: TextAlign.start,
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
                      buildLabel('이메일'),
                      buildTextField(
                        _emailController,
                        '이메일을 입력해주세요.',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 15),
                      buildLabel('비밀번호'),
                      buildTextField(
                        _passwordController,
                        '비밀번호를 입력해주세요.',
                        obscureText: true,
                      ),
                      const SizedBox(height: 15),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ✅ 이메일 찾기 비활성화
                            // GestureDetector(
                            //   onTap: () {
                            //     Navigator.pushReplacementNamed(
                            //       context,
                            //       '/auth_edit/FindID/step1',
                            //     );
                            //   },
                            //   child: const Padding(
                            //     padding: EdgeInsets.only(right: 5),
                            //     child: Text(
                            //       '이메일 찾기',
                            //       style: TextStyle(
                            //         color: Color(0xFF424242),
                            //         fontFamily: 'SpoqaHanSansNeo',
                            //         fontWeight: FontWeight.w500,
                            //         fontSize: 11,
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            // const Padding(
                            //   padding: EdgeInsets.symmetric(horizontal: 5),
                            //   child: Text(
                            //     '|',
                            //     style: TextStyle(
                            //       color: Color(0xFFADB5CA),
                            //       fontFamily: 'SpoqaHanSansNeo',
                            //       fontWeight: FontWeight.w600,
                            //       fontSize: 11,
                            //     ),
                            //   ),
                            // ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/auth_edit/ResetPW/step1',
                                );
                              },
                              child: const Padding(
                                padding: EdgeInsets.only(left: 5),
                                child: Text(
                                  '비밀번호 재설정',
                                  style: TextStyle(
                                    color: Color(0xFF424242),
                                    fontFamily: 'SpoqaHanSansNeo',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isKeyboardVisible) const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: Column(
                children: [
                  SizedBox(
                    width: buttonWidth,
                    height: 52,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: const Color(0xFF50A12E),
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        '로그인',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'SpoqaHanSansNeo',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                buildSocialButton(
                    label: '카카오로 로그인하기',
                    backgroundColor: const Color(0xFFF5EF44),
                    textColor: Colors.black,
                    onPressed: () async {
                      final loginResult = await _authService.loginWithKakao();

                      if (loginResult['success'] == true && loginResult['token'] != null) {
                        Navigator.pushReplacementNamed(context, '/home');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(loginResult['message'] ?? '카카오 연동된 계정이 없습니다.')),
                        );
                      }
                    }
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}