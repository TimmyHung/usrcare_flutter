import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:usrcare/api/APIService.dart';
import 'package:usrcare/utils/MiscUtil.dart';
import 'package:usrcare/utils/SharedPreference.dart';

class MoodPage extends StatefulWidget {
  const MoodPage({super.key});

  @override
  State<MoodPage> createState() => _MoodPageState();
}

class _MoodPageState extends State<MoodPage> {
  bool isLoading = false;

  Future<Map<String, dynamic>> _loadQuestions(int listID) async {
    setState(() {
      isLoading = true;
    });

    final loadedToken = await SharedPreferencesService().getData(StorageKeys.userToken) ?? "Null";
    final APIService apiService = APIService(token: loadedToken);
    final response = await apiService.getMentalRecord(listID);
    var x = handleHttpResponses(context, response, "無法取得心情量表題目(ID: $listID)");

    setState(() {
      isLoading = false;
    });

    if (x == null) {
      return {};
    } else {
      return x;
    }
  }

  void _navigateToQuestionPage(int listID, String title) async {
    if (isLoading) return;
    var data = await _loadQuestions(listID);
    if (data.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuestionPage(
            title: title,
            questions: data['questions'],
            listID: listID
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 252, 202, 229),
      appBar: AppBar(
        centerTitle: true,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color.fromARGB(255, 202, 0, 109), width: 3),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset("assets/HomePage_Icons/mood.png", height: 50),
              const Text("心情量表")
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
                onTap: () => _navigateToQuestionPage(0, 'AD8 認知功能評估表'),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color.fromARGB(255, 202, 0, 109), width: 3),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  width: double.infinity,
                  height: 80,
                  child: const Center(
                    child: Text(
                      "AD8 認知功能評估表",
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () => _navigateToQuestionPage(1, '寂寞量表'),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color.fromARGB(255, 202, 0, 109), width: 3),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  width: double.infinity,
                  height: 80,
                  child: const Center(
                    child: Text(
                      "寂寞量表",
                      style: TextStyle(fontSize: 24),
                    ),
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

class QuestionPage extends StatefulWidget {
  final String title;
  final List<dynamic> questions;
  final int listID;

  const QuestionPage({super.key, required this.title, required this.questions, required this.listID});

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  int currentQuestionIndex = 0;
  List<int?> answers = [];
  DateTime? startTime;

  @override
  void initState() {
    super.initState();
    answers = List<int?>.filled(widget.questions.length, null);
    startTime = DateTime.now();
  }

  Future<void> _submitAnswers() async {
    final loadedToken = await SharedPreferencesService().getData(StorageKeys.userToken) ?? "Null";
    final APIService apiService = APIService(token: loadedToken);
    DateTime endTime = DateTime.now();
    List<String> answerStrings = answers.map((answer) => answer.toString()).toList();

    Map<String, dynamic> record = {
      "answer": answerStrings,
      "start_time": startTime!.toIso8601String(),
      "end_time": endTime.toIso8601String(),
    };

    final response = await apiService.submitMentalRecord(widget.listID, record);
    var x = handleHttpResponses(context, response, "無法提交心情量表結果");
    if(x == null){
      return;
    }
    bool consultation = x['consultation'];
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ResultPage(consultation: consultation)),
    );

  }


  Future<void> _showExitConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.logout, color: Colors.orange, size: 35),
              SizedBox(width: 10),
              Text('確定要離開嗎？', style: TextStyle(fontSize: 30)),
            ],
          ),
          content: const Text('離開後將不會儲存此次填答結果'),
          actions: <Widget>[
            TextButton(
              child: const Text('取消', style: TextStyle(fontSize: 30)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('確定', style: TextStyle(fontSize: 30)),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var currentQuestion = widget.questions[currentQuestionIndex];
    var options = currentQuestion['ans'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 24),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _showExitConfirmationDialog();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              currentQuestion['ques'],
              style: const TextStyle(fontSize: 25),
            ),
            const Spacer(),
            Row(
              children: options.map<Widget>((option) {
                int optionIndex = options.indexOf(option);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: OptionButton(
                      label: option.toString(),
                      isSelected: answers[currentQuestionIndex] == optionIndex + 1,
                      onTap: () {
                        setState(() {
                          answers[currentQuestionIndex] = option;
                        });
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: currentQuestionIndex > 0 ? MainAxisAlignment.spaceBetween : MainAxisAlignment.end,
              children: [
                if (currentQuestionIndex > 0)
                  FloatingActionButton(
                    backgroundColor: Colors.orange,
                    heroTag: 'prev',
                    onPressed: currentQuestionIndex > 0
                        ? () {
                            setState(() {
                              currentQuestionIndex--;
                            });
                          }
                        : null,
                    child: const Icon(Icons.arrow_back),
                  ),
                FloatingActionButton(
                  backgroundColor: answers[currentQuestionIndex] != null ? Colors.orange : Colors.grey,
                  heroTag: 'next',
                  onPressed: answers[currentQuestionIndex] != null
                      ? () {
                          if (currentQuestionIndex < widget.questions.length - 1) {
                            setState(() {
                              currentQuestionIndex++;
                            });
                          } else {
                            _submitAnswers();
                          }
                      }
                      : null,
                  child: currentQuestionIndex < widget.questions.length - 1
                      ? const Icon(Icons.arrow_forward)
                      : const Text("提交", style: TextStyle(fontSize: 20)),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class OptionButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const OptionButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 228, 225),
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: Colors.orange, width: 3)
              : Border.all(color: Colors.transparent, width: 3),
        ),
        padding: const EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(fontSize: 25),
        ),
      ),
    );
  }
}


class ResultPage extends StatelessWidget {
  final bool consultation;
  const ResultPage({super.key, required this.consultation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color.fromARGB(255, 202, 0, 109), width: 3),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset("assets/HomePage_Icons/mood.png", height: 50),
              const Text("心情量表")
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 80),
                    SizedBox(width: 10),
                    Text(
                      "已完成",
                      style: TextStyle(fontSize: 40),
                    ),
                  ],
                ),
                const SizedBox(height: 40),  // 調整與標題的間距
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("親愛的朋友，"),
                    const SizedBox(height: 15),
                    const Text("感謝您完成心情量表，希望一同維護您的健康和幸福。"),
                    const SizedBox(height: 5),
                    Text(consultation ? "鼓勵您可與就近醫院或診所的醫療專業人員談談，會有不一樣的感覺喔！" : "請讓我們一起努力，促進腦部功能，維持心情平穩。"),
                    const SizedBox(height: 20),
                    const Text("愛陪伴團隊關心您"),
                  ],
                ),
                const Spacer(),
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    height: 80,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 245, 127, 191),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, "/home");
                      },
                      child: const Text("返回並獲得獎勵"),
                    ),
                  ),
                ),
              ],
            ),
          )
        ),
      ),
    );
  }
}