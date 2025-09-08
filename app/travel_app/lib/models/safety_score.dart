enum SafetyLevel {
  safe(5, 'Safe'),
  moderate(4, 'Moderate'),
  caution(3, 'Caution'),
  risky(2, 'Risky'),
  dangerous(1, 'Dangerous');

  const SafetyLevel(this.score, this.label);
  final int score;
  final String label;
}

class SafetyScore {
  final int score; // 1-5 scale
  final SafetyLevel level;
  final String description;
  final List<String> factors;
  final DateTime calculatedAt;

  SafetyScore({
    required this.score,
    required this.level,
    required this.description,
    required this.factors,
    required this.calculatedAt,
  });

  factory SafetyScore.calculate({
    required double latitude,
    required double longitude,
    required DateTime currentTime,
    List<String> nearbyIncidents = const [],
    bool isRestrictedZone = false,
    int crowdDensity = 0,
    bool hasPolicePresence = false,
  }) {
    int calculatedScore = 5;
    List<String> factors = [];

    // Time-based scoring
    int hour = currentTime.hour;
    if (hour >= 22 || hour <= 5) {
      calculatedScore -= 1;
      factors.add('Late night hours');
    }

    // Zone-based scoring
    if (isRestrictedZone) {
      calculatedScore -= 2;
      factors.add('Restricted zone');
    }

    // Incident-based scoring
    if (nearbyIncidents.isNotEmpty) {
      calculatedScore -= nearbyIncidents.length.clamp(0, 2);
      factors.add('Recent incidents nearby');
    }

    // Crowd density
    if (crowdDensity > 8) {
      calculatedScore -= 1;
      factors.add('High crowd density');
    } else if (crowdDensity < 2) {
      calculatedScore -= 1;
      factors.add('Isolated area');
    }

    // Police presence
    if (hasPolicePresence) {
      calculatedScore += 1;
      factors.add('Police presence nearby');
    }

    // Ensure score is within bounds
    calculatedScore = calculatedScore.clamp(1, 5);

    SafetyLevel level = SafetyLevel.values.firstWhere(
      (sl) => sl.score == calculatedScore,
      orElse: () => SafetyLevel.moderate,
    );

    String description = _getDescription(level, factors);

    return SafetyScore(
      score: calculatedScore,
      level: level,
      description: description,
      factors: factors,
      calculatedAt: currentTime,
    );
  }

  static String _getDescription(SafetyLevel level, List<String> factors) {
    switch (level) {
      case SafetyLevel.safe:
        return 'This area is generally safe for tourists. Continue enjoying your trip!';
      case SafetyLevel.moderate:
        return 'This area is moderately safe. Stay aware of your surroundings.';
      case SafetyLevel.caution:
        return 'Exercise caution in this area. Stay with groups when possible.';
      case SafetyLevel.risky:
        return 'This area has elevated risks. Consider moving to a safer location.';
      case SafetyLevel.dangerous:
        return 'This area is potentially dangerous. Leave immediately and seek help if needed.';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'level': level.name,
      'description': description,
      'factors': factors,
      'calculatedAt': calculatedAt.toIso8601String(),
    };
  }

  factory SafetyScore.fromJson(Map<String, dynamic> json) {
    return SafetyScore(
      score: json['score'],
      level: SafetyLevel.values.byName(json['level']),
      description: json['description'],
      factors: List<String>.from(json['factors']),
      calculatedAt: DateTime.parse(json['calculatedAt']),
    );
  }
}
