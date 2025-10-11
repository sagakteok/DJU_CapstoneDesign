// step3_account_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dju_parking_project/services/signup_state.dart';

class SignupStep3AccountScreen extends StatefulWidget {
  const SignupStep3AccountScreen({super.key});

  @override
  State<SignupStep3AccountScreen> createState() => _SignupStep3AccountScreenState();
}

class _SignupStep3AccountScreenState extends State<SignupStep3AccountScreen> {
  late final SignupState signupState;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      signupState = Provider.of<SignupState>(context, listen: false);

      // 이전 단계 정보 콘솔 출력
      print('>>> Step1 marketingOptIn: ${signupState.marketingOptIn}');
      print('>>> Step2 입력값: name=${signupState.name}, birthDate=${signupState.birthDate}, phoneNumber=${signupState.phoneNumber}');

      _emailController.text = signupState.email;
      _passwordController.text = signupState.password;

      _emailController.addListener(_validateInputs);
      _passwordController.addListener(_validateInputs);
      _passwordConfirmController.addListener(_validateInputs);
    });
  }

  @override
  void dispose() {
    _emailController.removeListener(_validateInputs);
    _passwordController.removeListener(_validateInputs);
    _passwordConfirmController.removeListener(_validateInputs);

    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  void _validateInputs() {
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirm = _passwordConfirmController.text;

    final isEnabled = email.isNotEmpty && password.isNotEmpty && confirm.isNotEmpty && password == confirm;

    if (isEnabled != _isButtonEnabled) {
      setState(() {
        _isButtonEnabled = isEnabled;
      });
    }
  }

  void _nextStep() {
    if (!_isButtonEnabled) return;

    signupState.updateStep3(
      email: _emailController.text,
      password: _passwordController.text,
    );

    // Step3 입력값 콘솔 출력
    print('>>> Step3 입력값: email=${signupState.email}, password=${signupState.password}');

    Navigator.pushNamed(context, '/signup/step4', arguments: signupState);
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
                    '회원 정보 입력',
                    style: TextStyle(
                      fontSize: 27,
                      fontFamily: 'VitroPride',
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '로그인 후 서비스 이용을 위해',
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'SpoqaHanSansNeo',
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF000000),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '회원 정보를 입력해주세요.',
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
                      buildTextField('이메일', _emailController, '이메일을 입력해주세요.', keyboardType: TextInputType.emailAddress),
                      buildTextField('비밀번호', _passwordController, '비밀번호를 입력해주세요.', obscure: true),
                      buildTextField('비밀번호 재입력', _passwordConfirmController, '비밀번호를 다시 입력해주세요.', obscure: true),
                      if (isKeyboardVisible) const SizedBox(height: 170),
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
                  onPressed: _isButtonEnabled ? _nextStep : null,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
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

  Widget buildTextField(String label, TextEditingController controller,
      String hintText, {
        bool obscure = false,
        TextInputType keyboardType = TextInputType.text,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(
          color: Color(0xFF525252),
          fontWeight: FontWeight.w400,
          fontSize: 10,
          fontFamily: 'SpoqaHanSansNeo',
        )),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
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
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}