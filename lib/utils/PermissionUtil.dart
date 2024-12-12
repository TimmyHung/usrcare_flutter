import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:usrcare/utils/ColorUtil.dart';

class PermissionUtil {
  static bool _isDialogShowing = false;
  static Map<Permission, PermissionStatus> _previousStatuses = {};
  static Permission _pendingAction = Permission.unknown;
  static VoidCallback? _onPermissionGranted;

  // 初始化權限狀態
  static Future<void> initPermissionStatus(List<Permission> permissions) async {
    for (var permission in permissions) {
      _previousStatuses[permission] = await permission.status;
    }
  }

  // 檢查並請求權限
  static Future<void> checkAndRequestPermission(
    BuildContext context,
    Permission permission,
    String permissionName,
    String description,
    VoidCallback onGranted, {
    bool isRequired = false,
    VoidCallback? onCancel,
  }) async {
    _onPermissionGranted = onGranted;
    final status = await permission.status;

    if (status.isGranted) {
      onGranted();
      return;
    }

    if (status.isPermanentlyDenied) {
      _pendingAction = permission;
      _showPermissionDeniedDialog(context, permissionName, description, isRequired, onCancel);
      return;
    }

    if (status.isDenied) {
      final bool? userAccepted = await showDialog<bool>(
        context: context,
        barrierDismissible: !isRequired,
        builder: (context) => AlertDialog(
          title: Center(
            child: Text(
              '需要$permissionName權限',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
          content: Text(
            description + "\n\n請在彈出的視窗中點選「允許」以繼續。",
            style: const TextStyle(fontSize: 24),
          ),
          actions: [
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorUtil.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text(
                      '好的',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: isRequired ? null : () {
                    Navigator.pop(context, false);
                    _pendingAction = Permission.unknown;
                    onCancel?.call();
                  },
                  child: Text(
                    isRequired ? '無法跳過' : '稍後再說',
                    style: TextStyle(
                      fontSize: 20,
                      color: isRequired ? Colors.grey : Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );

      if (userAccepted != true) {
        return;
      }

      final result = await permission.request();
      if (result.isGranted) {
        onGranted();
        return;
      }
      if (result.isDenied) {
        checkAndRequestPermission(
          context, 
          permission, 
          permissionName, 
          description, 
          onGranted, 
          isRequired: isRequired,
          onCancel: onCancel,
        );
        return;
      }
      if (result.isPermanentlyDenied) {
        _pendingAction = permission;
        _showPermissionDeniedDialog(context, permissionName, description, isRequired, onCancel);
        return;
      }
    }
  }

  // 處理應用程式生命週期變化
  static Future<void> handleAppLifecycleStateChange(
    AppLifecycleState state,
    BuildContext context,
  ) async {
    if (state == AppLifecycleState.resumed && _pendingAction != Permission.unknown) {
      for (var entry in _previousStatuses.entries) {
        if (entry.key == _pendingAction) {
          final status = await entry.key.status;
          if (status.isGranted) {
            if (_isDialogShowing) {
              Navigator.of(context, rootNavigator: true).pop();
              _isDialogShowing = false;
            }
            if (_previousStatuses[entry.key] != PermissionStatus.granted) {
              _onPermissionGranted?.call();
            }
          }
          _previousStatuses[entry.key] = status;
        }
      }
    }
  }

  // 顯示權限請求對話框
  static void _showPermissionDeniedDialog(
    BuildContext context,
    String permissionName,
    String description,
    bool isRequired,
    VoidCallback? onCancel,
  ) {
    if (_isDialogShowing) return;
    _isDialogShowing = true;

    showDialog(
      context: context,
      barrierDismissible: !isRequired,
      builder: (BuildContext context) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.center,
          title: Center(
            child: Text(
              '需要$permissionName權限',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: Text(
            description + "\n\n請點擊下方按鈕「前往設定」允許「$permissionName」權限以繼續。",
            style: const TextStyle(fontSize: 24),
          ),
          actions: [
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      await openAppSettings();
                    },
                    child: const Text(
                      '前往設定',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: isRequired ? null : () {
                    _pendingAction = Permission.unknown;
                    Navigator.pop(context);
                    _isDialogShowing = false;
                    onCancel?.call();
                  },
                  child: Text(
                    isRequired ? '無法跳過' : '稍後再說',
                    style: TextStyle(
                      fontSize: 20,
                      color: isRequired ? Colors.grey : Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    ).then((_) {
      if (_isDialogShowing) {
        _isDialogShowing = false;
      }
    });
  }
} 