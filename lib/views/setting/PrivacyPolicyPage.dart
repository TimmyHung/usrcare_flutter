import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '隱私政策',
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
                borderRadius: BorderRadius.circular(10),
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
                    '歡迎您使用本「為愛AI陪伴」APP（以下簡稱本APP），為了使您能夠安心使用本APP各項服務與資訊，特此向您說明本APP的隱私權保護政策，以保障您的權益，請您詳閱下列內容：',
                    style: TextStyle(fontSize: 20, height: 1.5),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "一、個人資料的蒐集、處理及利用方式",
                    style: TextStyle(
                      fontSize: 20,
                      height: 1.5,
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '● 當您使用本APP時，我們會視不同服務功能，請您提供必要的個人資料，並在該特定目的範圍內處理及利用您的個人資料；非經您書面同意，'
                    '本APP絕不會將您的個人資料用於其他用途。\n'
                    '● 我們會將蒐集的問卷調查內容進行統計及分析，分析的數據或說明文字呈現，均不涉及特定個人之資料。',
                    style: TextStyle(fontSize: 20, height: 1.5),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "二、資料之保護",
                    style: TextStyle(
                      fontSize: 20,
                      height: 1.5,
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '● 您的個人資料採用嚴格的保護措施，只有經過授權的人員才能接觸。',
                    style: TextStyle(fontSize: 20, height: 1.5),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "三、與第三人共用個人資料之政策",
                    style: TextStyle(
                      fontSize: 20,
                      height: 1.5,
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '● 本APP絕不會提供、出售您的個人資料給其他個人、企業或公務機關，除非已獲得您的書面同意。',
                    style: TextStyle(fontSize: 20, height: 1.5),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "四、隱私權保護政策之修正",
                    style: TextStyle(
                      fontSize: 20,
                      height: 1.5,
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '● 本隱私權保護政策將因應需求來修正，修正後條款將刊登於此。',
                    style: TextStyle(fontSize: 22, height: 1.5),
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