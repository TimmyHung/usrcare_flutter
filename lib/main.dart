import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:usrcare/TestPage.dart';
import 'package:usrcare/utils/ColorUtil.dart';
import 'package:usrcare/views/EmailVerificationPage.dart';
import 'package:usrcare/views/HomePage.dart';
import 'package:usrcare/views/RegisterPage.dart';
import 'package:usrcare/views/LoginPage.dart';

import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:usrcare/views/WelcomePage.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
  //載入 LineSDK
  LineSDK.instance.setup(dotenv.env['LINE_CHANNEL_ID']!).then((_) {
    // print("LineSDK Prepared");
  });
  

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: appTheme,
      initialRoute: '/',
      routes: {
        // '/': (context) => const HomePage(),
        // '/': (context) => const TestPage(),
        '/': (context) => const WelcomePage(),
        '/register': (context) => const RegisterPage(),
        '/EmailVerification': (context) => EmailVerificationPage(),
        '/register/AccountSetup': (context) => const AccountSetupPage(),
        '/register/InfoSetup': (context) => const InfoSetupPage(),
        '/login': (context) => const LoginPage(),
        '/login/pwdRecovery': (context) => const PasswordRecoveryPage(),
        '/login/pwdReset': (context) => const PasswordResetPage(),
        '/home': (context) => const HomePage(),
      },
      supportedLocales: const [
        Locale('zh', 'TW'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: const Locale('zh', 'TW'),

    );
  }
}

//GlobalTheme
final ThemeData appTheme = ThemeData(
  primarySwatch: Colors.blue,

  scaffoldBackgroundColor: Colors.grey.shade900,

  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black, fontSize: 30),
    bodyMedium: TextStyle(color: Colors.black, fontSize: 25),
    bodySmall: TextStyle(color: Colors.black, fontSize: 20),
  ),

  appBarTheme: const AppBarTheme(
    color: Colors.blue,
    titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
    centerTitle: true,
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: ColorUtil.primary,
      foregroundColor: Colors.white,
      textStyle: const TextStyle(color: Colors.white, fontSize: 22),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
    ),
  ),
  
  // inputDecorationTheme: InputDecorationTheme(
  //   border: OutlineInputBorder(
  //     borderRadius: BorderRadius.circular(10),
  //   ),
  //   labelStyle: const TextStyle(
  //     color: Colors.white,
  //     fontSize: 18,
  //   ),
  //   // suffixIconColor: Colors.green,
  // ),
);