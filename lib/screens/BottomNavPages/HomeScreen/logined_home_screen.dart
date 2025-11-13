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

// -------------------------------------------------------------------
// 헬퍼 함수
// -------------------------------------------------------------------
String formatDate(String rawDate) {
  try {
    DateTime dateTime = DateFormat('EEE, dd MMM yyyy HH:mm:ss', 'en')
        .parse(rawDate, true)
        .toLocal();
    return DateFormat("yyyy.MM.dd (E)", 'ko').format(dateTime);
  } catch (e) {
    print('Date parsing error: $e');
    return rawDate;
  }
}

String formatDuration(int seconds) {
  final int minutes = seconds ~/ 60;
  final int remainingSeconds = seconds % 60;
  return '${minutes}분 ${remainingSeconds}초';
}

// -------------------------------------------------------------------
// StatefulWidget
// -------------------------------------------------------------------
class LoginedHomeScreen extends StatefulWidget {
  const LoginedHomeScreen({super.key});

  @override
  State<LoginedHomeScreen> createState() => _LoginedHomeScreenState();
}

// -------------------------------------------------------------------
// State 클래스
// -------------------------------------------------------------------
class _LoginedHomeScreenState extends State<LoginedHomeScreen> {
  String userName = '';
  String carNumber = '';
  bool _isLoading = true;
  Map<String, dynamic>? _unpaidData;
  String _userName = "...";

  List<Map<String, dynamic>> _notices = [];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ko').then((_) {
      _fetchHomeData();
    });
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
                  'assets/images/parking_fee_table.png', // ✅ 실제 경로 확인
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

  // 홈 데이터 컨트롤 타워
  Future<void> _fetchHomeData() async {
    try {
      await Future.wait([
        _fetchNotices(),
        _fetchParkingData(),
      ]);
    } catch (e) {
      print('홈 화면 데이터 로딩 중 에러 발생: $e');
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchNotices() async {
    try {
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

        _notices = items
            .map((item) => {
          'title': item['title'],
        })
            .toList();
      } else {
        print('Failed to load notices: ${response.statusCode}');
      }
    } catch (e) {
      print('공지사항 로딩 중 오류: $e');
    }
  }

  Future<void> _fetchParkingData() async {
    try {
      final authService = AuthService();
      final userInfoResponse = await authService.getUserInfo();

      if (userInfoResponse['success'] == true &&
          userInfoResponse['user'] != null) {
        final user = userInfoResponse['user'];
        final userId = user['user_id'];

        String carRaw = user['car_number'] ?? '';
        final reg = RegExp(r'([0-9]+[가-힣]+)([0-9]+)');
        String formattedCar =
        carRaw.replaceAllMapped(reg, (m) => '${m[1]} ${m[2]}');

        userName = user['name'] ?? '';
        carNumber = formattedCar;

        final host = dotenv.env['HOST_ADDRESS'];
        final url = Uri.parse('$host/api/payment/unpaid/$userId');
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['success'] == true && data['unpaid'] != null) {
            _unpaidData = data['unpaid'];
          }
        }
      } else {
        debugPrint(
            '사용자 정보 로드 실패: ${userInfoResponse['message'] ?? userInfoResponse['error']}');
      }
    } catch (e) {
      print('사용자/주차 정보 로딩 중 오류: $e');
    }
  }

  // -------------------------------------------------------------------
  // UI
  // -------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

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
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 상단 이름 + 차량번호 + 주차현황 카드
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
                            ).createShader(Rect.fromLTWH(
                                0, 0, bounds.width, bounds.height)),
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
                  child: _buildParkingStatusSection(screenWidth),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // 정기권 구매 CTA
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

            // 최근 공지사항
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

  // -------------------------------------------------------------------
// 주차 현황 카드 (미납 데이터 여부에 따라 분기)
// -------------------------------------------------------------------
  Widget _buildParkingStatusSection(double screenWidth) {
    // 1) 미납/주차중 내역 없을 때
    if (_unpaidData == null) {
      return Container(
        width: screenWidth * 0.92,
        height: 235,
        padding: const EdgeInsets.only(
          left: 17,
          right: 17,
          top: 20,
          bottom: 15,
        ),
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
            // ⬆️ 항상 같은 자리: 주차 현황 + 요금표 보기
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
                GestureDetector(
                  onTap: _showFeeTableModal,
                  child: Row(
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
                ),
              ],
            ),
            const SizedBox(height: 15),

            // ⬇️ 아이콘 + 문구를 카드 안에서 완전 정중앙으로
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.check_circle_outline,
                      color: Color(0xFF65A549),
                      size: 40,
                    ),
                    SizedBox(height: 15),
                    Text(
                      '결제할 내역이 없습니다.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'SpoqaHanSansNeo',
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '현재 주차 중인 차량이 없거나, 정산할 요금이 없습니다.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontFamily: 'SpoqaHanSansNeo',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 2) 미납/주차중 내역 있을 때 (지금 쓰고 있던 분기 그대로 유지)
    final DateTime entryTime = DateTime.parse(_unpaidData!['entry_time']);

    final int totalMinutes = _unpaidData!['total_minutes'] ?? 0;
    final int hours = totalMinutes ~/ 60;
    final int minutes = totalMinutes % 60;
    final String durationString =
        (hours > 0 ? '${hours}시간 ' : '') + '${minutes}분';

    final String entryDateFormatted =
    DateFormat('yyyy.MM.dd (E)', 'ko').format(entryTime);
    final String entryTimeFormatted =
    DateFormat('a hh:mm', 'ko').format(entryTime);

    final int fee = _unpaidData!['parking_fee'] ?? 0;
    final String feeFormatted = NumberFormat('#,###').format(fee);

    const String nextFeeInfo = '200원 / 10분';

    return Container(
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
          // 타이틀 + 요금표 보기 (그대로)
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
              GestureDetector(
                onTap: _showFeeTableModal,
                child: Row(
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
              ),
            ],
          ),
          const SizedBox(height: 15),

          Text(
            entryDateFormatted,
            style: const TextStyle(
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
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$entryTimeFormatted ',
                      style: const TextStyle(
                        fontFamily: 'SpoqaHanSansNeo',
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Color(0xFF65A549),
                      ),
                    ),
                    const TextSpan(
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
                    const TextSpan(
                      text: '이용 시간: ',
                      style: TextStyle(
                        fontFamily: 'SpoqaHanSansNeo',
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: Color(0xFF414B6A),
                      ),
                    ),
                    TextSpan(
                      text: durationString,
                      style: const TextStyle(
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
                  text: '${feeFormatted}원',
                  style: const TextStyle(
                    fontFamily: 'SpoqaHanSansNeo',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFF65A549),
                  ),
                ),
                const TextSpan(
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
              Text(
                '0분',
                style: TextStyle(
                  fontFamily: 'SpoqaHanSansNeo',
                  fontWeight: FontWeight.w500,
                  fontSize: 8,
                  color: Color(0xFF4B7C76),
                ),
              ),
              RichText(
                text: TextSpan(
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
                      text: '200원 / 10분',
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
              Text(
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
                    colors: [Color(0xFF8CE2AA), Color(0xFF93D4C7)],
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
                        'duration': durationString,
                        'currentFee': fee,
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
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isAmount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
              fontFamily: 'SpoqaHanSansNeo',
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isAmount ? 20 : 16,
              fontWeight: isAmount ? FontWeight.bold : FontWeight.normal,
              color: Colors.black,
              fontFamily: 'SpoqaHanSansNeo',
            ),
          ),
        ],
      ),
    );
  }

  /// 건물별 잔여석 위젯
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
          // 왼쪽 정보
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

// -------------------------------------------------------------------
// 헬퍼 함수 (전역)
// -------------------------------------------------------------------
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
        notices.sort((a, b) {
          final da =
              DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(2000);
          final db =
              DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(2000);
          return db.compareTo(da);
        });
        return notices
            .take(3)
            .map<Map<String, dynamic>>((n) => n as Map<String, dynamic>)
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
        padding: const EdgeInsets.only(
            top: 20, left: 15, right: 15, bottom: 30),
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