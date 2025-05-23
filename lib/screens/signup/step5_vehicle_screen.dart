import 'package:flutter/material.dart';

class Step5VehicleScreen extends StatefulWidget {
  const Step5VehicleScreen({super.key});

  @override
  State<Step5VehicleScreen> createState() => _Step5VehicleScreenState();
}

class _Step5VehicleScreenState extends State<Step5VehicleScreen> {
  final _vehicleNumberController = TextEditingController();

  void _completeSignup() {
    // 차량 번호 저장 및 회원가입 완료 처리 (서버 통신 등)
    Navigator.pushNamed(context, '/signup/step6');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('차량 정보 입력')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _vehicleNumberController,
              decoration: const InputDecoration(labelText: '차량 번호'),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _completeSignup,
              child: const Text('가입 완료하기'),
            ),
          ],
        ),
      ),
    );
  }
}