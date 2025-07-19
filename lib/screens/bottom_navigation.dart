import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

import 'BottomNavPages/HomeScreen/logined_home_screen.dart';
import 'BottomNavPages/car_breakdown.dart';
import 'BottomNavPages/payment_breakdown.dart';
import 'BottomNavPages/notice.dart';
import 'BottomNavPages/my_account.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    LoginedHomeScreen(),
    CarBreakdown(),
    PaymentBreakdown(),
    Notice(),
    MyAccount(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
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
              currentIndex: _currentIndex,
              onTap: (int index) => setState(() => _currentIndex = index),
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
                    children: const [
                      Icon(Icons.home),
                      SizedBox(height: 3), // ← 간격
                    ],
                  ),
                  label: '홈',
                ),
                BottomNavigationBarItem(
                  icon: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(MdiIcons.car),
                      SizedBox(height: 3),
                    ],
                  ),
                  label: '입출차 내역',
                ),
                BottomNavigationBarItem(
                  icon: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(MdiIcons.creditCardOutline),
                      SizedBox(height: 3),
                    ],
                  ),
                  label: '결제 내역',
                ),
                BottomNavigationBarItem(
                  icon: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(MdiIcons.messageText),
                      SizedBox(height: 3),
                    ],
                  ),
                  label: '공지사항',
                ),
                BottomNavigationBarItem(
                  icon: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(MdiIcons.accountCircleOutline),
                      SizedBox(height: 3),
                    ],
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