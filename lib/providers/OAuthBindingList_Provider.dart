import 'package:flutter/foundation.dart';

class OAuthBindingList_Provider extends ChangeNotifier {
  Map<String, bool> _oauthBindingList = {"Google": false, "LINE": false, "Apple": false};

  Map<String, bool> get oauthBindingList => _oauthBindingList;

  void updateBinding(String platform, bool isBound) {
    _oauthBindingList[platform] = isBound;
    notifyListeners();
  }

  void setBindingList(Map<String, bool> newList) {
    _oauthBindingList = newList;
    notifyListeners();
  }
}