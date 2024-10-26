import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uni_links/uni_links.dart';
import 'package:usrcare/api/APIService.dart';
import 'package:usrcare/providers/OAuthBindingList_Provider.dart';
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
          case 'bindingwithapple':
            await _handleAppleBindingDeepLink(uri, context);
            break;
          default:
            print('Unsupported deep link: $uri');
        }
      }
    }, onError: (err) {
      print('Deep link error: $err');
    });
  }

  void dispose() {
    _sub?.cancel();
  }

  Future<void> _handleAppleSignInDeepLink(Uri uri, BuildContext context) async {
    final appleUserID = uri.queryParameters['code'];
    final appleJWT = uri.queryParameters['id_token'];
    APIService apiService = APIService();
    final credential = {
      "code": appleUserID,
      "id_token": appleJWT,
    };
    try {
      final response = await apiService.oauthLogin("apple", credential, context);
      var x = handleHttpResponses(context, response, "Apple登入時發生錯誤");
      if (x == null) {
        return;
      }
      String? userToken = x["user_token"];
      String? userName = x["name"];
      if (userToken != null && userName != null) {
        await SharedPreferencesService().saveData(StorageKeys.userToken, userToken);
        await SharedPreferencesService().saveData(StorageKeys.userName, userName);
        Navigator.pushNamed(context, "/home", arguments: {"token": userToken, "name": userName});
      } else {
        Navigator.pushNamed(context, "/register/InfoSetup", arguments: {
          "authType": "oauth-apple",
          "id_token": appleJWT,
        });
      }
    } on Exception catch (error) {
      print("Apple Sign-in error: $error");
    }
  }

  Future<void> _handleAppleBindingDeepLink(Uri uri, BuildContext context) async {
    final userToken = await SharedPreferencesService().getData(StorageKeys.userToken);
    final appleUserCode = uri.queryParameters['code'];
    final appleJWT = uri.queryParameters['id_token'];

    if (appleUserCode == null || appleJWT == null) {
      showCustomDialog(context, "綁定失敗", "無法取得必要的認證資訊。");
      return;
    }

    APIService apiService = APIService(token: userToken);
    final credentials = {
      "code": appleUserCode,
      "id_token": appleJWT,
    };

    try {
      var response = await apiService.oauthBinding("apple", credentials, context);
      var x = handleHttpResponses(context, response, "綁定 Apple 帳戶時發生錯誤");
      if (x == null) {
        return;
      }
      String? bindExistAccountID = x["exist"];
      if (bindExistAccountID != null) {
        showConfirmDialog(
          context,
          "Apple 帳戶已綁定",
          "Apple 帳戶已綁定於其他帳戶，請問您是否願意改綁定至此帳戶上？",
          confirmText: "綁定至此帳號上",
          cancelText: "取消並返回",
          () async {
            final replacementCredentials = {
              "id_token": appleJWT,
              "old_userID": bindExistAccountID,
            };
            var replacementResponse = await apiService.oauthBindingReplacement("apple", replacementCredentials, context);
            var replacementResult = handleHttpResponses(context, replacementResponse, "取代綁定 Apple 帳戶時發生錯誤");
            if (replacementResult == null) {
              return;
            }

            showCustomDialog(context, "綁定成功", "已成功將 Apple 帳戶綁定至此帳號上");
            _updateBindingState(context, "Apple", true);
          },
        );
      } else {
        showCustomDialog(context, "綁定成功", "已成功將 Apple 帳戶綁定至此帳號上");
        _updateBindingState(context, "Apple", true);
      }
    } on Exception catch (error) {
      print("Apple Binding error: $error");
    }
  }

  void _updateBindingState(BuildContext context, String platform, bool isBound) async {
    final provider = Provider.of<OAuthBindingList_Provider>(context, listen: false);
    provider.updateBinding(platform, isBound);

    final localOauthBindingList = await SharedPreferencesService().getData(StorageKeys.oauthBindingList);
    if (localOauthBindingList != null) {
      final decoded = jsonDecode(localOauthBindingList);
      Map<String, bool> oauth_binding_list = Map<String, bool>.from(decoded);
      oauth_binding_list[platform] = isBound;
      await SharedPreferencesService().saveData(StorageKeys.oauthBindingList, jsonEncode(oauth_binding_list));
    }
  }
}
