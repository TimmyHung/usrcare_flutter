import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:usrcare/api/APIModels.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';

class APIService {
  static const String baseUrl = "https://api.tkuusraicare.org";
  String? token;
  static String defaultToken = dotenv.env['API_DEFAULT_TOKEN']!;

  APIService({this.token});

  Map<String, String> get headers {
    String userToken = token ?? defaultToken;
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $userToken',
    };
  }

  // 顯示與隱藏Loading對話框
  void showLoadingDialog(BuildContext context, {bool fullScreen = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _LoadingDialog(fullScreen: fullScreen);
      },
    );
  }
  
  void hideLoadingDialog(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  // 註冊相關
  Future<http.Response> checkEmail(String email, BuildContext context, {bool showLoading = false}) async {
    if (showLoading) showLoadingDialog(context);
    final url = Uri.parse('$baseUrl/v1/registration/email/$email');
    try {
      return await http.get(url, headers: headers);
    } finally {
      if (showLoading) hideLoadingDialog(context);
    }
  }

  Future<http.Response> emailOtpVerification_RegisterONLY(OTPRequest otpRequest, BuildContext context, {bool showLoading = false}) async {
    if (showLoading) showLoadingDialog(context);
    final url = Uri.parse('$baseUrl/v1/registration/email');
    try {
      return await http.post(url, headers: headers, body: json.encode(otpRequest.toJson()));
    } finally {
      if (showLoading) hideLoadingDialog(context);
    }
  }

  Future<http.Response> checkUsername(String username, BuildContext context, {bool showLoading = false}) async {
    if (showLoading) showLoadingDialog(context);
    final url = Uri.parse('$baseUrl/v1/registration/username/$username');
    try {
      return await http.get(url, headers: headers);
    } finally {
      if (showLoading) hideLoadingDialog(context);
    }
  }

  Future<http.Response> registerUser(User user, BuildContext context, {bool showLoading = false}) async {
    if (showLoading) showLoadingDialog(context);
    final url = Uri.parse('$baseUrl/v1/registration');
    try {
      return await http.post(url, headers: headers, body: json.encode(user.toJson()));
    } finally {
      if (showLoading) hideLoadingDialog(context);
    }
  }

  Future<http.Response> oauthRegister(String oauthType, User user, BuildContext context, {bool showLoading = false}) async {
    if (showLoading) showLoadingDialog(context);
    final url = Uri.parse('$baseUrl/v1/registration/oauth/$oauthType');
    try {
      return await http.post(url, headers: headers, body: json.encode(user.toJson()));
    } finally {
      if (showLoading) hideLoadingDialog(context);
    }
  }

  // 登入相關
  Future<http.Response> getSalt(String username, BuildContext context, {bool showLoading = false}) async {
    if (showLoading) showLoadingDialog(context);
    final url = Uri.parse('$baseUrl/v1/salt/$username');
    try {
      return await http.get(url, headers: headers);
    } finally {
      if (showLoading) hideLoadingDialog(context);
    }
  }

  Future<http.Response> oauthLogin(String oauthType, Map<String, dynamic> credentials, BuildContext context, {bool showLoading = false}) async {
    if (showLoading) showLoadingDialog(context);
    final url = Uri.parse('$baseUrl/v1/authentication/oauth/$oauthType');
    try {
      return await http.post(url, headers: headers, body: json.encode(credentials));
    } finally {
      if (showLoading) hideLoadingDialog(context);
    }
  }

  Future<http.Response> authenticate(Map<String, dynamic> credentials, BuildContext context, {bool showLoading = false}) async {
    if (showLoading) showLoadingDialog(context);
    final url = Uri.parse('$baseUrl/v1/authentication');
    try {
      return await http.post(url, headers: headers, body: json.encode(credentials));
    } finally {
      if (showLoading) hideLoadingDialog(context);
    }
  }

  Future<http.Response> validateToken(String version, BuildContext context, {bool showLoading = false}) async {
    if (showLoading) showLoadingDialog(context);
    final url = Uri.parse('$baseUrl/v1/token');
    try {
      return await http.post(url, headers: headers, body: json.encode({'version': version}));
    } finally {
      if (showLoading) hideLoadingDialog(context);
    }
  }

  // 忘記密碼/重設密碼相關
  Future<http.Response> forgotPassword(String email, BuildContext context, {bool showLoading = false}) async {
    if (showLoading) showLoadingDialog(context);
    final url = Uri.parse('$baseUrl/v1/forgot/email/$email');
    try {
      return await http.get(url, headers: headers);
    } finally {
      if (showLoading) hideLoadingDialog(context);
    }
  }

  Future<http.Response> resetPassword(PasswordReset passwordReset, BuildContext context, {bool showLoading = false}) async {
    if (showLoading) showLoadingDialog(context);
    final url = Uri.parse('$baseUrl/v1/password/reset');
    try {
      return await http.post(url, headers: headers, body: json.encode(passwordReset.toJson()));
    } finally {
      if (showLoading) hideLoadingDialog(context);
    }
  }

  Future<http.Response> otpVerification(OTPRequest otpRequest, BuildContext context, {bool showLoading = false}) async {
    if (showLoading) showLoadingDialog(context);
    final url = Uri.parse('$baseUrl/v1/otp');
    try {
      return await http.post(url, headers: headers, body: json.encode(otpRequest.toJson()));
    } finally {
      if (showLoading) hideLoadingDialog(context);
    }
  }

  // 心情量表相關
  Future<http.Response> getMentalRecords(BuildContext context, {bool showLoading = false}) async {
    if (showLoading) showLoadingDialog(context);
    final url = Uri.parse('$baseUrl/v1/mental_record');
    try {
      return await http.get(url, headers: headers);
    } finally {
      if (showLoading) hideLoadingDialog(context);
    }
  }

  Future<http.Response> getMentalRecord(int listID, BuildContext context, {bool showLoading = false}) async {
    if (showLoading) showLoadingDialog(context);
    final url = Uri.parse('$baseUrl/v1/mental_record/$listID');
    try {
      return await http.get(url, headers: headers);
    } finally {
      if (showLoading) hideLoadingDialog(context);
    }
  }

  Future<http.Response> submitMentalRecord(int listID, Map<String, dynamic> record, BuildContext context, {bool showLoading = false}) async {
    if (showLoading) showLoadingDialog(context);
    final url = Uri.parse('$baseUrl/v1/mental_record/$listID');
    try {
      return await http.post(url, headers: headers, body: json.encode(record));
    } finally {
      if (showLoading) hideLoadingDialog(context);
    }
  }

  // 每日心情相關
  Future<http.Response> postMood(MoodRecord moodRecord, BuildContext context, {bool showLoading = false}) async {
    if (showLoading) showLoadingDialog(context);
    final url = Uri.parse('$baseUrl/v1/mood/${moodRecord.mood}');
    try {
      return await http.post(url, headers: headers, body: json.encode(moodRecord.toJson()));
    } finally {
      if (showLoading) hideLoadingDialog(context);
    }
  }

  Future<http.Response> getCheckin(BuildContext context, {bool showLoading = false}) async {
    if (showLoading) showLoadingDialog(context);
    final url = Uri.parse('$baseUrl/v1/record/checkin');
    try {
      return await http.get(url, headers: headers);
    } finally {
      if (showLoading) hideLoadingDialog(context);
    }
  }

  // 心情打字機
  Future<http.Response> postTypewriter(String typewriter, BuildContext context, {bool showLoading = true}) async {
    if (showLoading) showLoadingDialog(context);
    final url = Uri.parse('$baseUrl/v2/mood/typewriter');
    final body = {
      'typewriter': typewriter,
    };
    try {
      return await http.post(url, headers: headers, body: json.encode(body));
    } finally {
      if (showLoading) hideLoadingDialog(context);
    }
  }

  Future<http.Response> getTypeWriterHistory(
      BuildContext context, {
      required int batchSize,
      required int batch,
      bool showLoading = false,
    }) async {
    if (showLoading) showLoadingDialog(context);

    // 組合URL
    final url = Uri.parse('$baseUrl/v2/mood/typewriter/history')
        .replace(queryParameters: {
      'batchSize': batchSize.toString(),
      'batch': batch.toString(),
    });

    try {
      return await http.get(url, headers: headers);
    } finally {
      if (showLoading) hideLoadingDialog(context);
    }
  }


  // 點數相關
  Future<http.Response> getPoints(BuildContext context, {bool showLoading = false}) async {
    if (showLoading) showLoadingDialog(context);
    final url = Uri.parse('$baseUrl/v1/points');
    try {
      return await http.get(url, headers: headers);
    } finally {
      if (showLoading) hideLoadingDialog(context);
    }
  }

  Future<http.Response> postPointsDeduction(PointsDeduction pointsDeduction, BuildContext context, {bool showLoading = false}) async {
    if (showLoading) showLoadingDialog(context);
    final url = Uri.parse('$baseUrl/v1/points/deduction');
    try {
      return await http.post(url, headers: headers, body: json.encode(pointsDeduction.toJson()));
    } finally {
      if (showLoading) hideLoadingDialog(context);
    }
  }

  Future<http.Response> getPointsCheat(BuildContext context, {bool showLoading = false}) async {
    if (showLoading) showLoadingDialog(context);
    final url = Uri.parse('$baseUrl/v1/points/cheat');
    try {
      return await http.get(url, headers: headers);
    } finally {
      if (showLoading) hideLoadingDialog(context);
    }
  }

  // 首頁Banner
  Future<http.Response> getHistoryStory(BuildContext context, {bool showLoading = false}) async {
    if (showLoading) showLoadingDialog(context);
    final url = Uri.parse('$baseUrl/v1/history_story');
    try {
      return await http.get(url, headers: headers);
    } finally {
      if (showLoading) hideLoadingDialog(context);
    }
  }

  Future<http.Response> getVocabulary(BuildContext context, {bool showLoading = false}) async {
    if (showLoading) showLoadingDialog(context);
    final url = Uri.parse('$baseUrl/v1/vocabulary');
    try {
      return await http.get(url, headers: headers);
    } finally {
      if (showLoading) hideLoadingDialog(context);
    }
  }

  // 遊戲
  Future<http.Response> postGameRecordCard(GameRecordCard gameRecordCard, BuildContext context, {bool showLoading = false}) async {
    if (showLoading) showLoadingDialog(context);
    final url = Uri.parse('$baseUrl/v1/game_record/card');
    try {
      return await http.post(url, headers: headers, body: json.encode(gameRecordCard.toJson()));
    } finally {
      if (showLoading) hideLoadingDialog(context);
    }
  }

  Future<http.Response> postGameRecordOcean(GameRecordOcean gameRecordOcean, BuildContext context, {bool showLoading = false}) async {
    if (showLoading) showLoadingDialog(context);
    final url = Uri.parse('$baseUrl/v1/game_record/ocean');
    try {
      return await http.post(url, headers: headers, body: json.encode(gameRecordOcean.toJson()));
    } finally {
      if (showLoading) hideLoadingDialog(context);
    }
  }

  // 愛來運動
  Future<http.StreamedResponse> uploadVideo(List<int> videoFile, BuildContext context, {bool showLoading = false}) async {
    if (showLoading) showLoadingDialog(context);
    final url = Uri.parse('$baseUrl/v1/video/analysis/upload');
    var request = http.MultipartRequest('POST', url)
      ..headers.addAll(headers)
      ..files.add(http.MultipartFile.fromBytes('video', videoFile, filename: 'video.mp4'));

    try {
      return await request.send();
    } finally {
      if (showLoading) hideLoadingDialog(context);
    }
  }

  Future<http.Response> videoAnalysisWebhook(String videoName, BuildContext context, {bool showLoading = false}) async {
    if (showLoading) showLoadingDialog(context);
    final url = Uri.parse('$baseUrl/video/analysis/webhook/$videoName');
    try {
      return await http.get(url, headers: headers);
    } finally {
      if (showLoading) hideLoadingDialog(context);
    }
  }

}

class _LoadingDialog extends StatefulWidget {
  final bool fullScreen;

  const _LoadingDialog({super.key, required this.fullScreen});

  @override
  __LoadingDialogState createState() => __LoadingDialogState();
}

class __LoadingDialogState extends State<_LoadingDialog> {
  late Timer _timer;
  String _loadingText = "載入中";
  int _dotCount = 1;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() {
        _dotCount = (_dotCount + 1) % 4; // 循環點數：0 到 3
        _loadingText = "載入中. ${". " * _dotCount}"; // 根據點數變化顯示 "載入中."
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // 在對話框銷毀時取消計時器
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: widget.fullScreen ? Colors.white : Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 圓形圖片背景
          Container(
            width: 300,
            height: 300,
            decoration: const BoxDecoration(
              color: Colors.white, // 白色背景
              shape: BoxShape.circle, // 圓形
            ),
            padding: const EdgeInsets.all(10),
            child: ClipOval(
              child: Image.asset(
                'assets/logo.png',
                fit: BoxFit.scaleDown,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // 圓角矩形文字背景
          Container(
            width: 205,
            decoration: BoxDecoration(
              color: Colors.white, // 白色背景
              borderRadius: BorderRadius.circular(20), // 圓角矩形
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              _loadingText, // 動態顯示的載入中文字
              style: const TextStyle(fontSize: 33, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
