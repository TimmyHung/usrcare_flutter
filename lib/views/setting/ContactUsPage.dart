import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:usrcare/utils/MiscUtil.dart';
import 'package:usrcare/widgets/Dialog.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  final String _officialWebsiteUrl = 'https://www.tkuusraicare.org/';
  final String _facebookUrl = 'https://www.facebook.com/TKUSRAI';
  final String _email = 'tkuusrcare@gmail.com';

  Future<void> _launchEmail(context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: _email,
      query: _encodeQueryParameters(<String, String>{
        'subject': '為愛AI陪伴-使用問題回饋',
      }),
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      showCustomDialog(context, "無法打開郵件應用程式", "已將電子郵件複製到您的剪貼簿！");
    }
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('聯絡我們',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => launchExternalUrl(_officialWebsiteUrl),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colors.grey.shade400, width: 1),
                        ),
                        padding: const EdgeInsets.all(5),
                        child: Image.asset("assets/logo.png", height: 25),
                      ),
                      const SizedBox(width: 10),
                      const Text('官方網站', style: TextStyle(fontSize: 24)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => launchExternalUrl(_facebookUrl),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  child: const Row(
                    children: [
                      Icon(Icons.facebook, size: 45, color: Colors.blue),
                      SizedBox(width: 10),
                      Text('FB粉絲專頁', style: TextStyle(fontSize: 24)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => _launchEmail(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  child: Row(
                    children: [
                      Icon(Icons.email_outlined,
                          size: 40, color: Colors.red.shade300),
                      const SizedBox(width: 10),
                      const Text('tkuusrcare@gmail.com',
                          style: TextStyle(fontSize: 22)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
