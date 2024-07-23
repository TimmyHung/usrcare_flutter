import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:usrcare/api/APIModels.dart';
import 'package:usrcare/api/APIService.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  UserProfile? _userProfile;
  final APIService apiService = APIService();
  void test() async {
    Map<String, dynamic> credentials = {
      "username": "testuser",
      "password": "testpwd"
    };

    final response = await apiService.authenticate(credentials);

    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      print(responseBody);
    } else {
      print(response.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(100.0),
          child: Container(
            child: Column(
              children: [
                ElevatedButton(onPressed: (){
                  test();
                }, child: const Text("Post測試")),
              ],
            ),
          ),
        ),
      )
    );
  }
}