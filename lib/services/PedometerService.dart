import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:pedometer/pedometer.dart';
import 'package:workmanager/workmanager.dart';
import 'package:usrcare/utils/SharedPreference.dart';

class StepData {
  final String date;
  final int steps;

  StepData({required this.date, required this.steps});

  Map<String, dynamic> toJson() => {
    'date': date,
    'steps': steps,
  };

  factory StepData.fromJson(Map<String, dynamic> json) => StepData(
    date: json['date'],
    steps: json['steps'],
  );
}

class PedometerService {
  static const String _workManagerTaskName = 'stepCounterTask';
  final _sharedPrefs = SharedPreferencesService();
  
  // 註冊活動-每15分鐘執行callBackDispatcher
  Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: kDebugMode);
    await Workmanager().registerPeriodicTask(
      _workManagerTaskName,
      _workManagerTaskName,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: false,
      ),
    );
  }

  // 修改：保存最後一次的步數記錄
  Future<void> _saveLastStepRecord(int totalSteps) async {
    await _sharedPrefs.saveData(
      StorageKeys.petCompanionPedometerLastRecord,
      json.encode({
        'timestamp': DateTime.now().toIso8601String(),
        'steps': totalSteps,
      }),
    );
  }

  // 修改：獲取最後一次的步數記錄
  Future<Map<String, dynamic>?> _getLastStepRecord() async {
    final recordStr = await _sharedPrefs.getData(StorageKeys.petCompanionPedometerLastRecord);
    if (recordStr != null) {
      return json.decode(recordStr) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> saveStepData(int currentTotalSteps) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day).toIso8601String().split('T')[0];
    
    // 獲取上一次的記錄
    final lastRecord = await _getLastStepRecord();
    
    if (lastRecord != null) {
      final lastTimestamp = DateTime.parse(lastRecord['timestamp']);
      final lastSteps = lastRecord['steps'] as int;
      
      // 計算步數差
      int stepsDiff = currentTotalSteps - lastSteps;
      
      // 如果當前步數小於上次記錄（可能是手機重啟），則直接使用當前步數
      if (stepsDiff < 0) {
        stepsDiff = currentTotalSteps;
      }
      
      // 檢查是否跨日
      final lastDate = DateTime(lastTimestamp.year, lastTimestamp.month, lastTimestamp.day);
      final currentDate = DateTime(now.year, now.month, now.day);
      
      if (lastDate.isBefore(currentDate)) {
        // 跨日情況：將步數差按時間比例分配給兩天
        final totalMinutes = now.difference(lastTimestamp).inMinutes;
        final lastDayMinutes = DateTime(currentDate.year, currentDate.month, currentDate.day)
            .difference(lastTimestamp).inMinutes;
        
        if (totalMinutes > 0) {
          // 計算上一天的步數
          final lastDaySteps = (stepsDiff * lastDayMinutes / totalMinutes).round();
          // 計算今天的步數
          final todaySteps = stepsDiff - lastDaySteps;
          
          // 保存上一天的步數
          await _saveStepsForDate(
            lastDate.toIso8601String() + 'T00:00:00Z',
            lastDaySteps,
            append: true
          );
          
          // 保存今天的步數
          await _saveStepsForDate(today + 'T00:00:00Z', todaySteps, append: true);
        }
      } else {
        // 同一天：直接將步數差加到今天
        await _saveStepsForDate(today + 'T00:00:00Z', stepsDiff, append: true);
      }
    } else {
      // 第一次記錄：將當前步數記錄為今天的步數
      await _saveStepsForDate(today + 'T00:00:00Z', currentTotalSteps);
    }
    
    // 更新最後一次記錄
    await _saveLastStepRecord(currentTotalSteps);
  }

  // 新增：為特定日期保存步數
  Future<void> _saveStepsForDate(String date, int steps, {bool append = false}) async {
    final storedDataStr = await _sharedPrefs.getData(StorageKeys.petCompanionPedometerData);
    List<StepData> stepDataList = [];
    
    if (storedDataStr != null) {
      final List<dynamic> storedData = json.decode(storedDataStr);
      stepDataList = storedData.map((data) => StepData.fromJson(data)).toList();
    }

    final dateIndex = stepDataList.indexWhere((data) => data.date == date);
    if (dateIndex != -1) {
      final currentSteps = stepDataList[dateIndex].steps;
      stepDataList[dateIndex] = StepData(
        date: date,
        steps: append ? currentSteps + steps : steps
      );
    } else {
      stepDataList.add(StepData(date: date, steps: steps));
    }

    await _sharedPrefs.saveData(
      StorageKeys.petCompanionPedometerData,
      json.encode(stepDataList.map((data) => data.toJson()).toList()),
    );
  }

  Future<List<StepData>> getStoredStepData() async {
    final storedDataStr = await _sharedPrefs.getData(StorageKeys.petCompanionPedometerData);
    if (storedDataStr == null) return [];

    final List<dynamic> storedData = json.decode(storedDataStr);
    return storedData.map((data) => StepData.fromJson(data)).toList();
  }

  Future<void> clearStoredStepData() async {
    await _sharedPrefs.clearData(StorageKeys.petCompanionPedometerData);
  }

  Future<int> getTodaySteps() async {
    final today = DateTime.now().toIso8601String().split('T')[0] + 'T00:00:00Z';
    final stepDataList = await getStoredStepData();
    
    final todayData = stepDataList.firstWhere(
      (data) => data.date == today,
      orElse: () => StepData(date: today, steps: 0),
    );
    
    return todayData.steps;
  }

  Future<List<StepData>> getHistoricalStepData() async {
    final today = DateTime.now().toIso8601String().split('T')[0] + 'T00:00:00Z';
    final stepDataList = await getStoredStepData();
    
    return stepDataList.where((data) => data.date != today).toList();
  }

  Future<void> clearHistoricalStepData(List<String> dates) async {
    final stepDataList = await getStoredStepData();
    final remainingData = stepDataList.where(
      (data) => !dates.contains(data.date)
    ).toList();
    
    await _sharedPrefs.saveData(
      StorageKeys.petCompanionPedometerData,
      json.encode(remainingData.map((data) => data.toJson()).toList()),
    );
  }
}

class KDebugMode {
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName == 'stepCounterTask') {
      final pedometerService = PedometerService();
      
      try {
        final stepCount = await Pedometer.stepCountStream.first;
        await pedometerService.saveStepData(stepCount.steps);
        return true;
      } catch (e) {
        return false;
      }
    }
    return false;
  });
} 