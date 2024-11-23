import 'package:flutter/material.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:usrcare/api/APIService.dart';
import 'package:usrcare/utils/ColorUtil.dart';
import 'package:usrcare/utils/MiscUtil.dart';
import 'package:usrcare/views/home/ExerciseResultPage.dart';
import 'package:usrcare/widgets/Dialog.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'dart:async';
import 'package:usrcare/utils/SharedPreference.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:usrcare/utils/PermissionUtil.dart';

final borderColor = const Color.fromARGB(255, 0, 107, 185);


class ExercisePage extends StatefulWidget {
  const ExercisePage({super.key});

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> with WidgetsBindingObserver {
  late APIService _apiService;
  final SharedPreferencesService _prefsService = SharedPreferencesService();
  
  final List<Map<String, String>> videoList = [
    {
      "title": "一、健康操完整版",
      "url": "https://www.youtube.com/watch?v=_w50TfdCmKU"
    },
    {
      "title": "二、健康操台語精簡版",
      "url": "https://www.youtube.com/watch?v=VEAqBmJHbIw"
    },
    {
      "title": "三、居家自主健康操",
      "url": "https://www.youtube.com/watch?v=slZgx4uGa7Y"
    },
  ];
  
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    PermissionUtil.initPermissionStatus([
      Permission.camera,
      Permission.photos,
    ]);
    _asyncInit();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    PermissionUtil.handleAppLifecycleStateChange(state, context);
  }

  Future<void> _asyncInit() async {
    final token = await SharedPreferencesService().getData(StorageKeys.userToken);
    _apiService = APIService(token: token);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // 檢查相機權限
  void _onCameraButtonPressed() {
    PermissionUtil.checkAndRequestPermission(
      context,
      Permission.camera,
      '相機',
      '為了讓您能使用運動攝影功能，我們需要取得您的相機權限。',
      () => _showRecordingNotice(),
    );
  }

  // 檢查相簿權限
  void _onGalleryButtonPressed() {
    PermissionUtil.checkAndRequestPermission(
      context,
      Permission.photos,
      '相簿',
      '為了讓您能選擇影片上傳，我們需要取得您的相簿權限。',
      () => _pickAndUploadVideo(),
    );
  }

  // 開始錄影
  Future<void> _startRecording() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 3),
      );

      if (video != null) {
        await _handleVideo(video);
      }
    } catch (e) {
      if (mounted) {
        showCustomDialog(
          context,
          "錄影時發生錯誤",
          "請確認相機是否可以正常開啟！",
          closeButton: true,
        );
      }
    }
  }

  // 選擇相簿影片
  Future<void> _pickAndUploadVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 3),
      );

      if (video != null) {
        await _handleVideo(video);
      }
    } catch (e) {
      if (mounted) {
        showCustomDialog(
          context,
          "錯誤",
          "上傳影片時發生錯誤",
          closeButton: true,
        );
      }
    }
  }

  // 處理錄製的影片或選擇的影片
  Future<void> _handleVideo(XFile video) async {
    Uint8List? uint8list;
    try {
      uint8list = await VideoThumbnail.thumbnailData(
        video: video.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 1024,
        quality: 30,
      );
    } catch (e) {
      print('生成縮圖失: $e');
    }

    if (!mounted) return;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "確認上傳",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (context) => _buildVideoPreviewPage(video.path),
                  ),
                );
              },
              child: Container(
                width: double.maxFinite,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (uint8list != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          uint8list,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      )
                    else
                      const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.movie,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text(
                            "影片無法顯示預覽",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    if (uint8list != null)
                      const Icon(
                        Icons.play_circle_outline,
                        color: Colors.white,
                        size: 64,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "確定要上傳這部影片嗎?",
              style: TextStyle(fontSize: 22),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              "取消",
              style: TextStyle(fontSize: 20),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "確定上傳",
              style: TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final videoBytes = await video.readAsBytes();
    final response = await _apiService.uploadVideo(videoBytes, context);
    final x = handleHttpResponses(context, response, "上傳影片失敗");
    if (x == null) return;
    
    showCustomDialog(
      context,
      "影片上傳成功",
      "分析完成後我們會發送通知給您，屆時再請您回來查看結果！",
      closeButton: true,
    );
  }

  // 顯示運動攝影使用說明
  Future<void> _showRecordingNotice() async {
    final hideNotice = await _prefsService.getData(StorageKeys.hideExerciseRecordingNotice);
    if (hideNotice == 'true') {
      _startRecording();
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool doNotShowAgain = false;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            '運動攝影使用說明',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '感謝您使用運動攝影功能，攝影時長最多為『3分鐘』，攝影完畢後我們會將影片進行分析，分析完畢後會提醒您回來查看結果。',
                    style: TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Transform.scale(
                        scale: 1.3,
                        child: Checkbox(
                          value: doNotShowAgain,
                          onChanged: (bool? value) {
                            setState(() {
                              doNotShowAgain = value ?? false;
                            });
                          },
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            doNotShowAgain = !doNotShowAgain;
                          });
                        },
                        child: const Text(
                          '不再顯示',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, right: 8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorUtil.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  if (doNotShowAgain) {
                    await _prefsService.saveData(
                      StorageKeys.hideExerciseRecordingNotice,
                      'true'
                    );
                  }
                  Navigator.of(context).pop();
                  _startRecording();
                },
                child: const Text(
                  '我知道了',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // 播放Youtube影片
  Future<void> _playYoutubeVideo(String url) async {
    final videoId = url.split('watch?v=').last;
    final youtubePlayerController = YoutubePlayerController.fromVideoId(
      autoPlay: true,
      videoId: videoId,
      params: const YoutubePlayerParams(
        showControls: true,
        strictRelatedVideos: true,
        loop: true,
        enableCaption: false
      ),
    );

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    if (mounted) {

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => StatefulBuilder(
            builder: (context, setState) {
              return Stack(
                children: [
                  Scaffold(
                    backgroundColor: Colors.black,
                    extendBodyBehindAppBar: true,
                    appBar: AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      leading: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.black),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),
                    body: OrientationBuilder(
                      builder: (context, orientation) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: orientation == Orientation.landscape 
                                ? MediaQuery.of(context).size.height
                                : MediaQuery.of(context).size.width * 9 / 16,
                              child: YoutubePlayer(
                                controller: youtubePlayerController,
                                aspectRatio: 16 / 9,
                              ),
                            ),
                            if (orientation == Orientation.portrait)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    "橫向擺放即可全螢幕播放觀看影片",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      }
                    ),
                  ),
                ],
              );
            },
          ),
          fullscreenDialog: true,
        ),
      );
    }

    await youtubePlayerController.close();
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 241, 249, 255),
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: borderColor, width: 3),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                clipBehavior: Clip.hardEdge,
                child: Image.asset(
                  "assets/HomePage_Icons/sport.png",
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                ),
              ),
              const Text("愛來運動")
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: const Color.fromARGB(255, 64, 146, 206),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        onPressed: _onCameraButtonPressed,
                        icon: Icons.videocam,
                        label: "運動攝影",
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 40,
                      color: const Color.fromARGB(255, 64, 146, 206),
                    ),
                    Expanded(
                      child: _buildActionButton(
                        onPressed: _onGalleryButtonPressed,
                        icon: Icons.upload_file,
                        label: "上傳影片",
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 40,
                      color: const Color.fromARGB(255, 64, 146, 206),
                    ),
                    Expanded(
                      child: _buildActionButton(
                        onPressed: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ExerciseResultPage(apiService: _apiService),
                          ),
                        );
                        },
                        icon: Icons.visibility,
                        label: "觀看成果",
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: videoList.length,
                  itemBuilder: (context, index) {
                    final video = videoList[index];
                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(
                          color: Colors.black,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              video["title"]!,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ClipRRect(
                            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
                            child: _buildYoutubePlayer(video["url"]!),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 使用者上傳或選擇畫面的預覽影片頁面
  Widget _buildVideoPreviewPage(String videoPath) {
    return FutureBuilder<VideoPlayerController>(
      future: VideoPlayerController.file(File(videoPath)).initialize().then((value) {
        final controller = VideoPlayerController.file(File(videoPath));
        return controller.initialize().then((_) => controller);
      }),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done || 
            snapshot.data == null) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        final videoPlayerController = snapshot.data!;
        final chewieController = ChewieController(
          videoPlayerController: videoPlayerController,
          autoPlay: true,
          looping: false,
          aspectRatio: videoPlayerController.value.aspectRatio,
          autoInitialize: true,
          showControls: true,
          allowFullScreen: true,
          allowMuting: true,
          deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
          deviceOrientationsOnEnterFullScreen: [
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ],
        );

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                videoPlayerController.dispose();
                chewieController.dispose();
                Navigator.of(context).pop();
              },
            ),
          ),
          body: SafeArea(
            child: Center(
              child: AspectRatio(
                aspectRatio: videoPlayerController.value.aspectRatio,
                child: Chewie(
                  controller: chewieController,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // 使用者點擊三個基礎運動教學影片
  Widget _buildYoutubePlayer(String url, {bool showControls = true}) {
    try {
      final videoId = url.split('watch?v=').last;
      final thumbnailUrl = 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';

      return GestureDetector(
        onTap: () => _playYoutubeVideo(url),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(thumbnailUrl),
              fit: BoxFit.cover,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      print('Error: $e');
      return const Text('無法載入影縮圖', style: TextStyle(fontSize: 12));
    }
  }

  // 運動攝影、上傳影片、觀看成果按鈕
  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.blue,
            size: 32,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
