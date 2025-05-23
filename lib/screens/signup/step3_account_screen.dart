import 'package:flutter/material.dart';

class Step3AccountScreen extends StatefulWidget {
  const Step3AccountScreen({super.key});

  @override
  State<Step3AccountScreen> createState() => _Step3AccountScreenState();
}

class _Step3AccountScreenState extends State<Step3AccountScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  void _nextStep() {
    if (_passwordController.text != _passwordConfirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비밀번호가 일치하지 않습니다.')),
      );
      return;
    }
    Navigator.pushNamed(context, '/signup/step4');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원 정보 입력')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: '이메일'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: '비밀번호'),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordConfirmController,
              decoration: const InputDecoration(labelText: '비밀번호 재입력'),
              obscureText: true,
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