import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usrcare/api/APIService.dart';
import 'package:usrcare/utils/ColorUtil.dart';
import 'package:usrcare/utils/MiscUtil.dart';
import 'package:usrcare/utils/SharedPreference.dart';
import 'package:usrcare/views/setting/AboutAppPage.dart';
import 'package:usrcare/views/setting/ContactUsPage.dart';
import 'package:usrcare/views/setting/FAQPage.dart';
import 'package:usrcare/views/setting/PrivacyPolicyPage.dart';
import 'package:usrcare/views/setting/TermsOfServicePage.dart';
import 'package:usrcare/widgets/Button.dart';
import 'package:usrcare/widgets/Dialog.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: 9,
                    itemBuilder: (context, index) {
                      return SizedBox(
                        height: 60,
                        child: _buildListTile(index),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const Divider(
                        color: Colors.black,
                        thickness: 1,
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      showConfirmDialog(context, "登出", "確定要登出嗎？", () async {
                        await SharedPreferencesService().clearAllData();
                        Navigator.pushNamed(context, "/");
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorUtil.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    ),
                    child: const Text(
                      '登出',
                      style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListTile(int index) {
  switch (index) {
    case 0:
      return ListTile(
        leading: Image.asset('assets/google.png', height: 30),
        title: const Text('綁定Google快速登入', style: TextStyle(fontSize: 24)),
        trailing: const Icon(Icons.arrow_forward_ios),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
        onTap: () {},
      );
    case 1:
      return ListTile(
        leading: Image.asset('assets/line.png', height: 30),
        title: const Text('綁定LINE快速登入', style: TextStyle(fontSize: 24)),
        trailing: const Icon(Icons.arrow_forward_ios),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
        onTap: () {},
      );
    case 2:
      return ListTile(
        leading: const Icon(Icons.help_outline, size: 30),
        title: const Text('常見問題', style: TextStyle(fontSize: 24)),
        trailing: const Icon(Icons.arrow_forward_ios),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FAQPage()),
          );
        },
      );
    case 3:
      return ListTile(
        leading: const Icon(Icons.message_outlined, size: 30),
        title: const Text('聯絡我們', style: TextStyle(fontSize: 24)),
        trailing: const Icon(Icons.arrow_forward_ios),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ContactUsPage()),
          );
        },
      );
    // case 4:
    //   return ListTile(
    //     leading: const Icon(Icons.lock_outline, size: 30),
    //     title: const Text('密碼與帳號安全', style: TextStyle(fontSize: 24)),
    //     trailing: const Icon(Icons.arrow_forward_ios),
    //     contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
    //     onTap: () {},
    //   );
    case 4:
      return ListTile(
        leading: const Icon(Icons.info_outline, size: 30),
        title: const Text('關於APP', style: TextStyle(fontSize: 24)),
        trailing: const Icon(Icons.arrow_forward_ios),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AboutAppPage()),
          );
        },
      );
    case 5:
      return ListTile(
        leading: const Icon(Icons.privacy_tip_outlined, size: 30),
        title: const Text('隱私政策', style: TextStyle(fontSize: 24)),
        trailing: const Icon(Icons.arrow_forward_ios),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
          );
        },
      );
    case 6:
      return ListTile(
        leading: const Icon(Icons.people_outline_outlined, size: 30),
        title: const Text('服務條款', style: TextStyle(fontSize: 24)),
        trailing: const Icon(Icons.arrow_forward_ios),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TermsOfServicePage()),
          );
        },
      );
    case 7:
      return ListTile(
        leading: const Icon(Icons.card_giftcard_outlined, size: 30),
        title: const Text('輸入獎勵代碼', style: TextStyle(fontSize: 24)),
        trailing: const Icon(Icons.arrow_forward_ios),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
        onTap: () {
          
        },
      );
    case 8:
      return ListTile(
        leading: const Icon(Icons.update, size: 30),
        title: const Text('檢查更新', style: TextStyle(fontSize: 24)),
        trailing: const Icon(Icons.arrow_forward_ios),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
        onTap: () {},
      );
    default:
      return Container();
  }
}
}