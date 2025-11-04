// ★ 1. video_player 패키지 임포트
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

class ViewParkingCam extends StatefulWidget {
  final int initialBuildingIndex;

  const ViewParkingCam({super.key, this.initialBuildingIndex = 0});

  @override
  State<ViewParkingCam> createState() => _ViewParkingCamState();
}

class _ViewParkingCamState extends State<ViewParkingCam> {
  late int selectedBuildingIndex;
  int selectedCameraIndex = 0;

  // --- 기존 데이터 (스타일 유지) ---
  final List<String> buildings = ["융합과학관", "서문 잔디밭", "산학합력관"];
  final List<Map<String, int>> parkingData = [
    {"remain": 200, "total": 250, "cameras": 4},
    {"remain": 0, "total": 250, "cameras": 6},
    {"remain": 20, "total": 250, "cameras": 4},
  ];
  // --- 기존 데이터 끝 ---


  // ★ 2. 비디오 로직을 위한 상태 변수 추가
  VideoPlayerController? _controller; // 여러 비디오를 교체해야 하므로 nullable(?)로 선언
  bool _isLoading = true; // 비디오 로딩 중 상태
  bool _hasError = false; // 비디오 에러 상태

  // ★ 3. 실제 비디오 URL 데이터 구조 (매우 중요)
  // parkingData의 건물/카메라 개수와 순서가 정확히 일치해야 합니다.
  // (현재는 테스트용 URL을 사용. 실제 CCTV 스트림 URL로 교체해야 함)
  final List<List<String>> _videoUrls = [
    // 1. 융합과학관 (카메라 4개)
    [
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4', // 카메라 1
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4', // 카메라 2
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4', // 카메라 3
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4', // 카메라 4
    ],
    // 2. 서문 잔디밭 (카메라 6개)
    [
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4', // 카메라 1
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4', // ...
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4', // 카메라 6
    ],
    // 3. 산학합력관 (카메라 4개)
    [
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4', // 카메라 1
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4', // 카메라 2
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4', // 카메라 3
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4', // 카메라 4
    ],
  ];


  @override
  void initState() {
    super.initState();
    selectedBuildingIndex = widget.initialBuildingIndex;

    // ★ 4. 초기 비디오 로드 (첫 번째 건물, 첫 번째 카메라)
    _initializeVideoPlayer(selectedBuildingIndex, selectedCameraIndex);
  }

  // ★ 5. 비디오 플레이어 초기화/교체 핵심 로직
  Future<void> _initializeVideoPlayer(int buildingIdx, int cameraIdx) async {
    // 0. 로딩 상태로 즉시 변경 (UI 스피너 표시)
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    // 1. 기존 컨트롤러가 있으면 반드시 dispose (메모리 해제)
    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
    }

    // 2. _videoUrls에서 새 URL 가져오기
    //    (데이터 구조가 비어있거나 인덱스가 안 맞을 경우를 대비한 방어 코드)
    if (buildingIdx >= _videoUrls.length || cameraIdx >= _videoUrls[buildingIdx].length) {
      print("비디오 URL 인덱스 오류");
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      return;
    }
    final String url = _videoUrls[buildingIdx][cameraIdx];

    // 3. 새 컨트롤러 생성 및 초기화 시도
    try {
      _controller = VideoPlayerController.networkUrl(Uri.parse(url));
      await _controller!.initialize();
      await _controller!.play();
      await _controller!.setLooping(true); // CCTV처럼 계속 반복

      // 4. 성공 시: 로딩 종료
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      // 5. 실패 시: 에러 상태로 변경 (대체 이미지 표시)
      print("비디오 로드 실패 (URL: $url): $error");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  // ★ 6. 위젯이 사라질 때 컨트롤러 리소스 해제
  @override
  void dispose() {
    _controller?.dispose(); // nullable이므로 ?. 사용
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // --- 기존 스타일 코드 (변경 없음) ---
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
      // --- 기존 스타일 코드 끝 ---

      body: Container(
        color: Colors.black,
        child: Column(
          children: [
            // ★ 7. Stack으로 변경 (비디오/컨트롤러 겹치기)
            Expanded(
              child: Stack( // 기존 Align -> Stack으로 변경
                children: [

                  // ★ 7-1. (배경) 비디오 플레이어 영역
                  Center(
                    child: _buildVideoContent(),
                  ),

                  // ★ 7-2. (전경) 기존 하단 컨트롤러 UI (코드 변경 없음)
                  Align(
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
                                    // --- 기존 로직 (변경 없음) ---
                                    setState(() {
                                      selectedBuildingIndex = index;
                                      selectedCameraIndex = 0; // 건물 바꾸면 1번 카메라로 리셋
                                    });
                                    // --- 기존 로직 끝 ---

                                    // ★ 8. 빌딩 탭 클릭 시 비디오 교체
                                    _initializeVideoPlayer(index, 0);
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

                          // --- (중간 RichText 등) 기존 스타일 코드 (변경 없음) ---
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
                          const Expanded(child: SizedBox()),
                          // --- 기존 스타일 코드 끝 ---


                          // 카메라 버튼 (하단 고정)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: List.generate(
                                  parkingData[selectedBuildingIndex]["cameras"]!,
                                      (index) {
                                    // --- 기존 스타일 코드 (변경 없음) ---
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
                                      // --- 기존 스타일 코드 끝 ---
                                      child: GestureDetector(
                                        onTap: () {
                                          // --- 기존 로직 (변경 없음) ---
                                          setState(() {
                                            selectedCameraIndex = index;
                                          });
                                          // --- 기존 로직 끝 ---

                                          // ★ 9. 카메라 버튼 클릭 시 비디오 교체
                                          _initializeVideoPlayer(selectedBuildingIndex, index);
                                        },
                                        // --- 나머지 스타일 코드 (변경 없음) ---
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
                                        // --- 스타일 코드 끝 ---
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ★ 10. (신규) 비디오/로더/대체 이미지를 상태에 따라 표시하는 헬퍼
  Widget _buildVideoContent() {
    // 10-1. 로딩 중일 때
    if (_isLoading) {
      return const CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white), // 로딩 스피너 흰색
      );
    }

    // 10-2. 에러가 발생했거나, 컨트롤러가 준비되지 않았을 때
    if (_hasError || _controller == null || !_controller!.value.isInitialized) {
      // 'camera_error.png'는 assets/images/ 폴더에 있는 X 표시 이미지 파일명입니다.
      return Image.asset(
        'assets/images/camera_error.png',
        width: 150, // 대체 이미지 크기 (스타일이긴 하지만... 기능상 필요)
        fit: BoxFit.contain,
      );
    } 

    // 10-3. 비디오 로딩 성공
    // 비디오의 원본 비율을 유지하며 화면에 맞게 조절합니다.
    return AspectRatio(
      aspectRatio: _controller!.value.aspectRatio,
      child: VideoPlayer(_controller!),
    );
  }


  // --- (이하) 기존 헬퍼 함수 (스타일 코드이므로 변경 없음) ---
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