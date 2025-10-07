import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../NoticeItem.dart';
import '../../main.dart';

class Notice extends StatefulWidget {
  const Notice({super.key});

  @override
  State<Notice> createState() => _NoticeState();
}

class _NoticeState extends State<Notice> {
  String _selectedCategory = '전체';
  List<Map<String, dynamic>> _notices = [];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ko').then((_) {
      fetchNotices();
    });
  }

  // API에서 받은 날짜를 'YYYY.MM.DD (오전/오후)'로 변환
  String formatDate(String rawDate) {
    try {
      // GMT 문자열 파싱 후 한국 시간으로 변환
      DateTime dateTime = DateFormat('EEE, dd MMM yyyy HH:mm:ss', 'en')
          .parse(rawDate, true)
          .toLocal();
      return DateFormat("yyyy.MM.dd (E)", 'ko').format(dateTime);
    } catch (e) {
      print('Date parsing error: $e');
      return rawDate;
    }
  }

  Future<void> fetchNotices() async {
    final response =
    await http.get(Uri.parse('http://192.168.75.23:3000/api/notices'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final items = data['items'] as List<dynamic>;

      setState(() {
        _notices.clear();
        _notices.addAll(items.map((item) => {
          'title': item['title'],
          'content': item['content'],
          'date': formatDate(item['created_at']), // 날짜 포맷 적용
          'category': '전체', // API에 카테고리 없으므로 임시값
        }).toList());
      });
    } else {
      print('Failed to load notices: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
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
        ),
        centerTitle: true,
        title: const Text(
          '공지사항',
          style: TextStyle(
            fontFamily: 'SpoqaHanSansNeo',
            fontWeight: FontWeight.w500,
            fontSize: 15,
            color: Colors.black,
          ),
        ),
        flexibleSpace: Container(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 카테고리 드롭다운
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 12, bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 40,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: false,
                        value: _selectedCategory,
                        icon: const Icon(Icons.expand_more,
                            color: Color(0xFFD6E1D1)),
                        style: const TextStyle(
                          fontFamily: 'SpoqaHanSansNeo',
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Color(0xFF6B907F),
                        ),
                        items: const [
                          DropdownMenuItem(value: '전체', child: Text('전체')),
                          DropdownMenuItem(value: '앱공지', child: Text('앱공지')),
                          DropdownMenuItem(
                              value: '건물공지', child: Text('건물공지')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 공지사항 목록
            Column(
              children: _notices.map((notice) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.92,
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
                          shadowColor: Colors.black.withOpacity(0.0),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.all(16),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NoticeItem(
                                title: notice['title'] ?? '',
                                content: notice['content'] ?? '',
                                date: notice['date'] ?? '',
                                category: notice['category'] ?? '전체',
                              ),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        notice['title'] ?? '',
                                        style: const TextStyle(
                                          fontFamily: 'SpoqaHanSansNeo',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF4B7C76),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      notice['category'] ?? '',
                                      style: const TextStyle(
                                        fontFamily: 'SpoqaHanSansNeo',
                                        fontSize: 8,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF76B55C),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  notice['content'] ?? '',
                                  style: const TextStyle(
                                    fontFamily: 'SpoqaHanSansNeo',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF414B6A),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              notice['date'] ?? '',
                              style: const TextStyle(
                                fontFamily: 'SpoqaHanSansNeo',
                                fontSize: 8,
                                fontWeight: FontWeight.w200,
                                color: Color(0xFFADB5CA),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}