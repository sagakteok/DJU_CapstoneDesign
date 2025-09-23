// step5_vehicle_screen.dart
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:dju_parking_project/services/signup_state.dart';

class SignupStep5VehicleScreen extends StatefulWidget {
  const SignupStep5VehicleScreen({super.key});

  @override
  State<SignupStep5VehicleScreen> createState() => _SignupStep5VehicleScreenState();
}

class _SignupStep5VehicleScreenState extends State<SignupStep5VehicleScreen> {
  final _vehicleNumberController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isButtonEnabled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _vehicleNumberController.addListener(_validateInput);
    _validateInput();
  }

  void _validateInput() {
    setState(() {
      _isButtonEnabled = _vehicleNumberController.text.trim().isNotEmpty;
    });
  }

  Future<void> _completeSignup() async {
    setState(() { _isLoading = true; });
    final _signupState = Provider.of<SignupState>(context, listen: false);

    final carRaw = _vehicleNumberController.text.trim();
    String formattedCar = carRaw;

    // 차량번호 한글 뒤 공백 적용
    final reg = RegExp(r'([0-9]+[가-힣]+)([0-9]+)');
    if (reg.hasMatch(carRaw)) {
      formattedCar = carRaw.replaceAllMapped(reg, (m) => '${m[1]} ${m[2]}');
    }

    // SignupState에 차량번호 저장
    _signupState.updateStep5(carNumber: formattedCar);

    // SignupState에 누적된 정보 가져오기
    final data = _signupState.toJson();

    // null 체크
    if (data['name'] == null ||
        data['email'] == null ||
        data['password'] == null ||
        data['phone_number'] == null ||
        data['birth_date'] == null ||
        data['car_number'] == null ||
        data['marketing_opt_in'] == null) {
      setState(() { _isLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('회원 정보가 올바르게 입력되지 않았습니다.')),
      );
      return;
    }

// 서버로 회원가입 요청 (7개 정보 모두 전달)
    final result = await _authService.signup(
      data['name']!,
      data['birth_date']!,
      data['phone_number']!,
      data['email']!,
      data['password']!,
      data['car_number']!,
      data['marketing_opt_in']!,
    );

    setState(() { _isLoading = false; });

    if (result['success'] == true) {
      Navigator.pushNamed(context, '/signup/step6');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? '가입 실패')),
      );
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

  Widget buildTextField(String label, TextEditingController controller, String hintText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle),
        TextField(
          controller: controller,
          style: _textStyle,
          decoration: buildInputDecoration(hintText),
        ),
      ],
    );
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
                    '차량 정보 입력',
                    style: TextStyle(
                      fontSize: 27,
                      fontFamily: 'VitroPride',
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '본인의 차량 정보를 입력 후',
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'SpoqaHanSansNeo',
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF000000),
                    ),
                  ),
                  Text(
                    '가입을 완료해주세요.',
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
                padding: const EdgeInsets.only(top: 80, bottom: 60),
                child: SizedBox(
                  width: buttonWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      buildTextField('차량 번호', _vehicleNumberController, '차량번호를 입력해주세요.'),
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
                  onPressed: _isButtonEnabled ? _completeSignup : null,
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
                    '가입 완료',
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