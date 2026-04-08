abstract class IHydrationLogLocalDataSource {
  Future<List<Map<String, dynamic>>> getHydrationLogs();
  Future<void> addHydrationLog(Map<String, dynamic> json);
}
