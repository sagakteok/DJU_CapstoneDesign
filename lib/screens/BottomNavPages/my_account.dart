import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../main.dart';
import '../../services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class MyAccount extends StatefulWidget {
  const MyAccount({super.key});

  @override
  State<MyAccount> createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
  String? userName;
  String? userBirth;
  String? userPhone;
  String? userEmail;
  String? carNumber;
  bool _isLoading = true;
  Map<String, dynamic>? user; // DB 사용자 정보 저장
  bool isKakaoLinked = false; // ← 연동 상태 직접 관리

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final userInfo = await AuthService().getUserInfo();

    if (userInfo['success'] == true && userInfo['user'] != null) {
      user = userInfo['user'];

      String birthRaw = user!['birth_date'] ?? '';
      String formattedBirth = '';
      if (birthRaw.isNotEmpty) {
        try {
          DateTime birthDate = DateTime.parse(birthRaw);
          formattedBirth = DateFormat('yyyy.MM.dd').format(birthDate);
        } catch (e) {
          formattedBirth = birthRaw;
        }
      }

      String phoneRaw = user!['phone_number'] ?? '';
      String formattedPhone = phoneRaw;
      if (phoneRaw.length == 11) {
        formattedPhone =
        '${phoneRaw.substring(0, 3)}-${phoneRaw.substring(3, 7)}-${phoneRaw.substring(7, 11)}';
      } else if (phoneRaw.length == 10) {
        formattedPhone =
        '${phoneRaw.substring(0, 3)}-${phoneRaw.substring(3, 6)}-${phoneRaw.substring(6, 10)}';
      }

      String carRaw = user!['car_number'] ?? '';
      String formattedCar = carRaw;
      final reg = RegExp(r'([0-9]+[가-힣]+)([0-9]+)');
      if (reg.hasMatch(carRaw)) {
        formattedCar = carRaw.replaceAllMapped(reg, (m) => '${m[1]} ${m[2]}');
      }

      setState(() {
        userName = user!['name'] ?? '';
        userBirth = formattedBirth;
        userPhone = formattedPhone;
        userEmail = user!['email'] ?? '';
        carNumber = formattedCar;
        isKakaoLinked = user!['kakao_auth'] != null; // ← 초기 상태 설정
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      debugPrint('사용자 정보 로드 실패: ${userInfo['message'] ?? userInfo['error']}');
    }
  }

  Future<void> _confirmAndDeleteAccount() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('회원 탈퇴 확인'),
        content: const Text('정말로 회원 탈퇴를 진행하시겠습니까? 이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('확인'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      const storage = FlutterSecureStorage();
      final userIdStr = await storage.read(key: 'user_id');
      if (userIdStr == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('사용자 정보를 찾을 수 없습니다.')),
        );
        return;
      }
      final int? userId = int.tryParse(userIdStr);
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('유효하지 않은 사용자 ID입니다.')),
        );
        return;
      }

      final result = await AuthService().deleteUser(userId);
      if (result['success'] == true) {
        await storage.deleteAll();
        Navigator.pushNamedAndRemoveUntil(context, '/appstart', (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? '회원 탈퇴에 실패했습니다.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
            bottomNavIndex.value = 0;
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                        '${userName ?? ''} 님',
                        style: const TextStyle(
                          fontFamily: 'SpoqaHanSansNeo',
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        carNumber ?? '',
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
                    infoRow('이름', userName ?? ''),
                    const SizedBox(height: 25),
                    const SizedBox(height: 10),
                    infoRow('생년월일', userBirth ?? ''),
                    const SizedBox(height: 25),
                    const SizedBox(height: 10),
                    infoRow('전화번호', userPhone ?? '', showArrow: true,
                      onTap: () {
                        Navigator.pushNamed(context, '/auth_edit/UserInfoEdit');
                      },
                    ),
                    const SizedBox(height: 25),
                    const SizedBox(height: 10),
                    infoRow('이메일', userEmail ?? '', showArrow: true,
                      onTap: () {
                        Navigator.pushNamed(context, '/auth_edit/EmailEdit');
                      },
                    ),
                    const SizedBox(height: 25),
                    const SizedBox(height: 10),
                    infoRow('비밀번호', '', showArrow: true,
                      onTap: () {
                        Navigator.pushNamed(context, '/auth_edit/PasswordEdit');
                      },
                    ),
                    const SizedBox(height: 25),
                    const SizedBox(height: 10),
                    infoRow('차량번호', carNumber ?? '', showArrow: true,
                      onTap: () {
                        Navigator.pushNamed(context, '/auth_edit/VehicleEdit');
                      },
                    ),
                    const SizedBox(height: 25),
                    const SizedBox(height: 2),
                    infoRow('카카오 로그인', '', showArrow: false,
                      onTap: null,
                      isKakao: true, // ← 카카오 로그인 버튼 렌더링
                    ),
                    const SizedBox(height: 25),
                    SizedBox(height: screenHeight * 0.06),
                  ],
                ),
              ),
            ),
            Center(
              child: SizedBox(
                width: screenWidth * 0.8,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    const storage = FlutterSecureStorage();
                    await storage.delete(key: 'token');
                    final token = await storage.read(key: 'token');
                    debugPrint('[MyAccount] 로그아웃 후 토큰 확인: $token');
                    Navigator.pushNamedAndRemoveUntil(context, '/appstart', (route) => false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF50A12E),
                    elevation: 0,
                    shadowColor: Colors.transparent,
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
            Center(
              child: GestureDetector(
                onTap: _confirmAndDeleteAccount,
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
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget infoRow(String label, String value,
      {bool showArrow = false, VoidCallback? onTap, bool isKakao = false}) {
    final storage = const FlutterSecureStorage();

    if (isKakao) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '카카오 로그인',
            style: TextStyle(
              fontFamily: 'SpoqaHanSansNeo',
              fontWeight: FontWeight.w300,
              fontSize: 14,
              color: Color(0xFF414B6A),
            ),
          ),
          Row(
            children: [
              if (isKakaoLinked)
                const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Text(
                    '연동완료',
                    style: TextStyle(
                      fontFamily: 'SpoqaHanSansNeo',
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Color(0xFF50A12E),
                    ),
                  ),
                ),
              SizedBox(
                width: 70,
                height: 35,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      final userIdStr = await storage.read(key: 'user_id');
                      if (userIdStr == null) return;
                      final int? userId = int.tryParse(userIdStr);
                      if (userId == null) return;

                      if (isKakaoLinked) {
                        // 🔹 연동 해제
                        final response = await AuthService().unlinkKakao(userId);
                        if (response['success'] == true) {
                          await storage.delete(key: 'kakao_id');
                          await storage.delete(key: 'kakao_access_token');
                          if (mounted) setState(() => isKakaoLinked = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('카카오 연동이 해제되었습니다.')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('서버 연동 해제 실패: ${response['message']}')),
                          );
                        }
                      } else {
                        // 🔹 연동하기
                        OAuthToken token;
                        if (await isKakaoTalkInstalled()) {
                          token = await UserApi.instance.loginWithKakaoTalk();
                        } else {
                          token = await UserApi.instance.loginWithKakaoAccount();
                        }

                        final userKakao = await UserApi.instance.me();
                        final String kakaoId = userKakao.id.toString();

                        final response = await AuthService().linkKakao(userId, kakaoId);

                        if (response['success'] == true) {
                          await storage.write(key: 'kakao_id', value: kakaoId);
                          await storage.write(key: 'kakao_access_token', value: token.accessToken);
                          if (mounted) setState(() => isKakaoLinked = true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('카카오 연동이 완료되었습니다.')),
                          );
                        } else {
                          // 🔹 여기가 핵심: 409 오류 메시지 감지
                          final String message =
                          response['error']?.toString().contains('409') == true
                              ? '이미 등록된 카카오 사용자입니다.'
                              : (response['message'] ?? '서버 연동 실패');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(message)),
                          );
                        }
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('카카오 연동 실패: $e')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isKakaoLinked ? const Color(0xFF6B907F) : const Color(0xFF50A12E),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ),
                  child: Text(
                    isKakaoLinked ? '연동해제' : '연동하기',
                    style: const TextStyle(
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
        ],
      );
    }

    // 일반 정보 Row
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