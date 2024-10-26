import 'package:shared_preferences/shared_preferences.dart';

enum StorageKeys {
  userToken,
  userName,
  checkinDates,
  skipUpdateVersion,
  oauthBindingList,
}

const Map<StorageKeys, String> storageKeysMap = {
  StorageKeys.userToken: 'user_token',
  StorageKeys.userName: 'user_name',
  StorageKeys.checkinDates: 'checkin_dates',
  StorageKeys.skipUpdateVersion: 'skip_update_version',
  StorageKeys.oauthBindingList: 'oauth_binding_list',
};

extension StorageKeysExtension on StorageKeys {
  String get key => storageKeysMap[this]!;
}

class SharedPreferencesService {
  Future<void> saveData(StorageKeys key, String? value) async {
    if (value == null) {
      clearData(key);
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key.key, value);
    }
  }

  Future<String?> getData(StorageKeys key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key.key);
  }

  Future<void> clearData(StorageKeys key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key.key);
  }

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();

    final String? skipUpdateVersion = prefs.getString(StorageKeys.skipUpdateVersion.key);

    await prefs.clear();

    if (skipUpdateVersion != null) {
      await prefs.setString(StorageKeys.skipUpdateVersion.key, skipUpdateVersion);
    }
  }

}
