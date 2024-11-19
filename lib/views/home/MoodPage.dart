import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:usrcare/api/APIService.dart';
import 'package:usrcare/utils/MiscUtil.dart';
import 'package:usrcare/utils/SharedPreference.dart';
import 'package:usrcare/widgets/Dialog.dart';

class MoodPage extends StatefulWidget {
  const MoodPage({super.key});

  @override
  State<MoodPage> createState() => _MoodPageState();
}

class _MoodPageState extends State<MoodPage> {
  bool isLoading = false;
  Map<int, Map<String, dynamic>> questionsData = {};
  APIService? apiService;

  @override
  void initState() {
    super.initState();
    _loadAllQuestions(); // 初始化時就去加載所有題目
  }

  Future<void> _loadAllQuestions() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    final loadedToken =
        await SharedPreferencesService().getData(StorageKeys.userToken) ??
            "Null";
    apiService = APIService(token: loadedToken);

    const listIDs = [0, 1];

    try {
      final futures = listIDs.map((listID) => apiService!
              .getMentalRecord(listID, context, showLoading: false)
              .then((response) {
            final result = handleHttpResponses(
                context, response, "無法取得心情量表題目(ID: $listID)");
            if (result != null) {
              questionsData[listID] = result;
            }
          }));

      await Future.wait(futures);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _navigateToQuestionPage(int listID, String title) {
    if (isLoading) return; // 如果還在加載，禁止點擊

    var data = questionsData[listID];
    if (data != null) {
      if (!data['available']) {
        String sheet_name = data['sheet_name'] ?? '未知量表';
        int days_remaining = data['days_remaining'] ?? '未知日期';

        showCustomDialog(context, "請您再等等",
            '感謝您已經完成「$sheet_name」量表的測驗。為了更精確地了解您的健康狀況，我們建議您在「$days_remaining天」後再進行一次測驗。這有助於我們追蹤您的情況，並確保能夠提供最合適的照護建議。如果您在此期間有任何疑慮或需要協助，請隨時與我們聯繫。',
            closeButton: true);
      }

      if (data['content'] != null && data['content'].isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuestionPage(
              title: title,
              questions: data['content']['questions'],
              listID: listID,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color.fromARGB(255, 252, 202, 229),
        appBar: AppBar(
          centerTitle: true,
          title: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                  color: const Color.fromARGB(255, 202, 0, 109), width: 3),
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
              children: [
                Expanded(
                  flex: 6,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, // 垂直置中
                    children: [
                      InkWell(
                        onTap: () => _navigateToQuestionPage(0, 'AD8 認知功能評估表'),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isLoading ||
                                    (questionsData[0] != null &&
                                        !questionsData[0]!['available'])
                                ? Colors.grey[300]
                                : Colors.white,
                            border: Border.all(
                                color: const Color.fromARGB(255, 202, 0, 109),
                                width: 3),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          width: double.infinity,
                          height: 80,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "AD8 認知功能評估表",
                                style: TextStyle(fontSize: 26),
                              ),
                              if (questionsData[0] != null &&
                                  !questionsData[0]!['available'])
                                Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Icon(
                                    Icons.access_time,
                                    color: Colors.grey[800],
                                    size: 30,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      InkWell(
                        onTap: () => _navigateToQuestionPage(1, '寂寞量表'),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isLoading ||
                                    (questionsData[1] != null &&
                                        !questionsData[1]!['available'])
                                ? Colors.grey[300]
                                : Colors.white,
                            border: Border.all(
                                color: const Color.fromARGB(255, 202, 0, 109),
                                width: 3),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          width: double.infinity,
                          height: 80,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "寂寞量表",
                                style: TextStyle(fontSize: 26),
                              ),
                              if (questionsData[1] != null &&
                                  !questionsData[1]!['available'])
                                Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Icon(
                                    Icons.access_time,
                                    color: Colors.grey[800],
                                    size: 30,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(
                  thickness: 2,
                  color: Color.fromARGB(255, 202, 0, 109),
                ),
                Expanded(
                  flex: 4,
                  child: Center(
                    child: InkWell(
                      onTap: () => {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TypeWriter_Page(apiService: apiService!),
                          ),
                        )
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              color: const Color.fromARGB(255, 202, 0, 109),
                              width: 3),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        width: double.infinity,
                        height: 80,
                        child: const Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.edit,
                                size: 28,
                                color: Color.fromARGB(255, 202, 0, 109),
                              ),
                              SizedBox(width: 8),
                              Text(
                                "心情打字機",
                                style: TextStyle(fontSize: 26),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

class QuestionPage extends StatefulWidget {
  final String title;
  final List<dynamic> questions;
  final int listID;

  const QuestionPage(
      {super.key,
      required this.title,
      required this.questions,
      required this.listID});

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
    final loadedToken =
        await SharedPreferencesService().getData(StorageKeys.userToken) ??
            "Null";
    final APIService apiService = APIService(token: loadedToken);
    DateTime endTime = DateTime.now();
    List<String> answerStrings =
        answers.map((answer) => answer.toString()).toList();

    Map<String, dynamic> record = {
      "answer": answerStrings,
      "start_time": startTime!.toIso8601String(),
      "end_time": endTime.toIso8601String(),
    };

    final response =
        await apiService.submitMentalRecord(widget.listID, record, context);
    var x = handleHttpResponses(context, response, "無法提交心情量表結果");
    if (x == null) {
      return;
    }
    bool consultation = x['consultation'];
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ResultPage(consultation: consultation)),
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
      resizeToAvoidBottomInset: false,
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
                      isSelected:
                          answers[currentQuestionIndex] == optionIndex + 1,
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
              mainAxisAlignment: currentQuestionIndex > 0
                  ? MainAxisAlignment.spaceBetween
                  : MainAxisAlignment.end,
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
                  backgroundColor: answers[currentQuestionIndex] != null
                      ? Colors.orange
                      : Colors.grey,
                  heroTag: 'next',
                  onPressed: () {
                    if (answers[currentQuestionIndex] == null) {
                      showToast(context, "請先選擇一個選項");
                      return;
                    }
                    if (currentQuestionIndex < widget.questions.length - 1) {
                      setState(() {
                        currentQuestionIndex++;
                      });
                    } else {
                      _submitAnswers();
                    }
                  },
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
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
                color: const Color.fromARGB(255, 202, 0, 109), width: 3),
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
              const SizedBox(height: 40),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("親愛的朋友，"),
                  const SizedBox(height: 15),
                  const Text("感謝您完成心情量表，希望一同維護您的健康和幸福。"),
                  const SizedBox(height: 5),
                  Text(consultation
                      ? "鼓勵您可與就近醫院或診所的醫療專業人員談談，會有不一樣的感覺喔！"
                      : "請讓我們一起努力，促進腦部功能，維持心情平穩。"),
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
                      Navigator.popUntil(context, ModalRoute.withName('/home'));
                    },
                    child: const Text("返回並獲得獎勵"),
                  ),
                ),
              ),
            ],
          ),
        )),
      ),
    );
  }
}

class TypeWriter_Page extends StatefulWidget {
  final APIService apiService;
  const TypeWriter_Page({super.key, required this.apiService});

  @override
  State<TypeWriter_Page> createState() => _TypeWriter_PageState();
}

class _TypeWriter_PageState extends State<TypeWriter_Page> {
  List<dynamic> moodHistory = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMoreData = true;
  int batch = 1;

  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _fetchMoodHistory();
  }

  Future<void> _fetchMoodHistory({bool isLoadMore = false}) async {
    if (isLoadingMore || !hasMoreData) {
      return;
    }

    setState(() {
      if (isLoadMore) {
        isLoadingMore = true;
      } else {
        isLoading = true;
      }
    });

    var response = await widget.apiService.getTypeWriterHistory(
      context,
      batch: batch,
    );
    var result = handleHttpResponses(context, response, "無法取得心情打字機歷史紀錄");
    var moodRecordData = result["data"];
    var totalRecords = result["total_records"];
    if (moodRecordData != null && mounted) {
      setState(() {
        if (moodRecordData.isEmpty) {
          hasMoreData = false;
        } else {
          // 合併新的資料
          moodHistory.addAll(moodRecordData);
          batch++;
        }
        isLoading = false;
        isLoadingMore = false;
        if (moodHistory.length >= totalRecords) {
          hasMoreData = false;
        }
      });
    } else {
      setState(() {
        isLoading = false;
        isLoadingMore = false;
        hasMoreData = false;
      });
    }
  }

  // 當滾動到底部時觸發加載更多資料
  void _onScroll() {
    if (!_scrollController.hasClients || isLoadingMore || !hasMoreData) return;

    final thresholdReached = _scrollController.position.extentAfter < 200;

    if (thresholdReached) {
      _fetchMoodHistory(isLoadMore: true);
    }
  }

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String formatDate(String dateStr) {
    try {
      DateTime dateTime = HttpDate.parse(dateStr);
      return DateFormat('yyyy年MM月dd日 HH:mm:ss').format(dateTime);
    } catch (e) {
      return dateStr;
    }
  }

  void _showResponseDetailDialog(
      BuildContext context, String userInput, String aiSuggestion) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: "您的心情紀錄：\n",
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: userInput,
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: "溫馨提醒：\n",
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: aiSuggestion,
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _focusNode.unfocus();
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
                  child: Text("關閉",
                      style: TextStyle(
                          fontSize: 22,
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.bold)),
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
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 252, 202, 229),
      appBar: AppBar(
        centerTitle: true,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
                color: const Color.fromARGB(255, 202, 0, 109), width: 3),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.edit,
                size: 28,
                color: Color.fromARGB(255, 202, 0, 109),
              ),
              Text("心情打字機")
            ],
          ),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _focusNode.unfocus();
        },
        child: Padding(
          padding: const EdgeInsets.only(right: 20, left: 20, top: 20),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.black87),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Text(
                          "您現在心情怎麼樣呢？",
                          style: TextStyle(
                            fontSize: 26,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                      ),
                    ),
                    TextField(
                      focusNode: _focusNode,
                      controller: _textController,
                      style: const TextStyle(fontSize: 24),
                      maxLines: 6,
                      decoration: InputDecoration(
                        hintText: "點擊這裡輸入您的心情...",
                        hintStyle: const TextStyle(fontSize: 24),
                        filled: true,
                        fillColor: Colors.grey[350],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.mic,
                                  color: Color.fromARGB(255, 202, 0, 109),
                                  size: 28),
                              onPressed: () {
                                // TODO: 添加語音輸入功能
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.document_scanner,
                                  color: Color.fromARGB(255, 202, 0, 109),
                                  size: 28),
                              onPressed: () {
                                // TODO: 添加掃描功能
                              },
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () async {
                            String userInput = _textController.text.trim();
                            final DateTime rawDateTime = DateTime.now();
                            //將時間轉換為ISO8601格式
                            final String creationTime_ISO8601 =
                                DateFormat('yyyy-MM-ddTHH:mm:ss')
                                    .format(rawDateTime);
                            final String creationTime =
                                '${DateFormat('EEE, dd MMM yyyy HH:mm:ss').format(rawDateTime)} GMT';
                            if (userInput.isEmpty) {
                              showCustomDialog(context, "提示", "請先輸入您的心情內容再送出。",
                                  closeButton: true);
                              return;
                            }
                            var response = await widget.apiService
                                .postTypewriter(
                                    userInput, creationTime_ISO8601, context);
                            var aiReply = handleHttpResponses(
                                context, response, "無法取得心情打字機回應物件");
                            final responseSuggestion = aiReply["suggestion"];
                            _showResponseDetailDialog(
                                context, userInput, responseSuggestion);
                            // 清除使用者的輸入內容
                            _textController.clear();

                            // 更新資料至歷史紀錄
                            var newRecord = {
                              "AI_reply": json.encode(aiReply),
                              "user_input": userInput,
                              "start_time": creationTime,
                            };

                            setState(() {
                              moodHistory.insert(0, newRecord);
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 20.0),
                              child: Text("送出",
                                  style: TextStyle(
                                      fontSize: 22, color: Colors.black)),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: Divider(
                  color: Colors.black,
                  height: 0,
                ),
              ),
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.black),
                      )
                    : moodHistory.isEmpty
                        ? const Center(
                            child: Text(
                              "目前沒有心情紀錄",
                              style: TextStyle(
                                  fontSize: 22, color: Colors.black54),
                            ),
                          )
                        : NotificationListener<ScrollNotification>(
                            onNotification: (ScrollNotification scrollInfo) {
                              if (scrollInfo.metrics.pixels ==
                                      scrollInfo.metrics.maxScrollExtent &&
                                  !isLoadingMore) {
                                _fetchMoodHistory(
                                    isLoadMore: true); // 當滾動到列表底部時加載更多資料
                              }
                              return true;
                            },
                            child: ListView.builder(
                              controller: _scrollController,
                              itemCount: moodHistory.length +
                                  (hasMoreData ? 1 : 0), // 顯示更多加載標誌
                              itemBuilder: (context, index) {
                                if (index == moodHistory.length) {
                                  // 加載更多的進度條
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Center(
                                        child: CircularProgressIndicator(
                                      color: Colors.black,
                                    )),
                                  );
                                }

                                var record = moodHistory[index];
                                var userInput = record['user_input'] ?? '無心情內容';
                                var aiReply = record['AI_reply'];
                                var aiSuggestion = json
                                        .decode(aiReply)['suggestion'] ??
                                    (json.decode(aiReply)['message'] ?? '暫無建議');
                                var formattedDate =
                                    formatDate(record['start_time']);

                                return GestureDetector(
                                  onTap: () {
                                    _showResponseDetailDialog(
                                        context, userInput, aiSuggestion);
                                  },
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: ListTile(
                                      title: Text(
                                        userInput,
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                      subtitle: Text(
                                        "日期: $formattedDate",
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    ),
                                  ),
                                );
                              },
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
