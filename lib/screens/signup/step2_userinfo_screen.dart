// step2_userinfo_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dju_parking_project/services/signup_state.dart';

class SignupStep2UserInfoScreen extends StatefulWidget {

  const SignupStep2UserInfoScreen({super.key});

  @override
  State<SignupStep2UserInfoScreen> createState() => _SignupStep2UserInfoScreenState();
}

class _SignupStep2UserInfoScreenState extends State<SignupStep2UserInfoScreen> {
  final _nameController = TextEditingController();
  final _birthController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _allFieldsFilled() {
    return _nameController.text.isNotEmpty &&
        _birthController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty;
  }

  void _nextStep() {
    final signupState = Provider.of<SignupState>(context, listen: false);

    signupState.updateStep2(
      name: _nameController.text,
      birthDate: _birthController.text,
      phoneNumber: _phoneController.text,
    );

    // 콘솔 출력
    print(">>> Step1 marketingOptIn: ${signupState.marketingOptIn}");
    print(">>> Step2 입력값: name=${signupState.name}, birthDate=${signupState.birthDate}, phoneNumber=${signupState.phoneNumber}");

    Navigator.pushNamed(context, '/signup/step3');
  }

  @override
  Widget build(BuildContext context) {
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
                      _buildTextField(_nameController, '이름을 입력해주세요.', onChanged: (_) => setState(() {})),
                      const SizedBox(height: 15),
                      _buildLabel('생년월일'),
                      _buildTextField(_birthController, '예: 19990101', onChanged: (_) => setState(() {})),
                      const SizedBox(height: 15),
                      _buildLabel('전화번호'),
                      _buildTextField(_phoneController, '예: 01012345678', isPhone: true, onChanged: (_) => setState(() {})),
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
                  onPressed: _allFieldsFilled() ? _nextStep : null,
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

  Widget _buildLabel(String text) => Text(
    text,
    style: const TextStyle(
      color: Color(0xFF525252),
      fontWeight: FontWeight.w400,
      fontSize: 10,
      fontFamily: 'SpoqaHanSansNeo',
    ),
  );

  Widget _buildTextField(
      TextEditingController controller,
      String hintText, {
        bool isPhone = false,
        Function(String)? onChanged,
      }) {
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
      onChanged: onChanged,
    );
  }
}