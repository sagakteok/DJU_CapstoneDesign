import 'package:flutter/material.dart';

class Step1TermsScreen extends StatelessWidget {
  const Step1TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('약관 동의')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('필수 및 선택 약관에 동의해 주세요.'),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signup/step2');
              },
              child: const Text('다음 단계로 이동'),
            ),
          ],
        ),
      ),
    );
  }
}