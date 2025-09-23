import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // 날짜/숫자 포맷용

class BuyPassScreen extends StatelessWidget {
  const BuyPassScreen({super.key});

  // API 호출 함수
  Future<Map<String, dynamic>> fetchPassPlan() async {
    final response = await http.get(
        Uri.parse('http://192.168.75.57:3000/api/admin/passes/plans'),
        headers: {
          'x-user-id': '1', // 실제 로그인한 유저 ID
        }
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['items'] != null && data['items'].isNotEmpty) {
        return data['items'][0]; // 첫 번째 플랜
      } else {
        throw Exception('플랜 데이터 없음');
      }
    } else {
      throw Exception('API 호출 실패');
    }
  }

  // 숫자 포맷 함수
  String formatPrice(String price) {
    final number = double.tryParse(price) ?? 0;
    final formatter = NumberFormat('#,###');
    return '${formatter.format(number)}원';
  }

  // 날짜 계산 함수
  String formatDate(DateTime date) {
    final formatter = DateFormat('yyyy.MM.dd');
    return formatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    final double buttonWidth = MediaQuery.of(context).size.width * 0.85;
    final double contentWidth = MediaQuery.of(context).size.width * 0.8;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
        centerTitle: true,
        title: const Text(
          '정기권 구매하기',
          style: TextStyle(
            fontFamily: 'SpoqaHanSansNeo',
            fontWeight: FontWeight.w500,
            fontSize: 15,
            color: Colors.black,
          ),
        ),
      ),
      body: Center(
        child: FutureBuilder<Map<String, dynamic>>(
          future: fetchPassPlan(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('오류: ${snapshot.error}');
            } else {
              final plan = snapshot.data!;
              final String name = plan['name'];
              final String price = formatPrice(plan['price']);
              final int durationDays = plan['duration_days'] ?? 0;

              // 날짜 계산
              final DateTime now = DateTime.now();
              final String startDate = formatDate(now);
              final String endDate = formatDate(now.add(Duration(days: durationDays)));

              return Column(
                children: [
                  SizedBox(height: screenHeight * 0.02),
                  // 상단 텍스트
                  SizedBox(
                    width: buttonWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          '정기권 구매하기',
                          style: TextStyle(
                            fontSize: 27,
                            fontFamily: 'VitroPride',
                            color: Color(0xFF1E1E1E),
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          '정기권을 구매하여',
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'SpoqaHanSansNeo',
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1E1E1E),
                          ),
                        ),
                        Text(
                          '남은 기간 편하게 출입해보세요.',
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'SpoqaHanSansNeo',
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1E1E1E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // 중앙 컨텐츠
                  Column(
                    children: [
                      Container(
                        width: contentWidth,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FCFB),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0x1A000000),
                              offset: const Offset(0, 4),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // 왼쪽 텍스트 (기간)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '사용 가능 기간',
                                  style: TextStyle(
                                      fontFamily: 'SpoqaHanSansNeo',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF2F3644)
                                  ),
                                ),
                                Text(
                                  '$startDate ~',
                                  style: const TextStyle(
                                      fontFamily: 'SpoqaHanSansNeo',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF65A549)
                                  ),
                                ),
                                Text(
                                  endDate,
                                  style: const TextStyle(
                                      fontFamily: 'SpoqaHanSansNeo',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF65A549)
                                  ),
                                ),
                              ],
                            ),

                            // 오른쪽 금액 텍스트
                            RichText(
                              text: TextSpan(
                                children: [
                                  const TextSpan(
                                    text: '금액: ',
                                    style: TextStyle(
                                        fontFamily: 'SpoqaHanSansNeo',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF414B6A)
                                    ),
                                  ),
                                  TextSpan(
                                    text: price,
                                    style: const TextStyle(
                                      fontFamily: 'SpoqaHanSansNeo',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF76B55C),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                      // ShaderMask로 DB name 적용
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFF76B55C), Color(0xFF15C3AF)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ).createShader(bounds),
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontFamily: 'SpoqaHanSansNeo',
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),

                  // 하단 버튼
                  Padding(
                    padding: const EdgeInsets.only(bottom: 50),
                    child: SizedBox(
                      width: buttonWidth,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/payment/purchase',
                            arguments: {
                              'name': plan['name'],
                              'price': plan['price'].toString(), // <- 여기서 반드시 문자열로 변환
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: const Color(0xFF50A12E),
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          '구매하기',
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
                ],
              );
            }
          },
        ),
      ),
    );
  }
}