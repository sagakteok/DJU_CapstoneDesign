import 'package:flutter/material.dart';

class BuyPassScreen extends StatelessWidget {
  const BuyPassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double buttonWidth = MediaQuery.of(context).size.width * 0.85;
    final double contentWidth = MediaQuery.of(context).size.width * 0.8;
    final double screenHeight = MediaQuery.of(context).size.height;

    // 더미 데이터
    final String startDate = '2025.06.05';
    final String endDate = '2025.06.21';
    final String price = '5,000원';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
        centerTitle: true,
        title: const Text(
          '정기권 구매하기',
          style: TextStyle(
            fontFamily: 'SpoqaHanSansNeo',
            fontWeight: FontWeight.w500,
            fontSize: 15,
            color: Colors.black,
          ),
        ),
      ),
      body: Center (
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.02),

            // 상단 텍스트
            SizedBox(
              width: buttonWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '정기권 구매하기',
                    style: TextStyle(
                      fontSize: 27,
                      fontFamily: 'VitroPride',
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '정기권을 구매하여',
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'SpoqaHanSansNeo',
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  Text(
                    '남은 기간 편하게 출입해보세요.',
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'SpoqaHanSansNeo',
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),

            // ✅ 중간 컨텐츠 (정중앙 배치)
            Column(
              children: [
                Container(
                  width: contentWidth,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FCFB),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0x1A000000),
                        offset: const Offset(0, 4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 왼쪽 텍스트
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '사용 가능 기간',
                            style: TextStyle(
                              fontFamily: 'SpoqaHanSansNeo',
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF2F3644)
                            ),
                          ),
                          Text(
                            '$startDate ~',
                            style: const TextStyle(
                              fontFamily: 'SpoqaHanSansNeo',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF65A549)
                            ),
                          ),
                          Text(
                            endDate,
                            style: const TextStyle(
                              fontFamily: 'SpoqaHanSansNeo',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF65A549)
                            ),
                          ),
                        ],
                      ),

                      // 오른쪽 금액 텍스트
                      RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: '금액: ',
                              style: TextStyle(
                                fontFamily: 'SpoqaHanSansNeo',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF414B6A)
                              ),
                            ),
                            TextSpan(
                              text: price,
                              style: const TextStyle(
                                fontFamily: 'SpoqaHanSansNeo',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF76B55C),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF76B55C), Color(0xFF15C3AF)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ).createShader(bounds),
                  child: const Text(
                    '남은 기간 정기권',
                    style: TextStyle(
                      fontFamily: 'SpoqaHanSansNeo',
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            Spacer(),

            // 하단 버튼
            Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: SizedBox(
                width: buttonWidth,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/payment/purchase');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: const Color(0xFF50A12E),
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    '구매하기',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'SpoqaHanSansNeo',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      )
    );
  }
}