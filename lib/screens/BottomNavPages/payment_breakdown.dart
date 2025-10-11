// payment_breakdown.dart
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../main.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../services/auth_service.dart';

class PaymentBreakdown extends StatefulWidget {
  const PaymentBreakdown({super.key});

  @override
  State<PaymentBreakdown> createState() => _PaymentBreakdownState();
}

class _PaymentBreakdownState extends State<PaymentBreakdown> {
  String _selectedType = '전체 내역';
  final List<String> _types = ['전체 내역', '출차', '정기권'];

  bool _isDropdownOpen = false;
  bool _searchPerformed = false;
  List<Map<String, dynamic>> _filteredData = [];
  List<Map<String, dynamic>> _allData = [];

  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndFetchData();
  }

  Future<void> _loadUserIdAndFetchData() async {
    final authService = AuthService();
    final token = await authService.getToken();
    debugPrint('[PaymentBreakdown] token: $token');

    if (token == null) return;

    final decodedToken = JwtDecoder.decode(token);
    final userId = decodedToken['user_id'];
    debugPrint('[PaymentBreakdown] decoded userId: $userId');

    if (mounted) {
      setState(() {
        _userId = userId;
      });
      _fetchPaymentData();
    }
  }

  Future<void> _fetchPaymentData() async {
    if (_userId == null) return;

    try {
      final host = dotenv.env['HOST_ADDRESS'];
      final url = Uri.parse('$host/api/payment/history/$_userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final payments = data['payments'] as List;

        setState(() {
          _allData = payments.map((item) {
            final date = DateTime.parse(item['use_date']);
            final time = item['created_at'] != null
                ? DateTime.parse(item['created_at']).toLocal()
                : date;

            return {
              'date': DateFormat('yyyy-MM-dd').format(date),
              'time': DateFormat('a hh:mm', 'ko_KR').format(time),
              'amount': item['amount'],
              'type': item['type'], // DB enum 그대로
            };
          }).toList();
        });
      } else {
        print("결제내역 로드 실패: ${response.statusCode}");
      }
    } catch (e) {
      print("결제내역 API 호출 에러: $e");
    }
  }

  void _performSearch() {
    setState(() {
      _searchPerformed = true;
      if (_selectedType == '전체 내역') {
        _filteredData = List.from(_allData);
      } else {
        _filteredData = _allData.where((item) => item['type'] == _selectedType).toList();
      }
    });
  }

  String _formatAmount(int amount) {
    final formatter = NumberFormat('#,###');
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FCFB),
      appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              bottomNavIndex.value = 0;
            },
          )
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 15),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.02),
                  const Text(
                    '결제 내역',
                    style: TextStyle(
                      fontSize: 25,
                      fontFamily: 'VitroPride',
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    '유형',
                    style: TextStyle(
                      fontSize: 15,
                      fontFamily: 'SpoqaHanSansNeo',
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF414B6A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Theme(
                    data: Theme.of(context).copyWith(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton2<String>(
                        isExpanded: true,
                        value: _selectedType,
                        onMenuStateChange: (isOpen) {
                          setState(() {
                            _isDropdownOpen = isOpen;
                          });
                        },
                        selectedItemBuilder: (context) => _types.map((type) {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              type,
                              style: const TextStyle(
                                fontSize: 15,
                                fontFamily: 'SpoqaHanSansNeo',
                                fontWeight: FontWeight.w300,
                                color: Color(0xFF414B6A),
                              ),
                            ),
                          );
                        }).toList(),
                        items: _types.map((type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 15),
                              child: Text(
                                type,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'SpoqaHanSansNeo',
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF2F3644),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value!;
                          });
                        },
                        iconStyleData: IconStyleData(
                          icon: Padding(
                            padding: const EdgeInsets.only(right: 0),
                            child: Icon(
                              _isDropdownOpen
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: const Color(0xFF2F3644),
                            ),
                          ),
                        ),
                        buttonStyleData: const ButtonStyleData(
                          height: 45,
                          width: double.infinity,
                          padding: EdgeInsets.zero,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border(
                              bottom: BorderSide(
                                color: Color(0xFFD6E1D1),
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                        dropdownStyleData: DropdownStyleData(
                          maxHeight: 200,
                          width: double.infinity,
                          padding: EdgeInsets.zero,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                            border: Border.all(
                                color: const Color(0xFFD6E1D1), width: 1),
                          ),
                          elevation: 1,
                          offset: const Offset(0, 8),
                        ),
                        menuItemStyleData: const MenuItemStyleData(
                          height: 50,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Center(
                    child: SizedBox(
                      width: screenWidth * 0.85,
                      height: 42,
                      child: ElevatedButton(
                        onPressed: _performSearch,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF50A12E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                        ),
                        child: const Text(
                          '검색',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'SpoqaHanSansNeo',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                ],
              ),
            ),

            // 조건부 내역 출력
            _searchPerformed
                ? _filteredData.isNotEmpty
                ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: Text(
                      '내역 리스트',
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'SpoqaHanSansNeo',
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFB8C8B1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(
                    color: Color(0xFFECF2E9),
                    height: 1,
                  ),
                  ..._filteredData.map((item) {
                    return Column(
                      children: [
                        Container(
                          color: Colors.white,
                          height: 60,
                          padding:
                          const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['date'],
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontFamily: 'SpoqaHanSansNeo',
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF2F3644),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        item['time'],
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'SpoqaHanSansNeo',
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF65A549),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        item['type'],
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontFamily: 'SpoqaHanSansNeo',
                                          fontWeight: FontWeight.w500,
                                          color: item['type'] == '출차'
                                              ? const Color(0xFFCD0505)
                                              : const Color(0xFF15C3AF),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              Row(
                                crossAxisAlignment:
                                CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    '이용 금액:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'SpoqaHanSansNeo',
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF414B6A),
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    _formatAmount(item['amount']) + '원',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'SpoqaHanSansNeo',
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF76B55C),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Divider(
                          color: Color(0xFFECF2E9),
                          height: 1,
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
            )
                : Container(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: const Center(
                child: Text(
                  '존재한 내역이 없습니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'SpoqaHanSansNeo',
                    color: Color(0xFFB8C8B1),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
                : Container(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: const Center(
                child: Text(
                  '원하는 내역을 선택해주세요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'SpoqaHanSansNeo',
                    color: Color(0xFFB8C8B1),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}