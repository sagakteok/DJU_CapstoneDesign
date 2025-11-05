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

// ★ 1. 2단계에서 만든 '스마트 위젯' import (기존 코드에 이미 존재했음)
import 'package:dju_parking_project/widgets/building_status_box.dart';
// ★ ViewParkingCam import는 BuildingStatusBox가 하므로 여기서 중복 선언할 필요 없음
// import 'package:dju_parking_project/screens/ViewParkingCam.dart';

// (formatDate, formatDuration 함수는 변경 없음)
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

// (StatefulWidget 선언 및 _LoginedHomeScreenState 클래스 선언은 변경 없음)
class LoginedHomeScreen extends StatefulWidget {
  const LoginedHomeScreen({super.key});

  @override
  State<LoginedHomeScreen> createState() => _LoginedHomeScreenState();
}

class _LoginedHomeScreenState extends State<LoginedHomeScreen> {
  // (기존 상태 변수 및 initState, _fetchUserInfo, fetchNotices 함수는 변경 없음)
  // (이 함수들은 '사용자 정보'와 '공지사항'을 위한 것이며,
  //  '건물 별 잔여석'과는 독립적으로 작동하므로 그대로 둡니다.)
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

  // ★ 2. build 메서드 수정
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // (페이지 자체 로딩 로직은 변경 없음)
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // (주차 현황 하드코딩된 데이터는 '5번 기능'에서 사용하므로 일단 둡니다)
    // (만약 5번 기능에서 이 데이터를 서버에서 받아온다면, 그때 이 부분도 수정됩니다)
    const String entryDate = '2025.06.05 (목)';
    const String entryTime = '오전 11:26';
    final int duration = 2000; // 예시
    final String formattedDuration = formatDuration(duration);
    const int currentFeeValue = 5000; // 숫자만 저장
    final String currentFee = '${NumberFormat('#,###').format(currentFeeValue)}원';
    const String nextFeeInfo = '200원 / 10분';

    // (Scaffold, AppBar, SingleChildScrollView 등 전체 구조는 변경 없음)
    return Scaffold(
      backgroundColor: const Color(0xFFF9FCFB),
      appBar: AppBar(
        // ... (기존 AppBar 스타일 및 타이틀)
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
              color: Colors.white,
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
                // ...
                // (SizedBox, "박준호의 12가 3456" Text 부분 등)
                // (모든 '주차 현황' 박스 UI는 '5번 기능'에서 다루므로)
                // (지금은 변경 없이 그대로 둡니다)
                // ...
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
                        // ... (주차 현황' 타이틀, '요금표 보기' 버튼)
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
                        // ... (entryDate, entryTime, duration 등 하드코딩된 '주차 현황' UI)
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
                                  shadowColor: Colors.transparent,
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

            // ... (SizedBox, '정기권 구매하기' 버튼 등)
            // (이 위젯들은 2번 기능과 관련 없으므로 변경 없이 그대로 둡니다)
            const SizedBox(height: 25),
            Center(
              child: SizedBox(
                width: screenWidth * 0.92,
                height: 85,
                child: Container(
                  // ... (정기권 구매하기 버튼 스타일)
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
                        // ... (정기권 구매하기 버튼 내부 UI)
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

            // ★ 3. (수정) 기존의 하드코딩된 Container를
            //    2단계에서 만든 '스마트 위젯'으로 교체합니다.
            const BuildingStatusBox(),

            // ★ 4. (삭제)
            // 기존 Container( ... ) // 304~365줄에 있던 코드 삭제
            // 기존 _buildBuildingStatus(...) 함수 (370~459줄) 삭제
            // (이하 코드에서 해당 함수를 찾아서 삭제해야 합니다)

            // ... (최근 공지사항 타이틀)
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

            // ... (공지사항 섹션)
            _buildNoticeSection(context, screenWidth),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

// ★ 4. (삭제)
// _buildBuildingStatus 함수는 building_status_box.dart로 이동했으므로
// 이 파일에서는 *완전히 삭제*합니다.
/* Widget _buildBuildingStatus({ ... }) {
    ... (370~459줄 코드 전체 삭제) ...
  }
  */
} // ★ _LoginedHomeScreenState 클래스가 여기서 끝납니다.

// ★ 5. (삭제)
// _getStatusColor 함수도 building_status_box.dart로 이동했으므로
// 이 파일에서는 *완전히 삭제*합니다.
/*
Color _getStatusColor(congestionText) {
  ... (462~476줄 코드 전체 삭제) ...
}
*/

// ★ 6. (유지)
// _buildNoticeSection 함수는 이 파일의 build 메서드에서
// "최근 공지사항"을 위해 사용하고 있으므로, *반드시 유지*해야 합니다.
Widget _buildNoticeSection(BuildContext context, double screenWidth) {
  // (이하 공지사항 코드 변경 없음)
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