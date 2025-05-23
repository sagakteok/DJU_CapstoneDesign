import 'package:flutter/material.dart';

class Step4EmailVerifyScreen extends StatefulWidget {
  const Step4EmailVerifyScreen({super.key});

  @override
  State<Step4EmailVerifyScreen> createState() => _Step4EmailVerifyScreenState();
}

class _Step4EmailVerifyScreenState extends State<Step4EmailVerifyScreen> {
  final _emailCodeController = TextEditingController();

  void _sendEmailCode() {
    // 이메일 인증번호 발송 로직
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('이메일 인증번호가 발송되었습니다.')),
    );
  }

  void _verifyCode() {
    // 인증번호 확인 로직 (생략)
    Navigator.pushNamed(context, '/signup/step5');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('이메일 인증')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailCodeController,
              decoration: const InputDecoration(labelText: '이메일 인증번호'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _sendEmailCode,
              child: const Text('인증번호 보내기'),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _verifyCode,
              child: const Text('인증 완료하기'),
            ),
          ],
        ),
      ),
    );
  }
}