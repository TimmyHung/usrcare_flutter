import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:usrcare/utils/ColorUtil.dart';
import 'package:usrcare/views/SplashPage.dart';
import 'package:usrcare/views/authorization/EmailVerificationPage.dart';
import 'package:usrcare/views/home/GamePage.dart';
import 'package:usrcare/views/home/HomePage.dart';
import 'package:usrcare/views/authorization/RegisterPage.dart';
import 'package:usrcare/views/authorization/LoginPage.dart';

import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:usrcare/views/setting/SettingPage.dart';
import 'package:usrcare/views/WelcomePage.dart';
import 'package:usrcare/views/home/MoodPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  LineSDK.instance.setup(dotenv.env['LINE_CHANNEL_ID']!);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: appTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashPage(),
        '/welcome': (context) => const WelcomePage(),
        '/register': (context) => const RegisterPage(),
        '/EmailVerification': (context) => EmailVerificationPage(),
        '/register/AccountSetup': (context) => const AccountSetupPage(),
        '/register/InfoSetup': (context) => const InfoSetupPage(),
        '/login': (context) => const LoginPage(),
        '/login/pwdRecovery': (context) => const PasswordRecoveryPage(),
        '/login/pwdReset': (context) => const PasswordResetPage(),
        '/home': (context) => const HomePage(),
        '/setting': (context) => const SettingPage(),
        // '/game': (context) => const GamePage(),
        '/mood': (context) => const MoodPage(),
      },
      supportedLocales: const [
        Locale('zh', 'TW'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: const Locale('zh', 'TW'),
      localeResolutionCallback: (locale, supportedLocales) {
        return const Locale('zh', 'TW');
      },
    );
  }
}

//GlobalTheme
final ThemeData appTheme = ThemeData(
  primarySwatch: Colors.blue,

  scaffoldBackgroundColor: ColorUtil.bg_lightBlue,

  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black, fontSize: 30),
    bodyMedium: TextStyle(color: Colors.black, fontSize: 25),
    bodySmall: TextStyle(color: Colors.black, fontSize: 20),
  ),

  appBarTheme: const AppBarTheme(
    color: Colors.transparent,
    titleTextStyle: TextStyle(
        color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold),
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
);
