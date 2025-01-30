class PetMilestone {
  final String title;
  final String description;
  final DateTime achievedDate;
  final String icon;

  PetMilestone({
    required this.title,
    required this.description,
    required this.achievedDate,
    required this.icon,
  });
}

class PetMilestones {
  final List<PetMilestone> milestones = [];

  void addMilestone(PetMilestone milestone) {
    milestones.add(milestone);
  }

  void checkStepsMilestone(int steps) {
    if (steps >= 1000 && !_hasMilestone("首次達成千步")) {
      addMilestone(PetMilestone(
        title: "首次達成千步",
        description: "你和寵物一起完成了1000步的里程碑！",
        achievedDate: DateTime.now(),
        icon: "🏃",
      ));
    }
    // 可以添加更多里程碑檢查
  }

  bool _hasMilestone(String title) {
    return milestones.any((m) => m.title == title);
  }
} 