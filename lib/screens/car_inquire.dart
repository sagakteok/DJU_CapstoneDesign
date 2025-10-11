import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../main.dart';
import '../../services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CarInquireScreen extends StatefulWidget {
  const CarInquireScreen({super.key});

  @override
  State<CarInquireScreen> createState() => _CarInquireScreenState();
}

class _CarInquireScreenState extends State<CarInquireScreen> {
  String? userName;
  String? userBirth;
  String? userPhone;
  String? userEmail;
  String? carNumber;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final userInfo = await AuthService().getUserInfo();

    if (userInfo['success'] == true && userInfo['user'] != null) {
      final user = userInfo['user'];

      // 생년월일 YYYY.MM.DD
      String birthRaw = user['birth_date'] ?? '';
      String formattedBirth = '';
      if (birthRaw.isNotEmpty) {
        try {
          DateTime birthDate = DateTime.parse(birthRaw);
          formattedBirth = DateFormat('yyyy.MM.dd').format(birthDate);
        } catch (e) {
          formattedBirth = birthRaw;
        }
      }

      // 전화번호 하이픈
      String phoneRaw = user['phone_number'] ?? '';
      String formattedPhone = phoneRaw;
      if (phoneRaw.length == 11) {
        formattedPhone =
        '${phoneRaw.substring(0, 3)}-${phoneRaw.substring(3, 7)}-${phoneRaw.substring(7, 11)}';
      } else if (phoneRaw.length == 10) {
        formattedPhone =
        '${phoneRaw.substring(0, 3)}-${phoneRaw.substring(3, 6)}-${phoneRaw.substring(6, 10)}';
      }

      // 차량번호 한글 뒤 공백
      String carRaw = user['car_number'] ?? '';
      String formattedCar = carRaw;
      final reg = RegExp(r'([0-9]+[가-힣]+)([0-9]+)');
      if (reg.hasMatch(carRaw)) {
        formattedCar = carRaw.replaceAllMapped(reg, (m) => '${m[1]} ${m[2]}');
      }

      setState(() {
        userName = user['name'] ?? '';
        userBirth = formattedBirth;
        userPhone = formattedPhone;
        userEmail = user['email'] ?? '';
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

  // ----- 포맷 함수들 (요청하신대로 반드시 존재해야 함) -----
  String formatDateTime(DateTime dt) {
    // ex: 2025.10.04 (토) 12:00
    final datePart = DateFormat('yyyy.MM.dd').format(dt);
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekdayKor = weekdays[dt.weekday - 1];
    final timePart = DateFormat('HH:mm').format(dt); // 24시간, 0패딩
    return '$datePart ($weekdayKor) $timePart';
  }

  String formatDuration(num minutes) {
    // 입력 예: 20.00 -> 반올림 후 정수 분으로 표시 (예: 20분)
    final int rounded = minutes.round();
    return '${rounded}분';
  }

  String formatCurrency(num amount) {
    // 입력 예: 1000.00 -> "1,000"
    final int rounded = amount.round();
    final formatter = NumberFormat('#,###', 'ko_KR');
    return formatter.format(rounded);
  }
  // -------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // 하드코딩된 표시 값 (요청하신 대로 하드코딩)
    final String displayCarNumber = '372머 9480';
    final String displayEntryTime = formatDateTime(DateTime(2025, 10, 4, 12, 0));
    final String displayDuration = formatDuration(20.00);
    final String displayAmount = '${formatCurrency(1000.00)}원';

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
            Navigator.pushReplacementNamed(context, '/logoutedhome');
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
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

                  // 🔹 계정 정보 영역
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
                          const SizedBox(height: 10),
                          infoRow('차량번호', displayCarNumber),
                          const SizedBox(height: 25),
                          const SizedBox(height: 10),
                          infoRow('입차 일시', displayEntryTime),
                          const SizedBox(height: 25),
                          const SizedBox(height: 10),
                          infoRow('이용 시간', displayDuration),
                          const SizedBox(height: 25),
                          const SizedBox(height: 10),
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

          // 🔹 하단 버튼
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
                        Navigator.pushReplacementNamed(context, '/payment/purchase');
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