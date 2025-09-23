import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../../services/auth_service.dart';
import '../../../main.dart';
import '../../ViewParkingCam.dart';
import '../../NoticeItem.dart';

void _showLoginAlertAndRedirect(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('로그인 후 서비스 이용해주세요.'),
      duration: Duration(seconds: 2),
    ),
  );
  Future.delayed(const Duration(seconds: 2), () {
    Navigator.pushNamed(context, '/appstart');
  });
}


class LogoutedHomeScreen extends StatelessWidget {
  const LogoutedHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FCFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF76B55C),
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: false,
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
            // 상단 차량번호 조회 박스
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
                                  color: Color(0xFFD6E1D1),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFFD6E1D1), width: 1),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFF76B55C), width: 1),
                                ),
                              ),
                              style: const TextStyle(
                                fontFamily: 'SpoqaHanSansNeo',
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF2F3644),
                              ),
                            ),
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

            // 정기권 구매 박스
            Center(
              child: SizedBox(
                width: screenWidth * 0.92,
                height: 85,
                child: Container(
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        offset: const Offset(0, 0),
                        blurRadius: 7,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      _showLoginAlertAndRedirect(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 23, right: 17),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                ),
              ),
            ),

            const SizedBox(height: 25),

            // 건물별 잔여석
            Container(
              width: screenWidth * 0.92,
              padding: const EdgeInsets.all(20),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '건물 별 잔여석',
                    style: TextStyle(
                      fontFamily: 'SpoqaHanSansNeo',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4B7C76),
                    ),
                  ),
                  const Text(
                    '실시간 주차칸도 확인해보세요.',
                    style: TextStyle(
                      fontFamily: 'VitroPride',
                      fontSize: 10,
                      color: Color(0xFF414B6A),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildBuildingStatus(
                    context: context,
                    buildingName: '융합과학관',
                    available: 200,
                    total: 250,
                    buildingIndex: 0,
                  ),
                  _buildBuildingStatus(
                    context: context,
                    buildingName: '서문 잔디밭',
                    available: 0,
                    total: 250,
                    buildingIndex: 1,
                  ),
                  _buildBuildingStatus(
                    context: context,
                    buildingName: '산학협력관',
                    available: 20,
                    total: 250,
                    buildingIndex: 2,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // 최근 공지사항 타이틀
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '최근 공지사항',
                  style: TextStyle(
                    fontFamily: 'VitroPride',
                    fontSize: 18,
                    color: Color(0xFF376524),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // ✅ 동적 공지사항 섹션
            _buildNoticeSection(context, screenWidth),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  /// 건물 별 잔여석 UI
  Widget _buildBuildingStatus({
    required BuildContext context,
    required String buildingName,
    required int available,
    required int total,
    required int buildingIndex,
  }) {
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
                        color: const Color(0xFF38A48E),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ViewParkingCam(initialBuildingIndex: buildingIndex)
                  ),
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

/// 최근 공지사항 동적 섹션
Widget _buildNoticeSection(BuildContext context, double screenWidth) {
  Future<List<Map<String, dynamic>>> fetchNotices() async {
    final uri = Uri.parse('http://192.168.75.57:3000/api/notices');
    final res = await http.get(uri);

    if (res.statusCode == 200) {
      final decoded = json.decode(res.body);
      if (decoded['items'] != null) {
        List<dynamic> notices = decoded['items'];
        notices.sort((a, b) {
          final da = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(2000);
          final db = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(2000);
          return db.compareTo(da);
        });
        return notices.take(3).map<Map<String, dynamic>>((n) => n as Map<String, dynamic>).toList();
      }
    }
    return [];
  }

  return FutureBuilder<List<Map<String, dynamic>>>(
    future: fetchNotices(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Container(
          width: screenWidth * 0.92,
          height: 120,
          alignment: Alignment.center,
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
          child: const CircularProgressIndicator(),
        );
      }

      final notices = snapshot.data ?? [];
      return Container(
        width: screenWidth * 0.92,
        padding: const EdgeInsets.only(top: 20, left: 15, right: 15, bottom: 30),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...notices.map((notice) {
              final date = DateTime.tryParse(notice['created_at'] ?? '');
              final dateString = date != null ? DateFormat('yyyy.MM.dd').format(date) : '';
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NoticeItem(
                            title: notice['title'] ?? '',
                            content: notice['content'] ?? '',
                            date: notice['date'] ?? '',
                            category: notice['category'] ?? '전체',
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFFFFF),
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 15, right: 5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${notice['title']}',
                            style: const TextStyle(
                              fontFamily: 'SpoqaHanSansNeo',
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF414B6A),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          dateString,
                          style: const TextStyle(
                            fontFamily: 'VitroPride',
                            fontSize: 10,
                            color: Color(0xFF757575),
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_right,
                          size: 20,
                          color: Color(0xFFC0C3CD),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: screenWidth * 0.8,
                height: 45,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        offset: const Offset(0, 3),
                        blurRadius: 7,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      _showLoginAlertAndRedirect(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF50A12E),
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      '더 읽어보러 가기',
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
            ),
          ],
        ),
      );
    },
  );
}