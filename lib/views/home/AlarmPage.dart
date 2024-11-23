import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:usrcare/utils/AlarmNotificationService.dart';
import 'package:usrcare/widgets/Dialog.dart';
import 'package:usrcare/utils/SharedPreference.dart';

const Map<String, List<String>> defaultPresets = {
  '用藥提醒': [
    '血壓藥',
    "維他命",
    "胃藥",
    "助眠藥",
  ],
  '活動提醒': [
    '散步',
    '復健',
    '看醫生',
    '量血壓',
    "聚會",
  ],
  '喝水提醒': [
    '100 CC',
    '200 CC',
    '300 CC',
  ],
  '休息提醒': [
    '午休',
    '睡覺',
    '休息一下',
  ],
};

class AlarmItem {
  String name;
  TimeOfDay time;
  List<bool> weekdays;
  bool isEnabled;
  String type;

  AlarmItem({
    required this.name,
    required this.time,
    required this.weekdays,
    required this.type,
    this.isEnabled = true,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'hour': time.hour,
        'minute': time.minute,
        'weekdays': weekdays,
        'isEnabled': isEnabled,
        'type': type,
      };

  factory AlarmItem.fromJson(Map<String, dynamic> json) => AlarmItem(
        name: json['name'],
        time: TimeOfDay(hour: json['hour'], minute: json['minute']),
        weekdays: List<bool>.from(json['weekdays']),
        isEnabled: json['isEnabled'],
        type: json['type'],
      );

  String get weekdaysText {
    List<String> weekdayNames = ['一', '二', '三', '四', '五', '六', '日'];

    bool isEveryWeekday = weekdays.sublist(0, 5).every((day) => day) &&
        !weekdays[5] &&
        !weekdays[6];
    bool isEveryWeekend =
        !weekdays.sublist(0, 5).any((day) => day) && weekdays[5] && weekdays[6];
    bool isEveryday = weekdays.every((day) => day);

    if (isEveryday) {
      return '每天';
    } else if (isEveryWeekday) {
      return '每個平日';
    } else if (isEveryWeekend) {
      return '每個週末';
    } else {
      List<String> selectedDays = [];
      for (int i = 0; i < weekdays.length; i++) {
        if (weekdays[i]) {
          selectedDays.add(weekdayNames[i]);
        }
      }
      return '每週${selectedDays.join('、')}';
    }
  }

  int compareTo(AlarmItem other) {
    // 先比較小時
    if (time.hour != other.time.hour) {
      return time.hour.compareTo(other.time.hour);
    }
    // 小時相同時比較分鐘
    return time.minute.compareTo(other.time.minute);
  }
}

class AlarmPage extends StatefulWidget {
  const AlarmPage({super.key});

  @override
  State<AlarmPage> createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  final borderColor = const Color.fromARGB(255, 61, 64, 181);
  final Map<String, List<AlarmItem>> alarms = {
    '用藥提醒': [],
    '活動提醒': [],
    '喝水提醒': [],
    '休息提醒': [],
  };

  final Map<String, String> labels = {
    '用藥提醒': '💊 用藥提醒',
    '活動提醒': '🏃‍♂️ 活動提醒',
    '喝水提醒': '💧 喝水提醒',
    '休息提醒': '💤 休息提醒',
  };

  String? _pendingNavigationType;

  @override
  void initState() {
    super.initState();
    _loadAlarms();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final String? alarmType =
        ModalRoute.of(context)?.settings.arguments as String?;

    if (alarmType != null && alarmType != _pendingNavigationType) {
      _pendingNavigationType = alarmType;
      // 延遲執行以確保頁面已完全加載
      Future.microtask(() => _navigateToAlarmDetail(alarmType));
    }
  }

  @override
  void dispose() {
    _pendingNavigationType = null;
    super.dispose();
  }

  Future<void> _loadAlarms() async {
    final alarmsJson =
        await SharedPreferencesService().getData(StorageKeys.alarms);
    if (alarmsJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(alarmsJson);
      setState(() {
        decoded.forEach((key, value) {
          alarms[key] =
              (value as List).map((item) => AlarmItem.fromJson(item)).toList();
        });
      });
    }
  }

  Future<void> _saveAlarms() async {
    final Map<String, dynamic> alarmsMap = {};
    alarms.forEach((key, value) {
      alarmsMap[key] = value.map((item) => item.toJson()).toList();
    });
    await SharedPreferencesService().saveData(
      StorageKeys.alarms,
      jsonEncode(alarmsMap),
    );
  }

  void _navigateToAlarmDetail(String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _AlarmDetailPage(
          title: labels[type]!,
          alarms: alarms[type]!,
          borderColor: borderColor,
          onSave: (newAlarms) {
            setState(() {
              alarms[type] = newAlarms;
            });
            _saveAlarms();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 238, 238, 255),
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: borderColor, width: 3),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                clipBehavior: Clip.hardEdge,
                child: Image.asset(
                  "assets/HomePage_Icons/alarm.png",
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                ),
              ),
              const Text("鬧鐘小提醒")
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAlarmButton('用藥提醒'),
              const SizedBox(height: 20),
              _buildAlarmButton('活動提醒'),
              const SizedBox(height: 20),
              _buildAlarmButton('喝水提醒'),
              const SizedBox(height: 20),
              _buildAlarmButton('休息提醒'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlarmButton(String type) {
    return InkWell(
      onTap: () => _navigateToAlarmDetail(type),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: borderColor, width: 3),
          borderRadius: BorderRadius.circular(15),
        ),
        width: double.infinity,
        height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              labels[type]!,
              style: const TextStyle(fontSize: 30),
              textAlign: TextAlign.start,
            ),
          ],
        ),
      ),
    );
  }
}

class _AlarmDetailPage extends StatefulWidget {
  final String title;
  final List<AlarmItem> alarms;
  final Color borderColor;
  final Function(List<AlarmItem>) onSave;

  const _AlarmDetailPage({
    required this.title,
    required this.alarms,
    required this.borderColor,
    required this.onSave,
  });

  @override
  State<_AlarmDetailPage> createState() => _AlarmDetailPageState();
}

class _AlarmDetailPageState extends State<_AlarmDetailPage> {
  late List<AlarmItem> _alarms;

  @override
  void initState() {
    super.initState();
    _alarms = List.from(widget.alarms);
  }

  void _addOrUpdateAlarm(AlarmItem alarm, {bool isNew = true}) {
    setState(() {
      if (isNew) {
        _alarms.add(alarm);
        _alarms.sort((a, b) => a.compareTo(b));
      }
      if (alarm.isEnabled) {
        NotificationService().scheduleAlarm(alarm);
      }
    });
  }

  void _toggleAlarm(AlarmItem alarm, bool value) {
    setState(() {
      alarm.isEnabled = value;
    });
    if (value) {
      NotificationService().scheduleAlarm(alarm);
    } else {
      NotificationService().cancelAlarm(alarm);
    }
    widget.onSave(_alarms);
  }

  void _deleteAlarm(int index) {
    NotificationService().cancelAlarm(_alarms[index]);
    setState(() {
      _alarms.removeAt(index);
    });
    widget.onSave(_alarms);
  }

  void _editAlarm(int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AlarmSettingDialog(
        borderColor: widget.borderColor,
        alarmType: widget.title,
        initialAlarm: _alarms[index],
        onSave: (AlarmItem editedAlarm) {
          setState(() {
            // 先取消舊的通知
            NotificationService().cancelAlarm(_alarms[index]);

            // 更新鬧鐘
            _alarms[index] = editedAlarm;
            _alarms.sort((a, b) => a.compareTo(b));

            // 如果新的鬧鐘是啟用的，則設置通知
            if (editedAlarm.isEnabled) {
              NotificationService().scheduleAlarm(editedAlarm);
            }
          });
          widget.onSave(_alarms);
        },
        onDelete: () {
          _deleteAlarm(index);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 238, 238, 255),
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: widget.borderColor, width: 3),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.title),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: FloatingActionButton(
          backgroundColor: widget.borderColor,
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => _AlarmSettingDialog(
                borderColor: widget.borderColor,
                alarmType: widget.title,
                onSave: (AlarmItem newAlarm) {
                  _addOrUpdateAlarm(newAlarm);
                  widget.onSave(_alarms);
                },
              ),
            );
          },
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      body: _alarms.isEmpty
          ? Center(
              child: Text(
                '沒有任何 ${widget.title}',
                style: const TextStyle(fontSize: 28, color: Colors.black),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(
                  left: 16, right: 16, top: 16, bottom: 90),
              itemCount: _alarms.length,
              itemBuilder: (context, index) {
                final alarm = _alarms[index];
                return InkWell(
                  onTap: () => _editAlarm(index),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(color: widget.borderColor, width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${alarm.time.hour.toString().padLeft(2, '0')}:${alarm.time.minute.toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: alarm.isEnabled
                                        ? Colors.black
                                        : Colors.grey,
                                  ),
                                ),
                                Text(
                                  '${alarm.name}，${alarm.weekdaysText}',
                                  style: TextStyle(
                                    fontSize: 22,
                                    color: alarm.isEnabled
                                        ? Colors.black87
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: alarm.isEnabled,
                            onChanged: (value) {
                              _toggleAlarm(alarm, value);
                            },
                            activeColor: widget.borderColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _AlarmSettingDialog extends StatefulWidget {
  final Color borderColor;
  final String alarmType;
  final Function(AlarmItem) onSave;
  final Function()? onDelete;
  final AlarmItem? initialAlarm;

  const _AlarmSettingDialog({
    required this.borderColor,
    required this.alarmType,
    required this.onSave,
    this.onDelete,
    this.initialAlarm,
  });

  @override
  State<_AlarmSettingDialog> createState() => _AlarmSettingDialogState();
}

class _AlarmSettingDialogState extends State<_AlarmSettingDialog> {
  late final TextEditingController _nameController;
  late TimeOfDay _selectedTime;
  late final List<bool> _selectedWeekdays;
  final List<String> _weekdayNames = ['一', '二', '三', '四', '五', '六', '日'];
  late List<String> _presets = [];
  late StorageKeys _presetsKey;
  final FocusNode _nameFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.initialAlarm?.name ?? '');
    _selectedTime = widget.initialAlarm?.time ?? TimeOfDay.now();
    _selectedWeekdays =
        List.from(widget.initialAlarm?.weekdays ?? List.filled(7, false));

    String alarmTypeWithoutEmoji = _getAlarmTypeWithoutEmoji();
    switch (alarmTypeWithoutEmoji) {
      case '用藥提醒':
        _presetsKey = StorageKeys.medicinePresets;
        _presets = List<String>.from(defaultPresets['用藥提醒']!);
        break;
      case '活動提醒':
        _presetsKey = StorageKeys.activityPresets;
        _presets = List<String>.from(defaultPresets['活動提醒']!);
        break;
      case '喝水提醒':
        _presetsKey = StorageKeys.waterPresets;
        _presets = List<String>.from(defaultPresets['喝水提醒']!);
        break;
      case '休息提醒':
        _presetsKey = StorageKeys.restPresets;
        _presets = List<String>.from(defaultPresets['休息提醒']!);
        break;
      default:
        throw Exception('Unknown alarm type: ${widget.alarmType}');
    }
    _loadPresets();
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadPresets() async {
    final presetsJson = await SharedPreferencesService().getData(_presetsKey);
    if (presetsJson != null) {
      setState(() {
        _presets = List<String>.from(jsonDecode(presetsJson));
      });
    } else {
      _savePresets();
    }
  }

  Future<void> _savePresets() async {
    await SharedPreferencesService().saveData(
      _presetsKey,
      jsonEncode(_presets),
    );
  }

  void _showPresetsDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('取消', style: TextStyle(fontSize: 24)),
                    ),
                    Text(
                      '選擇${widget.alarmType}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (dialogContext) => _AddPresetDialog(
                            onAdd: (String newPreset) {
                              setModalState(() {
                                setState(() {
                                  _presets.add(newPreset);
                                  _savePresets();
                                });
                              });
                              Navigator.pop(dialogContext);
                            },
                          ),
                        );
                      },
                      child: const Text('新增', style: TextStyle(fontSize: 24)),
                    ),
                  ],
                ),
              ),
              const Divider(thickness: 1),
              Expanded(
                child: _presets.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            '點擊右上角新增第一筆自訂提醒名稱',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _presets.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                              _presets[index],
                              style: const TextStyle(fontSize: 20),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                setModalState(() {
                                  setState(() {
                                    _presets.removeAt(index);
                                    _savePresets();
                                  });
                                });
                              },
                            ),
                            onTap: () {
                              _nameController.text = _presets[index];
                              Navigator.pop(context);
                            },
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

  void _showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          '確認刪除',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          '確定要刪除這個提醒嗎？',
          style: TextStyle(fontSize: 20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消', style: TextStyle(fontSize: 20)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete?.call();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('刪除', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }

  String _getAlarmTypeWithoutEmoji() {
    return widget.alarmType
        .replaceAll('💊 ', '')
        .replaceAll('🏃‍♂️ ', '')
        .replaceAll('💧 ', '')
        .replaceAll('💤 ', '');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        '取消',
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                    Text(
                      widget.initialAlarm == null
                          ? '新增${_getAlarmTypeWithoutEmoji()}'
                          : '編輯${_getAlarmTypeWithoutEmoji()}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        if (_nameController.text.isEmpty) {
                          showCustomDialog(context, "提示", "請輸入提醒內容",
                              closeButton: true);
                          return;
                        }
                        if (!_selectedWeekdays.contains(true)) {
                          showCustomDialog(context, "提示", "請選擇每週幾需要提醒",
                              closeButton: true);
                          return;
                        }
                        final newAlarm = AlarmItem(
                          name: _nameController.text,
                          time: _selectedTime,
                          weekdays: _selectedWeekdays,
                          type: _getAlarmTypeWithoutEmoji(),
                        );
                        widget.onSave(newAlarm);
                        Navigator.pop(context);
                      },
                      child: const Text(
                        '儲存',
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(thickness: 1),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '提醒內容',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _nameController,
                              focusNode: _nameFocusNode,
                              style: const TextStyle(fontSize: 24),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.edit),
                            label: const Text(
                              '選擇',
                              style: TextStyle(fontSize: 20),
                            ),
                            onPressed: _showPresetsDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  widget.borderColor.withOpacity(0.8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        '時間',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () async {
                          FocusScope.of(context).unfocus();
                          TimeOfDay selectedTime = _selectedTime;
                          await showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (BuildContext context) {
                              DateTime initialDateTime = DateTime(
                                0,
                                0,
                                0,
                                _selectedTime.hour,
                                _selectedTime.minute,
                              );
                              return Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.4,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20)),
                                ),
                                child: CupertinoDatePicker(
                                  mode: CupertinoDatePickerMode.time,
                                  initialDateTime: initialDateTime,
                                  use24hFormat: true,
                                  itemExtent: 38,
                                  onDateTimeChanged: (DateTime newDateTime) {
                                    selectedTime = TimeOfDay(
                                      hour: newDateTime.hour,
                                      minute: newDateTime.minute,
                                    );
                                  },
                                ),
                              );
                            },
                          ).then((_) {
                            setState(() {
                              _selectedTime = selectedTime;
                            });
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time, size: 30),
                              const SizedBox(width: 12),
                              Text(
                                '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(fontSize: 24),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        '重複',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(7, (index) {
                          return Container(
                            width: 45,
                            height: 45,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                backgroundColor: _selectedWeekdays[index]
                                    ? widget.borderColor
                                    : Colors.white,
                                foregroundColor: _selectedWeekdays[index]
                                    ? Colors.white
                                    : Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22.5),
                                  side: BorderSide(
                                    color: widget.borderColor,
                                    width: 2,
                                  ),
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  _selectedWeekdays[index] =
                                      !_selectedWeekdays[index];
                                });
                              },
                              child: Text(
                                _weekdayNames[index],
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          );
                        }),
                      ),
                      if (widget.initialAlarm != null) ...[
                        const SizedBox(height: 32),
                        Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD32F2F),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: _showDeleteConfirmDialog,
                              child: const Text(
                                '刪除提醒',
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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

class _AddPresetDialog extends StatefulWidget {
  final Function(String) onAdd;

  const _AddPresetDialog({required this.onAdd});

  @override
  State<_AddPresetDialog> createState() => _AddPresetDialogState();
}

class _AddPresetDialogState extends State<_AddPresetDialog> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('新增項目名稱',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      content: TextField(
        controller: _controller,
        style: const TextStyle(fontSize: 20),
        decoration: const InputDecoration(
          hintText: '請輸入名稱',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消', style: TextStyle(fontSize: 20)),
        ),
        TextButton(
          onPressed: () {
            if (_controller.text.isNotEmpty) {
              widget.onAdd(_controller.text);
            }
          },
          child: const Text('確定', style: TextStyle(fontSize: 20)),
        ),
      ],
    );
  }
}
