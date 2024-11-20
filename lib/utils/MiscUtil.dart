import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:usrcare/widgets/Dialog.dart';
import 'package:url_launcher/url_launcher.dart';

dynamic handleHttpResponses(
    BuildContext context, dynamic response, String? errorTitle) {
  if (kDebugMode) {
    try {
      print(
          "HttpCode: ${response.statusCode} \nBody: ${json.decode(response.body)}");
    } catch (err) {
      print(response);
      return null;
    }
  }
  if (response.statusCode == 200 || response.statusCode == 201) {
    final responseBody = json.decode(response.body);
    return responseBody;
  } else {
    if (errorTitle != null) {
      showCustomDialog(context, errorTitle, response.reasonPhrase.toString());
    }
    return;
  }
}

String hashPassword(String password, String salt) {
  final bytes = utf8.encode(password + salt);
  final digest = sha256.convert(bytes);
  return digest.toString();
}

Future<void> launchExternalUrl(String url) async {
  final targetUri = Uri.parse(url);
  if (await canLaunchUrl(targetUri)) {
    await launchUrl(targetUri, mode: LaunchMode.externalApplication);
  } else {
    throw '無法打開此連結 $url';
  }
}

String generateSalt() {
  //生成64字元的鹽巴
  final bytes = List<int>.generate(64, (i) => i + 1);
  return base64Url.encode(bytes);
}