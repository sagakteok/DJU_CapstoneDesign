import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// 내부 화면 import
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/app_start.dart';

// 회원가입 단계별 화면 import
import 'screens/signup/step1_terms_screen.dart';
import 'screens/signup/step2_userinfo_screen.dart';
import 'screens/signup/step3_account_screen.dart';
import 'screens/signup/step4_email_verify_screen.dart';
import 'screens/signup/step5_vehicle_screen.dart';
import 'screens/signup/step6_complete_screen.dart';

// 앱 실행 시작점
void main() {
  runApp(const MyApp()); // MyApp 위젯을 앱 전체로 실행
}

// MyApp은 StatefulWidget으로, 로그인 여부에 따라 초기 화면이 달라져야 하므로 상태가 필요함
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // 보안 저장소 인스턴스 생성 (토큰을 안전하게 저장/읽기용)
  final storage = FlutterSecureStorage();

  // 초기 화면은 로딩 중을 나타내기 위해 CircularProgressIndicator로 설정
  Widget _defaultScreen = const Center(child: CircularProgressIndicator());

  @override
  void initState() {
    super.initState();
    _checkToken(); // 위젯 초기화 시 토큰 확인
  }

  // 저장된 토큰이 있는지 확인해서 초기 화면을 결정하는 비동기 함수
  Future<void> _checkToken() async {
    final token = await storage.read(key: 'token'); // 토큰 읽기
    setState(() {
      // 토큰이 없으면 AppStartScreen (로그인/회원가입 화면)
      // 토큰이 있으면 HomeScreen으로 이동
      _defaultScreen = token == null ? const AppStart() : const HomeScreen();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OAuth Login Demo', // 앱 제목
      theme: ThemeData(
        primarySwatch: Colors.blue, // 기본 테마 색상
        scaffoldBackgroundColor: Colors.white, // 배경색
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(), // 텍스트필드 기본 테두리 설정
        ),
      ),
      debugShowCheckedModeBanner: false, // 오른쪽 상단 debug 배너 제거
      home: _defaultScreen, // 초기 화면 설정 (토큰 여부에 따라 다름)
      routes: {
        '/appstart': (context) => const AppStart(), // 앱 시작 화면 경로 등록
        '/login': (context) => const LoginScreen(), // 로그인 화면 경로 등록
        '/signup': (context) => const SignupScreen(), // 회원가입 화면 경로 등록
        '/home': (context) => const HomeScreen(), // 홈 화면 경로 등록
        '/signup/step1': (_) => const Step1TermsScreen(),
        '/signup/step2': (_) => const Step2UserInfoScreen(),
        '/signup/step3': (_) => const Step3AccountScreen(),
        '/signup/step4': (_) => const Step4EmailVerifyScreen(),
        '/signup/step5': (_) => const Step5VehicleScreen(),
        '/signup/step6': (_) => const Step6CompleteScreen(),
      },
    );
  }
}