import 'package:flutter/material.dart';

class NoticeItem extends StatelessWidget {
  final String title;
  final String content;
  final String date;
  final String category;

  const NoticeItem({
    super.key,
    this.title = '대전대학교 주차장 앱 LotBot 출시',
    this.content = '대전대학교 주차장 앱 LotBot 출시\n공지사항 내용 예시 줄바꿈입니다.\n여러 줄을 확인할 수 있습니다.',
    this.date = '2025.09.16 오후 12:45',
    this.category = '앱 공지',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '공지사항 상세',
          style: TextStyle(
            fontFamily: 'SpoqaHanSansNeo',
            fontWeight: FontWeight.w500,
            fontSize: 15,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: SingleChildScrollView( // ✅ 화면 전체 스크롤
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category,
                style: const TextStyle(
                  fontFamily: 'SpoqaHanSansNeo',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6BB54C),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'SpoqaHanSansNeo',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2F3644),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                date,
                style: const TextStyle(
                  fontFamily: 'SpoqaHanSansNeo',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFFADB5CA),
                ),
              ),
              const SizedBox(height: 40), // ✅ 날짜와 내용 사이 간격
              Text(
                content,
                style: const TextStyle(
                  fontFamily: 'SpoqaHanSansNeo',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 2.0, // ✅ 줄 간격 (기본 폰트크기 12 → 약 18px = 15 정도)
                  color: Color(0xFF1E1E1E),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}