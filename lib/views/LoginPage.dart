import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:usrcare/api/APIService.dart';
import 'package:usrcare/utils/MiscUtil.dart';
import 'package:usrcare/widgets/Dialog.dart';
import 'package:usrcare/widgets/TextField.dart';
import 'package:usrcare/widgets/button.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController accountController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  APIService api = APIService();

  bool _passwordVisible = false;
  bool _disableLoginButton = true;

  void _validateInput(String? value) {
    print("OK");
    if(accountController.text.isEmpty || passwordController.text.isEmpty) {
      setState(() {
        _disableLoginButton = true;
      });
    } else {
      setState(() {
        _disableLoginButton = false;
      });
    }
  }

  void _loginProcess()async{
    final credentials = {
      'username': accountController.text,
      'password': passwordController.text,
    };

    dynamic response = await api.checkUsername(credentials['username']!);
    dynamic x = handleHttpResponses(context, response, "驗證帳號時發生錯誤");
    if (!x["exist"]){
      showCustomDialog(context, "登入失敗", "帳號或密碼輸入錯誤");
      return;
    }

    _getSalt().then((salt) {
      credentials['password'] = hashPassword(credentials['password']!, salt);
    });

    response = await api.authenticate(credentials);
    x = handleHttpResponses(context, response, null);
    if(x == null){
      showCustomDialog(context, "登入失敗", "帳號或密碼輸入錯誤");
      return;
    }
    final token = x["user_token"];
    final name = x["name"];
    print(token + "\n" +name);
  }

  Future<String> _getSalt()async{
    final response = await api.getSalt(accountController.text);
    final x = handleHttpResponses(context, response, "取得加密鹽巴時發生錯誤");
    if(x == null){
      return "";
    }
    return x["salt"];
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
                    '歡迎回來!',
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(height: 10),
                  CustomTextField(
                    label: '帳號',
                    inputType: InputType.text,
                    controller: accountController,
                    onChanged: _validateInput,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    label: '密碼',
                    inputType: InputType.password,
                    suffixIcon: _passwordVisible ? Icons.visibility : Icons.visibility_off,
                    onChanged: _validateInput,
                    controller: passwordController,
                    onSuffixIconPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                    obscureText: !_passwordVisible,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: '登入',
                      type: ButtonType.primary,
                      disabled: _disableLoginButton,
                      onPressed: () {
                        _loginProcess();
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(onPressed: (){
                    Navigator.pushNamed(context, '/login/pwdRecovery');
                  }, child: const Text("忘記密碼？", style: TextStyle(color: Colors.black87, fontSize: 22))),
                  const Spacer()
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PasswordRecoveryPage extends StatefulWidget {
  const PasswordRecoveryPage({super.key});

  @override
  _PasswordRecoveryPageState createState() => _PasswordRecoveryPageState();
}

class _PasswordRecoveryPageState extends State<PasswordRecoveryPage> {
  final TextEditingController emailController = TextEditingController();
  final APIService apiService = APIService();
  String _email = '';
  bool _isEmailValid = false;

  void _validateEmail(String email) {
    setState(() {
      _email = email;
      if (email.isEmpty) {
        _isEmailValid = false;
      } else {
        final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
        _isEmailValid = regex.hasMatch(email);
      }
    });
  }

  void _checkEmailExists(BuildContext context) async {
    print("信箱:$_email");
    final response = await apiService.forgotPassword(_email);
    final responseBody = json.decode(response.body);
    switch(responseBody["status"]){
      case "single":
        List user = [{
          "user_token": responseBody["user_token"],
          "username:": responseBody["username"],
        }];
        final arguments = {"route": "/login/pwdReset", "email": _email, "users": user};
        Navigator.pushNamed(context, '/EmailVerification', arguments: arguments);
        break;
      case "multiple":
        List users = responseBody["users"];
        final arguments = {"route": "/login/pwdReset", "email": _email, "users": users};
        Navigator.pushNamed(context, '/EmailVerification', arguments: arguments);
        break;
      default:
        showConfirmDialog(context, "帳號不存在", "請問是否要前往註冊？", toRegisterPage);
        break;
    }
  }

  void toRegisterPage(){
    Navigator.pushReplacementNamed(context, '/register');
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
                    '密碼找回!',
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  CustomTextField(
                    label: '電子信箱',
                    
                    inputType: InputType.email,
                    suffixIcon: _email.isEmpty
                        ? null
                        : (_isEmailValid ? Icons.check_circle : Icons.cancel),
                    suffixIconColor: (_isEmailValid ? Colors.green : Colors.red),
                    onChanged: _validateEmail,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: '下一步',
                      type: ButtonType.primary,
                      disabled: !_isEmailValid,
                      onPressed: () {
                        // 註冊邏輯
                        _checkEmailExists(context);
                        // showConfirmDialog(context, "帳號已存在", "請問是否要前往註冊", (){Navigator.pushReplacementNamed(context, '/register');});
                      },
                    ),
                  ),
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

class PasswordResetPage extends StatefulWidget {
  const PasswordResetPage({super.key});

  @override
  _PasswordResetPageState createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final TextEditingController emailController = TextEditingController();
  final APIService apiService = APIService();
  String _email = '';
  bool _isEmailValid = false;

  void _validateEmail(String email) {
    setState(() {
      _email = email;
      if (email.isEmpty) {
        _isEmailValid = false;
      } else {
        final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
        _isEmailValid = regex.hasMatch(email);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List users = ModalRoute.of(context)?.settings.arguments as List;
    print(users);

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
                    '請選擇要重設密碼的帳號!',
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  CustomTextField(
                    label: '帳號列表',
                    inputType: InputType.email,
                    suffixIcon: _email.isEmpty
                        ? null
                        : (_isEmailValid ? Icons.check_circle : Icons.cancel),
                    suffixIconColor: (_isEmailValid ? Colors.green : Colors.red),
                    onChanged: _validateEmail,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: '重設',
                      type: ButtonType.primary,
                      disabled: !_isEmailValid,
                      onPressed: () {
                        // 註冊邏輯
                        // _checkEmailExists(context);
                        // showConfirmDialog(context, "帳號已存在", "請問是否要前往註冊", (){Navigator.pushReplacementNamed(context, '/register');});
                      },
                    ),
                  ),
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
      size.width * 0.2, size.height * 0.75,
      size.width * 0.5, size.height * 0.75,
    );
    path.quadraticBezierTo(
      size.width * 0.5, size.height * 0.3,
      size.width, size.height * 0.4,
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
      size.width * 0.25, size.height * 0.4,
      size.width * 0.5, size.height * 0.35,
    );
    secondPath.quadraticBezierTo(
      size.width * 0.75, size.height * 0.3,
      size.width, size.height * 0.4,
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
