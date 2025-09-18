import 'package:flutter/material.dart';

class MyAccount extends StatelessWidget {
  const MyAccount({super.key});

  @override
  Widget build(BuildContext context) {
    final String userName = '신용범';
    final String userBirth = '2001.07.08';
    final String userPhone = '010-4084-8891';
    final String userEmail = 'syb010708@gmail.com';
    final String carNumber = '372머 9480';

    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

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
          '내 계정',
          style: TextStyle(
            fontFamily: 'SpoqaHanSansNeo',
            fontWeight: FontWeight.w500,
            fontSize: 15,
            color: Colors.black,
          ),
        ),
        flexibleSpace: Container(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.03),
            Center(
              child: Container(
                width: screenWidth * 0.92,
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xFF25C1A1), Color(0xFF76B55C)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x1A000000),
                      offset: Offset(0, 0),
                      blurRadius: 9,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$userName 님',
                        style: const TextStyle(
                          fontFamily: 'SpoqaHanSansNeo',
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        carNumber,
                        style: const TextStyle(
                          fontFamily: 'SpoqaHanSansNeo',
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          color: Color(0xFFECF2E9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.05),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: const Text(
                '계정 정보',
                style: TextStyle(
                  fontFamily: 'VitroPride',
                  fontSize: 20,
                  color: Color(0xFF2F3644),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: Container(
                width: screenWidth * 0.9,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    infoRow('이름', userName),
                    const SizedBox(height: 10),
                    const Divider(thickness: 1, color: Color(0xFFECF2E9)),
                    const SizedBox(height: 10),
                    infoRow('생년월일', userBirth),
                    const SizedBox(height: 10),
                    const Divider(thickness: 1, color: Color(0xFFECF2E9)),
                    const SizedBox(height: 10),
                    infoRow('전화번호', userPhone, showArrow: true,
                      onTap: () {
                        Navigator.pushNamed(context, '/auth_edit/UserInfoEdit');
                      },
                    ),
                    const SizedBox(height: 10),
                    const Divider(thickness: 1, color: Color(0xFFECF2E9)),
                    const SizedBox(height: 10),
                    infoRow('이메일', userEmail, showArrow: true,
                      onTap: () {
                        Navigator.pushNamed(context, '/auth_edit/EmailEdit');
                      },
                    ),
                    const SizedBox(height: 10),
                    const Divider(thickness: 1, color: Color(0xFFECF2E9)),
                    const SizedBox(height: 10),
                    infoRow('비밀번호', '', showArrow: true,
                      onTap: () {
                        Navigator.pushNamed(context, '/auth_edit/PasswordEdit');
                      },
                    ),
                    const SizedBox(height: 10),
                    const Divider(thickness: 1, color: Color(0xFFECF2E9)),
                    const SizedBox(height: 10),
                    infoRow('차량번호', carNumber, showArrow: true,
                      onTap: () {
                        Navigator.pushNamed(context, '/auth_edit/VehicleEdit');
                      },
                    ),
                    const SizedBox(height: 10),
                    const Divider(thickness: 1, color: Color(0xFFECF2E9)),
                    SizedBox(height: screenHeight * 0.06),
                  ],
                ),
              ),
            ),
            // 로그아웃 버튼
            Center(
              child: SizedBox(
                width: screenWidth * 0.8,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // 로그아웃 처리 로직
                    Navigator.pushNamedAndRemoveUntil(context, '/appstart', (route) => false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF50A12E),
                    elevation: 0, // 그림자 제거
                    shadowColor: Colors.transparent, // 그림자 제거
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    '로그아웃',
                    style: TextStyle(
                      fontFamily: 'SpoqaHanSansNeo',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // 회원 탈퇴하기 텍스트
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/withdraw'); // 실제 탈퇴 페이지 경로로 연결
                },
                child: const Text(
                  '회원 탈퇴하기',
                  style: TextStyle(
                    fontFamily: 'SpoqaHanSansNeo',
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: Color(0xFF8B95A1),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30), // ✅ 하단 여백
          ],
        ),
      ),
    );
  }

  Widget infoRow(String label, String value, {bool showArrow = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'SpoqaHanSansNeo',
              fontWeight: FontWeight.w300,
              fontSize: 14,
              color: Color(0xFF414B6A),
            ),
          ),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'SpoqaHanSansNeo',
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: Color(0xFF50A12E),
                ),
              ),
              if (showArrow) ...[
                const SizedBox(width: 5),
                const Icon(
                  Icons.keyboard_arrow_right,
                  size: 15,
                  color: Color(0xFF2F3644),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}