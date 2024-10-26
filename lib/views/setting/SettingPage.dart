import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:usrcare/api/APIService.dart';
import 'package:usrcare/providers/OAuthBindingList_Provider.dart';
import 'package:usrcare/utils/ColorUtil.dart';
import 'package:usrcare/utils/MiscUtil.dart';
import 'package:usrcare/utils/SharedPreference.dart';
import 'package:usrcare/views/setting/AboutAppPage.dart';
import 'package:usrcare/views/setting/ContactUsPage.dart';
import 'package:usrcare/views/setting/FAQPage.dart';
import 'package:usrcare/views/setting/PrivacyPolicyPage.dart';
import 'package:usrcare/views/setting/TermsOfServicePage.dart';
import 'package:usrcare/widgets/Dialog.dart';

class SettingPage extends StatefulWidget {
  final APIService apiService;
  const SettingPage({super.key, required this.apiService});

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  Future<void> _handleOAuthBinding(String provider) async {
    try {
      Map<String, dynamic> credentials = {};
      switch (provider) {
        case "line":
          {
            final result = await LineSDK.instance.login();
            credentials = {"id_token": result.accessToken.value};
            break;
          }
        case "apple":
          {
            final credential = await SignInWithApple.getAppleIDCredential(
              scopes: [
                AppleIDAuthorizationScopes.email,
                AppleIDAuthorizationScopes.fullName,
              ],
              webAuthenticationOptions: WebAuthenticationOptions(
                clientId: 'com.tku.usrcare.auth',
                redirectUri: Uri.parse(
                  'https://api.tkuusraicare.org/v1/authentication/oauth/apple/callback/bindingwithapple',
                ),
              ),
            );
            credentials = {
              "code": credential.authorizationCode,
              "id_token": credential.identityToken,
            };
            break;
          }
        case "google":
          {
            showToast(context, "功能開發中...");
            return;
          }
        default:
          {
            return;
          }
      }

      var response = await widget.apiService.oauthBinding(provider, credentials, context);
      var x = handleHttpResponses(context, response, "綁定${_getProviderName(provider)}帳戶時發生錯誤");
      if (x == null) return;

      String? bindExistAccountID = x["exist"];
      if (bindExistAccountID != null) {
        showConfirmDialog(
          context,
          "${_getProviderName(provider)}帳戶已綁定",
          "${_getProviderName(provider)}帳戶已綁定於其他帳戶，請問您是否願意改綁定至此帳戶上？",
          confirmText: "綁定至此帳號上",
          cancelText: "取消並返回",
          () async {
            credentials["old_userID"] = bindExistAccountID;
            var response = await widget.apiService.oauthBindingReplacement(provider, credentials, context);
            var x = handleHttpResponses(context, response, "取代綁定${_getProviderName(provider)}帳戶時發生錯誤");
            if (x == null) return;
            Provider.of<OAuthBindingList_Provider>(context, listen: false)
                .updateBinding(_getProviderName(provider), true);
            showCustomDialog(context, "綁定成功", "已成功將${_getProviderName(provider)}帳戶綁定至此帳號上", closeButton: true);
          },
        );
      } else {
        Provider.of<OAuthBindingList_Provider>(context, listen: false)
            .updateBinding(_getProviderName(provider), true);
        showCustomDialog(context, "綁定成功", "已成功將${_getProviderName(provider)}帳戶綁定至此帳號上", closeButton: true);
      }
    } on Exception catch (error) {
      print("${_getProviderName(provider)} Binding failed: $error");
    }
  }

  Future<void> _handleOAuthUnbinding(String provider) async {
    final response = await widget.apiService.oauthUnBinding(provider, context);
    if (handleHttpResponses(context, response, "取消綁定${_getProviderName(provider)}帳戶時發生錯誤") == null) return;
    Provider.of<OAuthBindingList_Provider>(context, listen: false)
        .updateBinding(_getProviderName(provider), false);
    showCustomDialog(context, "取消綁定成功", "您已成功取消此帳戶的 ${_getProviderName(provider)} 帳號綁定", closeButton: true);
  }

  String _getProviderName(String provider) {
    switch (provider) {
      case 'line':
        return 'LINE';
      case 'apple':
        return 'Apple';
      case 'google':
        return 'Google';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> OAuthBindingButton = [
      {
        'name': 'Google',
        'icon': Image.asset('assets/google.png', height: 30),
        'providerKey': 'google',
      },
      {
        'name': 'LINE',
        'icon': Image.asset('assets/line.png', height: 30),
        'providerKey': 'line',
      },
      {
        'name': 'Apple',
        'icon': const Icon(Icons.apple, size: 30, color: Colors.black),
        'providerKey': 'apple',
      },
    ];

    final List<Map<String, dynamic>> settings = [
      {
        'icon': Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black87),
          ),
          child: Image.asset('assets/Icons/app_icon.png', height: 30),
        ),
        'title': '關於APP',
        'route': const AboutAppPage(),
      },
      {
        'icon': const Icon(Icons.message_outlined, size: 30),
        'title': '聯絡我們',
        'route': const ContactUsPage(),
      },
      {
        'icon': const Icon(Icons.help_outline, size: 30),
        'title': '常見問題',
        'route': const FAQPage(),
      },
      {
        'icon': const Icon(Icons.privacy_tip_outlined, size: 30),
        'title': '隱私政策',
        'route': const PrivacyPolicyPage(),
      },
      {
        'icon': const Icon(Icons.people_outline_outlined, size: 30),
        'title': '服務條款',
        'route': const TermsOfServicePage(),
      },
      {
        'icon': const Icon(Icons.card_giftcard_outlined, size: 30),
        'title': '輸入獎勵代碼',
        'route': null,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
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
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Consumer<OAuthBindingList_Provider>(
                    builder: (context, provider, child) {
                      return ListView.separated(
                        shrinkWrap: true,
                        itemCount: OAuthBindingButton.length + settings.length,
                        itemBuilder: (context, index) {
                          if (index < OAuthBindingButton.length) {
                            var item = OAuthBindingButton[index];
                            bool isBound = provider.oauthBindingList[item['name']]!;
                            int boundCount = provider.oauthBindingList.values.where((v) => v).length;
                            bool canUnbind = !(isBound && boundCount <= 1);
                            TextStyle textStyle = canUnbind ? const TextStyle(fontSize: 24) : TextStyle(fontSize: 24, decoration: TextDecoration.lineThrough, decorationThickness: 2.0, decorationColor: Colors.red[700]);

                            return Container(
                              child: ListTile(
                                leading: item['icon'] as Widget?,
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          isBound
                                              ? '取消綁定${item['name']}帳戶'
                                              : '綁定${item['name']}快速登入',
                                          style: textStyle,
                                        ),
                                      ),
                                    ),
                                    const Icon(Icons.arrow_forward_ios)
                                  ],
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                                onTap: () {
                                  if (isBound) {
                                    if (boundCount <= 1) {
                                      showCustomDialog(context, "無法取消綁定", "目前的帳戶只有綁定這個登入方式，如果取消綁定您就沒辦法再登入這個帳戶了！", closeButton: true);
                                    } else {
                                      _handleOAuthUnbinding(item['providerKey'] as String);
                                    }
                                  } else {
                                    _handleOAuthBinding(item['providerKey'] as String);
                                  }
                                },
                              ),
                            );
                          } else {
                            var setting = settings[index - OAuthBindingButton.length];
                            return ListTile(
                              leading: setting['icon'] as Widget?,
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        setting['title'] as String,
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios)
                                ],
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                              onTap: () {
                                if (setting['route'] != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => setting['route'] as Widget),
                                  );
                                } else {
                                  showToast(context, "功能開發中...");
                                }
                              },
                            );
                          }
                        },
                        separatorBuilder: (context, index) {
                          return const Divider(
                            color: Colors.black,
                            thickness: 1,
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      showConfirmDialog(context, "登出", "確定要登出嗎？", () async {
                        await SharedPreferencesService().clearAllData();
                        Navigator.pushNamed(context, "/");
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorUtil.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    ),
                    child: const Text(
                      '登出',
                      style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
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
