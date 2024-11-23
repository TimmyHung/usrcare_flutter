import 'package:flutter/material.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '服務條款',
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
                children: [
                  Text(
                    "一、會員註冊條款",
                    style: TextStyle(
                      fontSize: 20,
                      height: 1.5,
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "當您完成註冊會員手續，代表您已閱讀、了解並同意接受本服務條款所有內容。",
                    style: TextStyle(fontSize: 20, height: 1.5),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "二、隱私權保護條款",
                    style: TextStyle(
                      fontSize: 20,
                      height: 1.5,
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '為保護用戶的隱私權，請您詳閱本APP隱私權條款，當您瞭解並同意後，'
                    '本APP可依據隱私權條款之規範進行您個人資料的蒐集及利用。',
                    style: TextStyle(fontSize: 20, height: 1.5),
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