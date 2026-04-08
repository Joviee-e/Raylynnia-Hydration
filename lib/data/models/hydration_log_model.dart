class HydrationLogModel {
  const HydrationLogModel({
    required this.id,
    required this.timestamp,
    required this.volumeMl,
  });

  final String id;
  final DateTime timestamp;
  final int volumeMl;

  factory HydrationLogModel.fromJson(Map<String, dynamic> json) {
    return HydrationLogModel(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      volumeMl: json['volumeMl'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'volumeMl': volumeMl,
    };
  }
}
