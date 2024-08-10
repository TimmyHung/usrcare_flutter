import 'package:flutter/material.dart';
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
  UserProfile? _userProfile;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus()async{
    var userToken = await SharedPreferencesService().getData(StorageKeys.userToken) ?? "";
    var userName = await SharedPreferencesService().getData(StorageKeys.userName) ?? "";

    if(userToken.isNotEmpty && userName.isNotEmpty){
      Navigator.pushNamed(context, "/home");
    }else{
      await SharedPreferencesService().clearAllData();
    }
  }

  void LineLogin() async {
    try {
      final result = await LineSDK.instance.login();
      setState(() {
        _userProfile = result.userProfile;
        print(_userProfile);
        // user id -> result.userProfile?.userId
        // user name -> result.userProfile?.displayName
        // user avatar -> result.userProfile?.pictureUrl
        // etc...
      });
    } on Exception catch (e) {
      print(e);
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
            Positioned.fill(
              child: CustomPaint(
                painter: BackgroundPainter(),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(150),
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(10),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/logo.png',
                          height: 200,
                          width: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      GetString.appName,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 100),
                    const Text(
                      GetString.welcomeTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
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
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(right: 10.0),
                            color: Colors.black54,
                            height: 2,
                          ),
                        ),
                        const Text("或使用以下方式繼續", style: TextStyle(fontSize: 20)),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(left: 10.0),
                            color: Colors.black54,
                            height: 2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: SizedBox(
                              height: 35,
                              width: 35,
                              child: Image.asset('assets/google.png', height: 35)),
                            type: ButtonType.secondary,
                            onPressed: () {
                              // GoogleLogin();
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomButton(
                            text: SizedBox(
                              height: 35,
                              width: 35,
                              child: Image.asset('assets/line.png', height: 35)),
                            type: ButtonType.secondary,
                            onPressed: () {
                              // LineLogin();
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomButton(
                            text: const SizedBox(
                              height: 70,
                              width: 70,
                              child: Icon(Icons.apple, size: 70, color: Colors.black)),
                            type: ButtonType.secondary,
                            onPressed: () async {
                              try{
                                final credential = await SignInWithApple.getAppleIDCredential(
                                  scopes: [
                                    AppleIDAuthorizationScopes.email,
                                    AppleIDAuthorizationScopes.fullName,
                                  ],
                                  webAuthenticationOptions: WebAuthenticationOptions(
                                    clientId: 'com.tku.usrcare.auth',
                                    redirectUri: Uri.parse('https://api.tkuusraicare.org/v1/authentication/oauth/apple/callback',),
                                  ),
                                  // TODO: Remove these if you have no need for them
                                  // nonce: 'example-nonce',
                                  // state: 'example-state',
                                );
                                APIService apiService = APIService();
                                final credentials = {
                                  "code": credential.authorizationCode,
                                  "id_token": credential.identityToken,
                                };
                                var response = await apiService.oauthLogin("apple", credentials);
                                var x = handleHttpResponses(context, response, "登入時發生錯誤");
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
                                    "authType": "oauth",
                                    "id_token": credential.identityToken,
                                  });
                                }



                                // This is the endpoint that will convert an authorization code obtained
                                // via Sign in with Apple into a session in your system

                                  // If we got this far, a session based on the Apple ID credential has been created in your system,
                                  // and you can now set this as the app's session
                                  // ignore: avoid_print
                                  // print(session);
                              }on Exception catch(e){
                                print(e);
                              }
                             
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFA0C0FF)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, -50);  // 向上移動 50 單位
    path.lineTo(0, size.height * 0.45 - 50);
    path.quadraticBezierTo(
      size.width * 0.2,
      size.height - 50,
      size.width * 0.5,
      size.height - 50,
    );
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.45 - 50,
      size.width,
      size.height * 0.55 - 50,
    );
    path.lineTo(size.width, -50);
    path.close();

    canvas.drawPath(path, paint);

    final secondPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final secondPath = Path();
    secondPath.moveTo(0, size.height * 0.45 - 50);
    secondPath.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.56 - 50,
      size.width * 0.5,
      size.height * 0.51 - 50,
    );
    secondPath.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.45 - 50,
      size.width,
      size.height * 0.55 - 50,
    );
    secondPath.lineTo(size.width, size.height);
    secondPath.lineTo(0, size.height);
    secondPath.close();

    canvas.drawPath(secondPath, secondPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
