import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:usrcare/utils/AlarmNotificationService.dart';
import 'package:usrcare/utils/ColorUtil.dart';
import 'package:usrcare/utils/MiscUtil.dart';
import 'package:usrcare/widgets/Dialog.dart';
import 'package:usrcare/utils/SharedPreference.dart';

// 新增通知項目模型
class NotificationItem {
  final String id;
  final String title;
  final String content;
  final DateTime timestamp;
  final String? actionType; // 可以用來定義點擊後的行為
  final String? actionData; // 存放相關的數據
  bool isRead; // 新增已讀狀態

  NotificationItem({
    required this.id,
    required this.title,
    required this.content,
    required this.timestamp,
    this.actionType,
    this.actionData,
    this.isRead = false, // 預設為未讀
  });
}

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final borderColor = Colors.black;
  List<NotificationItem> notifications = [];

  @override
  void initState() {
    super.initState();
    _loadTestData();
  }

  void _loadTestData() {
    // 載入測試數據
    notifications = [
      NotificationItem(
        id: '4',
        title: '這些是通知模板雛形',
        content: '每一個模板都有各自不同的點擊功能，目前放的都是測試資料所以不會消失:D',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        actionType: 'system_message',
        isRead: false,
      ),
      NotificationItem(
        id: '1',
        title: '愛來運動分析完成',
        content: '您於 2024/11/20 14:00 的運動影片已經分析完成，請前往查看！',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        actionType: 'exercise_video',
        actionData: 'video_123', // 影片ID
        isRead: false,
      ),
      NotificationItem(
        id: '2',
        title: '重要更新提醒',
        content: '新版本 2.1.0 現已推出！我們新增了更多功能並優化了使用體驗，立即更新體驗看看吧！',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        actionType: 'app_update',
        isRead: true,
      ),
      NotificationItem(
        id: '3',
        title: '什麼?發現世界最大花瓶',
        content: '這到底是什麼奇怪的東西，快來看看這個有趣的發現！',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        actionType: 'launch_url',
        actionData: 'https://www.instagram.com/vanexxu',
        isRead: true,
      ),
      NotificationItem(
        id: '7',
        title: '心情量表填寫',
        content: '距離上次您填寫『寂寞量表』已經過了三個月，為了追蹤您的情緒變化，請填寫最新的寂寞量表',
        timestamp: DateTime.now().subtract(const Duration(days: 4)),
        actionType: 'deeplink',
        actionData: '/mood',
        isRead: true,
      ),
    ];
  }

  void _handleNotificationTap(NotificationItem notification) {
    setState(() {
      notification.isRead = true;
    });

    switch (notification.actionType) {
      case 'system_message':
        showCustomDialog(context, notification.title, notification.content,
            closeButton: true);
        break;

      case 'exercise_video':
        // 導向到運動影片頁面
        // Navigator.pushNamed(
        //   context,
        //   '/exercise-video',
        //   arguments: notification.actionData, // 影片ID或相關參數
        // );
        showToast(context, "你不愛運動，所以影片已經被刪了QQ");
        break;

      case 'app_update':
        final storeUrl = Platform.isIOS
            ? 'https://apps.apple.com/'
            : 'https://play.google.com/store/apps/details?id=com.tku.usrcare';
        launchExternalUrl(storeUrl);
        break;

      case 'launch_url':
        if (notification.actionData != null) {
          launchExternalUrl(notification.actionData!);
        }
        break;

      case 'deeplink':
        if (notification.actionData != null) {
          Navigator.pushNamed(context, notification.actionData!);
        }
        break;
    }
  }

  void _deleteNotification(NotificationItem notification) {
    setState(() {
      notifications.removeWhere((item) => item.id == notification.id);
    });
  }

  // 新增檢查是否有未讀通知的方法
  bool _hasUnreadNotifications() {
    return notifications.any((notification) => !notification.isRead);
  }

  // 新增全部標為已讀的方法
  void _markAllAsRead() {
    setState(() {
      for (var notification in notifications) {
        notification.isRead = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: borderColor, width: 3),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.notifications_outlined, size: 40),
              SizedBox(width: 10),
              Text("系統通知")
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Expanded(
                child: notifications.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_off_outlined,
                              size: 64,
                              color: Colors.black,
                            ),
                            SizedBox(height: 16),
                            Text(
                              '目前沒有任何通知',
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final notification = notifications[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: InkWell(
                              onTap: () => _handleNotificationTap(notification),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        if (!notification.isRead)
                                          Container(
                                            width: 10,
                                            height: 10,
                                            margin:
                                                const EdgeInsets.only(right: 8),
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        Expanded(
                                          child: Text(
                                            notification.title,
                                            style: const TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          icon:
                                              const Icon(Icons.delete_outline),
                                          onPressed: () =>
                                              _deleteNotification(notification),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      notification.content,
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatTimestamp(notification.timestamp),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              if (_hasUnreadNotifications()) ...[
                // const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _markAllAsRead,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: const Color.fromARGB(255, 118, 129, 245),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "全部已讀",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} 分鐘前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} 小時前';
    } else {
      return '${difference.inDays} 天前';
    }
  }
}
