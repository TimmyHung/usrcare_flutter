import 'package:flutter/material.dart';

class FAQPage extends StatefulWidget {
  const FAQPage({super.key});

  @override
  _FAQPageState createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  final List<Map<String, String>> _faqs = [
    {"question": "收不到通知怎麼辦？", "answer": "您可以到手機的設定介面開啟愛為AI夥伴應用程式通知。"},
    {"question": "簽簽樂是什麼功能？", "answer": "「簽簽樂」可以讓長者每天簽到，記錄自己的心情，並賺取代幣兌換獎勵，進一步鼓勵長者主動關注自己的情緒。"},
    {"question": "每日任務是什麼功能？", "answer": "「每日任務」設計了多個任務，鼓勵長者頻繁使用APP，完成任務可以獲得額外的代幣，提升參與度和使用頻率。"},
    {"question": "動腦小遊戲是什麼功能？", "answer": "「動腦小遊戲」專為長者設計的遊戲，可以娛樂同時訓練認知能力、記憶力和思考能力，通過遊戲關卡，長者可以賺取更多代幣，增加挑戰性和趣味性。"},
    {"question": "寵物陪伴是什麼功能？", "answer": "「寵物陪伴」可以讓長者在APP上與虛擬寵物互動，獲得滿足感與情感陪伴。"},
    {"question": "愛來運動是什麼功能？", "answer": "「愛來運動」讓長者多參與運動，有助於增強身心健康、提升心理幸福感，並促進社交互動。"},
    {"question": "鬧鐘小提醒是什麼功能？", "answer": "「鬧鐘小提醒」是APP內的小幫手，提供用藥、活動、喝水、睡眠提醒等功能，幫助長者規律生活，注意每日重要事項。"},
    // {"question": "好物雜貨舖是什麼功能？", "answer": "待補上"},
    {"question": "心情量表是什麼功能？", "answer": "「心情量表」將醫師推薦的專業量表轉化成小測驗，讓長者更深入了解自己的心理和身體狀態，進而提供更好的心理健康管理。"},
  ];

  void _showAnswerDialog(String question, String answer) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(question, style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold, fontSize: 24)),
          content: Text(answer, style: const TextStyle(fontSize: 22),),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
                  child: Text("關閉", style: TextStyle(fontSize: 20, color: Colors.black)),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('常見問題', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: ListView.builder(
          itemCount: _faqs.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(_faqs[index]['question']!, style: const TextStyle(fontSize: 24)),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    _showAnswerDialog(_faqs[index]['question']!, _faqs[index]['answer']!);
                  },
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
}

}
