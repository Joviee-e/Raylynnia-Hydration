import 'hydration_log.dart';

class DailyHydrationSummary {
  const DailyHydrationSummary({
    required this.date,
    required this.totalVolumeMl,
    required this.logs,
  });

  final DateTime date;
  final int totalVolumeMl;
  final List<HydrationLog> logs;
}
