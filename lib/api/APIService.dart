import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:usrcare/api/APIModels.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class APIService {
  static const String baseUrl = "https://api.tkuusraicare.org/v1";
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

  // 註冊相關
  Future<http.Response> checkEmail(String email) {
    final url = Uri.parse('$baseUrl/registration/email/$email');
    return http.get(url, headers: headers);
  }

  Future<http.Response> emailOtpVerification_RegisterONLY(OTPRequest otpRequest) {
    final url = Uri.parse('$baseUrl/registration/email');
    return http.post(url, headers: headers, body: json.encode(otpRequest.toJson()));
  }

  Future<http.Response> checkUsername(String username) {
    final url = Uri.parse('$baseUrl/registration/username/$username');
    return http.get(url, headers: headers);
  }

  Future<http.Response> registerUser(User user) {
    final url = Uri.parse('$baseUrl/registration');
    return http.post(url, headers: headers, body: json.encode(user.toJson()));
  }

  Future<http.Response> oauthRegister(String oauthType, User user) {
    final url = Uri.parse('$baseUrl/registration/oauth/$oauthType');
    return http.post(url, headers: headers, body: json.encode(user.toJson()));
  }

  // 登入相關
  Future<http.Response> getSalt(String username) {
    final url = Uri.parse('$baseUrl/salt/$username');
    return http.get(url, headers: headers);
  }

  // Future<http.Response> authenticate(Map<String, dynamic> credentials) {
  //   final url = Uri.parse('$baseUrl/authentication');
  //   return http.post(url, headers: headers, body: json.encode(credentials));
  // }

  Future<http.Response> oauthLogin(String oauthType,Map<String, dynamic> credentials) {
    final url = Uri.parse('$baseUrl/authentication/oauth/$oauthType');
    return http.post(url, headers: headers, body: json.encode(credentials));
  }

  Future<http.Response> authenticate(Map<String, dynamic> credentials) {
    final url = Uri.parse('$baseUrl/authentication');
    return http.post(url, headers: headers, body: json.encode(credentials));
  }
  

  Future<http.Response> validateToken(String version) {
    final url = Uri.parse('$baseUrl/token');
    return http.post(url, headers: headers, body: json.encode({'version': version}));
  }

  // 忘記密碼/重設密碼相關
  Future<http.Response> forgotPassword(String email) {
    final url = Uri.parse('$baseUrl/forgot/email/$email');
    return http.get(url, headers: headers);
  }

  Future<http.Response> resetPassword(PasswordReset passwordReset) {
    final url = Uri.parse('$baseUrl/password/reset');
    return http.post(url, headers: headers, body: json.encode(passwordReset.toJson()));
  }

  Future<http.Response> otpVerification(OTPRequest otpRequest) {
    final url = Uri.parse('$baseUrl/otp');
    return http.post(url, headers: headers, body: json.encode(otpRequest.toJson()));
  }

  // 心情量表相關
  Future<http.Response> getMentalRecords() {
    final url = Uri.parse('$baseUrl/mental_record');
    return http.get(url, headers: headers);
  }

  Future<http.Response> getMentalRecord(int listID) {
    final url = Uri.parse('$baseUrl/mental_record/$listID');
    return http.get(url, headers: headers);
  }

  Future<http.Response> submitMentalRecord(int listID, Map<String, dynamic> record) {
    final url = Uri.parse('$baseUrl/mental_record/$listID');
    return http.post(url, headers: headers, body: json.encode(record));
  }

  // Future<http.Response> getMentalRecordResult() {
  //   final url = Uri.parse('$baseUrl/mental_record/result');
  //   return http.get(url, headers: headers);
  // }

  // 每日心情相關
  Future<http.Response> postMood(MoodRecord moodRecord) {
    final url = Uri.parse('$baseUrl/mood/${moodRecord.mood}');
    return http.post(url, headers: headers, body: json.encode(moodRecord.toJson()));
  }

  Future<http.Response> getCheckin() {
    final url = Uri.parse('$baseUrl/record/checkin');
    return http.get(url, headers: headers);
  }

  // 心情打字機
  Future<http.Response> postTypewriter(TypewriterRecord typewriterRecord) {
    final url = Uri.parse('$baseUrl/mood/typewriter');
    return http.post(url, headers: headers, body: json.encode(typewriterRecord.toJson()));
  }

  // 點數相關
  Future<http.Response> getPoints() {
    final url = Uri.parse('$baseUrl/points');
    return http.get(url, headers: headers);
  }

  Future<http.Response> postPointsDeduction(PointsDeduction pointsDeduction) {
    final url = Uri.parse('$baseUrl/points/deduction');
    return http.post(url, headers: headers, body: json.encode(pointsDeduction.toJson()));
  }

  Future<http.Response> getPointsCheat() {
    final url = Uri.parse('$baseUrl/points/cheat');
    return http.get(url, headers: headers);
  }

  // 首頁Banner
  Future<http.Response> getHistoryStory() {
    final url = Uri.parse('$baseUrl/history_story');
    return http.get(url, headers: headers);
  }

  Future<http.Response> getVocabulary() {
    final url = Uri.parse('$baseUrl/vocabulary');
    return http.get(url, headers: headers);
  }

  // 遊戲
  Future<http.Response> postGameRecordCard(GameRecordCard gameRecordCard) {
    final url = Uri.parse('$baseUrl/game_record/card');
    return http.post(url, headers: headers, body: json.encode(gameRecordCard.toJson()));
  }

  Future<http.Response> postGameRecordOcean(GameRecordOcean gameRecordOcean) {
    final url = Uri.parse('$baseUrl/game_record/ocean');
    return http.post(url, headers: headers, body: json.encode(gameRecordOcean.toJson()));
  }

   // 愛來運動
  Future<http.StreamedResponse> uploadVideo(List<int> videoFile) {
    final url = Uri.parse('$baseUrl/video/analysis/upload');
    var request = http.MultipartRequest('POST', url)
      ..headers.addAll(headers)
      ..files.add(http.MultipartFile.fromBytes('video', videoFile, filename: 'video.mp4'));

    return request.send();
  }

  Future<http.Response> videoAnalysisWebhook(String videoName) {
    final url = Uri.parse('$baseUrl/video/analysis/webhook/$videoName');
    return http.get(url, headers: headers);
  }

  // 測試用API
  // Future<http.Response> testToken() {
  //   final url = Uri.parse('$baseUrl/test/token');
  //   return http.get(url, headers: headers);
  // }

  // Future<http.Response> testGetUsers() {
  //   final url = Uri.parse('$baseUrl/test/users');
  //   return http.get(url, headers: headers);
  // }

  // Future<http.Response> testGetUser(String userID) {
  //   final url = Uri.parse('$baseUrl/test/users/$userID');
  //   return http.get(url, headers: headers);
  // }

  // Future<http.Response> testPostData(Map<String, dynamic> data) {
  //   final url = Uri.parse('$baseUrl/test/post');
  //   return http.post(url, headers: headers, body: json.encode(data));
  // }

  // Future<http.Response> testCreateUser(Map<String, dynamic> data) {
  //   final url = Uri.parse('$baseUrl/test/users');
  //   return http.post(url, headers: headers, body: json.encode(data));
  // }

  // Future<http.Response> testPutUser(String userID, Map<String, dynamic> data) {
  //   final url = Uri.parse('$baseUrl/test/users/$userID');
  //   return http.put(url, headers: headers, body: json.encode(data));
  // }

  // Future<http.Response> testPatchUser(String userID, Map<String, dynamic> data) {
  //   final url = Uri.parse('$baseUrl/test/users/$userID');
  //   return http.patch(url, headers: headers, body: json.encode(data));
  // }

  // Future<http.Response> testDeleteUser(String userID) {
  //   final url = Uri.parse('$baseUrl/test/users/$userID');
  //   return http.delete(url, headers: headers);
  // }
}
