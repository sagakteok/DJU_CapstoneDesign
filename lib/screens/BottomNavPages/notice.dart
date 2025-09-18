import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import '../NoticeItem.dart';

class Notice extends StatefulWidget {
  const Notice({super.key});

  @override
  State<Notice> createState() => _NoticeState();
}

class _NoticeState extends State<Notice> {
  String _selectedCategory = '전체';

  final List<Map<String, String>> _notices = [
    {
      'title': '대전대학교 주차장 앱 LotBot 출시',
      'content': '공지사항 내용 미리보기 텍스트입니다.',
      'date': '2025.09.16 오후 12:45',
      'category': '앱 공지',
    },
    {
      'title': '혜화문화관 주차장 폐쇄 안내',
      'content': '공지사항 내용 미리보기 텍스트입니다.',
      'date': '2025.09.16 오후 12:45',
      'category': '건물 공지',
    },
    {
      'title': '2025학년도 2학기 조기 종강 안내',
      'content': '공지사항 내용 미리보기 텍스트입니다.',
      'date': '2025.09.16 오후 12:45',
      'category': '학사 공지',
    },
  ];

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
            Navigator.pushReplacementNamed(context, '/home');
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
                        icon: const Icon(Icons.expand_more, color: Color(0xFFD6E1D1)),
                        style: const TextStyle(
                          fontFamily: 'SpoqaHanSansNeo',
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Color(0xFF6B907F),
                        ),
                        items: const [
                          DropdownMenuItem(value: '전체', child: Text('전체')),
                          DropdownMenuItem(value: '앱공지', child: Text('앱공지')),
                          DropdownMenuItem(value: '건물공지', child: Text('건물공지')),
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
            Column(
              children: _notices.map((notice) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.92,
                      height: 95,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            offset: const Offset(0, 3),
                            blurRadius: 7,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shadowColor: Colors.black.withOpacity(0.05),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.all(16),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/NoticeItem');
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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