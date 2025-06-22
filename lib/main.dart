import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// 내부 화면 import
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/app_start.dart';

// 회원가입 단계별 화면 import
import 'screens/signup/step1_terms_screen.dart';
import 'screens/signup/step2_userinfo_screen.dart';
import 'screens/signup/step3_account_screen.dart';
import 'screens/signup/step4_email_verify_screen.dart';
import 'screens/signup/step5_vehicle_screen.dart';
import 'screens/signup/step6_complete_screen.dart';

// ID 찾기 단계별 화면 import
import 'screens/auth_edit/FindID/step1_email_verify_screen.dart';
import 'screens/auth_edit/FindID/step2_complete_screen.dart';

// 비밀번호 재설정 단계별 화면 import
import 'screens/auth_edit/ResetPW/step1_userinfo_screen.dart';
import 'screens/auth_edit/ResetPW/step2_email_verify_screen.dart';
import 'screens/auth_edit/ResetPW/step3_resetpw_screen.dart';
import 'screens/auth_edit/ResetPW/step4_complete_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 화면 회전 금지: 세로 방향 고정
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // 시스템 UI 스타일 (상태바, 내비게이션바 색상)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final storage = FlutterSecureStorage();

  Widget _defaultScreen = const Center(child: CircularProgressIndicator());

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    final token = await storage.read(key: 'token');
    setState(() {
      _defaultScreen = token == null ? const AppStart() : const HomeScreen();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '랏봇',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            systemNavigationBarColor: Colors.white,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: _defaultScreen,
      routes: {
        '/appstart': (context) => const AppStart(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/signup/step1': (_) => const SignupStep1TermsScreen(),
        '/signup/step2': (_) => const SignupStep2UserInfoScreen(),
        '/signup/step3': (_) => const SignupStep3AccountScreen(),
        '/signup/step4': (_) => const SignupStep4EmailVerifyScreen(),
        '/signup/step5': (_) => const SignupStep5VehicleScreen(),
        '/signup/step6': (_) => const SignupStep6CompleteScreen(),
        '/auth_edit/FindID/step1': (_) => const FindIDStep1EmailVerifyScreen(),
        '/auth_edit/FindID/step2': (_) => const FindIDStep2CompleteScreen(),
        '/auth_edit/ResetPW/step1': (_) => const ResetPWStep1UserInfoScreen(),
        '/auth_edit/ResetPW/step2': (_) => const ResetPWStep2EmailVerifyScreen(),
        '/auth_edit/ResetPW/step3': (_) => const ResetPWStep3ResetPWScreen(),
        '/auth_edit/ResetPW/step4': (_) => const ResetPWStep4ResetCompleteScreen()
      },
    );
  }
}