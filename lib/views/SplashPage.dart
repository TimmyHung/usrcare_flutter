import 'dart:io';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:usrcare/api/APIService.dart';
import 'package:usrcare/utils/MiscUtil.dart';
import 'package:usrcare/utils/SharedPreference.dart';
import 'package:usrcare/utils/DeepLinkService.dart';
import 'package:usrcare/widgets/Dialog.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final DeepLinkService _deepLinkService = DeepLinkService();
  bool forceUpdate = false;
  late String userToken;
  late String userName;

  @override
  void initState() {
    super.initState();
    _deepLinkService.init(context);
    _versionTest();
  }

  @override
  void dispose() {
    _deepLinkService.dispose();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    userToken = await SharedPreferencesService().getData(StorageKeys.userToken) ?? "";
    userName = await SharedPreferencesService().getData(StorageKeys.userName) ?? "";

    if (userToken.isNotEmpty && userName.isNotEmpty) {
      await _validateTokenAndNavigate();
    } else {
      await SharedPreferencesService().clearAllData();
      Navigator.pushNamed(context, "/welcome");
    }
  }

  Future<void> _validateTokenAndNavigate() async {
    final APIService apiService = APIService(token: userToken);
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String appVersion = packageInfo.version;

    var response = await apiService.validateToken(appVersion, context);
    var x = handleHttpResponses(context, response, null);

    if (x != null) {
      Navigator.pushReplacementNamed(context,"/home",arguments: {"token": userToken,"name": userName});
    } else {
      await SharedPreferencesService().clearAllData();
      Navigator.pushNamed(context, "/welcome");
      showCustomDialog(
        context,
        "請重新登入",
        "您的帳戶已在其它裝置上登入，請重新登入以繼續使用。",
        closeButton: true,
      );
    }
  }

  void _versionTest() async {
    final versionStatus = await _getVersionStatus();

    if (versionStatus == null) {
      _checkLoginStatus();
      return;
    }

    final String? skippedVersion = await SharedPreferencesService().getData(StorageKeys.skipUpdateVersion);
    if (skippedVersion == versionStatus["storeVersion"]) {
      _checkLoginStatus();
      return;
    }

    final needUpdate = versionStatus["canUpdate"];
    if (needUpdate) {
      APIService apiService = APIService();
      final response = await apiService.getMinimumAppVersion();
      final x = handleHttpResponses(context, response, "取得APP最低版本限制時發生錯誤");
      final String? minimum_version = Platform.isIOS ? x["iOS"] : x["Android"];

      if(minimum_version != null){
        forceUpdate = _compareVersion(minimum_version, versionStatus["localVersion"]) > 0;
      }
      _showUpdateDialog(versionStatus);
    } else {
      _checkLoginStatus();
    }
  }

  Future<Map<String, dynamic>?> _getVersionStatus() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String localVersion = packageInfo.version;
    const String bundleId = "com.tku.usrcare";

    final String appStoreUrl = Platform.isIOS
        ? 'https://itunes.apple.com/lookup?bundleId=$bundleId'
        : 'https://play.google.com/store/apps/details?id=$bundleId';

    try {
      final response = await http.get(Uri.parse(appStoreUrl));
      if (response.statusCode == 200) {
        if (Platform.isIOS) {
          final jsonResponse = jsonDecode(response.body);
          final String appStoreVersion = jsonResponse['results'][0]['version'];
          return {
            "canUpdate": _compareVersion(appStoreVersion, localVersion) > 0,
            "localVersion": localVersion,
            "storeVersion": appStoreVersion,
            "appStoreLink": jsonResponse['results'][0]['trackViewUrl'],
          };
        } else {
          final regex = RegExp(r'\[\[\[\"(\d+\.\d+(\.[a-z]+)?(\.[^"]*)?)\"\]\]');
          final storeVersion = regex.firstMatch(response.body)?.group(1);
          return storeVersion != null
              ? {
                  "canUpdate": _compareVersion(storeVersion, localVersion) > 0,
                  "localVersion": localVersion,
                  "storeVersion": storeVersion,
                  "appStoreLink": appStoreUrl,
                }
              : null;
        }
      }
    } catch (e) {
      print('取得版本資訊時發生錯誤: $e');
    }
    return null;
  }

  void _showUpdateDialog(Map<String, dynamic> versionStatus) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.center,
          title: Center(child: Text("發現新版本 ${versionStatus['storeVersion']}", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 30))),
          content: Text(
            forceUpdate
                ? "目前版本已不再支援，為了您的資料安全與APP穩定性，請立即更新至最新版本。"
                : "新版本已推出！立即更新享受最新功能！",
            style: const TextStyle(fontSize: 24),
          ),
          actions: <Widget>[
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    child: const Text("前往更新", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      _launchUrl(versionStatus['appStoreLink']);
                    },
                  ),
                ),
                TextButton(
                  onPressed: forceUpdate ? null : () async {
                    await SharedPreferencesService().saveData(StorageKeys.skipUpdateVersion, versionStatus["storeVersion"]);
                    Navigator.pop(context);
                    _checkLoginStatus();
                  },
                  child: Text(forceUpdate ? "無法跳過本次更新" : "跳過本次更新",style: const TextStyle(fontSize: 18, color: Colors.grey)),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  int _compareVersion(String version1, String version2) {
    List<String> v1Components = version1.split('.');
    List<String> v2Components = version2.split('.');

    for (int i = 0; i < v1Components.length || i < v2Components.length; i++) {
      int v1Component = i < v1Components.length ? int.parse(v1Components[i]) : 0;
      int v2Component = i < v2Components.length ? int.parse(v2Components[i]) : 0;
      if (v1Component > v2Component) {
        return 1;
      } else if (v1Component < v2Component) {
        return -1;
      }
    }
    return 0;
  }

  Future<void> _launchUrl(String url) async {
    final targetUri = Uri.parse(url);
    if (await canLaunchUrl(targetUri)) {
      await launchUrl(targetUri, mode: LaunchMode.externalApplication);
    } else {
      throw '無法打開此連結 $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Image.asset("assets/logo.png")),
          ],
        ),
      ),
    );
  }
}
