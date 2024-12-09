import 'dart:math';

import 'package:flutter/material.dart';
import 'package:usrcare/api/APIService.dart';
import 'package:usrcare/utils/MiscUtil.dart';
import 'package:usrcare/utils/SharedPreference.dart';
import 'package:usrcare/services/PedometerService.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:usrcare/utils/PermissionUtil.dart';

class PetCompanionPage extends StatefulWidget {
  const PetCompanionPage({super.key});

  @override
  _PetCompanionPageState createState() => _PetCompanionPageState();
}

class _PetCompanionPageState extends State<PetCompanionPage> with WidgetsBindingObserver {
  String petName = "您的寵物";
  double happiness = 0;
  double hunger = 0;
  double cleanliness = 0;
  int steps = 0;
  int targetSteps = 1000;
  int level = 1;
  int experience = 0;
  late APIService _apiService;
  final _sharedPrefs = SharedPreferencesService();
  late PedometerService _pedometerService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    PermissionUtil.initPermissionStatus([
      Permission.activityRecognition,
    ]);
    _checkActivityPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    PermissionUtil.handleAppLifecycleStateChange(state, context);
  }

  Future<void> _checkActivityPermission() async {
    await PermissionUtil.checkAndRequestPermission(
      context,
      Permission.activityRecognition,
      "活動追蹤",
      "為了使用完整功能，我們需要活動追蹤權限用於紀錄您的走路步數。",
      () {
        _pedometerService = PedometerService();
        _initializeAPI();
        _initializePetName();
        _initializePedometer();
      },
      onCancel: () {
        Navigator.of(context).pop();
      },
    );
  }

  Future<void> _initializeAPI() async {
    final token = await _sharedPrefs.getData(StorageKeys.userToken);
    _apiService = APIService(token: token);
    await _initializePedometerGoal();
  }

  Future<void> _initializePetName() async {
    final localPetName = await _sharedPrefs.getData(StorageKeys.petCompanionPetName);
    
    if (localPetName != null) {
      setState(() {
        petName = localPetName;
      });
    } else {
      final response = await _apiService.getPetName(context);
      final result = handleHttpResponses(context, response, "取得寵物名稱失敗");
      
      if (result != null) {
        final name = result['pet_companion_pet_name'];
        if (name != null) {
          await _sharedPrefs.saveData(StorageKeys.petCompanionPetName, name.toString());
          if (mounted) {
            setState(() {
              petName = name.toString();
            });
          }
        }
      }
    }
  }

  Future<void> _initializePedometerGoal() async {
    final response = await _apiService.getPedometerGoal(context);
    final result = handleHttpResponses(context, response, "取得步數目標失敗");
    
    if (result != null) {
      final goalValue = result['pet_companion_pedomoter_goal'];
      if (goalValue == null) {
        final suggestedSteps = result['pet_companion_pedomoter_goal_suggestion'] ?? 1000;
        
        if (mounted) {
          _showSetGoalDialog(int.parse(suggestedSteps.toString()));
        }
      } else {
        setState(() {
          targetSteps = int.parse(goalValue.toString());
        });
      }
    }
  }

  Future<void> _initializePedometer() async {
    await _pedometerService.initialize();
    
    // 獲取歷史數據（不包括今天）
    final historicalStepData = await _pedometerService.getHistoricalStepData();
    
    if (historicalStepData.isNotEmpty) {
      final syncedDates = <String>[];
      
      for (var stepData in historicalStepData) {
        final response = await _apiService.postPedometerSteps(
          stepData.steps,
          DateTime.parse(stepData.date),
          context,
        );
        
        final result = handleHttpResponses(
          context,
          response,
          "同步步數資料失敗",
        );
        
        if (result != null) {
          syncedDates.add(stepData.date);
        }
      }
      
      // 清除已同步的歷史數據
      if (syncedDates.isNotEmpty) {
        await _pedometerService.clearHistoricalStepData(syncedDates);
      }
    }
    
    // 更新顯示今天的步數
    if (mounted) {
      final todaySteps = await _pedometerService.getTodaySteps();
      setState(() {
        steps = todaySteps;
      });
    }
  }

  void _showSetGoalDialog(int suggestedSteps) {
    int currentSteps = suggestedSteps;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: true,
          child: StatefulBuilder(
            builder: (context, setState) {
              void updateSteps(int change) {
                setState(() {
                  currentSteps = min(50000, max(1000, currentSteps + change));
                });
              }

              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  width: 300,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "設定每日步數目標",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 240, 255, 238),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color.fromARGB(255, 61, 152, 71),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.tips_and_updates,
                              color: Color.fromARGB(255, 61, 152, 71),
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "建議步數：$suggestedSteps步",
                              style: const TextStyle(
                                fontSize: 24,
                                color: Color.fromARGB(255, 61, 152, 71),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStepButton(
                            icon: Icons.remove,
                            onPressed: () => updateSteps(-1000),
                            isEnabled: currentSteps > 1000,
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 140,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color.fromARGB(255, 61, 152, 71),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "$currentSteps步",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildStepButton(
                            icon: Icons.add,
                            onPressed: () => updateSteps(1000),
                            isEnabled: currentSteps < 50000,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          final response = await _apiService.setPedometerGoal(
                            currentSteps,
                            context,
                          );
                          
                          final result = handleHttpResponses(
                            context,
                            response,
                            "設定步數目標失敗",
                          );
                          
                          if (result != null && mounted) {
                            Navigator.of(context).pop();
                            this.setState(() {
                              targetSteps = currentSteps;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 61, 152, 71),
                          minimumSize: const Size(double.infinity, 45),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "確定",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStepButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isEnabled,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isEnabled 
          ? const Color.fromARGB(255, 61, 152, 71)
          : Colors.grey[400],
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: isEnabled ? onPressed : null,
        icon: Icon(icon, color: Colors.white),
        padding: const EdgeInsets.all(12),
      ),
    );
  }

  Widget _buildStatusBar(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 16)),
            Text(
              "${value.toInt()}/100",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            value: value / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildStepsProgress() {
    return Container(
      height: 230,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            height: 300,
            width: 300,
            child: Image.asset(
              "assets/Pet_Images/dog_bg.png",
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            left: 100,
            child: Container(
              height: 200,
              width: 200,
              child: Image.asset(
                "assets/Pet_Images/dog.png",
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color.fromARGB(255, 61, 152, 71).withOpacity(0.6),
                  width: 2
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "$steps",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 61, 152, 71),
                    ),
                  ),
                  const Text(
                    " / ",
                    style: TextStyle(
                      fontSize: 26,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    "${targetSteps}步",
                    style: const TextStyle(
                      fontSize: 26,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditPetNameDialog() {
    String newPetName = petName;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return PopScope(
          canPop: true,
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                width: 300,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "設定寵物名稱",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromARGB(255, 61, 152, 71),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: TextEditingController(text: newPetName),
                        onChanged: (value) {
                          if (value.length <= 7) {
                            newPetName = value;
                          }
                        },
                        maxLength: 7,
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: InputBorder.none,
                          counterText: "",
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        if (newPetName.trim().isEmpty) {
                          return;
                        }
                        
                        final response = await _apiService.setPetName(
                          newPetName.trim(),
                          context,
                        );
                        
                        final result = handleHttpResponses(
                          context,
                          response,
                          "設定寵物名稱失敗",
                        );
                        
                        if (result != null && mounted) {
                          await _sharedPrefs.saveData(
                            StorageKeys.petCompanionPetName,
                            newPetName.trim(),
                          );
                          
                          setState(() {
                            petName = newPetName.trim();
                          });
                          
                          Navigator.of(context).pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 61, 152, 71),
                        minimumSize: const Size(double.infinity, 45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "確定",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 222, 236, 220),
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color.fromARGB(255, 61, 152, 71), width: 3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset("assets/HomePage_Icons/pet.png", height: 50),
              const SizedBox(width: 10),
              const Text("寵物陪伴")
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          children: [
            Expanded(
              child: Card(
                elevation: 4,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.transparent,
                            ),
                            onPressed: (){},
                          ),
                          Container(
                            constraints: const BoxConstraints(maxWidth: 200),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                petName,
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.black54,
                              size: 30,
                            ),
                            onPressed: _showEditPetNameDialog,
                          ),
                        ],
                      ),
                      _buildStepsProgress(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: [
                            _buildStatusBar("心情", happiness, Colors.pink),
                            const SizedBox(height: 8),
                            _buildStatusBar("飢餓度", hunger, Colors.orange),
                            const SizedBox(height: 8),
                            _buildStatusBar("清潔度", cleanliness, Colors.blue),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 4,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildItemButton("球球", "https://api.tkuusraicare.org/img/shop/items/ball.png", () {
                      setState(() {
                        happiness = min(100, happiness + 20);
                      });
                    }),
                    _buildItemButton("骨頭", "https://api.tkuusraicare.org/img/shop/items/bone.png", () {
                      setState(() {
                        hunger = min(100, hunger + 20);
                      });
                    }),
                    _buildItemButton("肥皂", "https://api.tkuusraicare.org/img/shop/items/soap.png", () {
                      setState(() {
                        cleanliness = min(100, cleanliness + 20);
                      });
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemButton(String label, String imageURL, VoidCallback onPressed) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 50,
          width: 50,
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: Image.network(
              imageURL,
              fit: BoxFit.contain,
            ),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}

class ArcProgressPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;

  ArcProgressPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;
    final rect = Rect.fromCircle(center: center, radius: radius);
    
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    
    canvas.drawArc(
      rect,
      -pi * 0.8,
      pi * 1.6,
      false,
      backgroundPaint,
    );
    
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    
    canvas.drawArc(
      rect,
      -pi * 0.8,
      pi * 1.6 * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
