import '../models/loyalty_reward.dart';

class LoyaltyRewardsData {
  // Hardcoded user points for demo
  static UserPoints getUserPoints() {
    final totalPoints = 485;
    final currentStreakDays = 7;
    final totalTrips = 3;
    final safetyScore = 92;

    return UserPoints(
      totalPoints: totalPoints,
      currentStreakDays: currentStreakDays,
      totalTrips: totalTrips,
      safetyScore: safetyScore,
      unlockedRewards: _getUnlockedRewards(
        totalPoints,
        currentStreakDays,
        totalTrips,
        safetyScore,
      ),
      categoryPoints: {
        'Safety': 180,
        'Community': 125,
        'Technology': 95,
        'Streaks': 85,
      },
    );
  }

  // All available rewards - now without circular dependency
  static List<LoyaltyReward> getAllRewards() {
    final totalPoints = 485;
    final currentStreakDays = 7;
    final totalTrips = 3;
    final safetyScore = 92;

    return _generateAllRewards(
      totalPoints,
      currentStreakDays,
      totalTrips,
      safetyScore,
    );
  }

  // Generate all rewards without circular dependency
  static List<LoyaltyReward> _generateAllRewards(
    int totalPoints,
    int currentStreakDays,
    int totalTrips,
    int safetyScore,
  ) {
    return [
      // Safety-First Rewards
      LoyaltyReward(
        id: 'safe_explorer',
        title: 'Safe Explorer',
        description: 'Complete 5 trips without safety incidents',
        pointsRequired: 50,
        category: 'Safety',
        iconName: 'shield',
        isUnlocked: totalPoints >= 50,
        unlockedDate: totalPoints >= 50
            ? DateTime.now().subtract(const Duration(days: 15))
            : null,
      ),
      LoyaltyReward(
        id: 'zone_master',
        title: 'Zone Master',
        description: 'Navigate high-risk zones safely',
        pointsRequired: 25,
        category: 'Safety',
        iconName: 'location_on',
        isUnlocked: totalPoints >= 25,
        unlockedDate: totalPoints >= 25
            ? DateTime.now().subtract(const Duration(days: 20))
            : null,
      ),
      LoyaltyReward(
        id: 'emergency_prepared',
        title: 'Emergency Prepared',
        description: 'Complete safety tutorial and emergency setup',
        pointsRequired: 30,
        category: 'Safety',
        iconName: 'medical_services',
        isUnlocked: totalPoints >= 30,
        unlockedDate: totalPoints >= 30
            ? DateTime.now().subtract(const Duration(days: 18))
            : null,
      ),
      LoyaltyReward(
        id: 'alert_responder',
        title: 'Alert Responder',
        description: 'Respond quickly to geofence warnings',
        pointsRequired: 40,
        category: 'Safety',
        iconName: 'warning',
        isUnlocked: totalPoints >= 40,
        unlockedDate: totalPoints >= 40
            ? DateTime.now().subtract(const Duration(days: 12))
            : null,
      ),
      LoyaltyReward(
        id: 'safety_scout',
        title: 'Safety Scout',
        description: 'Visit 10 safe zones rated 4+ stars',
        pointsRequired: 20,
        category: 'Safety',
        iconName: 'star',
        isUnlocked: totalPoints >= 20,
        unlockedDate: totalPoints >= 20
            ? DateTime.now().subtract(const Duration(days: 25))
            : null,
      ),

      // Community & Feedback Rewards
      LoyaltyReward(
        id: 'safety_reporter',
        title: 'Safety Reporter',
        description: 'Submit verified safety feedback',
        pointsRequired: 45,
        category: 'Community',
        iconName: 'report',
        isUnlocked: totalPoints >= 45,
        unlockedDate: totalPoints >= 45
            ? DateTime.now().subtract(const Duration(days: 10))
            : null,
      ),
      LoyaltyReward(
        id: 'review_contributor',
        title: 'Review Contributor',
        description: 'Write detailed safety reviews for 5+ locations',
        pointsRequired: 20,
        category: 'Community',
        iconName: 'rate_review',
        isUnlocked: totalPoints >= 20,
        unlockedDate: totalPoints >= 20
            ? DateTime.now().subtract(const Duration(days: 22))
            : null,
      ),
      LoyaltyReward(
        id: 'mentor_tourist',
        title: 'Mentor Tourist',
        description: 'Help onboard 3+ new tourists',
        pointsRequired: 55,
        category: 'Community',
        iconName: 'people',
        isUnlocked: totalPoints >= 55,
        unlockedDate: totalPoints >= 55
            ? DateTime.now().subtract(const Duration(days: 8))
            : null,
      ),
      LoyaltyReward(
        id: 'incident_reporter',
        title: 'Incident Reporter',
        description: 'Report incidents that improve area monitoring',
        pointsRequired: 75,
        category: 'Community',
        iconName: 'report_problem',
        isUnlocked: totalPoints >= 75,
        unlockedDate: totalPoints >= 75
            ? DateTime.now().subtract(const Duration(days: 5))
            : null,
      ),

      // Technology Engagement
      LoyaltyReward(
        id: 'id_pioneer',
        title: 'ID Pioneer',
        description: 'Register blockchain-based digital tourist ID',
        pointsRequired: 25,
        category: 'Technology',
        iconName: 'badge',
        isUnlocked: totalPoints >= 25,
        unlockedDate: totalPoints >= 25
            ? DateTime.now().subtract(const Duration(days: 20))
            : null,
      ),
      LoyaltyReward(
        id: 'verification_master',
        title: 'Verification Master',
        description: 'Complete all verification steps',
        pointsRequired: 35,
        category: 'Technology',
        iconName: 'verified',
        isUnlocked: totalPoints >= 35,
        unlockedDate: totalPoints >= 35
            ? DateTime.now().subtract(const Duration(days: 16))
            : null,
      ),
      LoyaltyReward(
        id: 'feature_explorer',
        title: 'Feature Explorer',
        description: 'Use all major app features',
        pointsRequired: 30,
        category: 'Technology',
        iconName: 'explore',
        isUnlocked: totalPoints >= 30,
        unlockedDate: totalPoints >= 30
            ? DateTime.now().subtract(const Duration(days: 18))
            : null,
      ),
      LoyaltyReward(
        id: 'multilingual_user',
        title: 'Multilingual User',
        description: 'Use app in multiple languages',
        pointsRequired: 25,
        category: 'Technology',
        iconName: 'language',
        isUnlocked: totalPoints >= 25,
        unlockedDate: totalPoints >= 25
            ? DateTime.now().subtract(const Duration(days: 20))
            : null,
      ),

      // Streak & Consistency Rewards
      LoyaltyReward(
        id: 'safety_streak',
        title: 'Safety Streak',
        description: 'Maintain safe travel for 7+ consecutive days',
        pointsRequired: 70,
        category: 'Streaks',
        iconName: 'trending_up',
        isUnlocked: currentStreakDays >= 7,
        unlockedDate: currentStreakDays >= 7
            ? DateTime.now().subtract(const Duration(days: 1))
            : null,
      ),
      LoyaltyReward(
        id: 'checkin_streak',
        title: 'Check-in Streak',
        description: 'Daily check-ins for 7+ consecutive days',
        pointsRequired: 35,
        category: 'Streaks',
        iconName: 'check_circle',
        isUnlocked: currentStreakDays >= 7,
        unlockedDate: currentStreakDays >= 7
            ? DateTime.now().subtract(const Duration(days: 1))
            : null,
      ),
      LoyaltyReward(
        id: 'first_trip',
        title: 'First Trip',
        description: 'Successfully complete first trip',
        pointsRequired: 50,
        category: 'Milestones',
        iconName: 'flight_takeoff',
        isUnlocked: totalTrips >= 1,
        unlockedDate: totalTrips >= 1
            ? DateTime.now().subtract(const Duration(days: 30))
            : null,
      ),
      LoyaltyReward(
        id: 'veteran_traveler',
        title: 'Veteran Traveler',
        description: 'Complete 10+ safe trips',
        pointsRequired: 100,
        category: 'Milestones',
        iconName: 'card_travel',
        isUnlocked: totalTrips >= 10,
        unlockedDate: null,
      ),
      LoyaltyReward(
        id: 'safety_ambassador',
        title: 'Safety Ambassador',
        description: 'Maintain 95%+ safety score across trips',
        pointsRequired: 100,
        category: 'Special',
        iconName: 'emoji_events',
        isUnlocked: safetyScore >= 95,
        unlockedDate: safetyScore >= 95
            ? DateTime.now().subtract(const Duration(days: 2))
            : null,
      ),
    ];
  }

  // Get unlocked rewards
  static List<LoyaltyReward> _getUnlockedRewards(
    int totalPoints,
    int currentStreakDays,
    int totalTrips,
    int safetyScore,
  ) {
    return _generateAllRewards(
      totalPoints,
      currentStreakDays,
      totalTrips,
      safetyScore,
    ).where((reward) => reward.isUnlocked).toList();
  }

  // Get next reward to unlock
  static LoyaltyReward? getNextReward() {
    final lockedRewards = getAllRewards()
        .where((reward) => !reward.isUnlocked)
        .toList();
    if (lockedRewards.isEmpty) return null;

    lockedRewards.sort((a, b) => a.pointsRequired.compareTo(b.pointsRequired));
    return lockedRewards.first;
  }

  // Get rewards by category
  static List<LoyaltyReward> getRewardsByCategory(String category) {
    return getAllRewards()
        .where((reward) => reward.category == category)
        .toList();
  }
}
