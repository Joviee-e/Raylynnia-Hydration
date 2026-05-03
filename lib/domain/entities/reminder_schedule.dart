class ReminderSchedule {
  const ReminderSchedule({
    required this.isWeekend,
    required this.generatedAt,
    required this.times,
  });

  final bool isWeekend;
  final DateTime generatedAt;
  final List<DateTime> times;
}
