import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../main.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class VehicleEditScreen extends StatefulWidget {
  const VehicleEditScreen({super.key});

  @override
  State<VehicleEditScreen> createState() => _VehicleEditScreenState();
}

class _VehicleEditScreenState extends State<VehicleEditScreen> {
  final _vehicleNumberController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _completeSignup() async {
    setState(() {
      _isLoading = true;
    });

    // 차량번호 한글 뒤 공백 적용
    String carRaw = _vehicleNumberController.text.trim();
    String formattedCar = carRaw;
    final reg = RegExp(r'([0-9]+[가-힣]+)([0-9]+)');
    if (reg.hasMatch(carRaw)) {
      formattedCar = carRaw.replaceAllMapped(reg, (m) => '${m[1]} ${m[2]}');
    }

    // 저장된 토큰 가져오기
    final token = await _authService.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('토큰이 존재하지 않습니다. 다시 로그인해주세요.')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // JWT 디코딩하여 user_id 추출 (AuthService 내부에서 이미 처리 가능)
    final result = await _authService.updateCarNumber(formattedCar);

    setState(() {
      _isLoading = false;
    });

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('차량번호가 성공적으로 수정되었습니다.')),
      );
      Navigator.pushReplacementNamed(context, '/auth_edit/UserInfoEditComplete');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? '차량번호 수정 실패')),
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
              width: buttonWidth,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '차량번호 수정',
                    style: TextStyle(
                      fontSize: 27,
                      fontFamily: 'VitroPride',
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '새로운 차량번호를 설정해보세요.',
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
                  onPressed: _completeSignup,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: const Color(0xFF50A12E),
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
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