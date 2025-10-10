import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SelectPassScreen extends StatelessWidget {
  const SelectPassScreen({super.key});

  // API 호출 (정기권 리스트 전체 가져오기)
  Future<List<Map<String, dynamic>>> fetchPassPlans() async {
    final host = dotenv.env['HOST_ADDRESS'];
    final response = await http.get(Uri.parse('$host/api/admin/passes/plans'),
      headers: {
        'x-user-id': '1',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data);
      if (data['items'] != null) {
        return List<Map<String, dynamic>>.from(data['items']);
      } else {
        return [];
      }
    } else {
      throw Exception('API 호출 실패');
    }
  }

  String formatPrice(dynamic price) {
    final number = double.tryParse(price.toString()) ?? 0;
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FCFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FCFB),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: screenHeight * 0.03),
            SizedBox(
              width: screenWidth * 0.88,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '정기권 상품',
                    style: TextStyle(
                      fontSize: 27,
                      fontFamily: 'VitroPride',
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '원하는 상품을 선택하여',
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'SpoqaHanSansNeo',
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF000000),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '해당 기간 내 자유 출입해보세요,',
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'SpoqaHanSansNeo',
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF000000),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchPassPlans(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("오류: ${snapshot.error}"));
                } else {
                  final plans = snapshot.data ?? [];

                  if (plans.isEmpty) {
                    return const Center(child: Text("등록된 정기권이 없습니다."));
                  }

                  return Column(
                    children: plans.map((plan) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: Center(
                          child: Container(
                            width: screenWidth * 0.92,
                            height: 95,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 7,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.only(top: 16, bottom: 16, left: 18, right: 18),
                              ),
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/payment/BuyPass',
                                  arguments: {
                                    'id': plan['id'],
                                    'name': plan['name'],
                                    'price': plan['price'].toString(),
                                    'duration_days': plan['duration_days'] ?? 0,
                                  },
                                );
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // 왼쪽 정보
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // 그라데이션 적용 텍스트
                                      ShaderMask(
                                        shaderCallback: (bounds) => const LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [Color(0xFF76B55C), Color(0xFF15C3AF)],
                                        ).createShader(
                                          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                                        ),
                                        child: Text(
                                          plan['name'] ?? '이름 없음',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontFamily: 'SpoqaHanSansNeo',
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white, // ShaderMask 때문에 흰색 지정
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),

                                      const Text(
                                        '사용 가능 기간',
                                        style: TextStyle(
                                          fontSize: 8,
                                          fontFamily: 'SpoqaHanSansNeo',
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xFF414B6A),
                                        ),
                                      ),
                                      Text(
                                        "${DateTime.now().toString().substring(0, 10)} ~ ${DateTime.now().add(Duration(days: plan['duration_days'] ?? 0)).toString().substring(0, 10)}",
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontFamily: 'SpoqaHanSansNeo',
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF50A12E),
                                        ),
                                      ),
                                    ],
                                  ),

                                  // 오른쪽 금액 분리
                                  Row(
                                    children: [
                                      const Text(
                                        "금액: ",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'SpoqaHanSansNeo',
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF414B6A),
                                        ),
                                      ),
                                      Text(
                                        "${formatPrice(plan['price'])}원",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'SpoqaHanSansNeo',
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF76B55C),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList()
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}