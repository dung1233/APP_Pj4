class Rank {
  final int id;
  final int strengthScore;
  final int enduranceScore;
  final int healthScore;
  final int agilityScore;
  final int deathpoints;
  final double totalScore;
  final int rank;
  final String userName;

  Rank({
    required this.id,
    required this.strengthScore,
    required this.enduranceScore,
    required this.healthScore,
    required this.agilityScore,
    required this.deathpoints,
    required this.totalScore,
    required this.rank,
    required this.userName,
  });

  factory Rank.fromJson(Map<String, dynamic> json) {
    return Rank(
      id: json['id'] as int,
      strengthScore: json['strengthScore'] as int,
      enduranceScore: json['enduranceScore'] as int,
      healthScore: json['healthScore'] as int,
      agilityScore: json['agilityScore'] as int,
      deathpoints: json['deathpoints'] as int,
      totalScore: json['totalScore'] as double,
      rank: json['rank'] as int,
      userName: json['userName'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'strengthScore': strengthScore,
        'enduranceScore': enduranceScore,
        'healthScore': healthScore,
        'agilityScore': agilityScore,
        'deathpoints': deathpoints,
        'totalScore': totalScore,
        'rank': rank,
        'userName': userName,
      };
}
