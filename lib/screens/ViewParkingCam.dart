// ViewParkingCam.dart
import 'package:flutter/material.dart';

class ViewParkingCam extends StatefulWidget {
  final int initialBuildingIndex; // ★ 외부에서 초기 건물 선택 가능

  const ViewParkingCam({super.key, this.initialBuildingIndex = 0});

  @override
  State<ViewParkingCam> createState() => _ViewParkingCamState();
}

class _ViewParkingCamState extends State<ViewParkingCam> {
  late int selectedBuildingIndex; // ★ 초기화는 initState에서
  int selectedCameraIndex = 0;

  final List<String> buildings = ["융합과학관", "서문 잔디밭", "산학합력관"];
  final List<Map<String, int>> parkingData = [
    {"remain": 200, "total": 250, "cameras": 4},
    {"remain": 0, "total": 250, "cameras": 6},
    {"remain": 20, "total": 250, "cameras": 4},
  ];

  @override
  void initState() {
    super.initState();
    selectedBuildingIndex = widget.initialBuildingIndex; // ★ 전달된 인덱스로 초기화
  }

  @override
  Widget build(BuildContext context) {
    final buttonWidth = MediaQuery.of(context).size.width * 0.92;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '주차칸 보기',
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
      body: Container(
        color: Colors.black,
        child: Column(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  width: buttonWidth,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.only(left: 18, top: 15, right: 20, bottom: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 상단 탭
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Row(
                          children: List.generate(buildings.length, (index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedBuildingIndex = index;
                                  selectedCameraIndex = 0;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 0),
                                child: _buildTab(
                                  buildings[index],
                                  selectedBuildingIndex == index,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),

                      // 위쪽 여백 → 잔여석을 세로 가운데로 내리기 위한 공간
                      const Expanded(child: SizedBox()),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: "주차 잔여석: ",
                                style: TextStyle(
                                  fontFamily: 'SpoqaHanSansNeo',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  color: Color(0xFF4B7C76),
                                ),
                              ),
                              TextSpan(
                                text: "${parkingData[selectedBuildingIndex]["remain"]}",
                                style: TextStyle(
                                  fontFamily: 'SpoqaHanSansNeo',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: _getParkingColor(
                                    parkingData[selectedBuildingIndex]["remain"]!,
                                    parkingData[selectedBuildingIndex]["total"]!,
                                  ),
                                ),
                              ),
                              TextSpan(
                                text: " / ${parkingData[selectedBuildingIndex]["total"]}",
                                style: const TextStyle(
                                  fontFamily: 'SpoqaHanSansNeo',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: Color(0xFF414B6A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // 아래쪽 여백 → 카메라 버튼을 맨 밑으로 내리기 위한 공간
                      const Expanded(child: SizedBox()),

                      // 카메라 버튼 (하단 고정)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: List.generate(
                              parkingData[selectedBuildingIndex]["cameras"]!,
                                  (index) {
                                return Container(
                                  width: 90,
                                  height: 35,
                                  margin: EdgeInsets.only(
                                      right: index < parkingData[selectedBuildingIndex]["cameras"]! - 1 ? 10 : 0),
                                  decoration: BoxDecoration(
                                    color: selectedCameraIndex == index
                                        ? const Color(0xFF8CCE71)
                                        : const Color(0xFFECF2E9),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedCameraIndex = index;
                                      });
                                    },
                                    child: Center(
                                      child: Text(
                                        "카메라 ${index + 1}",
                                        style: TextStyle(
                                          fontFamily: 'SpoqaHanSansNeo',
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          color: selectedCameraIndex == index
                                              ? Colors.white
                                              : const Color(0xFFB8C8B1),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, bool isActive) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'SpoqaHanSansNeo',
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w300,
            color: isActive ? const Color(0xFF38A48E) : const Color(0xFFADB5CA),
          ),
        ),
        const SizedBox(height: 10),
        // 항상 80 공간 확보, 색만 바꿔주기
        Container(
          width: 80,
          height: 1,
          color: isActive ? const Color(0xFF38A48E) : Colors.transparent,
        ),
      ],
    );
  }

  Color _getParkingColor(int remain, int total) {
    final double rate = total == 0 ? 0 : remain / total;

    if (rate == 0) {
      return const Color(0xFF757575); // 만차
    } else if (rate <= 0.3) {
      return const Color(0xFFCD0505); // 혼잡
    } else if (rate <= 0.5) {
      return const Color(0xFFD7D139); // 보통
    } else {
      return const Color(0xFF76B55C); // 여유
    }
  }
}