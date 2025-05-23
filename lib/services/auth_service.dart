// HTTP 통신 및 JSON 변환, 보안 저장소 관련 패키지 import
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// 인증 관련 기능을 담당하는 서비스 클래스
class AuthService {
  // FlutterSecureStorage 인스턴스 (안전하게 토큰 저장하기 위해 사용)
  final storage = FlutterSecureStorage();

  // Flask 서버의 기본 주소 (10.0.2.2는 Android 에뮬레이터에서 로컬호스트를 의미함)
  final baseUrl = 'http://10.0.2.2:5000';

  /// 회원가입 요청을 서버에 보내고 성공 여부를 반환
  ///
  /// [name], [email], [password], [phone] 정보를 JSON으로 전송
  /// 서버 응답이 201(Created)이면 true 반환, 아니면 false
  Future<bool> signup(String name, String email, String password, String phone) async {
    final url = Uri.parse('$baseUrl/api/signup'); // 회원가입 API 주소
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"}, // JSON 형식 명시
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
      }),
    );

    if (response.statusCode == 201) {
      return true; // 회원가입 성공
    } else {
      print('회원가입 실패: ${response.body}'); // 실패 응답 출력
      return false;
    }
  }

  /// 로그인 요청을 보내고, 성공 시 JWT 토큰을 저장
  ///
  /// 로그인 성공 시 서버에서 받은 토큰을 secure storage에 저장
  /// 성공 여부를 boolean으로 반환
  Future<bool> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/api/login'); // 로그인 API 주소
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"}, // JSON 형식 명시
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body); // 응답 JSON 파싱
      await storage.write(key: 'token', value: data['token']); // 토큰 저장
      return true; // 로그인 성공
    } else {
      print('로그인 실패: ${response.body}'); // 실패 응답 출력
      return false;
    }
  }

  /// 저장된 토큰 삭제 (로그아웃 처리)
  Future<void> logout() async {
    await storage.delete(key: 'token'); // 토큰 삭제
  }

  /// 저장된 토큰을 반환
  ///
  /// 로그인 상태 확인 등에 사용 가능
  Future<String?> getToken() async {
    return await storage.read(key: 'token'); // 토큰 읽기
  }
}