import 'dart:convert'; // JSON 처리를 위한 import
import 'package:flutter_dotenv/flutter_dotenv.dart'; // .env 파일 접근
import 'package:http/http.dart' as http; // HTTP 통신

/// 주차장 관련 API 통신을 전담하는 서비스 클래스
class ParkingService {
  final String? _host = dotenv.env['HOST_ADDRESS'];

  /// 백엔드 서버(/api/parking/status)로부터 최신 건물별 주차 현황을 가져옵니다.
  ///
  /// 성공 시:
  /// {
  ///   "융합과학관": {"free": "0", "total": 1},
  ///   "서문잔디밭": {"free": "1", "total": 1}
  /// }
  /// 형태의 Map<String, dynamic>을 반환합니다.
  ///
  /// 실패 시: Exception을 발생시킵니다.
  // ★ 1. (수정) ★
  //    반환 타입을 List<dynamic>가 아닌 Map<String, dynamic>으로 변경합니다.
  Future<Map<String, dynamic>> getParkingStatus() async {

    // .env 파일에서 HOST_ADDRESS 로드 확인
    if (_host == null) {
      throw Exception('CRITICAL: .env 파일에 HOST_ADDRESS가 설정되지 않았습니다.');
    }

    // 2. 주소는 '/api/parking/status'로 올바릅니다. (수정 불필요)
    final Uri url = Uri.parse('$_host/api/parking/status');

    try {
      // 3. 백엔드(app.py)에 네트워크 요청
      final response = await http.get(url);

      // 4. 백엔드가 200 OK (성공) 응답을 주면
      if (response.statusCode == 200) {

        // ★★★ (핵심 수정) ★★★

        // 5. (수정)
        //    백엔드가 보낸 JSON Map을 그대로 디코딩하여 반환합니다.
        //    'items' 키를 찾는 복잡한 로직을 모두 제거합니다.
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData;

        // ★★★ (수정 완료) ★★★

      } else {
        // 6. 서버가 404, 500 등 오류 응답을 주면
        throw Exception('서버 응답 오류 (Code: ${response.statusCode})');
      }
    } catch (e) {
      // 5번 단계에서 `jsonDecode`가 실패하거나(예: HTML 응답),
      // 6번 단계에서 `Exception`이 발생하면 여기서 모두 잡힙니다.
      throw Exception('주차장 현황 로드 실패: $e');
    }
  }
}