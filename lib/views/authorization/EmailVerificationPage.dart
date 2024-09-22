import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:usrcare/api/APIModels.dart';
import 'package:usrcare/api/APIService.dart';
import 'package:usrcare/utils/ColorUtil.dart';
import 'package:usrcare/utils/MiscUtil.dart';
import 'package:usrcare/widgets/Button.dart';
import 'package:usrcare/widgets/Dialog.dart';

class EmailVerificationPage extends StatelessWidget {
  EmailVerificationPage({
    super.key,
    // required this.routeTo,
    // this.arguments,
  });

  final APIService apiService = APIService();

  void _validOTP(BuildContext context, String verificationCode) async {
    Map<String, dynamic> arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    String email = arguments["email"];
    // 驗證邏輯
    OTPRequest otpRequest = OTPRequest(email: email, OTP: verificationCode);

    final response =
        await apiService.emailOtpVerification_RegisterONLY(otpRequest);
    final handledResponse =
        handleHttpResponses(context, response, "OTP驗證時發生錯誤");
    if (handledResponse == null) {
      return;
    }
    bool OTPpass = handledResponse['success'];
    if (OTPpass) {
      final String route = arguments['route'];
      arguments.remove("route");

      Navigator.pushNamed(context, route, arguments: arguments);
    } else {
      showCustomDialog(context, "OTP驗證失敗", "請檢查您在信箱內收到的OTP六位數字是否正確");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 80),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: CustomButton(
                      text: '',
                      type: ButtonType.circular,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '電子信箱驗證',
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(height: 20),
                  OtpTextField(
                    autoFocus: true,
                    keyboardType: TextInputType.number,
                    numberOfFields: 6,
                    fieldWidth: MediaQuery.of(context).size.width * 0.14,
                    borderWidth: 2,
                    textStyle: const TextStyle(fontSize: 40),
                    margin: const EdgeInsets.only(right: 2.0),
                    borderRadius: BorderRadius.circular(10),
                    borderColor: ColorUtil.primary,
                    showFieldAsBox: true,
                    onSubmit: (String verificationCode) {
                      //當所有代碼都填入後執行
                      _validOTP(context, verificationCode);
                    },
                  ),
                  const SizedBox(height: 20),
                  const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text("請輸入信箱內收到的六位數字驗證碼",
                          style: TextStyle(fontSize: 30))),
                  const Spacer(),
                  const Spacer(),
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
    path.moveTo(0, -size.height * 0.2);
    path.lineTo(0, size.height * 0.3);
    path.quadraticBezierTo(
      size.width * 0.2,
      size.height * 0.75,
      size.width * 0.5,
      size.height * 0.75,
    );
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.3,
      size.width,
      size.height * 0.4,
    );
    path.lineTo(size.width, -size.height * 0.2);
    path.close();

    canvas.drawPath(path, paint);

    final secondPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final secondPath = Path();
    secondPath.moveTo(0, size.height * 0.3);
    secondPath.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.4,
      size.width * 0.5,
      size.height * 0.35,
    );
    secondPath.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.3,
      size.width,
      size.height * 0.4,
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
