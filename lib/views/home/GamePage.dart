import 'package:flutter/material.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color.fromARGB(255,212,152,0), width: 3),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
            Image.asset("assets/HomePage_Icons/brain_game.png",  height: 50),
            const SizedBox(width: 10),
            const Text("動腦小遊戲")
          ],),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 35),
          onPressed: () {
            Navigator.pop(context); // 返回上一頁
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                height: 80,
                child: ElevatedButton(
                  onPressed: () {
                    // 這裡可以加上跳轉到 Unity 小遊戲的邏輯
                  },
                  child: const Text(
                    "Unity 小遊戲",
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(height: 20), // 按鈕之間的間距
              SizedBox(
                width: double.infinity,
                height: 80,
                child: ElevatedButton(
                  onPressed: () {
                    // 這裡可以加上跳轉到 Web 小遊戲的邏輯
                  },
                  child: const Text(
                    "Web 小遊戲",
                    style: TextStyle(fontSize: 24),
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
