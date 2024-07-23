import 'package:flutter/material.dart';
import 'package:usrcare/strings.dart';
import 'package:usrcare/utils/ColorUtil.dart';
import 'package:usrcare/widgets/Button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, //關閉裝置返回鍵，回到上一頁
      child: Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: ColorUtil.bg_lightBlue,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(150),
                        color: Colors.white,
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/logo.png',
                          fit: BoxFit.scaleDown,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      GetString.appName,
                      style: TextStyle(
                        fontSize: 28,
                      ),
                    ),
                    const Spacer(),
                    CustomButton(
                      text: '',
                      type: ButtonType.circular,
                      onPressed: () {
                        // Circular button logic
                      },
                      icon: const Icon(Icons.notifications_outlined),
                    ),
                    const SizedBox(width: 5),
                    CustomButton(
                      text: '',
                      type: ButtonType.circular,
                      onPressed: () {
                        // Circular button logic
                      },
                      icon: const Icon(Icons.settings_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Column(
                  children: [
                    Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(150),
                        color: Colors.white,
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/logo.png',
                          fit: BoxFit.scaleDown,
                        ),
                      ),
                    ),
                    const Column(
      
                    )
                  ],
                ),
      
              ],
            ),
          ),
        ),
      ),
    );
  }
}
