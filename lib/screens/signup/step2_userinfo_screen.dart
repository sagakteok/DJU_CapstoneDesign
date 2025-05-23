import 'package:flutter/material.dart';

class Step2UserInfoScreen extends StatefulWidget {
  const Step2UserInfoScreen({super.key});

  @override
  State<Step2UserInfoScreen> createState() => _Step2UserInfoScreenState();
}

class _Step2UserInfoScreenState extends State<Step2UserInfoScreen> {
  final _nameController = TextEditingController();
  final _birthController = TextEditingController();
  final _phoneController = TextEditingController();
  final _authCodeController = TextEditingController();

  void _sendAuthCode() {
    // 인증번호 보내기 로직 (서버 호출 등)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('인증번호가 발송되었습니다.')),
    );
  }

  void _nextStep() {
    Navigator.pushNamed(context, '/signup/step3');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('기본 정보 확인')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '이름'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _birthController,
              decoration: const InputDecoration(labelText: '생년월일'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: '전화번호'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _authCodeController,
                    decoration: const InputDecoration(labelText: '전화번호 인증번호'),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _sendAuthCode,
                  child: const Text('인증번호 보내기'),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _nextStep,
              child: const Text('다음 단계로 이동'),
            ),
          ],
        ),
      ),
    );
  }
}