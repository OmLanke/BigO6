class LoyaltyReward {
  final String id;
  final String title;
  final String description;
  final int pointsRequired;
  final String category;
  final String iconName;
  final bool isUnlocked;
  final DateTime? unlockedDate;

  LoyaltyReward({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsRequired,
    required this.category,
    required this.iconName,
    this.isUnlocked = false,
    this.unlockedDate,
  });

  LoyaltyReward copyWith({
    String? id,
    String? title,
    String? description,
    int? pointsRequired,
    String? category,
    String? iconName,
    bool? isUnlocked,
    DateTime? unlockedDate,
  }) {
    return LoyaltyReward(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      pointsRequired: pointsRequired ?? this.pointsRequired,
      category: category ?? this.category,
      iconName: iconName ?? this.iconName,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedDate: unlockedDate ?? this.unlockedDate,
    );
  }
}

class UserPoints {
  final int totalPoints;
  final int currentStreakDays;
  final int totalTrips;
  final int safetyScore;
  final List<LoyaltyReward> unlockedRewards;
  final Map<String, int> categoryPoints;

  UserPoints({
    required this.totalPoints,
    required this.currentStreakDays,
    required this.totalTrips,
    required this.safetyScore,
    required this.unlockedRewards,
    required this.categoryPoints,
  });

  UserPoints copyWith({
    int? totalPoints,
    int? currentStreakDays,
    int? totalTrips,
    int? safetyScore,
    List<LoyaltyReward>? unlockedRewards,
    Map<String, int>? categoryPoints,
  }) {
    return UserPoints(
      totalPoints: totalPoints ?? this.totalPoints,
      currentStreakDays: currentStreakDays ?? this.currentStreakDays,
      totalTrips: totalTrips ?? this.totalTrips,
      safetyScore: safetyScore ?? this.safetyScore,
      unlockedRewards: unlockedRewards ?? this.unlockedRewards,
      categoryPoints: categoryPoints ?? this.categoryPoints,
    );
  }
}
