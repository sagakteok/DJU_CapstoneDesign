import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../main.dart';
import '../../services/auth_service.dart';

// 1. StatefulWidget으로 변경하여 상태 관리
class CarInquireScreen extends StatefulWidget {
  const CarInquireScreen({super.key});

  @override
  State<CarInquireScreen> createState() => _CarInquireScreenState();
}

class _CarInquireScreenState extends State<CarInquireScreen> {
  // 2. 화면에 표시할 데이터를 위한 상태 변수들
  bool _isLoading = true;
  String? _errorMessage;

  // 기본값을 '-'로 시작해 UI 안정성 확보
  String displayCarNumber = '-';
  String displayEntryTime = '-';
  String displayDuration = '-';
  String displayAmount = '-';

  // didChangeDependencies 중복 호출 가드
  bool _fetched = false;

  // 3. initState 대신 didChangeDependencies 사용 (build가 처음 호출되기 전에 arguments를 받기 위함)
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_fetched) return; // 중복 요청 방지

    // 이전 화면에서 전달된 차량 번호(argument)를 가져옴
    final carNumber = ModalRoute.of(context)!.settings.arguments as String?;
    if (carNumber != null && carNumber.isNotEmpty) {
      _fetched = true;
      // 차량 번호로 실제 DB 데이터 조회를 시작
      _fetchParkingDetails(carNumber);
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = "차량 번호를 전달받지 못했습니다.";
      });
    }
  }

  // ---- 응답 안전 파싱 유틸 ----
  // 다양한 키 후보 중 첫 매칭 값 반환
  dynamic _pick(Map<String, dynamic> map, List<String> keys) {
    for (final k in keys) {
      if (map.containsKey(k)) return map[k];
    }
    return null;
  }

  // 숫자/문자 모두 지원하는 안전 num 캐스팅
  num _toNum(dynamic v, {num fallback = 0}) {
    if (v is num) return v;
    if (v is String) return num.tryParse(v) ?? fallback;
    return fallback;
  }

  // entry_time 다양한 포맷 지원 파서
  DateTime? _parseEntryTime(dynamic raw) {
    if (raw == null) return null;

    // 1) 문자열 ISO / 'yyyy-MM-dd HH:mm:ss'
    if (raw is String && raw.trim().isNotEmpty) {
      final dt = DateTime.tryParse(raw);
      if (dt != null) return dt.toLocal();

      // 공백 포함 일반 포맷 수동 파싱
      final reg = RegExp(r'^(\d{4})-(\d{2})-(\d{2})[ T](\d{2}):(\d{2}):(\d{2})$');
      final m = reg.firstMatch(raw);
      if (m != null) {
        final dt2 = DateTime(
          int.parse(m.group(1)!),
          int.parse(m.group(2)!),
          int.parse(m.group(3)!),
          int.parse(m.group(4)!),
          int.parse(m.group(5)!),
          int.parse(m.group(6)!),
        );
        return dt2; // 서버가 로컬 기준 문자열이면 그대로 사용
      }
    }

    // 2) 숫자 에폭(초/밀리초)
    if (raw is num) {
      final int v = raw.toInt();
      final bool looksMs = v > 9999999999; // 10자리=초, 13자리=밀리초 추정
      final dt = DateTime.fromMillisecondsSinceEpoch(
        looksMs ? v : v * 1000,
        isUtc: true,
      );
      return dt.toLocal();
    }

    // 3) Map 형태 (예: {seconds: 1699250000} / {milliseconds: 1699250000000})
    if (raw is Map) {
      final sec = raw['seconds'] ?? raw['epoch_seconds'] ?? raw['epoch'];
      if (sec is num) {
        final dt = DateTime.fromMillisecondsSinceEpoch(sec.toInt() * 1000, isUtc: true);
        return dt.toLocal();
      }
      final ms = raw['milliseconds'] ?? raw['epoch_ms'];
      if (ms is num) {
        final dt = DateTime.fromMillisecondsSinceEpoch(ms.toInt(), isUtc: true);
        return dt.toLocal();
      }
      final s = raw['value'] ?? raw['time'] ?? raw['date'];
      if (s != null) return _parseEntryTime(s);
    }

    return null;
  }
  // -------------------------

  Future<void> _fetchParkingDetails(String carNumber) async {
    final raw = await AuthService().getParkingRecordForGuest(carNumber);
    if (!mounted) return;

    // 1) 응답 형식 점검
    if (raw is! Map) {
      setState(() {
        _isLoading = false;
        _errorMessage = '서버 응답이 올바르지 않습니다.';
      });
      return;
    }

    // 2) 성공은 오직 success == true 일 때만
    final bool success = raw['success'] == true;
    final Map<String, dynamic> body =
    (raw['data'] is Map) ? Map<String, dynamic>.from(raw['data']) : const {};

    if (!success) {
      setState(() {
        _isLoading = false;
        _errorMessage = (raw['message'] as String?) ?? '조회된 차량이 없습니다.';
      });
      return;
    }

    // 3) data가 비었거나 필수 필드가 없으면 "조회 없음" 처리
    if (body.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = '조회된 차량이 없습니다.';
      });
      return;
    }

    // 4) 필수 필드 점검 (entry_time 기준으로 기록 존재 판단)
    final dynamic entryRaw = _pick(body, [
      'entry_time',
      'entryTime',
      'entry_at',
      'entryTimeUtc',
      'entry',
    ]);
    final DateTime? entryTime = _parseEntryTime(entryRaw);

    if (entryTime == null) {
      // 기록이 없다고 판단 → 에러 화면
      setState(() {
        _isLoading = false;
        _errorMessage = '조회된 차량이 없습니다.';
      });
      return;
    }

    // 5) 부가 필드 파싱
    final num durationSeconds = _toNum(_pick(body, [
      'duration_seconds',
      'durationSecs',
      'duration',
      'elapsed_seconds'
    ]));
    final num currentFee = _toNum(_pick(body, [
      'current_fee',
      'fee',
      'amount',
      'price'
    ]));

    // 6) 성공적으로 표시
    setState(() {
      displayCarNumber = formatCarNumber(carNumber);
      displayEntryTime = formatDateTime(entryTime);
      displayDuration  = formatDuration(durationSeconds / 60); // 초→분
      displayAmount    = '${formatCurrency(currentFee)}원';
      _isLoading = false;
    });
  }

  // ----- 포맷 함수들 -----
  String formatCarNumber(String carRaw) {
    final reg = RegExp(r'([0-9]+[가-힣]+)([0-9]+)');
    if (reg.hasMatch(carRaw)) {
      return carRaw.replaceAllMapped(reg, (m) => '${m[1]} ${m[2]}');
    }
    return carRaw;
  }

  String formatDateTime(DateTime dt) {
    final datePart = DateFormat('yyyy.MM.dd').format(dt);
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekdayKor = weekdays[dt.weekday - 1];
    final timePart = DateFormat('HH:mm').format(dt);
    return '$datePart ($weekdayKor) $timePart';
  }

  String formatDuration(num minutes) {
    final int rounded = minutes.round();
    return '${rounded}분';
  }

  String formatCurrency(num amount) {
    final int rounded = amount.round();
    final formatter = NumberFormat('#,###', 'ko_KR');
    return formatter.format(rounded);
  }
  // ---------------------

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double buttonWidth = screenWidth * 0.8;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, '/logoutedhome');
            }
          },
        ),
        centerTitle: true,
        title: const Text(
          '차량 조회',
          style: TextStyle(
            fontFamily: 'SpoqaHanSansNeo',
            fontWeight: FontWeight.w500,
            fontSize: 15,
            color: Colors.black,
          ),
        ),
        flexibleSpace: Container(color: Colors.white),
      ),
      // 5. 로딩 및 에러 상태에 따라 다른 화면을 보여줌
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style:
            const TextStyle(fontSize: 16, color: Colors.red),
          ),
        ),
      )
          : Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.02),
                  Center(
                    child: SizedBox(
                      width: 300,
                      child: Image.asset(
                        'assets/images/sample_car.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.05),
                    child: const Text(
                      '조회된 차량',
                      style: TextStyle(
                        fontFamily: 'VitroPride',
                        fontSize: 20,
                        color: Color(0xFF2F3644),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: SizedBox(
                      width: screenWidth * 0.9,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 6. 상태 변수 사용
                          infoRow('차량번호', displayCarNumber),
                          const SizedBox(height: 25),
                          infoRow('입차 일시', displayEntryTime),
                          const SizedBox(height: 25),
                          infoRow('이용 시간', displayDuration),
                          const SizedBox(height: 25),
                          infoRow('이용 금액', displayAmount),
                          const SizedBox(height: 25),
                          SizedBox(height: screenHeight * 0.06),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
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
                        Navigator.pushReplacementNamed(
                          context,
                          '/payment/CarLeavePurchase',
                          arguments: {
                            'duration': displayDuration,
                            'currentFee': displayAmount,
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(15),
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
                            '출차 결제',
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
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget infoRow(String label, String value,
      {bool showArrow = false, VoidCallback? onTap}) {
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