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
      return await http.post(url,
          headers: headers, body: json.encode(otpRequest.toJson()));
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
      return await http.post(url,
          headers: headers, body: json.encode(user.toJson()));
    } finally {
      if (showLoading) hideLoadingDialog(context);
    }
  }

  Future<http.Response> oauthRegister(String oauthType, User user, BuildContext context, {bool showLoading = false}) async {
    if (showLoading) showLoadingDialog(context);
    final url = Uri.parse('$baseUrl/v1/registration/oauth/$oauthType');
    try {
      return await http.post(url,
          headers: headers, body: json.encode(user.toJson()));
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

  Future<http.Response> oauthLogin(String oauthType, Map<String, dynamic> credentials, BuildContext context, {bool showLoading = true}) async {
    if (showLoading) showLoadingDialog(context);
    final url = Uri.parse('$baseUrl/v1/authentication/oauth/$oauthType');
    try {
      return await http.post(url,
          headers: headers, body: json.encode(credentials));
    } finally {
      if (showLoading) hideLoadingDialog(context);
    }
  }

  Future<http.Response> authenticate(Map<String, dynamic> credentials, BuildContext context, {bool showLoading = false}) async {
    if (showLoading) showLoadingDialog(context);
    final url = Uri.parse('$baseUrl/v1/authentication');
    try {
      return await http.post(url,
          headers: headers, body: json.encode(credentials));
    } finally {
      if (showLoading) hideLoadingDialog(context);
    }
  }

  Future<http.Response> validateToken(String version, BuildContext context, {bool showLoading = false}) async {
    if (showLoading) showLoadingDialog(context);
    final url = Uri.parse('$baseUrl/v1/token');
    try {
      return await http.post(url,
          headers: headers, body: json.encode({'version': version}));
    } finally {
      if (showLoading) hideLoadingDialog(context);
    }
  }

  // OAuth綁定相關
  Future<http.Response> oauthBindingList(BuildContext context, {bool showLoading = false}) async {
    if (showLoading) showLoadingDialog(context);
    final url = Uri.parse('$baseUrl/v1/oauth/binding/inquiry');
    try {
      return await http.get(url, headers: headers);
    } finally {
      if (showLoading) hideLoadingDialog(context);
    }
  }

  Future<http.Response> oauthBinding(String oauthType, Map<String, dynamic> credentials, BuildContext context, {bool showLoading = true}) async {
    if (showLoading) showLoadingDialog(context);
    final url = Uri.parse('$baseUrl/v1/oauth/binding/$oauthType');
    try {
      return await http.post(url,
          headers: headers, body: json.encode(credentials));
    } finally {
      if (showLoading) hideLoadingDialog(context);
    }
  }

  Future<http.Response> oauthBindingReplacement(String oauthType, Map<String, dynamic> credentials, BuildContext context, {bool showLoading = true}) async {
    if (showLoading) showLoadingDialog(context);
    final url = Uri.parse('$baseUrl/v1/oauth/binding/replacement/$oauthType');
    try {
      return await http.post(url,
          headers: headers, body: json.encode(credentials));
    } finally {
      if (showLoading) hideLoadingDialog(context);
    }
  }

  Future<http.Response> oauthUnBinding(String oauthType, BuildContext context, {bool showLoading = true}) async {
    if (showLoading) showLoadingDialog(context);
    final url = Uri.parse('$baseUrl/v1/oauth/binding/cancelation/$oauthType');
    try {
      return await http.delete(url, headers: headers);
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
      return await http.post(url,
          headers: headers, body: json.encode(passwordReset.toJson()));
    } finally {
      if (showLoading) hideLoadingDialog(context);
    }
  }

  Future<http.Response> otpVerification(OTPRequest otpRequest, BuildContext context, {bool showLoading = false}) async {
    if (showLoading) showLoadingDialog(context);
    final url = Uri.parse('$baseUrl/v1/otp');
    try {
      return await http.post(url,
          headers: headers, body: json.encode(otpRequest.toJson()));
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
    final url = Uri.parse('$baseUrl/v2/mental_record/$listID');
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
  Future<http.Response> postMood(int moodScore, String time, BuildContext context, {bool showLoading = false}) async {
    if (showLoading) showLoadingDialog(context);
    final url = Uri.parse('$baseUrl/v1/mood/$moodScore');
    final body = {
      'time': time,
    };

    try {
      return await http.post(url, headers: headers, body: json.encode(body));
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
  Future<http.Response> postTypewriter(String typewriter, String creationTime, BuildContext context, {bool showLoading = true}) async {
    if (showLoading) showLoadingDialog(context);

    final url = Uri.parse('$baseUrl/v2/mood/typewriter');
    final body = {
      'typewriter': typewriter,
      'creation_time': creationTime,
    };

    try {
      return await http.post(url, headers: headers, body: json.encode(body));
    } finally {
      if (showLoading) hideLoadingDialog(context);
    }
  }

  Future<http.Response> getTypeWriterHistory(BuildContext context, {required int batch, bool showLoading = false}) async {
    if (showLoading) showLoadingDialog(context);

    // 組合URL
    final url = Uri.parse('$baseUrl/v2/mood/typewriter/history')
        .replace(queryParameters: {
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

  // 首頁Banner相關
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

  // 遊戲相關
  Future<http.Response> postGameRecord_WebBased(Map<String, dynamic> gameData, BuildContext context) async {
    final url = Uri.parse('$baseUrl/v1/game_record/web-based');
    return await http.post(url, headers: headers, body: json.encode(gameData));
  }

  // 愛來運動相關
  Future<http.Response> uploadVideo(List<int> videoFile, BuildContext context, {bool showLoading = false}) async {
    if (showLoading) showLoadingDialog(context);
    final url = Uri.parse('$baseUrl/v1/video/analysis/upload');
    
    try {
      var request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = headers['Authorization']!
        ..files.add(http.MultipartFile.fromBytes(
          'video',
          videoFile,
          filename: 'video.mp4'
        ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      return response;
      
    } finally {
      if (showLoading) hideLoadingDialog(context);
    }
  }

  Future<http.Response> getVideoList(BuildContext context, {bool showLoading = false}) async {
    if (showLoading) showLoadingDialog(context);
    final url = Uri.parse('$baseUrl/v1/video/list');
    try {
      return await http.get(url, headers: headers);
    } finally {
      if (showLoading) hideLoadingDialog(context);
    }
  }

  Future<http.Response> deleteVideo(String videoID, BuildContext context, {bool showLoading = false}) async {
    if (showLoading) showLoadingDialog(context);
    final url = Uri.parse('$baseUrl/v1/video/$videoID');
    try {
      return await http.delete(url, headers: headers);
    } finally {
      if (showLoading) hideLoadingDialog(context);
    }
  }

  // 寵物陪伴相關
  Future<http.Response> getPetName(BuildContext context){
    return getUserConfig(context, configKeys: [UserConfigKeys.petCompanionPetName]);
  }

  Future<http.Response> setPetName(String name, BuildContext context){
    return setUserConfig(UserConfigKeys.petCompanionPetName, name, context, showLoading: true);
  }

  Future<http.Response> getPedometerGoal(BuildContext context){
    return getUserConfig(context, configKeys: [UserConfigKeys.petCompanionPedometerGoal], showLoading: true);
  }

  Future<http.Response> setPedometerGoal(int goal, BuildContext context){
    return setUserConfig(UserConfigKeys.petCompanionPedometerGoal, goal, context);
  }

  Future<http.Response> postPedometerSteps(int steps, DateTime date, BuildContext context, {bool showLoading = false}) async {
    if (showLoading) showLoadingDialog(context);
    final url = Uri.parse('$baseUrl/v1/pet_companion/pedometer');
    try {
      return await http.post(
        url,
        headers: headers,
        body: json.encode({
          'steps': steps,
          'date': DateTime(date.year, date.month, date.day).toIso8601String()
        })
      );
    } finally {
      if (showLoading) hideLoadingDialog(context);
    }
  }

  Future<http.Response> getPedometerSteps(int year, int month, BuildContext context, {bool showLoading = false}) async {
    if (showLoading) showLoadingDialog(context);
    final url = Uri.parse('$baseUrl/v1/pet_companion/pedometer/$year/$month');
    try {
      return await http.get(url, headers: headers);
    } finally {
      if (showLoading) hideLoadingDialog(context);
    }
  }

  // 使用者設定相關
  Future<http.Response> getUserConfig(BuildContext context, {bool showLoading = false, List<String>? configKeys}) async {
    if (showLoading) showLoadingDialog(context);
    final keys = configKeys?.join(',') ?? UserConfigKeys.getAllKeys().join(',');
    final url = Uri.parse('$baseUrl/v1/user/config?config_key=$keys');
    try {
      return await http.get(url, headers: headers);
    } finally {
      if (showLoading) hideLoadingDialog(context);
    }
  }

  Future<http.Response> setUserConfig(String configKey, dynamic value, BuildContext context, {bool showLoading = false}) async {
    if (showLoading) showLoadingDialog(context);
    final url = Uri.parse('$baseUrl/v1/user/config/set');
    try {
      return await http.post(
        url, 
        headers: headers,
        body: json.encode({
          'config_key': configKey,
          'value': value
        })
      );
    } finally {
      if (showLoading) hideLoadingDialog(context);
    }
  }

  // 傳遞FCM Token
  Future<http.Response> postFCMToken(String FCMToken, BuildContext context, {bool showLoading = false}) async {
    if (showLoading) showLoadingDialog(context);
    final url = Uri.parse('$baseUrl/v1/device/registration');
    try {
      return await http.post(url, headers: headers, body: json.encode({'registration_token': FCMToken}));
    } finally {
      if (showLoading) hideLoadingDialog(context);
    }
  }

  // 最低版本限制
  Future<http.Response> getMinimumAppVersion() async {
    final url = Uri.parse('$baseUrl/v1/force_update_version');
    return await http.get(url, headers: headers);
  }

}

class _LoadingDialog extends StatefulWidget {
  final bool fullScreen;

  const _LoadingDialog({super.key, required this.fullScreen});

  @override
  __LoadingDialogState createState() => __LoadingDialogState();
}

class __LoadingDialogState extends State<_LoadingDialog> with SingleTickerProviderStateMixin {
  late Timer _timer;
  String _loadingText = "載入中.";
  int _dotCount = 0;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    setState(() {
      _loadingText = "載入中.";
    });

    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          _dotCount = (_dotCount + 1) % 4;
          _loadingText = "載入中${"." * (_dotCount + 1)}"; 
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 5,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RotationTransition(
                turns: _animation,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Text(
                _loadingText,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
