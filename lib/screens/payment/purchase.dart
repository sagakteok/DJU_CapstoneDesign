import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 현재 날짜 시간 포맷용

class PurchaseScreen extends StatelessWidget {
  const PurchaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final buttonWidth = MediaQuery.of(context).size.width * 0.85;
    final screenHeight = MediaQuery.of(context).size.height;

    // ✅ 상품명, 금액 변수 처리
    final String productName = '정기권 - 2025년 2학기';
    final String price = '40,000원';

    // ✅ 현재 시간 변수 처리
    final String currentDateTime =
    DateFormat('yyyy.MM.dd HH:mm').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text(
          '결제하기',
          style: TextStyle(
            fontFamily: 'SpoqaHanSansNeo',
            fontWeight: FontWeight.w500,
            fontSize: 15,
            color: Colors.black,
          ),
        ),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: screenHeight * 0.1),
            SizedBox(
              width: buttonWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    productName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'SpoqaHanSansNeo',
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF76B55C),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$price',
                    style: const TextStyle(
                      fontSize: 35,
                      fontFamily: 'SpoqaHanSansNeo',
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2F3644),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const Spacer(),

            // ✅ 결제 버튼 바로 위에 날짜 텍스트 추가
            SizedBox(
              width: buttonWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '구입 예정 일시: $currentDateTime',
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'SpoqaHanSansNeo',
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF376524),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ✅ 결제하기 버튼
                  SizedBox(
                    height: 52,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/payment/PaymentComplete');
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
                            '결제하기',
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
          ],
        ),
      ),
    );
  }
}