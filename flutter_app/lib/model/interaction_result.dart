class InteractionResult {
  final bool isSafe;
  final List<InteractionConflict> conflicts;

  InteractionResult({required this.isSafe, required this.conflicts});

  factory InteractionResult.fromJson(Map<String, dynamic> json) {
    final conflictList = (json['conflicts'] as List<dynamic>? ?? [])
        .map((e) => InteractionConflict.fromJson(e))
        .toList();
    return InteractionResult(
      isSafe: json['isSafe'] ?? true,
      conflicts: conflictList,
    );
  }
}

class InteractionConflict {
  final String drugA;
  final String drugB;
  final String reason;

  InteractionConflict({
    required this.drugA,
    required this.drugB,
    required this.reason,
  });

  factory InteractionConflict.fromJson(Map<String, dynamic> json) {
    return InteractionConflict(
      drugA: json['drugA'],
      drugB: json['drugB'],
      reason: json['reason'],
    );
  }
}