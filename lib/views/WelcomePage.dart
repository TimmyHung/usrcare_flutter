import 'package:flutter/material.dart';
import 'package:usrcare/strings.dart';
import 'package:usrcare/widgets/Button.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  UserProfile? _userProfile;

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
    return Scaffold(
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
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: Row(
                            children: [
                              Image.asset('assets/google.png', height: 35),
                              const SizedBox(width: 5),
                              const Text(GetString.loginWithGoogle),
                            ],
                          ),
                          type: ButtonType.secondary,
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CustomButton(
                          text: Row(
                            children: [
                              Image.asset('assets/line.png', height: 30),
                              const SizedBox(width: 5),
                              const Text(GetString.loginWithLine),
                            ],
                          ),
                          type: ButtonType.secondary,
                          onPressed: () {
                            LineLogin();
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
    path.moveTo(0, 0);
    path.lineTo(0, size.height * 0.45);
    path.quadraticBezierTo(
      size.width * 0.2, size.height,
      size.width * 0.5, size.height,
    );
    path.quadraticBezierTo(
      size.width * 0.5, size.height * 0.45,
      size.width, size.height * 0.55,
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
      size.width * 0.25, size.height * 0.56,
      size.width * 0.5, size.height * 0.51,
    );
    secondPath.quadraticBezierTo(
      size.width * 0.75, size.height * 0.45,
      size.width, size.height * 0.55,
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
