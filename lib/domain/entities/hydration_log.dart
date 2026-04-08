class HydrationLog {
  const HydrationLog({
    required this.id,
    required this.timestamp,
    required this.volumeMl,
  });

  final String id;
  final DateTime timestamp;
  final int volumeMl;
}
