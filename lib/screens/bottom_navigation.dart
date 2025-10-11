// bottom_navigation.dart
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'BottomNavPages/HomeScreen/logined_home_screen.dart';
import 'BottomNavPages/HomeScreen/membership_home_screen.dart';
import 'BottomNavPages/car_breakdown.dart';
import 'BottomNavPages/payment_breakdown.dart';
import 'BottomNavPages/notice.dart';
import 'BottomNavPages/my_account.dart';
import '../main.dart'; // bottomNavIndex 사용
import '../services/auth_service.dart'; // 서버에서 사용자 정보 가져오기

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _subscribeMembership = 0; // 0: 일반, 1: 구독
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    bottomNavIndex.addListener(_onIndexChanged);
    _fetchUserSubscription();
  }

  void _onIndexChanged() {
    _fetchUserSubscription();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    bottomNavIndex.removeListener(_onIndexChanged);
    super.dispose();
  }

  // 서버에서 사용자 정보 가져오기
  Future<void> _fetchUserSubscription() async {
    setState(() { _loading = true; });
    try {
      final authService = AuthService();
      final result = await authService.getUserInfo();
      if (mounted) {
        setState(() {
          _subscribeMembership = result['user']['subscribe_membership'] ?? 0;
          _loading = false;
        });
        print('[LOG] userInfo result: $result');
      }
    } catch (e) {
      if (mounted) setState(() {
        _subscribeMembership = 0;
        _loading = false;
      });
      print('[ERROR] userInfo fetch failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: bottomNavIndex.value,
        children: [
          // 숫자 값에 따라 화면 선택
          _subscribeMembership == 1
              ? MembershipHomeScreen(key: const ValueKey('membership'))
              : LoginedHomeScreen(key: const ValueKey('logined')),
          const CarBreakdown(),
          const PaymentBreakdown(),
          const Notice(),
          const MyAccount(),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(height: 0.2, color: const Color(0xFFDADADA)),
          Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
            ),
            child: BottomNavigationBar(
              currentIndex: bottomNavIndex.value,
              onTap: (index) => bottomNavIndex.value = index,
              selectedItemColor: const Color(0xFF76B55C),
              unselectedItemColor: const Color(0xFFADB5CA),
              backgroundColor: Colors.white,
              type: BottomNavigationBarType.fixed,
              iconSize: 20,
              selectedLabelStyle: const TextStyle(
                fontFamily: 'SpoqaHanSansNeo',
                fontWeight: FontWeight.w700,
                fontSize: 9,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: 'SpoqaHanSansNeo',
                fontWeight: FontWeight.w700,
                fontSize: 9,
              ),
              items: [
                BottomNavigationBarItem(
                  icon: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [Icon(Icons.home), SizedBox(height: 3)],
                  ),
                  label: '홈',
                ),
                BottomNavigationBarItem(
                  icon: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [Icon(MdiIcons.car), SizedBox(height: 3)],
                  ),
                  label: '입출차 내역',
                ),
                BottomNavigationBarItem(
                  icon: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [Icon(MdiIcons.creditCardOutline), SizedBox(height: 3)],
                  ),
                  label: '결제 내역',
                ),
                BottomNavigationBarItem(
                  icon: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [Icon(MdiIcons.messageText), SizedBox(height: 3)],
                  ),
                  label: '공지사항',
                ),
                BottomNavigationBarItem(
                  icon: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [Icon(MdiIcons.accountCircleOutline), SizedBox(height: 3)],
                  ),
                  label: '내 계정',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}