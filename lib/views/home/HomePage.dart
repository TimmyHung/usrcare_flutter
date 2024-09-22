import 'package:flutter/material.dart';
import 'package:usrcare/api/APIService.dart';
import 'package:usrcare/strings.dart';
import 'package:usrcare/utils/ColorUtil.dart';
import 'package:usrcare/utils/MiscUtil.dart';
import 'package:usrcare/utils/SharedPreference.dart';
import 'package:usrcare/widgets/Button.dart';
import 'package:usrcare/widgets/Dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String token = "";
  String name = "載入中...";
  String points = "載入中";
  List vocabulary = ["載入中...", " ", " "];
  List history_story = ["載入中...", " ", " "];

  @override
  void initState() {
    super.initState();
    _getLocalUserData();
  }

  Future<void> _getLocalUserData() async{
    final loadedName = await SharedPreferencesService().getData(StorageKeys.userName) ?? "Null";
    final loadedToken = await SharedPreferencesService().getData(StorageKeys.userToken) ?? "Null";
    setState(() {
      name = loadedName;
      token = loadedToken;
    });

    _loadData();
  }

  Future<void> _loadData() async {
    final APIService apiService = APIService(token: token);

    final pointsResponse = apiService.getPoints();
    final vocabularyResponse = apiService.getVocabulary();
    final historyStoryResponse = apiService.getHistoryStory();

    final results = await Future.wait([pointsResponse, vocabularyResponse, historyStoryResponse]);

    final pointsData = handleHttpResponses(context, results[0], "取得用戶金幣時發生錯誤");
    final vocabularyData = handleHttpResponses(context, results[1], "取得每日單字時發生錯誤");
    final historyStoryData = handleHttpResponses(context, results[2], "取得歷史上的今天/冷知識時發生錯誤");

    setState(() {
      points = pointsData["points"].toString();
      vocabulary = [vocabularyData["english"], vocabularyData["phonetic_notation"], vocabularyData["chinese"]];
      history_story = [historyStoryData["title"], historyStoryData["event"], historyStoryData["detail"], historyStoryData["date"]];
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: ColorUtil.bg_lightBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(150),
                        color: Colors.white,
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/logo.png',
                          fit: BoxFit.scaleDown,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      GetString.appName,
                      style: TextStyle(
                        fontSize: 28,
                      ),
                    ),
                    const Spacer(),
                    CustomButton(
                      text: '',
                      type: ButtonType.circular,
                      onPressed: () {
                        // Circular button logic
                      },
                      icon: const Icon(Icons.notifications_outlined),
                    ),
                    const SizedBox(width: 5),
                    CustomButton(
                      text: '',
                      type: ButtonType.circular,
                      onPressed: () {
                        Navigator.pushNamed(context, "/setting");
                      },
                      icon: const Icon(Icons.settings_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Column(
                  children: [
                    SizedBox(
                      height: 180,
                      width: MediaQuery.of(context).size.width,
                      child: PageView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          SizedBox(
                            height: 150,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  height: 150,
                                  width: 150,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(150),
                                    color: Colors.white,
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      'assets/logo.png',
                                      fit: BoxFit.scaleDown,
                                    ),
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                     SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.42,
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(name, style: const TextStyle(fontSize: 30)),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: (){
                                        // 金幣點擊邏輯
                                      },
                                      child: Container(
                                        width: MediaQuery.of(context).size.width * 0.42,
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(240, 240, 252, 255),
                                          border: Border.all(
                                            color: const Color(0xFF6262D9),
                                            width: 3.0,
                                          ),
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                          child: Row(
                                            children: [
                                              Image.asset(
                                                'assets/HomePage_Icons/coin.png',
                                                fit: BoxFit.scaleDown,
                                                height: 50,
                                              ),
                                              const Spacer(),
                                              SizedBox(
                                                width: MediaQuery.of(context).size.width * 0.2,
                                                child: FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Text(
                                                    points,
                                                    style: const TextStyle(
                                                      fontSize: 30,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const Spacer(),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          //每日英語
                          GestureDetector(
                            onTap: (){
                              showCustomDialog(context, "每日英語", 
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(vocabulary[0], style: const TextStyle(fontSize: 25)),
                                  const SizedBox(height: 20),
                                  Text(vocabulary[1], style: const TextStyle(fontSize: 25)),
                                  const SizedBox(height: 20),
                                  Text(vocabulary[2], style: const TextStyle(fontSize: 25)),
                                ],
                              ), closeButton: true);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  const Spacer(),
                                  const Text("每日英語", style: TextStyle(fontSize: 30)),
                                  FittedBox(fit: BoxFit.scaleDown, child: Text(vocabulary[0], style: const TextStyle(fontSize: 30))),
                                  FittedBox(fit: BoxFit.scaleDown, child: Text(vocabulary[1], style: const TextStyle(fontSize: 30))),
                                  const SizedBox(height:10),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                                      child: Text(
                                        "點擊查看中文...",
                                        style: TextStyle(fontSize: 20, color: Colors.grey[800]),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          //歷史上的今天/冷知識
                          GestureDetector(
                            onTap: (){
                              showCustomDialog(context, history_story[0], 
                              SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (history_story[3].length != 0) ...[
                                      const SizedBox(height: 20),
                                      Text(history_story[3]),
                                    ],
                                    Text(history_story[1], style: const TextStyle(fontSize: 25)),
                                    const SizedBox(height: 30),
                                    Text(history_story[2], style: const TextStyle(fontSize: 25)),
                                  ],
                                ),
                              ), closeButton: true);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Spacer(),
                                  Text(history_story[0], style: const TextStyle(fontSize: 30)),
                                  const SizedBox(height: 10),
                                  Text(history_story[1], style: const TextStyle(fontSize: 25)),
                                  const Spacer(),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                                      child: Text(
                                        "點擊閱讀更多...",
                                        style: TextStyle(fontSize: 20, color: Colors.grey[800]),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildGridButton("簽簽樂", "assets/HomePage_Icons/sign.png", Colors.red, 1, (){print("芊芊樂");}),
                            const SizedBox(width: 10),
                            _buildGridButton("每日任務", "assets/HomePage_Icons/daily_task.png", const Color.fromARGB(255,232,125,0), 1, (){print("OK2");}),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildGridButton("動腦小遊戲", "assets/HomePage_Icons/brain_game.png", const Color.fromARGB(255,212,152,0), 2, (){Navigator.pushNamed(context, "/game");}),
                            const SizedBox(width: 10),
                            _buildGridButton("寵物陪伴", "assets/HomePage_Icons/pet.png", const Color.fromARGB(255,0,143,0), 2, (){print("OK");}),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildGridButton("愛來運動", "assets/HomePage_Icons/sport.png", const Color.fromARGB(255,0,107,185), 2, (){print("OK");}),
                            const SizedBox(width: 10),
                            _buildGridButton("鬧鐘小提醒", "assets/HomePage_Icons/alarm.png", const Color.fromARGB(255,0,0,146), 2, (){print("OK");}),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildGridButton("好物雜貨鋪", "assets/HomePage_Icons/store.png", const Color.fromARGB(255,80,0,182), 2, (){print("OK");}),
                            const SizedBox(width: 10),
                            _buildGridButton("心情量表", "assets/HomePage_Icons/mood.png", const Color.fromARGB(255,202,0,109), 2, (){Navigator.pushNamed(context, "/mood");}),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridButton(String title, String iconPath, Color borderColor, int type, Function onPressed) {
    return InkWell(
      onTap: () {
        onPressed();
      },
      child: Container(
        height: type == 1 ? 60 : MediaQuery.of(context).size.width * 0.34,
        width: MediaQuery.of(context).size.width * 0.42,
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 3),
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
        ),
        child: type == 1 ?
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Image.asset(iconPath),
              const SizedBox(width: 0),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 30,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          )
          :
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(iconPath, height: 70),
               Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 30,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
      ),
    );
  }
}