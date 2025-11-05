import 'dart:convert'; // JSON 처리를 위한 import
import 'package:flutter_dotenv/flutter_dotenv.dart'; // .env 파일 접근
import 'package:http/http.dart' as http; // HTTP 통신

/// 주차장 관련 API 통신을 전담하는 서비스 클래스
class ParkingService {

  // .env 파일에서 백엔드 서버 주소를 읽어옵니다.
  // 이 값은 main.dart에서 dotenv.load()를 통해 미리 로드되어 있어야 합니다.
  final String? _host = dotenv.env['HOST_ADDRESS'];

  /// 백엔드 서버(/status)로부터 최신 건물별 주차 현황을 가져옵니다.
  ///
  /// 성공 시:
  /// [
  ///   {"name": "융합과학관", "available": 200, "total": 250},
  ///   {"name": "서문 잔디밭", "available": 0, "total": 250},
  ///   ...
  /// ]
  /// 형태의 List<dynamic>를 반환합니다.
  ///
  /// 실패 시: Exception을 발생시킵니다.
  Future<List<dynamic>> getParkingStatus() async {

    // _host가 null이면 (즉, .env 파일에 HOST_ADDRESS가 없으면) 즉시 오류 발생
    if (_host == null) {
      // 개발자가 즉시 알아챌 수 있도록 명확한 오류 메시지 제공
      throw Exception('CRITICAL: .env 파일에 HOST_ADDRESS가 설정되지 않았습니다.');
    }

    // 호출할 URL을 조합합니다. (예: http://localhost:3000/status)
    final Uri url = Uri.parse('$_host/status');

    try {
      // http.get으로 네트워크 요청
      // 웹(Chrome) 환경에서는 CORS 오류가 발생하지 않도록 백엔드(server.py)에서
      // 'http://localhost' (모든 포트)를 허용해야 합니다.
      final response = await http.get(url);

      // HTTP 상태 코드가 200 (OK)일 경우
      if (response.statusCode == 200) {

        // 백엔드가 보낸 응답(String)을 JSON List로 디코딩
        // (참고: response.body는 UTF-8이 아닐 수 있음. 한글이 깨지면 utf8.decode 사용)
        final List<dynamic> data = jsonDecode(response.body);
        return data;

      } else {
        // 서버가 200이 아닌 응답을 주면 (예: 404, 500)
        throw Exception('서버 응답 오류 (Code: ${response.statusCode})');
      }
    } catch (e) {
      // 네트워크 연결 실패 또는 JSON 파싱 실패 등
      // (예: XMLHttpRequest error)
      throw Exception('주차장 현황 로드 실패: $e');
    }
  }
}