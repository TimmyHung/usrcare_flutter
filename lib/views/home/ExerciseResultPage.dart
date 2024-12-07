import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:usrcare/api/APIService.dart';
import 'package:usrcare/utils/ColorUtil.dart';
import 'package:usrcare/utils/MiscUtil.dart';
import 'package:usrcare/utils/PermissionUtil.dart';
import 'package:usrcare/widgets/Dialog.dart';
import 'package:http/http.dart' as http;
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';


class VideoResult {
  final bool analyzed;
  final bool expired;
  final String expiryTime;
  final String uploadTime;
  final String? url;
  final String videoID;
  final double? score;

  VideoResult({
    required this.analyzed,
    required this.expired,
    required this.expiryTime,
    required this.uploadTime,
    this.url,
    required this.videoID,
    this.score,
  });

  factory VideoResult.fromJson(Map<String, dynamic> json) {
    return VideoResult(
      analyzed: json['analyzed'],
      expired: json['expired'],
      expiryTime: json['expiry_time'],
      uploadTime: json['upload_time'],
      url: json['url'],
      videoID: json['videoID'],
      score: json['score']?.toDouble(),
    );
  }
}


final borderColor = Color.fromARGB(255, 0, 107, 185);
class ExerciseResultPage extends StatefulWidget {
  final APIService apiService;
  const ExerciseResultPage({super.key,  required this.apiService});

  @override
  State<ExerciseResultPage> createState() => _ExerciseResultPageState();
}

class _ExerciseResultPageState extends State<ExerciseResultPage> with WidgetsBindingObserver{
  List<VideoResult>? _videos;
  bool _isLoading = true;
  final Map<String, ChewieController> _chewieControllers = {};
  final Set<String> _initializedVideos = {};

  @override
  void initState() {
    super.initState();
    PermissionUtil.initPermissionStatus([
      Permission.photos,
    ]);
    _asyncInit();
  }

  Future<void> _asyncInit() async {
    await _fetchVideoResults();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    PermissionUtil.handleAppLifecycleStateChange(state, context);
  }

  Future<void> _fetchVideoResults() async {
    setState(() {
      _isLoading = true;
    });
    
    final response = await widget.apiService.getVideoList(context);
    final x = handleHttpResponses(context, response, "無法取得影片列表");
    if (x == null){
      return;
    }

    final List<dynamic> data = x["list"];
    setState(() {
      _videos = data.map((e) => VideoResult.fromJson(e)).toList();
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _initializedVideos.clear();
    for (var controller in _chewieControllers.values) {
      controller.dispose();
    }
    super.dispose();
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
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                "assets/HomePage_Icons/sport.png",
                height: 50,
                width: 50,
                fit: BoxFit.cover,
              ),
              const Text("觀看成果",),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: borderColor,))
        : (_videos == null || _videos!.isEmpty || _videos!.every((video) => video.expired))
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.videocam_off,
                    size: 52,
                    color: Colors.black54,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "目前沒有上傳的影片",
                    style: TextStyle(fontSize: 28),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _videos!.where((video) => !video.expired).length,
              itemBuilder: (context, index) {
                final activeVideos = _videos!
                    .where((video) => !video.expired)
                    .toList()
                  ..sort((a, b) {
                    final dateA = DateTime.parse(a.uploadTime);
                    final dateB = DateTime.parse(b.uploadTime);
                    return dateB.compareTo(dateA);
                  });
                
                final video = activeVideos[index];
                
                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.black54, width: 0.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time, color: Colors.black),
                            const SizedBox(width: 4),
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "上傳時間：${video.uploadTime.replaceAll("T", " ").replaceAll("-", "/").substring(0,16)}",
                                  style: const TextStyle(
                                    fontSize: 24,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (video.url != null && video.analyzed)
                        ExerciseVideoWidget(url: video.url!)
                      else
                        Container(
                          height: 200,
                          color: Colors.grey[400],
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.movie_creation, size: 50),
                              ],
                            ),
                          ),
                        ),

                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!video.analyzed)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.orange),
                                ),
                                child: const Row(
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Flexible(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          "影片分析中...請稍後再查看",
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.orange,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else...[
                              if (video.analyzed) ...[
                                Builder(
                                  builder: (context) {
                                    final expiryTime = DateTime.parse(video.expiryTime);
                                    final now = DateTime.now();
                                    final difference = expiryTime.difference(now);
                                    
                                    final days = difference.inDays;
                                    final hours = difference.inHours.remainder(24);
                                    final minutes = difference.inMinutes.remainder(60);
                                    
                                    final timeText = days > 0 
                                        ? "$days天$hours小時$minutes分鐘"
                                        : "$hours小時$minutes分鐘";
                                    final isNearExpiry = difference.inHours < 24;
                                    
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isNearExpiry 
                                            ? Colors.red.withOpacity(0.1)
                                            : Colors.grey.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isNearExpiry ? Colors.red : Colors.grey,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.timer,
                                            size: 20,
                                            color: isNearExpiry ? Colors.red : Colors.black,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              "剩餘時間：$timeText",
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: isNearExpiry ? Colors.red : Colors.black,
                                                fontWeight: isNearExpiry ? FontWeight.bold : FontWeight.normal,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Expanded(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "活力指數：${video.score?.toStringAsFixed(2) ?? '不適用'}",
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    onPressed: () => PermissionUtil.checkAndRequestPermission(
                                      context,
                                      Permission.photos,
                                      '儲存空間',
                                      '為了讓您能下載影片，我們需要取得您的儲存空間權限。',
                                      () => _downloadVideo(context, video.url!, video.videoID),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: ColorUtil.primary,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    icon: const Icon(Icons.download, color: Colors.white, size: 24),
                                    label: const Text(
                                      "下載影片",
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ]
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Future<void> _downloadVideo(BuildContext context, String url, String videoId) async {
    try {
      BuildContext? dialogContext;
      double progress = 0;
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          dialogContext = context;
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.black54, width: 1),
                            ),
                            child: const Icon(
                              Icons.download_rounded,
                              color: Colors.black,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            "影片下載中",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Stack(
                        children: [
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          Container(
                            height: 8,
                            width: MediaQuery.of(context).size.width * progress,
                            decoration: BoxDecoration(
                              color: ColorUtil.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "${(progress * 100).toStringAsFixed(1)}%",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );


      final client = http.Client();
      final request = http.Request('GET', Uri.parse(url));
      final response = await client.send(request);
      final contentLength = response.contentLength ?? 0;
      int receivedBytes = 0;

      final dir = await getApplicationDocumentsDirectory();
      final file_path = '${dir.path}/$videoId.mp4';
      final file = File(file_path);
      final sink = file.openWrite();

      await for (final bytes in response.stream) {
        receivedBytes += bytes.length;
        sink.add(bytes);
        
        if (dialogContext != null && context.mounted) {
          progress = contentLength > 0 ? receivedBytes / contentLength : 0;
          (dialogContext! as Element).markNeedsBuild();
        }
      }

      await sink.close();
      client.close();

      await Gal.putVideo(file_path);

      if (await file.exists()) {
        await file.delete();
      }
      
      if (context.mounted && dialogContext != null) {
        Navigator.pop(dialogContext!);
        showCustomDialog(
          context,
          "下載成功",
          "影片已成功儲存至您的裝置",
          closeButton: true,
        );
      }

    } catch (e) {
      print("下載影片失敗: $e");
      if (context.mounted) {
        Navigator.pop(context);
        showCustomDialog(
          context,
          "下載失敗",
          "請稍後再試",
          closeButton: true,
        );
      }
    }
  }
}

class ExerciseVideoWidget extends StatefulWidget {
  final String url;
  const ExerciseVideoWidget({super.key, required this.url});

  @override
  State<ExerciseVideoWidget> createState() => _ExerciseVideoWidgetState();
}

class _ExerciseVideoWidgetState extends State<ExerciseVideoWidget> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isInitialized = false;
  bool _isLoadingThumbnail = false;
  Image? thumbnail;
  static final Map<String, Image> _thumbnailCache = {};

  @override
  void initState() {
    super.initState();
    _loadThumbnailWithCache();
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _loadThumbnailWithCache() async {
    if (_thumbnailCache.containsKey(widget.url)) {
      setState(() {
        thumbnail = _thumbnailCache[widget.url];
      });
      return;
    }

    if (_isLoadingThumbnail) return;
    _isLoadingThumbnail = true;

    try {
      final tempDir = await getTemporaryDirectory();
      final thumbnailFile = await VideoThumbnail.thumbnailFile(
        video: widget.url,
        thumbnailPath: tempDir.path,
        imageFormat: ImageFormat.PNG,
        maxHeight: 540,
        quality: 75,
      );

      if (mounted) {
        final thumbnailImage = Image.file(File(thumbnailFile.path));
        _thumbnailCache[widget.url] = thumbnailImage;
        setState(() {
          thumbnail = thumbnailImage;
        });
      }
    } catch (e) {
      print('縮圖載入錯誤: $e');
    } finally {
      _isLoadingThumbnail = false;
    }
  }

  Future<void> _initializeVideo() async {
    try {
      final videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.url)
      );
      await videoController.initialize();
      
      final chewieController = ChewieController(
        videoPlayerController: videoController,
        autoPlay: false,
        looping: false,
        aspectRatio: videoController.value.aspectRatio,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Colors.red, size: 30),
                SizedBox(height: 8),
                Text('影片載入失敗: $errorMessage'),
              ],
            ),
          );
        },
      );
      
      setState(() {
        _videoController = videoController;
        _chewieController = chewieController;
        _isInitialized = true;
      });
    } catch (e) {
      print('影片初始化錯誤: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialized && _chewieController != null) {
      return Container(
        height: 250,
        child: Chewie(
          controller: _chewieController!,
        ),
      );
    }

    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border.symmetric(horizontal: BorderSide(color: Colors.grey[400]!, width: 1)),
      ),
      child: GestureDetector(
        onTap: _initializeVideo,
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              thumbnail ?? Container(color: Colors.grey[400],),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                  if (thumbnail == null)...[
                    const SizedBox(height: 16),
                    const Text("縮圖載入中", style: TextStyle(fontSize: 28, color: Colors.black87, fontWeight: FontWeight.w500))
                  ]
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
