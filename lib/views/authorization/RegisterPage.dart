import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:usrcare/api/APIModels.dart';
import 'package:usrcare/api/APIService.dart';
import 'package:usrcare/utils/ColorUtil.dart';
import 'package:usrcare/utils/MiscUtil.dart';
import 'package:usrcare/utils/SharedPreference.dart';
import 'package:usrcare/widgets/Dialog.dart';
import 'package:usrcare/widgets/DropDown.dart';
import 'package:usrcare/widgets/TextField.dart';
import 'package:usrcare/widgets/button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
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
    final response = await apiService.checkEmail(_email);

    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      bool exists = responseBody['exist'];
      if (exists) {
        // showCustomDialog(context, "信箱已註冊", "此信箱已被註冊，請使用其他信箱。");
        final arguments = {"email": _email};
        Navigator.pushNamed(context, '/register/AccountSetup',
            arguments: arguments);
      } else {
        final arguments = {"route": "/register/AccountSetup", "email": _email};
        Navigator.pushNamed(context, '/EmailVerification',
            arguments: arguments);
      }
    } else {
      showCustomDialog(
          context, "驗證Email時發生錯誤", response.reasonPhrase.toString());
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
                    '歡迎註冊新帳號!',
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
                    suffixIconColor:
                        (_isEmailValid ? Colors.green : Colors.red),
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

class AccountSetupPage extends StatefulWidget {
  const AccountSetupPage({super.key});

  @override
  _AccountSetupPageState createState() => _AccountSetupPageState();
}

class _AccountSetupPageState extends State<AccountSetupPage> {
  final TextEditingController accountController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController repeatPasswordController =
      TextEditingController();
  final APIService apiService = APIService();

  bool _passwordVisible = false;
  bool _repeatPasswordVisible = false;
  String? _accountError;
  String? _passwordError;
  String? _repeatPasswordError;

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
                        Navigator.popUntil(
                            context, ModalRoute.withName("/register"));
                      },
                      icon: const Icon(Icons.arrow_back),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '建立新帳號（1/2)',
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  const Spacer(),
                  CustomTextField(
                    label: '帳號',
                    controller: accountController,
                    inputType: InputType.text,
                    errorText: _accountError,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    label: '密碼',
                    inputType: InputType.password,
                    controller: passwordController,
                    suffixIcon: _passwordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    onSuffixIconPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                    obscureText: !_passwordVisible,
                    errorText: _passwordError,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    label: '再次輸入密碼',
                    inputType: InputType.password,
                    controller: repeatPasswordController,
                    suffixIcon: _repeatPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    onSuffixIconPressed: () {
                      setState(() {
                        _repeatPasswordVisible = !_repeatPasswordVisible;
                      });
                    },
                    obscureText: !_repeatPasswordVisible,
                    errorText: _repeatPasswordError,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: '下一步',
                      type: ButtonType.primary,
                      onPressed: () {
                        _registerProcess(context);
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

  Future<void> _registerProcess(BuildContext context) async {
    final account = accountController.text;
    final password = passwordController.text;
    final repeatPassword = repeatPasswordController.text;
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final email = arguments["email"];

    if (!_validateInputs(account, password, repeatPassword)) {
      return;
    }

    try {
      final accountExists = await _checkAccountExists(account);
      if (accountExists == null) {
        _setError('_accountError', '驗證帳號時發生錯誤');
        return;
      } else if (accountExists) {
        _setError('_accountError', '帳號已存在');
        return;
      }

      Navigator.pushNamed(context, '/register/InfoSetup', arguments: {
        "authType": "default",
        "email": email,
        "account": account,
        "password": password
      });
    } catch (e) {
      _setError('_accountError', '發生未知錯誤');
    }
  }

  bool _validateInputs(String account, String password, String repeatPassword) {
    setState(() {
      _accountError = null;
      _passwordError = null;
      _repeatPasswordError = null;
    });

    if (account.isEmpty) {
      _setError('_accountError', '帳號不可為空');
      return false;
    }

    if (account.length > 50) {
      _setError('_accountError', '帳號長度不可超過50字元');
      return false;
    }

    if (password.length < 8) {
      _setError('_passwordError', '密碼長度不足');
      return false;
    }

    if (password != repeatPassword) {
      _setError('_repeatPasswordError', '密碼不一致');
      return false;
    }

    return true;
  }

  void _setError(String field, String message) {
    setState(() {
      if (field == '_accountError') {
        _accountError = message;
      } else if (field == '_passwordError') {
        _passwordError = message;
      } else if (field == '_repeatPasswordError') {
        _repeatPasswordError = message;
      }
    });
  }

  Future<bool?> _checkAccountExists(String username) async {
    final response = await apiService.checkUsername(username);
    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      return responseBody['exist'];
    } else {
      showCustomDialog(context, "驗證帳號時發生錯誤", response.reasonPhrase.toString());
      return null;
    }
  }
}

class InfoSetupPage extends StatefulWidget {
  const InfoSetupPage({super.key});

  @override
  _InfoSetupPageState createState() => _InfoSetupPageState();
}

class _InfoSetupPageState extends State<InfoSetupPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _neighborhoodController = TextEditingController();
  final APIService api = APIService();

  String? _gender;
  String? _city;

  String? _nameError;
  String? _genderError;
  String? _birthdayError;
  String? _cityError;
  String? _districtError;
  String? _neighborhoodError;

  void _validateAndSubmit() async {
    setState(() {
      _nameError = _nameController.text.isEmpty ? '姓名不能為空' : null;
      _genderError = _gender == null ? '性別不能為空' : null;
      _birthdayError = _birthdayController.text.isEmpty ? '生日不能為空' : null;
      _cityError = _city == null ? '居住縣市不能為空' : null;
      _districtError = _districtController.text.isEmpty ? '居住鄉鎮市區不能為空' : null;
      _neighborhoodError =
          _neighborhoodController.text.isEmpty ? '居住村里不能為空' : null;
    });

    if (_nameError == null &&
        _genderError == null &&
        _birthdayError == null &&
        _cityError == null &&
        _districtError == null &&
        _neighborhoodError == null) {
      final Map<String, dynamic> arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      final String authType = arguments["authType"];
      String gender = _gender! == "男性" ? "male" : "female";
      late String username;
      late String userToken;

      switch (authType) {
        case "default":
          final String email = arguments['email'];
          final String account = arguments['account'];
          final String password = arguments['password'];
          final String salt = generateSalt();
          final hashedPassword = hashPassword(password, salt);

          final User user = User(
              username: account,
              password: hashedPassword,
              salt: salt,
              email: email,
              name: _nameController.text,
              gender: gender,
              birthday: _birthdayController.text,
              city: _city!,
              district: _districtController.text,
              neighbor: _neighborhoodController.text);

          final response = await api.registerUser(user);
          dynamic handledResponse = handleHttpResponses(context, response, "創建帳號時發生錯誤");
          if (handledResponse == null) {
            return;
          }
          username = handledResponse["name"] ?? _nameController.text;
          userToken = handledResponse["user_token"];

          break;
        case "oauth":
          final String idToken = arguments['id_token'];

          final User user = User(
              id_token: idToken,
              name: _nameController.text,
              gender: gender,
              birthday: _birthdayController.text,
              city: _city!,
              district: _districtController.text,
              neighbor: _neighborhoodController.text);

          final response = await api.oauthRegister("apple",user);
          dynamic handledResponse = handleHttpResponses(context, response, "創建帳號時發生錯誤");
          if (handledResponse == null) {
            return;
          }
          username = handledResponse["name"];
          userToken = handledResponse["user_token"];
          break;
        default:
          showCustomDialog(context, "註冊時發生錯誤", "未知的註冊方式");
          break;
      }


      SharedPreferencesService().saveData(StorageKeys.userToken, userToken);
      SharedPreferencesService().saveData(StorageKeys.userName, username);

      Navigator.pushNamed(context, '/home');
    }
  }

  String generateSalt() {
    //生成64字元的鹽巴
    final bytes = List<int>.generate(64, (i) => i + 1);
    return base64Url.encode(bytes);
  }

  void _validateName(String value) {
    setState(() {
      _nameError = value.isEmpty ? '姓名不能為空' : null;
    });
  }

  void _validateGender(String? value) {
    setState(() {
      _genderError = value == null ? '性別不能為空' : null;
    });
  }

  void _validateBirthday(String value) {
    setState(() {
      _birthdayError = value.isEmpty ? '生日不能為空' : null;
    });
  }

  void _validateCity(String? value) {
    setState(() {
      _cityError = value == null ? '居住縣市不能為空' : null;
    });
  }

  void _validateDistrict(String value) {
    setState(() {
      _districtError = value.isEmpty ? '居住鄉鎮市區不能為空' : null;
    });
  }

  void _validateNeighborhood(String value) {
    setState(() {
      _neighborhoodError = value.isEmpty ? '居住村里不能為空' : null;
    });
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
                    '建立新帳號（2/2)',
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 120),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          CustomTextField(
                            label: '姓名',
                            controller: _nameController,
                            inputType: InputType.text,
                            errorText: _nameError,
                            onChanged: _validateName,
                          ),
                          const SizedBox(height: 10),
                          CustomDropdownButton(
                            label: '性別',
                            options: const ["男性", "女性"],
                            selectedValue: _gender,
                            onChanged: (String? value) {
                              setState(() {
                                _gender = value;
                                _validateGender(value);
                              });
                            },
                            errorText: _genderError,
                          ),
                          const SizedBox(height: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("生日",
                                  style: TextStyle(
                                      fontSize: 22, color: Colors.black)),
                              TextField(
                                controller: _birthdayController,
                                style: Theme.of(context).textTheme.bodySmall,
                                showCursor: false,
                                decoration: InputDecoration(
                                  errorStyle: const TextStyle(
                                      color: Colors.red, fontSize: 20),
                                  errorText: _birthdayError,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onChanged: _validateBirthday,
                                onTap: () async {
                                  DateTime? newDateTime =
                                      await showRoundedDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate:
                                        DateTime(DateTime.now().year - 110),
                                    lastDate: DateTime.now(),
                                    borderRadius: 16,
                                    theme: ThemeData(
                                      primaryColor: ColorUtil.bg_lightBlue,
                                      colorScheme: ColorScheme.fromSwatch(),
                                      dialogBackgroundColor: Colors.white,
                                      textTheme: const TextTheme(
                                        titleMedium: TextStyle(
                                            color: Colors.black, fontSize: 25),
                                        bodyLarge: TextStyle(
                                            color: Colors.black, fontSize: 22),
                                        bodyMedium: TextStyle(
                                            color: Colors.black, fontSize: 20),
                                        bodySmall: TextStyle(
                                            color: Colors.black, fontSize: 20),
                                      ),
                                    ),
                                  );
                                  if (newDateTime != null) {
                                    setState(() {
                                      _birthdayController.text = newDateTime
                                          .toString()
                                          .substring(0, 10);
                                      _validateBirthday(
                                          _birthdayController.text);
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          CustomDropdownButton(
                            label: '居住縣市',
                            options: const [
                              "臺北市",
                              "新北市",
                              "桃園市",
                              "臺中市",
                              "臺南市",
                              "高雄市",
                              "基隆市",
                              "新竹市",
                              "嘉義市",
                              "新竹縣",
                              "苗栗縣",
                              "彰化縣",
                              "南投縣",
                              "雲林縣",
                              "嘉義縣",
                              "屏東縣",
                              "宜蘭縣",
                              "花蓮縣",
                              "臺東縣",
                              "澎湖縣",
                              "金門縣",
                              "連江縣"
                            ],
                            selectedValue: _city,
                            onChanged: (String? value) {
                              setState(() {
                                _city = value;
                                _validateCity(value);
                              });
                            },
                            errorText: _cityError,
                          ),
                          const SizedBox(height: 10),
                          CustomTextField(
                            label: '居住鄉鎮市區',
                            controller: _districtController,
                            inputType: InputType.text,
                            errorText: _districtError,
                            onChanged: _validateDistrict,
                          ),
                          const SizedBox(height: 10),
                          CustomTextField(
                            label: '居住村里',
                            controller: _neighborhoodController,
                            inputType: InputType.text,
                            errorText: _neighborhoodError,
                            onChanged: _validateNeighborhood,
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              text: '完成',
                              type: ButtonType.primary,
                              onPressed: _validateAndSubmit,
                            ),
                          ),
                        ],
                      ),
                    ),
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

//波浪背景
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
