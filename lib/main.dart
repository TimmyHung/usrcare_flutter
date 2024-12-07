import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:usrcare/providers/OAuthBindingList_Provider.dart';
import 'package:usrcare/utils/ColorUtil.dart';
import 'package:usrcare/utils/AlarmNotificationService.dart';
import 'package:usrcare/views/SplashPage.dart';
import 'package:usrcare/views/authorization/EmailVerificationPage.dart';
import 'package:usrcare/views/home/HomePage.dart';
import 'package:usrcare/views/authorization/RegisterPage.dart';
import 'package:usrcare/views/authorization/LoginPage.dart';

import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:usrcare/views/WelcomePage.dart';
import 'package:usrcare/views/home/MoodPage.dart';
import 'package:usrcare/views/home/AlarmPage.dart';
import 'package:usrcare/views/home/NotificationPage.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");
  await NotificationService().init();
  LineSDK.instance.setup(dotenv.env['LINE_CHANNEL_ID']!);
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => OAuthBindingList_Provider()),
  ], child: const MyApp()));
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
      navigatorKey: navigatorKey,
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
        '/home': (context) => const HomePage(),
        '/notification': (context) => const NotificationPage(),
        '/mood': (context) => const MoodPage(),
        '/alarm': (context) => const AlarmPage(),
        // '/setting': (context) => const SettingPage(),
        // '/game': (context) => const GamePage(),
        // '/checkin': (context) => const CheckInPage(),
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
  dialogTheme: DialogTheme(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: ColorUtil.primary,
      foregroundColor: Colors.white,
      textStyle: const TextStyle(color: Colors.white, fontSize: 22),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
    ),
  ),
);
