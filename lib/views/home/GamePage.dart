import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:usrcare/api/APIService.dart';
import 'package:usrcare/utils/MiscUtil.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GamePage extends StatefulWidget {
  final APIService apiService;
  const GamePage({super.key, required this.apiService});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'FlutterInterface',
        onMessageReceived: (JavaScriptMessage message) async {
          String dataFromWeb = message.message;
          // print('接收到的遊戲數據: $dataFromWeb');
          final response = await widget.apiService.postGameRecord_WebBased(json.decode(dataFromWeb), context);
          handleHttpResponses(context, response, "上傳遊戲資料時發生錯誤");
        },
      );
    
    // 對於 Android 設備，允許混合內容模式以確保可以加載本地文件
    if (Platform.isAndroid) {
      _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    }
  }

  void _loadGame(String gamePath) {
    String encodedGamePath = Uri.encodeFull(gamePath);
    _controller.loadFlutterAsset(encodedGamePath);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebGameScreen(controller: _controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withAlpha(250),
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color.fromARGB(255, 212, 152, 0), width: 3),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                clipBehavior: Clip.hardEdge,
                child: Image.asset(
                  "assets/HomePage_Icons/brain_game.png",
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                ),
              ),
              const Text("動腦小遊戲")
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () => _loadGame('assets/Web_Game/WhackMoleGame/index.html'),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color.fromARGB(255, 212, 152, 0), width: 3),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  width: double.infinity,
                  height: 80,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("assets/Web_Game/WhackMoleGame/icon.png", height: 50),
                      const SizedBox(width: 15),
                      const Text(
                        "打地鼠     ",
                        style: TextStyle(fontSize: 30),
                        textAlign: TextAlign.start,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () => _loadGame('assets/Web_Game/SudokuGame/index.html'),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color.fromARGB(255, 212, 152, 0), width: 3),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  width: double.infinity,
                  height: 80,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("assets/Web_Game/SudokuGame/icon.png", height: 50),
                      const SizedBox(width: 15),
                      const Text(
                        "數獨        ",
                        style: TextStyle(fontSize: 30),
                        textAlign: TextAlign.start,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () => _loadGame('assets/Web_Game/NumberGuessGame/index.html'),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color.fromARGB(255, 212, 152, 0), width: 3),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  width: double.infinity,
                  height: 80,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("assets/Web_Game/NumberGuessGame/icon.png", height: 50),
                      const SizedBox(width: 15),
                      const Text(
                        "猜數字    ",
                        style: TextStyle(fontSize: 30),
                        textAlign: TextAlign.start,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () => _loadGame('assets/Web_Game/MemoryCardGame/index.html'),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color.fromARGB(255, 212, 152, 0), width: 3),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  width: double.infinity,
                  height: 80,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("assets/Web_Game/MemoryCardGame/icon.png", height: 50),
                      const SizedBox(width: 15),
                      const Text(
                        "翻牌記憶",
                        style: TextStyle(fontSize: 30),
                        textAlign: TextAlign.start,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),


    );
  }
}

class WebGameScreen extends StatelessWidget {
  final WebViewController controller;

  const WebGameScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color.fromARGB(255, 212, 152, 0), width: 3),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                clipBehavior: Clip.hardEdge,
                child: Image.asset(
                  "assets/HomePage_Icons/brain_game.png",
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                ),
              ),
              const Text("動腦小遊戲")
            ],
          ),
        ),
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}
