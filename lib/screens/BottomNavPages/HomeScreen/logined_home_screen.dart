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
import 'package:dju_parking_project/screens/ViewParkingCam.dart';

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

String formatDuration(int seconds) {
  final int minutes = seconds ~/ 60; // 몫 = 분
  final int remainingSeconds = seconds % 60; // 나머지 = 초
  return '${minutes}분 ${remainingSeconds}초';
}

class LoginedHomeScreen extends StatefulWidget {
  const LoginedHomeScreen({super.key});

  @override
  State<LoginedHomeScreen> createState() => _LoginedHomeScreenState();
}

class _LoginedHomeScreenState extends State<LoginedHomeScreen> {
  String userName = '';
  String carNumber = '';
  bool _isLoading = true;

  List<Map<String, dynamic>> _notices = [];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ko').then((_) {
      fetchNotices();
    });
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    final userInfo = await AuthService().getUserInfo();
    if (userInfo['success'] == true && userInfo['user'] != null) {
      final user = userInfo['user'];

      // 차량번호 한글 뒤 공백 적용
      String carRaw = user['car_number'] ?? '';
      String formattedCar = carRaw;
      final reg = RegExp(r'([0-9]+[가-힣]+)([0-9]+)');
      if (reg.hasMatch(carRaw)) {
        formattedCar = carRaw.replaceAllMapped(reg, (m) => '${m[1]} ${m[2]}');
      }

      setState(() {
        userName = user['name'] ?? '';
        carNumber = formattedCar;
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

      // 최신순 정렬
      items.sort((a, b) {
        final da = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(2000);
        final db = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(2000);
        return db.compareTo(da);
      });

      setState(() {
        _notices.clear();
        _notices.addAll(items.map((item) => {
          'title': item['title'],
        }).toList());
      });
    } else {
      print('Failed to load notices: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 기존 하드코딩된 entryDate, entryTime, duration 등
    const String entryDate = '2025.06.05 (목)';
    const String entryTime = '오전 11:26';
    final int duration = 2000; // 예시
    final String formattedDuration = formatDuration(duration);
    const int currentFeeValue = 5000; // 숫자만 저장
    final String currentFee = '${NumberFormat('#,###').format(currentFeeValue)}원';
    const String nextFeeInfo = '200원 / 10분';

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
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
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
                              ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                              child: Text(
                                '$carNumber', // ✅ 실제 변수 사용
                                style: const TextStyle(
                                  fontFamily: 'SpoqaHanSansNeo',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white, // ShaderMask 덮어쓰기용
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
                      height: 235,
                      padding: const EdgeInsets.only(left: 17, right: 17, top: 20, bottom: 15),
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
                                  color: Color(0xFF4B7C76),
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
                                      color: Color(0xFFADB5CA),
                                    ),
                                  ),
                                  Icon(
                                    Icons.keyboard_arrow_right,
                                    size: 12,
                                    color: Color(0xFFADB5CA),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            entryDate,
                            style: TextStyle(
                              fontFamily: 'SpoqaHanSansNeo',
                              fontWeight: FontWeight.w400,
                              fontSize: 9,
                              color: Color(0xFF6B907F),
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
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: Color(0xFF65A549),
                                      ),
                                    ),
                                    TextSpan(
                                      text: '입차',
                                      style: TextStyle(
                                        fontFamily: 'SpoqaHanSansNeo',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13,
                                        color: Color(0xFF414B6A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '이용 시간: ',
                                      style: TextStyle(
                                        fontFamily: 'SpoqaHanSansNeo',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13,
                                        color: Color(0xFF414B6A),
                                      ),
                                    ),
                                    TextSpan(
                                      text: formattedDuration,
                                      style: TextStyle(
                                        fontFamily: 'SpoqaHanSansNeo',
                                        fontWeight: FontWeight.w600,
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
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: currentFee,
                                  style: TextStyle(
                                    fontFamily: 'SpoqaHanSansNeo',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: Color(0xFF65A549),
                                  ),
                                ),
                                TextSpan(
                                  text: ' 이용 중',
                                  style: TextStyle(
                                    fontFamily: 'SpoqaHanSansNeo',
                                    fontWeight: FontWeight.w500,
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
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  // constraints.maxWidth는 여기서만 유효
                                  return Container(
                                    height: 5,
                                    width: constraints.maxWidth * 0.5,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF76B55C),
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
                              const Text(
                                '0분',
                                style: TextStyle(
                                  fontFamily: 'SpoqaHanSansNeo',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 8,
                                  color: Color(0xFF4B7C76),
                                ),
                              ),
                              RichText(
                                text: const TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '다음 구간: ',
                                      style: TextStyle(
                                        fontFamily: 'SpoqaHanSansNeo',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 10,
                                        color: Color(0xFF2F3644),
                                      ),
                                    ),
                                    TextSpan(
                                      text: nextFeeInfo,
                                      style: TextStyle(
                                        fontFamily: 'SpoqaHanSansNeo',
                                        fontWeight: FontWeight.w500,
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
                                  fontWeight: FontWeight.w500,
                                  fontSize: 8,
                                  color: Color(0xFF4B7C76),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Center(
                            child: SizedBox(
                              width: 160,
                              height: 40,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF8CE2AA),
                                      Color(0xFF93D4C7)
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      offset: const Offset(0, 3),
                                      blurRadius: 7,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/payment/CarLeavePurchase',
                                      arguments: {
                                        'duration': formattedDuration,
                                        'currentFee': currentFee,
                                      },
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    // ✅ 배경 투명 (Container 배경 보이게)
                                    shadowColor: Colors.transparent,
                                    // ✅ 버튼 자체 그림자 제거
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
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 25),

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
                      Navigator.pushNamed(context, '/payment/select_pass');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent, // Container 배경 보이게
                      shadowColor: Colors.transparent,     // 버튼 그림자 제거
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
                          // 왼쪽 텍스트
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
                          // 오른쪽 더보기
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
            // ✅ 건물 별 잔여석 박스 (이 블록으로 기존 해당 Container 대체)
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
                  // 타이틀 (왼쪽 상단)
                  const Text(
                    '건물 별 잔여석',
                    style: TextStyle(
                      fontFamily: 'SpoqaHanSansNeo',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4B7C76),
                    ),
                  ),
                  // 서브타이틀 (왼쪽)
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
                    buildingIndex: 0, // index 추가
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

            _buildNoticeSection(context, screenWidth),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  /// ✅ 건물 별 잔여석 UI 요소 (주차칸 보기 버튼 세로 가운데 정렬)
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
        crossAxisAlignment: CrossAxisAlignment.center, // ✅ 버튼과 그룹 세로 정렬
        children: [
          // ⬅️ 왼쪽 그룹 (건물명 + 혼잡도, 잔여석 숫자)
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
                // 건물별 주차칸 보기 눌렀을 때 해당 인덱스 전달
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

// 최근 공지사항 섹션 (API 연동, 제목 제거)
Widget _buildNoticeSection(BuildContext context, double screenWidth) {
  Future<List<Map<String, dynamic>>> fetchNotices() async {
    final host = dotenv.env['HOST_ADDRESS'];
    final uri = Uri.parse('$host/api/notices');
    final res = await http.get(uri);

    if (res.statusCode == 200) {
      final decoded = json.decode(res.body);
      if (decoded['items'] != null) {   // 여기 items로 바꿔야 함
        List<dynamic> notices = decoded['items'];
        // 최신순 정렬, 최대 3개만
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
            // 공지사항 리스트
            ...notices.map((notice) {
              final String title = notice['title'] ?? '';
              final String content = notice['content'] ?? '';
              final String category = notice['category'] ?? '';
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
                      padding: const EdgeInsets.only(left: 15, right: 5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            // 하단 "더 읽어보러 가기" 버튼
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