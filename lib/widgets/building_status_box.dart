import 'package:flutter/material.dart';
import 'package:dju_parking_project/services/parking_service.dart'; // 1단계 (수정 완료)
import 'package:dju_parking_project/screens/ViewParkingCam.dart'; // 1번 기능(카메라) 화면

/// "건물 별 잔여석" 박스를 담당하는 *재사용 가능한* 위젯.
///
/// 이 위젯은 스스로 데이터를 로드하고, 로딩/에러/성공 상태를 관리합니다.
class BuildingStatusBox extends StatefulWidget {
  const BuildingStatusBox({super.key});

  @override
  State<BuildingStatusBox> createState() => _BuildingStatusBoxState();
}

class _BuildingStatusBoxState extends State<BuildingStatusBox> {
  // --- 상태 관리 변수 ---
  final ParkingService _parkingService = ParkingService();
  bool _isLoading = true; // 초기 상태는 '로딩 중'
  String? _errorMessage; // 에러가 없으면 null

  // ★ 1. (핵심 수정) ★
  //    데이터 타입을 List<dynamic>에서 Map<String, dynamic>으로 변경합니다.
  Map<String, dynamic> _buildingData = {}; // 비어있는 Map으로 초기화

  // --- 생명주기(Lifecycle) 함수 ---

  @override
  void initState() {
    super.initState();
    // 이 위젯이 화면에 생성되는 즉시 데이터 로드를 시작
    _fetchParkingStatus();
  }

  /// 1단계에서 만든 ParkingService를 호출하여 데이터를 가져옵니다.
  Future<void> _fetchParkingStatus() async {
    try {
      // ★ 2. (수정) ★
      //    parking_service가 이제 Map을 반환하므로,
      //    'data' 변수의 타입을 명시적으로 Map으로 받습니다.
      final Map<String, dynamic> data = await _parkingService.getParkingStatus();

      // 위젯이 화면에서 사라지기 전에 데이터가 도착했다면
      if (mounted) {
        setState(() {
          _buildingData = data; // Map을 Map 변수에 저장 (오류 해결!)
          _isLoading = false; // 로딩 종료
          _errorMessage = null; // 에러 없음
        });
      }
    } catch (e) {
      // 위젯이 화면에서 사라지기 전에 에러가 발생했다면
      if (mounted) {
        setState(() {
          _errorMessage = e.toString(); // 에러 메시지 저장
          _isLoading = false; // 로딩 종료
        });
      }
    }
  }

  // --- UI 렌더링 함수 ---

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // "건물 별 잔여석" 박스의 *기존 스타일*을 그대로 가져옵니다.
    // (이 부분은 수정할 필요 없음)
    return Container(
      width: screenWidth * 0.92,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            offset: Offset(0, 0),
            blurRadius: 7,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 타이틀 (기존 스타일)
          const Text(
            '건물 별 잔여석',
            style: TextStyle(
              fontFamily: 'SpoqaHanSansNeo',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4B7C76),
            ),
          ),
          // 서브타이틀 (기존 스타일)
          const Text(
            '실시간 주차칸도 확인해보세요.',
            style: TextStyle(
              fontFamily: 'VitroPride',
              fontSize: 10,
              color: Color(0xFF414B6A),
            ),
          ),
          const SizedBox(height: 20),

          // ★ 핵심 로직: 상태에 따라 다른 UI를 렌더링합니다.
          _buildStatusContent(),
        ],
      ),
    );
  }

  /// 로딩/에러/성공 상태에 따라 다른 위젯을 반환하는 헬퍼 함수
  Widget _buildStatusContent() {
    // 1. 로딩 중일 때 (수정 불필요)
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 2. 에러 발생 시 (수정 불필요 - 이제 에러 메시지가 더 자세히 보일 것임)
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Text(
            '$_errorMessage', // e.toString()을 그대로 표시
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        ),
      );
    }

    // ★ 3. (수정) ★
    //    List가 아닌 Map의 'isEmpty'를 확인합니다. (동작은 동일함)
    if (_buildingData.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Text(
            '등록된 주차장 정보가 없습니다.',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
      );
    }

    // ★ 4. (핵심 수정) ★
    //    데이터가 `List`가 아닌 `Map` ({"융합과학관": {...}, ...})이므로,
    //    Map의 'entries'를 순회(iteration)해야 합니다.
    //
    //    .entries.toList() : Map을 List<MapEntry>로 변환
    //    .asMap().entries.map(): List를 돌면서 index(0, 1, 2...)와
    //                            entry(MapEntry)를 *동시에* 가져옵니다.
    return Column(
      children: _buildingData.entries.toList().asMap().entries.map((indexedEntry) {

        // 0, 1, 2... (ViewParkingCam으로 전달할 순서 인덱스)
        int index = indexedEntry.key;
        // MapEntry<String, dynamic> (Key/Value 쌍)
        var entry = indexedEntry.value;

        // entry.key = 건물 이름 (예: "융합과학관")
        String buildingName = entry.key;
        // entry.value = 상세 정보 (예: {"free": "0", "total": 1})
        Map<String, dynamic> details = entry.value;

        // 스크린샷(`image_438b8c.png`)을 보면 'free'가 String("0")으로,
        // 'total'이 int(1)로 왔습니다. 이를 안전하게 int로 변환합니다.
        int available = int.tryParse(details['free']?.toString() ?? '0') ?? 0;
        int total = details['total'] ?? 0;

        // 1번 기능에서 만들었던 헬퍼 함수를 재사용합니다.
        return _buildBuildingStatus(
          context: context,
          buildingName: buildingName,  // JSON의 Key를 이름으로 사용
          available: available,        // JSON의 'free' 값을 사용
          total: total,              // JSON의 'total' 값을 사용
          buildingIndex: index,        // ViewParkingCam을 위해 0, 1, 2 순서 전달
        );
      }).toList(),
    );
  }

  /// 개별 건물 현황을 그리는 위젯 (기존 `logined_home_screen.dart`에서 가져옴)
  /// ★ 이 함수는 수정할 필요가 전혀 없습니다. ★
  Widget _buildBuildingStatus({
    required BuildContext context,
    required String buildingName,
    required int available,
    required int total,
    required int buildingIndex,
  }) {
    // (이하 로직 및 스타일 코드 원본과 100% 동일)
    final double rate = total == 0 ? 0 : available / total;
    String congestionText;
    Color congestionColor;

    if (rate == 0) {
      congestionText = '만차';
      congestionColor = const Color(0xFF757575);
    } else if (rate <= 0.3) {
      congestionText = '혼잡';
      congestionColor = const Color(0xFFCD0505);
    } else if (rate <= 0.5) {
      congestionText = '보통';
      congestionColor = const Color(0xFFD7D139);
    } else {
      congestionText = '여유';
      congestionColor = const Color(0xFF76B55C);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    buildingName,
                    style: const TextStyle(
                      fontFamily: 'SpoqaHanSansNeo',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Color(0xFF414B6A),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    '-',
                    style: TextStyle(
                      fontFamily: 'SpoqaHanSansNeo',
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Color(0xFFADB5CA),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    congestionText,
                    style: TextStyle(
                      fontFamily: 'SpoqaHanSansNeo',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: congestionColor,
                    ),
                  ),
                ],
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '잔여석: ',
                      style: TextStyle(
                        fontFamily: 'SpoqaHanSansNeo',
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
                        color: Color(0xFF38A48E),
                      ),
                    ),
                    TextSpan(
                      text: '$available ',
                      style: TextStyle(
                        fontFamily: 'SpoqaHanSansNeo',
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                        color: _getStatusColor(congestionText),
                      ),
                    ),
                    TextSpan(
                      text: '/ $total',
                      style: const TextStyle(
                        fontFamily: 'SpoqaHanSansNeo',
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                        color: Color(0xFF414B6A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            width: 70,
            height: 35,
            child: ElevatedButton(
              onPressed: () {
                // (1번 기능에서 확인된 코드)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ViewParkingCam(initialBuildingIndex: buildingIndex)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8FD8A8),
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.zero,
                elevation: 0,
              ),
              child: const Text(
                '주차칸 보기',
                style: TextStyle(
                  fontFamily: 'SpoqaHanSansNeo',
                  fontWeight: FontWeight.w500,
                  fontSize: 10,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 혼잡도 텍스트에 따라 색상을 반환하는 헬퍼 함수
  Color _getStatusColor(String congestionText) {
    switch (congestionText) {
      case '만차':
        return const Color(0xFF757575);
      case '혼잡':
        return const Color(0xFFCD0505);
      case '보통':
        return const Color(0xFFD7D139);
      case '여유':
      default:
        return const Color(0xFF76B55C);
    }
  }
}