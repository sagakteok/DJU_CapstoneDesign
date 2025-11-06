import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class AuthService {
  final storage = FlutterSecureStorage();
  final String _host = dotenv.env['HOST_ADDRESS']!;
  late final Uri baseUrl = Uri.parse('$_host/api/auth');

  Future<Map<String, dynamic>> signup(String name,
      String birthDate,
      String phoneNumber,
      String email,
      String password,
      String carNumber,
      bool marketingOptIn,) async {
    final url = Uri.parse('$baseUrl/register');
    try {
      debugPrint('[AuthService] 회원가입 요청 시작');
      final response = await http
          .post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'name': name,
          'birth_date': birthDate,
          'phone_number': phoneNumber,
          'email': email,
          'password': password,
          'car_number': carNumber,
          'marketing_opt_in': marketingOptIn,
        }),
      )
          .timeout(const Duration(seconds: 10));
      debugPrint('[AuthService] 회원가입 응답 수신: ${response.statusCode}');
      Map<String, dynamic> body;
      try {
        body = jsonDecode(response.body);
        if (body is! Map<String, dynamic>) {
          body = {'error': '서버 응답 포맷 오류'};
        }
      } catch (e) {
        body = {'error': '서버 응답 파싱 실패'};
      }
      if (response.statusCode == 201) {
        return {'success': true, ...body};
      } else {
        return {
          'success': false,
          'message': body['error'] ?? body['message'] ?? '회원가입 실패'
        };
      }
    } on http.ClientException catch (e) {
      debugPrint('[AuthService] 회원가입 ClientException: $e');
      return {'success': false, 'message': '네트워크 오류: $e'};
    } on FormatException catch (e) {
      debugPrint('[AuthService] 회원가입 FormatException: $e');
      return {'success': false, 'message': '서버 응답 포맷 오류'};
    } on Exception catch (e) {
      debugPrint('[AuthService] 회원가입 일반 오류: $e');
      return {'success': false, 'message': '네트워크 오류: $e'};
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    try {
      debugPrint('[AuthService] 로그인 요청 시작');
      final response = await http
          .post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      )
          .timeout(const Duration(seconds: 10));
      debugPrint('[AuthService] 로그인 응답 수신: ${response.statusCode}');
      Map<String, dynamic> body;
      try {
        body = jsonDecode(response.body);
        if (body is! Map<String, dynamic>) {
          body = {'error': '서버 응답 포맷 오류'};
        }
      } catch (e) {
        body = {'error': '서버 응답 파싱 실패'};
      }
      if (response.statusCode == 200) {
        if (body['token'] != null) {
          await storage.write(key: 'token', value: body['token']);
          final decodedToken = JwtDecoder.decode(body['token']);
          final userId = decodedToken['user_id'];
          if (userId != null) {
            await storage.write(key: 'user_id', value: userId.toString());
          }
          debugPrint('[AuthService] 저장된 토큰: ${body['token']}');
        }
        return {'success': true, ...body};
      } else {
        return {
          'success': false,
          'message': body['error'] ?? body['message'] ?? '로그인 실패'
        };
      }
    } on http.ClientException catch (e) {
      debugPrint('[AuthService] 로그인 ClientException: $e');
      return {'success': false, 'message': '네트워크 오류: $e'};
    } on FormatException catch (e) {
      debugPrint('[AuthService] 로그인 FormatException: $e');
      return {'success': false, 'message': '서버 응답 포맷 오류'};
    } on Exception catch (e) {
      debugPrint('[AuthService] 로그인 일반 오류: $e');
      return {'success': false, 'message': '네트워크 오류: $e'};
    }
  }

  Future<void> logout() async {
    debugPrint('[AuthService] 로그아웃 요청');
    await storage.delete(key: 'token');
    debugPrint('[AuthService] 로그아웃 완료');
  }

  Future<String?> getToken() async {
    debugPrint('[AuthService] 토큰 조회');
    return await storage.read(key: 'token');
  }

  Future<Map<String, dynamic>> getUserInfo() async {
    final token = await storage.read(key: 'token');
    if (token == null) {
      return {'error': '토큰 없음'};
    }
    final url = Uri.parse('$baseUrl/user');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      Map<String, dynamic> body;
      try {
        body = jsonDecode(response.body);
        if (body is! Map<String, dynamic>) {
          return {'error': '서버 응답 포맷 오류'};
        }
      } catch (e) {
        return {'error': '서버 응답 파싱 실패'};
      }
      if (response.statusCode == 200) {
        return {'success': true, ...body};
      } else {
        return {
          'success': false,
          'message': body['error'] ?? body['message'] ?? '사용자 정보 조회 실패'
        };
      }
    } catch (e) {
      return {'success': false, 'message': '네트워크 오류: $e'};
    }
  }

  /// 차량번호만 업데이트 (JWT에서 user_id 자동 추출)
  Future<Map<String, dynamic>> updateCarNumber(String carNumber) async {
    final token = await storage.read(key: 'token');
    if (token == null) {
      return {'success': false, 'message': '토큰 없음'};
    }

    // JWT 디코딩 후 user_id 추출
    final decodedToken = JwtDecoder.decode(token);
    final userId = decodedToken['user_id'];
    if (userId == null) {
      return {'success': false, 'message': '유효하지 않은 토큰'};
    }

    final url = Uri.parse('$baseUrl/update/$userId');
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'car_number': carNumber}),
      );

      Map<String, dynamic> body;
      try {
        body = jsonDecode(response.body);
        if (body is! Map<String, dynamic>) {
          return {'success': false, 'message': '서버 응답 포맷 오류'};
        }
      } catch (e) {
        return {'success': false, 'message': '서버 응답 파싱 실패'};
      }

      if (response.statusCode == 200) {
        return {'success': true, ...body};
      } else {
        return {
          'success': false,
          'message': body['error'] ?? body['message'] ?? '차량번호 수정 실패'
        };
      }
    } catch (e) {
      return {'success': false, 'message': '네트워크 오류: $e'};
    }
  }

  /// 사용자 정보 수정 (이름, 생년월일, 전화번호)
  Future<Map<String, dynamic>> updateUserInfo({
    required String name,
    required String birthDate,
    required String phoneNumber,
  }) async {
    final token = await storage.read(key: 'token');
    if (token == null) return {'success': false, 'message': '토큰 없음'};

    final decodedToken = JwtDecoder.decode(token);
    final userId = decodedToken['user_id'];
    if (userId == null) return {'success': false, 'message': '유효하지 않은 토큰'};

    final url = Uri.parse('$baseUrl/update/$userId');
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'birth_date': birthDate,
          'phone_number': phoneNumber,
        }),
      );

      final body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, ...body};
      } else {
        return {
          'success': false,
          'message': body['error'] ?? body['message'] ?? '회원정보 수정 실패'
        };
      }
    } catch (e) {
      return {'success': false, 'message': '네트워크 오류: $e'};
    }
  }

  /// 비밀번호만 업데이트 (JWT에서 user_id 자동 추출)
  Future<Map<String, dynamic>> updatePassword(String password) async {
    final token = await storage.read(key: 'token');
    if (token == null) return {'success': false, 'message': '토큰 없음'};

    final decodedToken = JwtDecoder.decode(token);
    final userId = decodedToken['user_id'];
    if (userId == null) return {'success': false, 'message': '유효하지 않은 토큰'};

    final url = Uri.parse('$baseUrl/update/$userId');
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'password': password}),
      );

      Map<String, dynamic> body;
      try {
        body = jsonDecode(response.body);
        if (body is! Map<String, dynamic>) {
          return {'success': false, 'message': '서버 응답 포맷 오류'};
        }
      } catch (e) {
        return {'success': false, 'message': '서버 응답 파싱 실패'};
      }
      if (response.statusCode == 200) {
        return {'success': true, ...body};
      } else {
        return {
          'success': false,
          'message': body['error'] ?? body['message'] ?? '비밀번호 수정 실패'
        };
      }
    } catch (e) {
      return {'success': false, 'message': '네트워크 오류: $e'};
    }
  }

  /// 이메일 변경
  Future<Map<String, dynamic>> updateEmail(String newEmail) async {
    final token = await storage.read(key: 'token');
    if (token == null) return {'success': false, 'message': '토큰 없음'};

    final decodedToken = JwtDecoder.decode(token);
    final userId = decodedToken['user_id'];
    if (userId == null) return {'success': false, 'message': '유효하지 않은 토큰'};

    final url = Uri.parse('$baseUrl/update/$userId');
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'email': newEmail}),
      );

      final body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, ...body};
      } else {
        return {
          'success': false,
          'message': body['error'] ?? body['message'] ?? '이메일 수정 실패'
        };
      }
    } catch (e) {
      return {'success': false, 'message': '네트워크 오류: $e'};
    }
  }

  /// 이메일 인증번호 전송
  Future<Map<String, dynamic>> sendEmailVerification(String email) async {
    final url = Uri.parse('$baseUrl/send_verification');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, ...body};
      } else {
        return {'success': false, 'message': body['error'] ?? '인증번호 전송 실패'};
      }
    } catch (e) {
      return {'success': false, 'message': '네트워크 오류: $e'};
    }
  }

  /// 이메일 인증번호 검증
  Future<Map<String, dynamic>> verifyEmailCode(String email,
      String code) async {
    final url = Uri.parse('$baseUrl/verify_code');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'code': code}),
      );

      final body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, ...body};
      } else {
        return {'success': false, 'message': body['error'] ?? '인증번호 검증 실패'};
      }
    } catch (e) {
      return {'success': false, 'message': '네트워크 오류: $e'};
    }
  }

  Future<Map<String, dynamic>> checkUserExists(String email,
      String phoneNumber) async {
    final url = Uri.parse('$baseUrl/check_user');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'phone_number': phoneNumber}),
      );

      final body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, ...body};
      } else {
        return {'success': false, 'message': body['error'] ?? '사용자 없음'};
      }
    } catch (e) {
      return {'success': false, 'message': '네트워크 오류: $e'};
    }
  }

  /// ✅ 2. 최종 비밀번호 재설정
  Future<Map<String, dynamic>> resetPassword(String email, String newPassword) async {
    final url = Uri.parse('$baseUrl/reset_password');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': newPassword}),
      );

      try {
        final body = jsonDecode(response.body);
        if (response.statusCode == 200) {
          return {'success': true, ...body};
        } else {
          return {'success': false, 'message': body['error'] ?? '비밀번호 재설정 실패'};
        }
      } catch (e) {
        // JSON 파싱 실패 시
        return {'success': false, 'message': '서버 응답 오류: ${response.body}'};
      }
    } catch (e) {
      return {'success': false, 'message': '네트워크 오류: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteUser(int userId) async {
    final url = Uri.parse('$baseUrl/delete/$userId');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        return {"success": true, "message": jsonDecode(response.body)["message"]};
      } else {
        return {"success": false, "message": jsonDecode(response.body)["error"]};
      }
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  Future<Map<String, dynamic>> linkKakao(int userId, String kakaoId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/kakao_link'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId, 'kakao_id': kakaoId}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> unlinkKakao(int userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/kakao_unlink'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> loginWithKakao() async {
    try {
      OAuthToken token;
      if (await isKakaoTalkInstalled()) {
        token = await UserApi.instance.loginWithKakaoTalk();
      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      final user = await UserApi.instance.me();
      final kakaoId = user.id.toString();

      // 1️⃣ 서버에 카카오 로그인 요청
      final response = await http.post(
        Uri.parse('$baseUrl/login/kakao'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'kakao_id': kakaoId}),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['token'] != null) {
        // 2️⃣ 토큰 저장
        await storage.write(key: 'token', value: body['token']);
        await storage.write(key: 'user_id', value: body['user_id'].toString());

        return {'success': true, 'token': body['token'], 'user_id': body['user_id']};
      } else {
        return {'success': false, 'message': body['error'] ?? '카카오 연동된 계정이 없습니다.'};
      }
    } catch (e) {
      return {'success': false, 'message': '카카오 로그인 실패: $e'};
    }
  }

  Future<Map<String, dynamic>> getParkingRecordForGuest(String carNumber) async {
    // Note: The base URL for parking is different. We use _host directly.
    final url = Uri.parse('$_host/api/parking/inquire/guest/$carNumber');
    try {
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      ).timeout(const Duration(seconds: 10));

      final body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        // On success, the python server returns the data directly.
        // We wrap it with a success flag for consistent handling in the app.
        return {'success': true, ...body};
      } else {
        // On failure, the python server returns a body like {'error': 'message'}.
        return {'success': false, 'message': body['error'] ?? '차량 정보 조회 실패'};
      }
    } catch (e) {
      debugPrint('[AuthService] 비회원 차량 조회 오류: $e');
      return {'success': false, 'message': '네트워크 오류가 발생했습니다.'};
    }
  }
}
