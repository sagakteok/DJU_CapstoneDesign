import 'package:flutter/material.dart';

class AppStart extends StatelessWidget {
  const AppStart({super.key});

  @override
  Widget build(BuildContext context) {
    final buttonWidth = MediaQuery.of(context).size.width * 0.85;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/logoutedhome');
              },
              style: ButtonStyle(
                overlayColor: MaterialStateProperty.all(Colors.transparent),
              ),
              child: Row(
                children: const [
                  Text(
                    '비회원모드',
                    style: TextStyle(
                      color: Color(0xFF1E1E1E),
                      fontFamily: 'SpoqaHanSansNeo',
                      fontWeight: FontWeight.w100,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(width: 5),
                  Icon(
                    Icons.keyboard_double_arrow_right,
                    color: Color(0xFF757575),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: screenHeight * 0.01),
            SizedBox(
              width: buttonWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '안녕하세요!',
                    style: TextStyle(
                      fontSize: 27,
                      fontFamily: 'VitroPride',
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        '대전대학교 ',
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'SpoqaHanSansNeo',
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF65A549),
                        ),
                      ),
                      Text(
                        '주차장 서비스 앱입니다.',
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'SpoqaHanSansNeo',
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1E1E1E),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Text(
                    '정기권 발권과 사전 결제 서비스를',
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'SpoqaHanSansNeo',
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        'Lot Bot ',
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'VitroCore',
                          color: Color(0xFF65A549),
                        ),
                      ),
                      Text(
                        '에서 이용해보세요!',
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'SpoqaHanSansNeo',
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1E1E1E),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 버튼 그룹을 Expanded로 감싸서 아래로 밀기
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: buttonWidth,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 52,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF76B55C),
                                  Color(0xFF25C1A1),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              child: const Text(
                                '로그인하기',
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
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 52,
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/signup/step1');
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF50A12E), width: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            backgroundColor: Colors.white,
                          ),
                          child: const Text(
                            '회원가입하기',
                            style: TextStyle(
                              color: Color(0xFF50A12E),
                              fontSize: 14,
                              fontFamily: 'SpoqaHanSansNeo',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 50), // 하단 고정 여백
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}