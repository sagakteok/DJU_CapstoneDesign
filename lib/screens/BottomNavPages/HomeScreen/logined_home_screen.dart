import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../../services/auth_service.dart';
import '../../../main.dart';
import '../../ViewParkingCam.dart';
import '../../NoticeItem.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 콜론(:)으로 수정

// -------------------------------------------------------------------
// 헬퍼 함수 (수정 없음)
// -------------------------------------------------------------------
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

// -------------------------------------------------------------------
// StatefulWidget 클래스 (수정 없음)
// -------------------------------------------------------------------
class LoginedHomeScreen extends StatefulWidget {
  const LoginedHomeScreen({super.key});

  @override
  State<LoginedHomeScreen> createState() => _LoginedHomeScreenState();
}

// -------------------------------------------------------------------
// State 클래스 (데이터 로직 전체 수정)
// -------------------------------------------------------------------
class _LoginedHomeScreenState extends State<LoginedHomeScreen> {
  // --- State 변수 (수정 없음) ---
  String userName = '';
  String carNumber = '';
  bool _isLoading = true;
  Map<String, dynamic>? _unpaidData;
  String _userName = "..."; // (기존 코드에 있던 변수, 그대로 둠)

  List<Map<String, dynamic>> _notices = [];

  // --- 1. initState 수정 ---
  // 기존의 여러 함수 호출을 단일 컨트롤 타워(_fetchHomeData) 호출로 변경
  @override
  void initState() {
    super.initState();
    // 'ko' 로케일 초기화는 공지사항의 날짜 포맷팅(formatDate)에
    // 필수적이므로, 데이터 로딩 전에 먼저 실행합니다.
    initializeDateFormatting('ko').then((_) {
      _fetchHomeData(); // 모든 데이터 로딩을 시작하는 컨트롤 타워
    });
  }

  // --- 2. 컨트롤 타워 함수 생성 ---
  // 공지사항과 사용자/주차 정보를 동시에(병렬로) 호출합니다.
  Future<void> _fetchHomeData() async {
    // try-catch로 전체 로딩 과정의 에러를 관리할 수 있습니다.
    try {
      await Future.wait([
        _fetchNotices(),        // API 호출 1
        _fetchParkingData(),    // API 호출 2
      ]);
    } catch (e) {
      print('홈 화면 데이터 로딩 중 에러 발생: $e');
      // 필요시 사용자에게 에러 스낵바 등을 표시할 수 있습니다.
    }

    // 두 API 호출이 모두 (성공하든 실패하든) 완료된 후
    // 로딩 스피너를 멈추고 화면을 갱신합니다.
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // --- 3. 기존 fetchNotices -> _fetchNotices로 수정 ---
  // (setState 제거, 에러 핸들링 추가)
  Future<void> _fetchNotices() async {
    try {
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

        // setState 없이 변수에 직접 할당 (setState는 _fetchHomeData에서 한 번만 호출)
        _notices = items.map((item) => {
          'title': item['title'],
        }).toList();

      } else {
        print('Failed to load notices: ${response.statusCode}');
      }
    } catch (e) {
      // Future.wait 중 하나가 실패해도 다른 Future가 중단되지 않도록
      // 함수 내에서 try-catch로 에러를 처리합니다.
      print('공지사항 로딩 중 오류: $e');
    }
  }

  // --- 4. 기존 _fetchUserInfo -> _fetchParkingData로 확장 ---
  // (setState 제거, 미납 내역 API 호출 로직 추가, 에러 핸들링 추가)
  Future<void> _fetchParkingData() async {
    try {
      final authService = AuthService();
      final userInfoResponse = await authService.getUserInfo();

      if (userInfoResponse['success'] == true && userInfoResponse['user'] != null) {
        final user = userInfoResponse['user'];
        final userId = user['user_id'];

        // 차량번호 한글 뒤 공백 적용
        String carRaw = user['car_number'] ?? '';
        final reg = RegExp(r'([0-9]+[가-힣]+)([0-9]+)');
        String formattedCar = carRaw.replaceAllMapped(reg, (m) => '${m[1]} ${m[2]}');

        // setState 없이 변수에 직접 할당
        userName = user['name'] ?? '';
        carNumber = formattedCar;

        // --- ★ 요청하신 미납 내역 API 호출 로직 추가 ★ ---
        final host = dotenv.env['HOST_ADDRESS'];
        // (API 경로가 'history'가 아닌 'unpaid'일 수 있으므로,
        //  요청하신 'unpaid' 키를 사용하는 로직으로 수정했습니다.)
        final url = Uri.parse('$host/api/payment/unpaid/$userId');
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          // 요청하신 'unpaid' 키로 데이터를 받습니다.
          if (data['success'] == true && data['unpaid'] != null) {
            // setState 없이 변수에 직접 할당
            _unpaidData = data['unpaid'];
          }
        }
        // --- ★ 여기까지 추가된 로직 ★ ---

      } else {
        debugPrint('사용자 정보 로드 실패: ${userInfoResponse['message'] ?? userInfoResponse['error']}');
      }
    } catch (e) {
      print('사용자/주차 정보 로딩 중 오류: $e');
    }
  }


  // -------------------------------------------------------------------
  // UI 빌드 영역 (수정 없음)
  // -------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 📌 참고: '주차 현황' 관련 하드코딩 데이터를 모두 제거했습니다.
    // 📌 _buildParkingStatusSection() 함수가 모든 것을 처리합니다.

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
                          text: '$userName의 ', // ✅ API 연동됨
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
                              '$carNumber', // ✅ API 연동됨
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

                // ==================== 💡 여기가 수정된 부분 💡 ====================
                //
                // 기존의 하드코딩된 '주차 현황' Container(높이 235) 대신
                // _unpaidData 상태에 따라 UI를 그려주는 함수를 호출합니다.
                //
                Center(
                  child: _buildParkingStatusSection(screenWidth),
                ),
                // ========================================================
              ],
            ),

            const SizedBox(height: 25),

            // --- '정기권 구매하기' 버튼 (수정 없음) ---
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

            // --- '건물 별 잔여석' (수정 없음) ---
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

            // --- '최근 공지사항' (수정 없음) ---
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
  Widget _buildParkingStatusSection(double screenWidth) {
    // 경우 1: 미납/주차 중 내역이 없을 때 (수정 없음)
    if (_unpaidData == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        width: screenWidth * 0.92,
        height: 235,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.check_circle_outline, color: Color(0xFF65A549), size: 40),
            SizedBox(height: 15),
            Text('결제할 내역이 없습니다.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'SpoqaHanSansNeo')),
            SizedBox(height: 5),
            Text(
              '현재 주차 중인 차량이 없거나, 정산할 요금이 없습니다.',
              style: TextStyle(fontSize: 13, color: Colors.grey, fontFamily: 'SpoqaHanSansNeo'),
            ),
          ],
        ),
      );
    }

    // ==================== 💡 로직 수정됨 💡 ====================
    // 경우 2: 미납/주차 중 내역이 있을 때 (_unpaidData가 null이 아님)

    // 1. 입차 시간 처리 (날짜/시간 표기용)
    final DateTime entryTime = DateTime.parse(_unpaidData!['entry_time']);

    // 2. (💡수정됨) 이용 시간을 프론트엔드에서 계산하지 않습니다.
    //    백엔드(서버)가 계산한 'total_minutes' 값을 가져옵니다.
    final int totalMinutes = _unpaidData!['total_minutes'] ?? 0;
    final int hours = totalMinutes ~/ 60; // 몫: 시간
    final int minutes = totalMinutes % 60; // 나머지: 분

    // 이용 시간을 "○시간 ○분" 형식의 문자열로 만듦
    final String durationString = (hours > 0 ? '${hours}시간 ' : '') + '${minutes}분';

    // 3. 입차 날짜 및 시간 포맷팅 (수정 없음)
    final String entryDateFormatted = DateFormat('yyyy.MM.dd (E)', 'ko').format(entryTime);
    final String entryTimeFormatted = DateFormat('a hh:mm', 'ko').format(entryTime);

    // 4. 이용 금액 포맷팅 (수정 없음)
    final int fee = _unpaidData!['parking_fee'] ?? 0;
    final String feeFormatted = NumberFormat('#,###').format(fee);

    // 5. '다음 구간 요금' 정보 (수정 없음)
    const String nextFeeInfo = '200원 / 10분';

    // ==================== 로직 구현 끝 ====================

    // UI 위젯 반환 (수정 없음, 이제 durationString과 feeFormatted가 동기화됨)
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
          // '주차 현황' 타이틀
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text( '주차 현황', style: TextStyle( fontFamily: 'SpoqaHanSansNeo', fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF4B7C76))),
              Row(
                children: const [
                  Text('요금표 보기', style: TextStyle(fontFamily: 'SpoqaHanSansNeo', fontWeight: FontWeight.w600, fontSize: 9, color: Color(0xFFADB5CA))),
                  Icon(Icons.keyboard_arrow_right, size: 12, color: Color(0xFFADB5CA)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),

          // --- ✅ 데이터 연동된 부분 ---
          Text(
            entryDateFormatted, // ✅ 연동
            style: const TextStyle( fontFamily: 'SpoqaHanSansNeo', fontWeight: FontWeight.w400, fontSize: 9, color: Color(0xFF6B907F)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$entryTimeFormatted ', // ✅ 연동
                      style: const TextStyle( fontFamily: 'SpoqaHanSansNeo', fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF65A549)),
                    ),
                    const TextSpan(
                      text: '입차',
                      style: TextStyle( fontFamily: 'SpoqaHanSansNeo', fontWeight: FontWeight.w500, fontSize: 13, color: Color(0xFF414B6A)),
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: '이용 시간: ',
                      style: TextStyle( fontFamily: 'SpoqaHanSansNeo', fontWeight: FontWeight.w500, fontSize: 13, color: Color(0xFF414B6A)),
                    ),
                    TextSpan(
                      text: durationString, // ✅ (중요) 백엔드와 동기화된 시간
                      style: const TextStyle( fontFamily: 'SpoqaHanSansNeo', fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF65A549)),
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
                  text: '${feeFormatted}원', // ✅ (중요) 백엔드와 동기화된 요금
                  style: const TextStyle( fontFamily: 'SpoqaHanSansNeo', fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF65A549)),
                ),
                const TextSpan(
                  text: ' 이용 중',
                  style: TextStyle( fontFamily: 'SpoqaHanSansNeo', fontWeight: FontWeight.w500, fontSize: 13, color: Color(0xFF414B6A)),
                ),
              ],
            ),
          ),
          // --- (프로그레스 바 및 다음 구간 요금) ---
          const SizedBox(height: 10),
          Stack(
            children: [
              Container(height: 5, width: double.infinity, decoration: BoxDecoration(color: const Color(0xFFD9D9D9), borderRadius: BorderRadius.circular(4))),
              LayoutBuilder(
                builder: (context, constraints) {
                  return Container(height: 5, width: constraints.maxWidth * 0.5, decoration: BoxDecoration(color: const Color(0xFF76B55C), borderRadius: BorderRadius.circular(4)));
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('0분', style: TextStyle(fontFamily: 'SpoqaHanSansNeo', fontWeight: FontWeight.w500, fontSize: 8, color: Color(0xFF4B7C76))),
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(text: '다음 구간: ', style: TextStyle(fontFamily: 'SpoqaHanSansNeo', fontWeight: FontWeight.w500, fontSize: 10, color: Color(0xFF2F3644))),
                    TextSpan(text: nextFeeInfo, style: TextStyle(fontFamily: 'SpoqaHanSansNeo', fontWeight: FontWeight.w500, fontSize: 10, color: Color(0xFF61984A))),
                  ],
                ),
              ),
              const Text('60분', style: TextStyle(fontFamily: 'SpoqaHanSansNeo', fontWeight: FontWeight.w500, fontSize: 8, color: Color(0xFF4B7C76))),
            ],
          ),
          const Spacer(),
          // --- '출차 결제' 버튼 ---
          Center(
            child: SizedBox(
              width: 160,
              height: 40,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF8CE2AA), Color(0xFF93D4C7)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), offset: const Offset(0, 3), blurRadius: 7, spreadRadius: 2)],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/payment/CarLeavePurchase',
                      arguments: {
                        'duration': durationString, // 이용 시간
                        'currentFee': fee,           // 실제 요금
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text('출차 결제', style: TextStyle(fontFamily: 'SpoqaHanSansNeo', fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  // 💡 2. 정보 표시 헬퍼 위젯 (새로 추가)
  // -------------------------------------------------------------------
  /// 위젯 내부에서 사용된 헬퍼 위젯입니다. (이전 스레드에서 제안해 주신 코드)
  Widget _buildInfoRow(String label, String value, {bool isAmount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.black54, fontFamily: 'SpoqaHanSansNeo')),
          Text(
            value,
            style: TextStyle(
                fontSize: isAmount ? 20 : 16,
                fontWeight: isAmount ? FontWeight.bold : FontWeight.normal,
                color: Colors.black,
                fontFamily: 'SpoqaHanSansNeo'
            ),
          ),
        ],
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

// -------------------------------------------------------------------
// 헬퍼 함수 (수정 없음)
// -------------------------------------------------------------------

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