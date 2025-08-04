import 'package:flutter/material.dart';

class SignupStep1TermsScreen extends StatefulWidget {
  const SignupStep1TermsScreen({super.key});

  @override
  State<SignupStep1TermsScreen> createState() => _SignupStep1TermsScreenState();
}

class _SignupStep1TermsScreenState extends State<SignupStep1TermsScreen> {
  bool allChecked = false;
  bool termsChecked = false;
  bool privacyChecked = false;
  bool marketingChecked = false;

  bool showTermsDetail = false;
  bool showPrivacyDetail = false;
  bool showMarketingDetail = false;

  void _toggleAll(bool? value) {
    setState(() {
      allChecked = value ?? false;
      termsChecked = allChecked;
      privacyChecked = allChecked;
      marketingChecked = allChecked;
    });
  }

  void _toggleIndividual(bool? value, String type) {
    setState(() {
      switch (type) {
        case 'terms':
          termsChecked = value ?? false;
          break;
        case 'privacy':
          privacyChecked = value ?? false;
          break;
        case 'marketing':
          marketingChecked = value ?? false;
          break;
      }
      allChecked = termsChecked && privacyChecked && marketingChecked;
    });
  }

  @override
  Widget build(BuildContext context) {
    final buttonWidth = MediaQuery.of(context).size.width * 0.85;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        flexibleSpace: Container(
          color: Colors.white,
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: screenHeight * 0.02),
          Center(
            child: SizedBox(
              width: buttonWidth,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lot Bot 가입',
                    style: TextStyle(
                      fontSize: 27,
                      fontFamily: 'VitroPride',
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '서비스 이용을 위하여',
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'SpoqaHanSansNeo',
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF000000),
                    ),
                  ),
                  Text(
                    '다음 약관에 동의해주세요.',
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
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 50),
              child: Center(
                child: Column(
                  children: [
                    _buildAgreeAllTile(buttonWidth),
                    const SizedBox(height: 20),
                    Container(
                      width: buttonWidth,
                      height: 1.5,
                      color: const Color(0xFF000000),
                    ),
                    const SizedBox(height: 20),
                    _buildPlainItem(
                      label: '(필수) 서비스 이용약관 동의',
                      value: termsChecked,
                      onChanged: (v) => _toggleIndividual(v, 'terms'),
                      isExpanded: showTermsDetail,
                      onExpandToggle: () => setState(() => showTermsDetail = !showTermsDetail),
                      detail: '서비스 이용 약관 상세 내용이 여기에 표시됩니다.',
                      buttonWidth: buttonWidth,
                    ),
                    const SizedBox(height: 20),
                    _buildPlainItem(
                      label: '(필수) 개인정보 수집 동의',
                      value: privacyChecked,
                      onChanged: (v) => _toggleIndividual(v, 'privacy'),
                      isExpanded: showPrivacyDetail,
                      onExpandToggle: () => setState(() => showPrivacyDetail = !showPrivacyDetail),
                      detail: '개인정보 수집 동의 상세 내용이 여기에 표시됩니다.',
                      buttonWidth: buttonWidth,
                    ),
                    const SizedBox(height: 20),
                    _buildPlainItem(
                      label: '(선택) 마케팅 정보 수신 동의',
                      value: marketingChecked,
                      onChanged: (v) => _toggleIndividual(v, 'marketing'),
                      isExpanded: showMarketingDetail,
                      onExpandToggle: () => setState(() => showMarketingDetail = !showMarketingDetail),
                      detail: '마케팅 수신 동의 상세 내용이 여기에 표시됩니다.',
                      buttonWidth: buttonWidth,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 50),
            child: Center(
              child: SizedBox(
                width: buttonWidth,
                height: 52,
                child: ElevatedButton(
                  onPressed: termsChecked && privacyChecked
                      ? () => Navigator.pushNamed(context, '/signup/step2')
                      : null,
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
          ),
        ],
      ),
    );
  }

  Widget _buildAgreeAllTile(double width) {
    return SizedBox(
      width: width,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => _toggleAll(!allChecked),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildCircleCheckBox(allChecked, (v) => _toggleAll(v)),
            const SizedBox(width: 15),
            const Expanded(
              child: Text(
                '약관에 모두 동의합니다.',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'SpoqaHanSansNeo',
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlainItem({
    required String label,
    required bool value,
    required Function(bool?) onChanged,
    required bool isExpanded,
    required VoidCallback onExpandToggle,
    required String detail,
    required double buttonWidth,
  }) {
    return SizedBox(
      width: buttonWidth,
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => onChanged(!value),
            child: Row(
              children: [
                _buildCircleCheckBox(value, onChanged),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: 'SpoqaHanSansNeo',
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF424242),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onExpandToggle,
                  behavior: HitTestBehavior.translucent,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    alignment: Alignment.center,
                    child: Icon(
                      isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isExpanded)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 10),
              alignment: Alignment.centerLeft,
              child: Text(
                detail,
                style: const TextStyle(
                  fontSize: 11,
                  fontFamily: 'SpoqaHanSansNeo',
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCircleCheckBox(bool value, Function(bool?) onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: value ? const Color(0xFF65A549) : const Color(0xFFDADADA),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check,
          size: 16,
          color: Colors.white,
        ),
      ),
    );
  }
}