import 'package:flutter/material.dart';

class NoticeItem extends StatelessWidget {
  final String title;
  final String content;
  final String date;
  final String category;

  const NoticeItem({
    super.key,
    required this.title,
    required this.content,
    required this.date,
    required this.category,
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
      body: SingleChildScrollView(
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
              const SizedBox(height: 40),
              Text(
                content,
                style: const TextStyle(
                  fontFamily: 'SpoqaHanSansNeo',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 2.0,
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