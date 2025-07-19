import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';

class LoginedHomeScreen extends StatelessWidget {
  const LoginedHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final screenWidth = MediaQuery.of(context).size.width;

    // TODO: 실제 사용자 정보로 대체 예정
    const String userName = '홍길동';
    const String carNumber = '123사 4567';
    const String entryDate = '2025.06.05 (목)';
    const String entryTime = '오전 11:26';
    const String duration = '2분 10초';
    const String currentFee = '0원';
    const String nextFeeInfo = '200원 / 10분';

    return Scaffold(
      backgroundColor: const Color(0xFFF9FCFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF76B55C),
        elevation: 0,
        scrolledUnderElevation: 0, // ✅ 스크롤 시 색 변화 방지
        leading: null, // ✅ 뒤로가기 비활성화
        title: const Text(
          'Lot Bot',
          style: TextStyle(
            fontFamily: 'VitroCore',
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await authService.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/appstart');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 상단 영역
            Container(
              height: 300,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF76B55C),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$userName의 $carNumber',
                          style: const TextStyle(
                            fontFamily: 'SpoqaHanSansNeo',
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                        Row(
                          children: const [
                            Text(
                              '요금표 보기',
                              style: TextStyle(
                                fontFamily: 'SpoqaHanSansNeo',
                                fontWeight: FontWeight.w600,
                                fontSize: 9,
                                color: Color(0xFFD6E1D1),
                              ),
                            ),
                            SizedBox(width: 3),
                            Icon(
                              Icons.keyboard_arrow_right,
                              size: 12,
                              color: Color(0xFFD6E1D1),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Center(
                    child: Container(
                      width: screenWidth * 0.92,
                      height: 225,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '주차 현황',
                            style: TextStyle(
                              fontFamily: 'VitroPride',
                              fontWeight: FontWeight.w400,
                              fontSize: 11,
                              color: Color(0xFF61984A),
                            ),
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            entryDate,
                            style: TextStyle(
                              fontFamily: 'SpoqaHanSansNeo',
                              fontWeight: FontWeight.w500,
                              fontSize: 9,
                              color: Color(0xFF2F3644),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              RichText(
                                text: const TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '$entryTime ',
                                      style: TextStyle(
                                        fontFamily: 'SpoqaHanSansNeo',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: Color(0xFF65A549),
                                      ),
                                    ),
                                    TextSpan(
                                      text: '입차',
                                      style: TextStyle(
                                        fontFamily: 'SpoqaHanSansNeo',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: Color(0xFF414B6A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              RichText(
                                text: const TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '이용 시간: ',
                                      style: TextStyle(
                                        fontFamily: 'SpoqaHanSansNeo',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: Color(0xFF414B6A),
                                      ),
                                    ),
                                    TextSpan(
                                      text: duration,
                                      style: TextStyle(
                                        fontFamily: 'SpoqaHanSansNeo',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: Color(0xFF65A549),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: currentFee,
                                  style: TextStyle(
                                    fontFamily: 'SpoqaHanSansNeo',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: Color(0xFF65A549),
                                  ),
                                ),
                                TextSpan(
                                  text: ' 이용 중',
                                  style: TextStyle(
                                    fontFamily: 'SpoqaHanSansNeo',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: Color(0xFF414B6A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Stack(
                            children: [
                              Container(
                                height: 5,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD9D9D9),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              Container(
                                height: 5,
                                width: screenWidth * 0.3,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF76B55C),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '0분',
                                style: TextStyle(
                                  fontFamily: 'SpoqaHanSansNeo',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 8,
                                  color: Color(0xFF2F3644),
                                ),
                              ),
                              RichText(
                                text: const TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '다음 구간: ',
                                      style: TextStyle(
                                        fontFamily: 'SpoqaHanSansNeo',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10,
                                        color: Color(0xFF2F3644),
                                      ),
                                    ),
                                    TextSpan(
                                      text: nextFeeInfo,
                                      style: TextStyle(
                                        fontFamily: 'SpoqaHanSansNeo',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10,
                                        color: Color(0xFF61984A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Text(
                                '60분',
                                style: TextStyle(
                                  fontFamily: 'SpoqaHanSansNeo',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 8,
                                  color: Color(0xFF2F3644),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Center(
                            child: SizedBox(
                              width: 160,
                              height: 40,
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  shadowColor: Colors.transparent, // ✅ 그림자 제거
                                  backgroundColor: const Color(0xFF8CCE71),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                                child: const Text(
                                  '출차 결제',
                                  style: TextStyle(
                                    fontFamily: 'SpoqaHanSansNeo',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // 하단 버튼 2줄
            Column(
              children: [
                // 첫 번째 버튼
                Container(
                  width: screenWidth * 0.92,
                  height: 85,
                  margin: const EdgeInsets.only(bottom: 17),
                  padding: const EdgeInsets.only(left: 23, right: 17),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color(0xFF25C1A1), // 왼쪽 색상
                        Color(0xFF76B55C), // 오른쪽 색상
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x08000000), // 그림자 (3% 불투명도)
                        offset: Offset(0, 0),
                        blurRadius: 7,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 왼쪽 텍스트
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            '정기권 구매하기',
                            style: TextStyle(
                              fontFamily: 'SpoqaHanSansNeo',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFFFFFF),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '정기권을 구매하여',
                            style: TextStyle(
                              fontFamily: 'VitroPride',
                              fontSize: 10,
                              color: Color(0xFFFFFFFF),
                            ),
                          ),
                          Text(
                            '더 저렴하게 주차장을 이용해보세요.',
                            style: TextStyle(
                              fontFamily: 'VitroPride',
                              fontSize: 10,
                              color: Color(0xFFFFFFFF),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: const [
                          Text(
                            '더보기',
                            style: TextStyle(
                              fontFamily: 'SpoqaHanSansNeo',
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                              color: Color(0xFFECF2E9),
                            ),
                          ),
                          SizedBox(width: 3),
                          Icon(
                            Icons.keyboard_arrow_right,
                            size: 12,
                            color: Color(0xFFECF2E9),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 두 번째 버튼
                Container(
                  width: screenWidth * 0.92,
                  height: 85,
                  padding: const EdgeInsets.only(left: 23, right: 17),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0x08000000), // ✅ 3% 불투명도 그림자
                        offset: const Offset(0, 0),
                        blurRadius: 7,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 왼쪽 텍스트
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            '주차칸 예약하기',
                            style: TextStyle(
                              fontFamily: 'SpoqaHanSansNeo',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF376524),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '주차하고 싶은 건물의 주차 자리를',
                            style: TextStyle(
                              fontFamily: 'VitroPride',
                              fontSize: 10,
                              color: Color(0xFF2F3644),
                            ),
                          ),
                          Text(
                            '예약해보세요.',
                            style: TextStyle(
                              fontFamily: 'VitroPride',
                              fontSize: 10,
                              color: Color(0xFF2F3644),
                            ),
                          ),
                        ],
                      )
                      ,Row(
                        children: const [
                          Text(
                            '더보기',
                            style: TextStyle(
                              fontFamily: 'SpoqaHanSansNeo',
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                              color: Color(0xFF2F3644),
                            ),
                          ),
                          SizedBox(width: 3),
                          Icon(
                            Icons.keyboard_arrow_right,
                            size: 12,
                            color: Color(0xFF2F3644),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '건물 별 잔여석',
                  style: TextStyle(
                    fontFamily: 'VitroPride',
                    fontSize: 18,
                    color: Color(0xFF376524),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // ✅ 건물 별 잔여석 박스
            Container(
              width: screenWidth * 0.92,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x08000000),
                    offset: Offset(0, 0),
                    blurRadius: 7,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildBuildingStatus(
                    buildingName: '융합과학관',
                    available: 200,
                    total: 250,
                  ),
                  _buildBuildingStatus(
                    buildingName: '서문 잔디밭',
                    available: 0,
                    total: 250,
                  ),
                  _buildBuildingStatus(
                    buildingName: '산학협력관',
                    available: 20,
                    total: 250,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  /// ✅ 건물 별 잔여석 UI 요소
  Widget _buildBuildingStatus({
    required String buildingName,
    required int available,
    required int total,
  }) {
    final double rate = available / total;
    String congestionText;
    Color congestionColor;

    if (rate == 0) {
      congestionText = '만차';
      congestionColor = const Color(0xFF757575); // 빨강
    } else if (rate <= 0.3) {
      congestionText = '혼잡';
      congestionColor = const Color(0xFFCD0505); // 주황
    } else if (rate <= 0.5) {
      congestionText = '보통';
      congestionColor = const Color(0xFFD7D139); // 노랑
    } else {
      congestionText = '여유';
      congestionColor = const Color(0xFF76B55C); // 초록
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 왼쪽: 건물 이름 + "-" + 혼잡도
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
                  const SizedBox(width: 4),
                  const Text(
                    '-',
                    style: TextStyle(
                      fontFamily: 'SpoqaHanSansNeo',
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Color(0xFFADB5CA),
                    ),
                  ),
                  const SizedBox(width: 4),
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
                      text: '$available ',
                      style: TextStyle(
                        fontFamily: 'SpoqaHanSansNeo',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: _getStatusColor(congestionText),
                      ),
                    ),
                    TextSpan(
                      text: '/ $total',
                      style: const TextStyle(
                        fontFamily: 'SpoqaHanSansNeo',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF414B6A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(
            color: Color(0xFFECF2E9),
            thickness: 1,
            height: 1,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

Color _getStatusColor(congestionText) {
  switch (congestionText) {
    case '여유':
      return const Color(0xFF76B55C); // 녹색
    case '보통':
      return const Color(0xFFD7D139); // 노란색
    case '혼잡':
      return const Color(0xFFCD0505); // 주황
    case '만차':
      return const Color(0xFF757575); // 빨강
    default:
      return const Color(0xFF414B6A); // 기본색
  }
}