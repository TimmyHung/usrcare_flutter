import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:usrcare/api/APIService.dart';
import 'package:usrcare/strings.dart';
import 'package:usrcare/utils/MiscUtil.dart';
import 'package:usrcare/utils/SharedPreference.dart';
import 'package:usrcare/widgets/Button.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:usrcare/widgets/Dialog.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  void _GoogleLogin() async {
     const iOS_Clientid = "1059217142915-h9mm433edqc9kjvql43gbtaol985l6nl.apps.googleusercontent.com";
     const android_Clientid = "1059217142915-d8g811mbb67lbstm68829jturtjr5s55.apps.googleusercontent.com";
     GoogleSignIn googleSignIn = GoogleSignIn(
       scopes: ['email', 'profile', 'openid'],
       clientId: Platform.isIOS ? iOS_Clientid : android_Clientid,
     );

     try {
        GoogleSignInAccount? account = await googleSignIn.signIn();
        if (account != null) {
          GoogleSignInAuthentication auth = await account.authentication;

          APIService apiService = APIService();
          final credentials = {
            "id_token": auth.idToken,
          };
          var response = await apiService.oauthLogin("google", credentials, context);
          var x = handleHttpResponses(context, response, "Google登入時發生錯誤");
          if(x == null){
            return;
          }
          String? userToken = x["user_token"];
          String? userName = x["name"];
          if(userToken != null && userName != null){
            SharedPreferencesService().saveData(StorageKeys.userToken, userToken);
            SharedPreferencesService().saveData(StorageKeys.userName, userName);
            Navigator.pushNamed(context, "/home",arguments: {"token": userToken,"name": userName,},);
          }else{
            Navigator.pushNamed(context, "/register/InfoSetup", arguments: {
              "authType": "oauth-google",
              "id_token": auth.idToken,
            });
          }
       }
     } catch (error) {
       print("Google Sign-In failed. Error details: $error");
       showCustomDialog(context, "Google登入失敗", "詳細錯誤: $error");
     }
   }


  void _LineLogin() async {
    try {
      final result = await LineSDK.instance.login();
      APIService apiService = APIService();
      final credentials = {
        "id_token": result.accessToken.value,
      };
      var response = await apiService.oauthLogin("line", credentials, context);
      var x = handleHttpResponses(context, response, "Line登入時發生錯誤");
      if(x == null){
        return;
      }
      String? userToken = x["user_token"];
      String? userName = x["name"];
      if(userToken != null && userName != null){
        SharedPreferencesService().saveData(StorageKeys.userToken, userToken);
        SharedPreferencesService().saveData(StorageKeys.userName, userName);
        Navigator.pushNamed(context, "/home",arguments: {"token": userToken,"name": userName,},);
      }else{
        Navigator.pushNamed(context, "/register/InfoSetup", arguments: {
          "authType": "oauth-line",
          "id_token": result.accessToken.value,
        });
      }
    } on Exception catch (error) {
      print("Line Sing-In failed: $error");
    }
  }

  void _AppleLogin() async{
     try{
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: 'com.tku.usrcare.auth',
          redirectUri: Uri.parse('https://api.tkuusraicare.org/v1/authentication/oauth/apple/callback/signinwithapple',),
        ),
      );
      APIService apiService = APIService();
      final credentials = {
        "code": credential.authorizationCode,
        "id_token": credential.identityToken,
      };
      var response = await apiService.oauthLogin("apple", credentials, context);
      var x = handleHttpResponses(context, response, "Apple登入時發生錯誤");
      if(x == null){
        return;
      }
      String? userToken = x["user_token"];
      String? userName = x["name"];
      if(userToken != null && userName != null){
        SharedPreferencesService().saveData(StorageKeys.userToken, userToken);
        SharedPreferencesService().saveData(StorageKeys.userName, userName);
        Navigator.pushNamed(context, "/home",arguments: {"token": userToken,"name": userName,},);
      }else{
        Navigator.pushNamed(context, "/register/InfoSetup", arguments: {
          "authType": "oauth-apple",
          "id_token": credential.identityToken,
        });
      }
    }on Exception catch(error){
      print("Apple Sign-in error: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            const BackgroundPainter(),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Spacer(),
                              _buildLogoAndTitle(),
                              const Spacer(),
                              _buildWelcomeAndButtons(),
                              _buildSocialLoginOptions(),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoAndTitle() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(10),
          child: ClipOval(
            child: Image.asset(
              'assets/logo.png',
              height: 220,
              width: 220,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          GetString.appName,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeAndButtons() {
    return Column(
      children: [
        const Text(
          GetString.welcomeTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 30),
        CustomButton(
          text: GetString.register,
          type: ButtonType.primary,
          onPressed: () {
            Navigator.pushNamed(context, '/register');
          },
        ),
        const SizedBox(height: 15),
        CustomButton(
          text: GetString.login,
          type: ButtonType.secondary,
          onPressed: () {
            Navigator.pushNamed(context, '/login');
          },
        ),
      ],
    );
  }

  Widget _buildSocialLoginOptions() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Expanded(child: Divider(color: Colors.black54, thickness: 2)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text("或使用以下方式繼續", style: TextStyle(fontSize: 20)),
              ),
              Expanded(child: Divider(color: Colors.black54, thickness: 2)),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _socialLoginButton(Image.asset('assets/google.png', height: 35), _GoogleLogin),
            const SizedBox(width: 15),
            _socialLoginButton(Image.asset('assets/line.png', height: 35), _LineLogin),
            const SizedBox(width: 15),
            _socialLoginButton(const Icon(Icons.apple, size: 35, color: Colors.black), _AppleLogin, isApple: true),
          ],
        ),
      ],
    );
  }

  Widget _socialLoginButton(Widget IconWidget, VoidCallback onPressed, {bool isApple = false}) {
    return Expanded(
      child: CustomButton(
        text: SizedBox(
          height: 35,
          width: 35,
          child: IconWidget,
        ),
        type: ButtonType.secondary,
        onPressed: onPressed,
      ),
    );
  }
}

class BackgroundPainter extends StatelessWidget {
  const BackgroundPainter({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BackgroundPainterCustomPainter(),
      size: MediaQuery.of(context).size,
    );
  }
}

class _BackgroundPainterCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFA0C0FF)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(0, size.height * 0.45);
    path.quadraticBezierTo(
      size.width * 0.2,
      size.height,
      size.width * 0.5,
      size.height,
    );
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.45,
      size.width,
      size.height * 0.55,
    );
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);

    final secondPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final secondPath = Path();
    secondPath.moveTo(0, size.height * 0.45);
    secondPath.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.56,
      size.width * 0.5,
      size.height * 0.51,
    );
    secondPath.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.45,
      size.width,
      size.height * 0.55,
    );
    secondPath.lineTo(size.width, size.height);
    secondPath.lineTo(0, size.height);
    secondPath.close();

    canvas.drawPath(secondPath, secondPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}