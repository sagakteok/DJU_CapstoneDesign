import 'package:flutter/material.dart';

class Step6CompleteScreen extends StatelessWidget {
  const Step6CompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입 완료')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
                  (route) => false,
            );
          },
          child: const Text('로그인하기'),
        ),
      ),
    );
  }
}