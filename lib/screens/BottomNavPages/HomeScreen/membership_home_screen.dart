import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../../services/auth_service.dart';
import '../../../main.dart';
import '../../ViewParkingCam.dart';
import '../../NoticeItem.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

String formatDate(String rawDate) {
  try {
    // GMT 문자열 파싱 후 한국 시간으로 변환
    DateTime dateTime = DateFormat('EEE, dd MMM yyyy HH:mm:ss', 'en')
        .parse(rawDate, true)
        .toLocal();
    return DateFormat("yyyy.MM.dd (E)", 'ko').format(dateTime);
  } catch (e) {
    print('Date parsing error: $e');
    return rawDate; // 파싱 실패 시 원본 문자열 반환
  }
}

class MembershipHomeScreen extends StatefulWidget {
  const MembershipHomeScreen({super.key});

  @override
  State<MembershipHomeScreen> createState() => _MembershipHomeScreenState();
}

class _MembershipHomeScreenState extends State<MembershipHomeScreen> {
  String userName = '';
  String carNumber = '';
  bool _isLoading = true;

  List<Map<String, dynamic>> _notices = [];

  final String entryDate = '2025.06.05 (목)';
  final String entryTime = '오전 11:26';
  final String duration = '2분 10초';

  final DateTime today = DateTime.now();

  int totalDays = 0;
  int currentDay = 100;
  int remainingDays = 0;

  String startDateString = '';
  String todayString = '';
  String endDateString = '';

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ko').then((_) {
      fetchNotices();
    });
    fetchUserInfo(); // initState에서는 그냥 호출만
  }

  // ✅ 요금표 모달 띄우는 함수
  void _showFeeTableModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;

        return Container(
          padding: const EdgeInsets.only(
            top: 12,
            left: 16,
            right: 16,
            bottom: 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 위쪽 작은 바
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // 요금표 이미지
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/parking_fee_table.png', // ✅ 실제 이미지 경로로 맞춰주세요
                  width: screenWidth - 32,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> fetchUserInfo() async {
    final userInfo = await AuthService().getUserInfo();
    if (userInfo['success'] == true && userInfo['user'] != null) {
      final user = userInfo['user'];

      String carRaw = user['car_number'] ?? '';
      String formattedCar = carRaw;
      final reg = RegExp(r'([0-9]+[가-힣]+)([0-9]+)');
      if (reg.hasMatch(carRaw)) {
        formattedCar = carRaw.replaceAllMapped(reg, (m) => '${m[1]} ${m[2]}');
      }

      String startRaw = user['membership_start'] ?? '';
      String endRaw = user['membership_end'] ?? '';

      DateTime start = DateTime.tryParse(startRaw) ?? DateTime.now();
      DateTime end = DateTime.tryParse(endRaw) ?? DateTime.now();

      int total = end.difference(start).inDays + 1;
      int current = DateTime.now().difference(start).inDays + 1;
      int remaining = total - current;

      setState(() {
        userName = user['name'] ?? '';
        carNumber = formattedCar;

        totalDays = total;
        currentDay = current;
        remainingDays = remaining;

        startDateString =
        "${start.year}.${start.month.toString().padLeft(2, '0')}.${start.day.toString().padLeft(2, '0')}";
        todayString =
        "${today.year}.${today.month.toString().padLeft(2, '0')}.${today.day.toString().padLeft(2, '0')}";
        endDateString =
        "${end.year}.${end.month.toString().padLeft(2, '0')}.${end.day.toString().padLeft(2, '0')}";

        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      debugPrint('사용자 정보 로드 실패: ${userInfo['message'] ?? userInfo['error']}');
    }
  }

  Future<void> fetchNotices() async {
    final host = dotenv.env['HOST_ADDRESS'];
    final response = await http.get(Uri.parse('$host/api/notices'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final items = data['items'] as List<dynamic>;
      items.sort((a, b) {
        final da = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(2000);
        final db = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(2000);
        return db.compareTo(da);
      });

      setState(() {
        _notices.clear();
        _notices.addAll(items.map((item) => {'title': item['title']}).toList());
      });
    } else {
      print('Failed to load notices: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    print(
        "currentDay: $currentDay, totalDays: $totalDays, ratio: ${currentDay / totalDays}");
    print("width: ${screenWidth * (currentDay / totalDays)}");
    print("total width: ${screenWidth}");

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FCFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FCFB),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF76B55C), Color(0xFF15C3AF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
          child: const Text(
            'Lot Bot',
            style: TextStyle(
              fontFamily: 'VitroCore',
              fontSize: 20,
              color: Colors.white, // 반드시 지정해야 함 (실제 그라데이션으로 덮어씌워짐)
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding:
                  EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '$userName의 ',
                          style: const TextStyle(
                            fontFamily: 'SpoqaHanSansNeo',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF414B6A),
                          ),
                        ),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.baseline,
                          baseline: TextBaseline.alphabetic,
                          child: ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFF76B55C), Color(0xFF15C3AF)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ).createShader(
                                Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                            child: Text(
                              '$carNumber',
                              style: const TextStyle(
                                fontFamily: 'SpoqaHanSansNeo',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Center(
                  child: Container(
                    width: screenWidth * 0.92,
                    height: 215,
                    padding: const EdgeInsets.only(
                        left: 17, right: 17, top: 20, bottom: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          offset: const Offset(0, 0),
                          blurRadius: 7,
                          spreadRadius: 2,
                        ),
                      ],
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF53BEAC),
                          Color(0xFF47BE5B),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              '주차 현황',
                              style: TextStyle(
                                fontFamily: 'SpoqaHanSansNeo',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFF9FCFB),
                              ),
                            ),
                            // ✅ 요금표 보기 클릭 → 모달
                            GestureDetector(
                              onTap: () {
                                _showFeeTableModal();
                              },
                              child: Row(
                                children: const [
                                  Text(
                                    '요금표 보기',
                                    style: TextStyle(
                                      fontFamily: 'SpoqaHanSansNeo',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 9,
                                      color: Color(0xFFECF2E9),
                                    ),
                                  ),
                                  Icon(
                                    Icons.keyboard_arrow_right,
                                    size: 12,
                                    color: Color(0xFFECF2E9),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Text(
                          entryDate,
                          style: const TextStyle(
                            fontFamily: 'SpoqaHanSansNeo',
                            fontWeight: FontWeight.w400,
                            fontSize: 9,
                            color: Color(0xFFECF2E9),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '$entryTime ',
                                    style: const TextStyle(
                                      fontFamily: 'SpoqaHanSansNeo',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: '입차',
                                    style: TextStyle(
                                      fontFamily: 'SpoqaHanSansNeo',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                      color: Color(0xFFF9FCFB),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                children: [
                                  const TextSpan(
                                    text: '이용 시간: ',
                                    style: TextStyle(
                                      fontFamily: 'SpoqaHanSansNeo',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                      color: Color(0xFFF9FCFB),
                                    ),
                                  ),
                                  TextSpan(
                                    text: duration,
                                    style: const TextStyle(
                                      fontFamily: 'SpoqaHanSansNeo',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Text(
                          '남은 정기권 기간',
                          style: TextStyle(
                            fontFamily: 'VitroPride',
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // 현재 진행일
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "$currentDay",
                                    style: const TextStyle(
                                      fontFamily: 'SpoqaHanSansNeo',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: " 일차",
                                    style: TextStyle(
                                      fontFamily: 'SpoqaHanSansNeo',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                      color: Color(0xFFF9FCFB),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // 남은 일수
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "$remainingDays일",
                                    style: const TextStyle(
                                      fontFamily: 'SpoqaHanSansNeo',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: " 남음",
                                    style: TextStyle(
                                      fontFamily: 'SpoqaHanSansNeo',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                      color: Color(0xFFF9FCFB),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
                            LayoutBuilder(
                              builder: (context, constraints) {
                                return Container(
                                  height: 5,
                                  width: constraints.maxWidth *
                                      (totalDays == 0
                                          ? 0
                                          : currentDay / totalDays),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFFFFF),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              startDateString,
                              style: const TextStyle(
                                fontFamily: 'SpoqaHanSansNeo',
                                fontWeight: FontWeight.w500,
                                fontSize: 8,
                                color: Color(0xFFD6E1D1),
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                children: [
                                  const TextSpan(
                                    text: "오늘: ",
                                    style: TextStyle(
                                      fontFamily: 'SpoqaHanSansNeo',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 10,
                                      color: Color(0xFFECF2E9),
                                    ),
                                  ),
                                  TextSpan(
                                    text: todayString,
                                    style: const TextStyle(
                                      fontFamily: 'SpoqaHanSansNeo',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 10,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              endDateString,
                              style: const TextStyle(
                                fontFamily: 'SpoqaHanSansNeo',
                                fontWeight: FontWeight.w500,
                                fontSize: 8,
                                color: Color(0xFFD6E1D1),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            if (remainingDays <= 7) const SizedBox(height: 25),

            if (remainingDays <= 7)
              Center(
                child: SizedBox(
                  width: screenWidth * 0.92,
                  height: 85,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          offset: const Offset(0, 0),
                          blurRadius: 7,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/payment/select_pass');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
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
                                  '정기권 연장하기',
                                  style: TextStyle(
                                    fontFamily: 'SpoqaHanSansNeo',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF376524),
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  '정기권을 연장하여',
                                  style: TextStyle(
                                    fontFamily: 'VitroPride',
                                    fontSize: 10,
                                    color: Color(0xFF2F3644),
                                  ),
                                ),
                                Text(
                                  '자유 출입 혜택을 이어가보세요.',
                                  style: TextStyle(
                                    fontFamily: 'VitroPride',
                                    fontSize: 10,
                                    color: Color(0xFF2F3644),
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
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 25),

            // 건물 별 잔여석 박스
            Container(
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

            Padding(
              padding:
              EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
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

            _buildNoticeSection(context, screenWidth),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  /// 건물 별 잔여석 UI 요소
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
          // 왼쪽 그룹
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
                    const TextSpan(
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
                      style: TextStyle(
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
                    builder: (context) =>
                        ViewParkingCam(initialBuildingIndex: buildingIndex),
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

Color _getStatusColor(congestionText) {
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

// 최근 공지사항 섹션
Widget _buildNoticeSection(BuildContext context, double screenWidth) {
  Future<List<Map<String, dynamic>>> fetchNotices() async {
    final host = dotenv.env['HOST_ADDRESS'];
    final uri = Uri.parse('$host/api/notices');
    final res = await http.get(uri);

    if (res.statusCode == 200) {
      final decoded = json.decode(res.body);
      if (decoded['items'] != null) {
        List<dynamic> notices = decoded['items'];
        // 최신순 정렬, 최대 3개만
        notices.sort((a, b) {
          final da =
              DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(2000);
          final db =
              DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(2000);
          return db.compareTo(da);
        });
        return notices
            .take(3)
            .map<Map<String, dynamic>>(
                (n) => n as Map<String, dynamic>)
            .toList();
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
          ),
          child: const CircularProgressIndicator(),
        );
      }
      final notices = snapshot.data ?? [];
      return Container(
        width: screenWidth * 0.92,
        padding:
        const EdgeInsets.only(top: 20, left: 15, right: 15, bottom: 30),
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
            ...notices.map((notice) {
              final String title = notice['title'] ?? '';
              final String dateRaw = notice['created_at'] ?? '';
              final String formattedDate = formatDate(dateRaw);
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
                            date: formattedDate,
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
                      padding:
                      const EdgeInsets.only(left: 15, right: 5),
                    ),
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontFamily: 'SpoqaHanSansNeo',
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF414B6A),
                            ),
                            overflow: TextOverflow.ellipsis,
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
                      bottomNavIndex.value = 3;
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