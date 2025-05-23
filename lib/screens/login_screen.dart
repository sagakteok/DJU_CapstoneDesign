import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  final _authService = AuthService();

  Future<void> _login() async {
    setState(() => _isLoading = true);

    final success = await _authService.login(
      _emailController.text,
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인 실패')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('로그인')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 이메일 입력
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: '이메일'),
            ),
            const SizedBox(height: 10),

            // 비밀번호 입력
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: '비밀번호'),
            ),
            const SizedBox(height: 10),

            // ID 찾기 | 비밀번호 찾기 (오른쪽 정렬)
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () {
                      print("ID 찾기 클릭");
                      // TODO: ID 찾기 페이지 이동
                    },
                    child: const Text('ID 찾기'),
                  ),
                  const Text('|', style: TextStyle(color: Colors.grey)),
                  TextButton(
                    onPressed: () {
                      print("비밀번호 찾기 클릭");
                      // TODO: 비밀번호 찾기 페이지 이동
                    },
                    child: const Text('비밀번호 찾기'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 로그인 버튼 or 로딩 인디케이터
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: _login,
              child: const Text('로그인'),
            ),
            const SizedBox(height: 30),

            // 네이버 로그인 버튼
            ElevatedButton.icon(
              onPressed: () {
                print("네이버 로그인");
                // TODO: 네이버 로그인 연동
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF03C75A),
                foregroundColor: Colors.white,
              ),
              label: const Text('네이버로 로그인하기'),
            ),
            const SizedBox(height: 10),

            // 카카오 로그인 버튼
            ElevatedButton.icon(
              onPressed: () {
                print("카카오 로그인");
                // TODO: 카카오 로그인 연동
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFE812),
                foregroundColor: Colors.black,
              ),
              label: const Text('카카오로 로그인하기'),
            ),
          ],
        ),
      ),
    );
  }
}