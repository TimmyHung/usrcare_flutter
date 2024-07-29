import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usrcare/api/APIService.dart';
import 'package:usrcare/utils/MiscUtil.dart';
import 'package:usrcare/utils/SharedPreference.dart';
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
      resizeToAvoidBottomInset: false,
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            children: [
              Stack(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CustomButton(
                        text: '',
                        type: ButtonType.circular,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back),
                      ),
                    ],
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '設定',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.only(top: 16),
                height: MediaQuery.of(context).size.height * 0.83,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListView.separated(
                  padding: const EdgeInsets.only(top:5 ),
                  itemCount: 11,
                  itemBuilder: (context, index) {
                    return SizedBox(
                      height: 50,
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
          titleAlignment: ListTileTitleAlignment.titleHeight,
          leading: Image.asset('assets/google.png', height: 30),
          title: const Align(
            alignment: Alignment.topLeft,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('綁定Google快速登入', style: TextStyle(fontSize: 28)),
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {},
        );
      case 1:
        return ListTile(
          titleAlignment: ListTileTitleAlignment.titleHeight,
          leading: Image.asset('assets/line.png', height: 30),
          title: const Align(
            alignment: Alignment.topLeft,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('綁定LINE快速登入', style: TextStyle(fontSize: 28)),
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {},
        );
      case 2:
        return ListTile(
          titleAlignment: ListTileTitleAlignment.titleHeight,
          leading: const Icon(Icons.help_outline, size: 30),
          title: const Align(
            alignment: Alignment.topLeft,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('常見問題', style: TextStyle(fontSize: 28)),
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {},
        );
      case 3:
        return ListTile(
          titleAlignment: ListTileTitleAlignment.titleHeight,
          leading: const Icon(Icons.message_outlined, size: 30),
          title: const Align(
            alignment: Alignment.topLeft,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('聯絡我們', style: TextStyle(fontSize: 28)),
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {},
        );
      case 4:
        return ListTile(
          titleAlignment: ListTileTitleAlignment.titleHeight,
          leading: const Icon(Icons.lock_outline, size: 30),
          title: const Align(
            alignment: Alignment.topLeft,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('密碼與帳號安全', style: TextStyle(fontSize: 28)),
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {},
        );
      case 5:
        return ListTile(
          titleAlignment: ListTileTitleAlignment.titleHeight,
          leading: const Icon(Icons.info_outline, size: 30),
          title: const Align(
            alignment: Alignment.topLeft,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('關於APP', style: TextStyle(fontSize: 28)),
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {},
        );
      case 6:
        return ListTile(
          titleAlignment: ListTileTitleAlignment.titleHeight,
          leading: const Icon(Icons.privacy_tip_outlined, size: 30),
          title: const Align(
            alignment: Alignment.topLeft,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('隱私政策', style: TextStyle(fontSize: 28)),
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {},
        );
      case 7:
        return ListTile(
          titleAlignment: ListTileTitleAlignment.titleHeight,
          leading: const Icon(Icons.people_outline_outlined, size: 30),
          title: const Align(
            alignment: Alignment.topLeft,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('服務條款', style: TextStyle(fontSize: 28)),
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {},
        );
      case 8:
        return ListTile(
          titleAlignment: ListTileTitleAlignment.titleHeight,
          leading: const Icon(Icons.card_giftcard_outlined, size: 30),
          title: const Align(
            alignment: Alignment.topLeft,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('輸入獎勵代碼', style: TextStyle(fontSize: 28)),
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {},
        );
      case 9:
        return ListTile(
          titleAlignment: ListTileTitleAlignment.titleHeight,
          leading: const Icon(Icons.update, size: 30),
          title: const Align(
            alignment: Alignment.topLeft,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('檢查更新', style: TextStyle(fontSize: 28)),
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {},
        );
      case 10:
        return ListTile(
          titleAlignment: ListTileTitleAlignment.titleHeight,
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Align(
            alignment: Alignment.topLeft,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('登出', style: TextStyle(fontSize: 28, color: Colors.red)),
            ),
          ),
          onTap: () {
            showConfirmDialog(context, "登出", "確定要登出嗎？", 
            ()async{
              await SharedPreferencesService().clearAllData();
              Navigator.pushNamed(context, "/");
            });
          },
        );
      default:
        return Container();
    }
  }
}
