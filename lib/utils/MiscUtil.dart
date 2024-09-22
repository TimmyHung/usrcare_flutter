

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:usrcare/widgets/Dialog.dart';


dynamic handleHttpResponses(BuildContext context, dynamic response, String? errorTitle) {
  if(kDebugMode) {
    print("HttpCode: ${response.statusCode} \nBody: ${response.body}");
  }
  if (response.statusCode == 200 || response.statusCode == 201) {
    final responseBody = json.decode(response.body);
    return responseBody;
  } else {
    if(errorTitle != null) {
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