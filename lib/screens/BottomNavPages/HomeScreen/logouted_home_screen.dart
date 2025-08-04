import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';

class LogoutedHomeScreen extends StatelessWidget {
  const LogoutedHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FCFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF76B55C),
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Lot Bot',
          style: TextStyle(
            fontFamily: 'VitroCore',
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
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
                        const Text(
                          '로그인 해주세요.',
                          style: TextStyle(
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
                            '차량 번호 조회',
                            style: TextStyle(
                              fontFamily: 'VitroPride',
                              fontWeight: FontWeight.w400,
                              fontSize: 11,
                              color: Color(0xFF61984A),
                            ),
                          ),
                          const SizedBox(height: 17),

                          // ✅ 추가된 가운데 텍스트
                          const Center(
                            child: Text(
                              '조회하실 차량번호를\n입력해주세요',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'SpoqaHanSansNeo',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF414B6A),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          SizedBox(
                            width: double.infinity,
                            child: TextField(
                              decoration: const InputDecoration(
                                hintText: '차량번호 입력 (ex.123사 5678)',
                                hintStyle: TextStyle(
                                  fontFamily: 'SpoqaHanSansNeo',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11,
                                  color: Color(0xFFD6E1D1), // 힌트 색상
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFFD6E1D1), width: 1), // 비활성 밑줄
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFF76B55C), width: 1), // 포커스 밑줄
                                ),
                              ),
                              style: const TextStyle(
                                fontFamily: 'SpoqaHanSansNeo',
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF2F3644), // 입력 시 텍스트 색상
                              ),
                            ),
                          ),

                          const Spacer(),

                          // 조회하기 버튼
                          Center(
                            child: SizedBox(
                              width: 160,
                              height: 40,
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                  backgroundColor: const Color(0xFF8CCE71),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                                child: const Text(
                                  '조회하기',
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

            Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/payment/BuyPass');
                  },
                  child: Container(
                    width: screenWidth * 0.92,
                    height: 85,
                    padding: const EdgeInsets.only(left: 23, right: 17),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color(0xFF25C1A1),
                          Color(0xFF76B55C),
                        ],
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x08000000),
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
                ),
              ],
            ),
            const SizedBox(height: 30),

            // 건물 별 잔여석
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

  /// 건물 별 잔여석 UI 요소
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
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

  Color _getStatusColor(String congestionText) {
    switch (congestionText) {
      case '여유':
        return const Color(0xFF76B55C);
      case '보통':
        return const Color(0xFFD7D139);
      case '혼잡':
        return const Color(0xFFCD0505);
      case '만차':
        return const Color(0xFF757575);
      default:
        return const Color(0xFF414B6A);
    }
  }
}