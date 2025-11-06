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
  String displayCarNumber = '';
  String displayEntryTime = '';
  String displayDuration = '';
  String displayAmount = '';

  // 3. initState 대신 didChangeDependencies 사용 (build가 처음 호출되기 전에 arguments를 받기 위함)
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 이전 화면에서 전달된 차량 번호(argument)를 가져옴
    final carNumber = ModalRoute.of(context)!.settings.arguments as String?;
    if (carNumber != null && carNumber.isNotEmpty) {
      // 차량 번호로 실제 DB 데이터 조회를 시작
      _fetchParkingDetails(carNumber);
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = "차량 번호를 전달받지 못했습니다.";
      });
    }
  }

  // 4. DB에서 실제 주차 기록을 가져오는 새로운 함수
  Future<void> _fetchParkingDetails(String carNumber) async {
    // AuthService에 새로 추가한 함수를 호출
    final result = await AuthService().getParkingRecordForGuest(carNumber);

    if (mounted) { // 위젯이 화면에 아직 붙어있는지 확인
      if (result['success'] == true) {
        // 성공적으로 데이터를 받아왔을 경우
        final entryTime = DateTime.parse(result['entry_time']).toLocal();
        final durationSeconds = result['duration_seconds'] as num;
        final currentFee = result['current_fee'] as num;

        setState(() {
          // 상태 변수에 실제 데이터 할당
          displayCarNumber = formatCarNumber(carNumber);
          displayEntryTime = formatDateTime(entryTime);
          displayDuration = formatDuration(durationSeconds / 60); // 초를 분으로 변환
          displayAmount = '${formatCurrency(currentFee)}원';
          _isLoading = false;
        });
      } else {
        // 데이터를 받아오지 못했을 경우 (차량이 없거나, 서버 오류 등)
        setState(() {
          _isLoading = false;
          _errorMessage = result['message'] ?? '주차 정보를 조회할 수 없습니다.';
        });
      }
    }
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
                  style: const TextStyle(fontSize: 16, color: Colors.red),
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
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
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
                    child: Container(
                      width: screenWidth * 0.9,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 6. 하드코딩된 값 대신 실제 DB에서 가져온 상태 변수 사용
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
