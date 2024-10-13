// deep_link_service.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';
import 'package:usrcare/api/APIService.dart';
import 'package:usrcare/utils/MiscUtil.dart';
import 'package:usrcare/utils/SharedPreference.dart';
import 'package:usrcare/widgets/Dialog.dart';

class DeepLinkService {
  StreamSubscription? _sub;

  void init(BuildContext context) {
    _sub = uriLinkStream.listen((Uri? uri) async {
      if (uri != null) {
        switch (uri.scheme) {
          case 'signinwithapple':
            await _handleAppleSignInDeepLink(uri, context);
            break;
          default:
            print('Unsupported deep link: $uri');
        }
      }
    }, onError: (err) {
      print('Deep link error: $err');
    });
  }

  Future<void> _handleAppleSignInDeepLink(Uri uri, BuildContext context) async {
    final appleUserID = uri.queryParameters['code'];
    final appleJWT = uri.queryParameters['id_token'];
    APIService apiService = APIService();
    final credential = {
      "code": appleUserID,
      "id_token": appleJWT,
    };
    try{
      final response = await apiService.oauthLogin("apple", credential, context);
      var x = handleHttpResponses(context, response, "Apple登入時發生錯誤");
        if(x == null){
          return;
        }
        String? userToken = x["user_token"];
        String? userName = x["name"];
        if(userToken != null && userName != null){
          SharedPreferencesService().saveData(StorageKeys.userToken, userToken);
          SharedPreferencesService().saveData(StorageKeys.userName, userName);
          Navigator.pushNamed(context, "/home");
        }else{
          Navigator.pushNamed(context, "/register/InfoSetup", arguments: {
            "authType": "oauth-apple",
            "id_token": appleJWT,
          });
        }
    }on Exception catch(error){
      print("Apple Sign-in error: $error");
    }
    
  }

  void dispose() {
    _sub?.cancel();
  }
}
