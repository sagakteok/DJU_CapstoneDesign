import 'package:dju_parking_project/screens/auth_edit/password_edit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// 로그인 전후 화면
import 'screens/login_screen.dart';
import 'screens/app_start.dart';
import 'screens/bottom_navigation.dart'; // ✅ 바텀 네비가 포함된 메인 루트

// 회원가입 단계별 화면
import 'screens/signup/step1_terms_screen.dart';
import 'screens/signup/step2_userinfo_screen.dart';
import 'screens/signup/step3_account_screen.dart';
import 'screens/signup/step4_email_verify_screen.dart';
import 'screens/signup/step5_vehicle_screen.dart';
import 'screens/signup/step6_complete_screen.dart';

// ID 찾기 단계별 화면
import 'screens/auth_edit/FindID/step1_email_verify_screen.dart';
import 'screens/auth_edit/FindID/step2_complete_screen.dart';

// 비밀번호 재설정 단계별 화면
import 'screens/auth_edit/ResetPW/step1_userinfo_screen.dart';
import 'screens/auth_edit/ResetPW/step2_email_verify_screen.dart';
import 'screens/auth_edit/ResetPW/step3_resetpw_screen.dart';
import 'screens/auth_edit/ResetPW/step4_complete_screen.dart';

// 계정 정보 수정
import 'screens/auth_edit/userinfo_edit.dart';
import 'screens/auth_edit/email_edit.dart';
import 'screens/auth_edit/password_edit.dart';
import 'screens/auth_edit/vehicle_edit.dart';
import 'screens/auth_edit/userinfo_edit_complete.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 화면 회전 금지: 세로 방향 고정
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // 상태바 & 내비게이션바 스타일
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
      _defaultScreen = token == null ? const AppStart() : const BottomNavigation(); // ✅ 여기만 변경
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
        '/appstart': (_) => const AppStart(),
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const BottomNavigation(),
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
        '/auth_edit/ResetPW/step4': (_) => const ResetPWStep4ResetCompleteScreen(),
        '/auth_edit/UserInfoEdit': (_) => const UserInfoEditScreen(),
        '/auth_edit/EmailEdit': (_) => const EmailEditScreen(),
        '/auth_edit/PasswordEdit': (_) => const PasswordEditScreen(),
        '/auth_edit/VehicleEdit': (_) => const VehicleEditScreen(),
        '/auth_edit/UserInfoEditComplete': (_) => const UserInfoEditCompleteScreen()
      },
    );
  }
}