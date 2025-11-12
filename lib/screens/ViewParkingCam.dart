import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // .env 파일 임포트

class ViewParkingCam extends StatefulWidget {
  final int initialBuildingIndex;

  const ViewParkingCam({super.key, this.initialBuildingIndex = 0});

  @override
  State<ViewParkingCam> createState() => _ViewParkingCamState();
}

class _ViewParkingCamState extends State<ViewParkingCam> {
  // --- 기존 데이터 (스타일 유지) ---
  late int selectedBuildingIndex;
  int selectedCameraIndex = 0;
  final List<String> buildings = ["융합과학관", "서문 잔디밭", "산학합력관"];
  final List<Map<String, int>> parkingData = [
    {"remain": 200, "total": 250, "cameras": 4},
    {"remain": 0, "total": 250, "cameras": 6},
    {"remain": 20, "total": 250, "cameras": 4},
  ];
  // --- 기존 데이터 끝 ---


  // --- 비디오 로직 변수 ---
  VideoPlayerController? _controller; // 비디오 플레이어 컨트롤러
  bool _isLoading = true; // 로딩 중 상태
  bool _hasError = false; // 에러 발생 상태

  // .env에서 HOST_ADDRESS (예: http://localhost:5000)를 가져옵니다.
  final String? _host = dotenv.env['HOST_ADDRESS'];

  // ★ (수정) ★
  // 비디오 URL 리스트를 'late final'로 선언합니다.
  late final List<List<String>> _videoUrls;

  @override
  void initState() {
    super.initState();
    selectedBuildingIndex = widget.initialBuildingIndex;

    // ★ (핵심 수정) ★
    // initState가 실행되는 시점에, .env에서 읽어온 _host 변수를 사용하여
    // 백엔드 서버(app.py)가 제공하는 비디오 URL로 리스트를 동적으로 생성합니다.
    _videoUrls = [
      // 1. 융합과학관 (카메라 4개)
      [
        '$_host/videos/1.mp4', // 융합관 1번 (lotbot_server/videos/1.mp4)
        '$_host/videos/2.mp4', // 융합관 2번 (2.mp4가 있다고 가정)
        '$_host/videos/3.mp4', // 융합관 3번
        '$_host/videos/4.mp4', // 융합관 4번
      ],
      // 2. 서문 잔디밭 (카메라 6개)
      [
        '$_host/videos/5.mp4', // 서문 1번
        '$_host/videos/6.mp4',
        '$_host/videos/7.mp4',
        '$_host/videos/8.mp4',
        '$_host/videos/9.mp4',
        '$_host/videos/10.mp4', // 서문 6번
      ],
      // 3. 산학합력관 (카메라 4개)
      [
        '$_host/videos/11.mp4', // 산학 1번
        '$_host/videos/12.mp4',
        '$_host/videos/13.mp4',
        '$_host/videos/14.mp4', // 산학 4번
      ],
    ];
    // ★ (수정 완료) ★


    // 0번 건물의 0번 카메라(즉, 1.mp4)를 초기 비디오로 로드합니다.
    _initializeVideoPlayer(selectedBuildingIndex, selectedCameraIndex);
  }

  // ★ 5. 비디오 플레이어 초기화/교체 핵심 로직
  // (이 함수는 _videoUrls 리스트를 사용하므로 수정할 필요가 없습니다.)
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
    if (buildingIdx >= _videoUrls.length || cameraIdx >= _videoUrls[buildingIdx].length) {
      print("비디오 URL 인덱스 오류");
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      return;
    }

    // 3. url 변수는 이제 'http://localhost:5000/videos/1.mp4' 같은
    //    올바른 *웹 URL*을 갖게 됩니다.
    final String url = _videoUrls[buildingIdx][cameraIdx];

    // 4. 새 컨트롤러 생성 및 초기화 시도
    try {
      // VideoPlayerController.networkUrl은 http://... URL을 사용합니다.
      _controller = VideoPlayerController.networkUrl(Uri.parse(url));
      await _controller!.initialize();
      await _controller!.play();
      await _controller!.setLooping(true); // 비디오 반복 재생

      // 5. 성공 시: 로딩 종료
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      // 6. 실패 시: 에러 상태로 변경 (대체 이미지 표시)
      //    (예: 1.mp4 파일이 서버에 없거나, app.py 서버가 꺼진 경우)
      print("비디오 로드 실패 (URL: $url): $error");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  // ★ 6. 위젯이 사라질 때 컨트롤러 리소스 해제 (수정 없음)
  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  // ★ (이하 build, _buildVideoContent, _buildTab, _getParkingColor 함수는) ★
  // ★ (스타일과 UI 로직이므로 단 한 줄도 수정할 필요가 없습니다.) ★
  // ★ (100% 원본 코드와 동일) ★

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
              child: Stack(
                children: [
                  Center(
                    child: _buildVideoContent(),
                  ),
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
                                    _initializeVideoPlayer(index, 0); // ★ 로직이 살아있는지 확인
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
                                          _initializeVideoPlayer(selectedBuildingIndex, index); // ★ 로직이 살아있는지 확인
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoContent() {
    if (_isLoading) {
      return const CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      );
    }
    if (_hasError || _controller == null || !_controller!.value.isInitialized) {
      return Image.asset(
        'assets/images/camera_error.png', // assets/images/에 대체 이미지가 있어야 합니다.
        width: 150,
        fit: BoxFit.contain,
      );
    }
    return AspectRatio(
      aspectRatio: _controller!.value.aspectRatio,
      child: VideoPlayer(_controller!),
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
      return const Color(0xFF757575);
    } else if (rate <= 0.3) {
      return const Color(0xFFCD0505);
    } else if (rate <= 0.5) {
      return const Color(0xFFD7D139);
    } else {
      return const Color(0xFF76B55C);
    }
  }
}