import 'package:flutter/material.dart';
import 'package:dju_parking_project/services/parking_service.dart'; // 1단계에서 만든 서비스
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
  List<dynamic> _buildingData = []; // 비어있는 리스트로 초기화

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
      final data = await _parkingService.getParkingStatus();

      // 위젯이 화면에서 사라지기 전에 데이터가 도착했다면
      if (mounted) {
        setState(() {
          _buildingData = data;
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
    // 1. 로딩 중일 때
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 2. 에러 발생 시
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Text(
            '오류: 데이터를 불러올 수 없습니다.\n($_errorMessage)',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        ),
      );
    }

    // 3. 성공했으나 데이터가 비어있을 때
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

    // 4. 성공 시: 백엔드에서 받은 _buildingData로 리스트 생성
    return Column(
      children: _buildingData.asMap().entries.map((entry) {
        int index = entry.key; // 리스트의 순서 (0, 1, 2...)
        Map<String, dynamic> building = entry.value;

        // ★★★ (매우 중요) 백엔드 JSON 키 확인 ★★★
        // 'name', 'available', 'total'이 백엔드 JSON과 일치하는지 확인!
        return _buildBuildingStatus(
          context: context,
          buildingName: building['name'] ?? '이름 없음',
          available: building['available'] ?? 0,
          total: building['total'] ?? 0,
          buildingIndex: index, // 1번 기능(카메라)을 위해 인덱스 전달
        );
      }).toList(),
    );
  }

  /// 개별 건물 현황을 그리는 위젯 (스타일 코드 수정 없음)
  Widget _buildBuildingStatus({
    required BuildContext context,
    required String buildingName,
    required int available,
    required int total,
    required int buildingIndex,
  }) {
    // (로직 및 스타일 코드 원본과 100% 동일)
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