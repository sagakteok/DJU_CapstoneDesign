import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'BottomNavPages/HomeScreen/logined_home_screen.dart';
import 'BottomNavPages/HomeScreen/logouted_home_screen.dart';
import 'BottomNavPages/car_breakdown.dart';
import 'BottomNavPages/payment_breakdown.dart';
import 'BottomNavPages/notice.dart';
import 'BottomNavPages/my_account.dart';
import '../main.dart'; // bottomNavIndex 사용

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  final List<Widget> _pages = const [
    LoginedHomeScreen(),
    CarBreakdown(),
    PaymentBreakdown(),
    Notice(),
    MyAccount(),
  ];

  @override
  void initState() {
    super.initState();
    bottomNavIndex.addListener(_onIndexChanged);
  }

  void _onIndexChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    bottomNavIndex.removeListener(_onIndexChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[bottomNavIndex.value],
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