import 'package:flutter/material.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '關於APP',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(15),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '「為愛AI陪伴」是一款專為長者設計的APP，提供個人數位助理、線上娛樂、生活資訊和健康照護等多項功能。'
                    '透過後台數據的擷取、整理、追蹤和分析，我們可以了解使用者的線上行為、生理和心理狀態的變化。'
                    '這些數據可以用來提供健康照護的參考數值，並且在偵測到異常時，我們可以提供及時的醫療介入措施。'
                    '我們致力於關懷長者，陪伴銀髮族，讓他們在使用APP的同時享受到更好的生活品質。',
                    style: TextStyle(fontSize: 24, height: 1.3),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}