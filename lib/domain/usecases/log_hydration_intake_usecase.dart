import '../entities/hydration_log.dart';
import '../repositories/i_hydration_log_repository.dart';

/// Use case: Log hydration intake.
/// Records a drink event with volume and timestamp.
class LogHydrationIntakeUseCase {
  const LogHydrationIntakeUseCase(this.hydrationLogRepository);

  final IHydrationLogRepository hydrationLogRepository;

  /// Execute the use case.
  /// Appends a new hydration log entry.
  Future<void> execute({
    required int volumeMl,
    required DateTime timestamp,
  }) async {
    final log = HydrationLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      volumeMl: volumeMl,
      timestamp: timestamp,
    );
    await hydrationLogRepository.appendEntry(log);
  }
}
