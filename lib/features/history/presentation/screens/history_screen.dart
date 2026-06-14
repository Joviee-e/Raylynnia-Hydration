import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../widgets/daily_log_tile.dart';
import '../widgets/weekly_bar_chart.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(historyViewModelProvider);
    final historyViewModel = ref.read(historyViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        elevation: 0,
      ),
      body: historyState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Weekly chart
                  if (historyState.weeklyData.isNotEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'This Week',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            WeeklyBarChart(
                              weeklyData: historyState.weeklyData,
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Daily logs
                  Text(
                    'Daily Logs',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),

                  // Date picker
                  Card(
                    child: ListTile(
                      title: Text(
                        'Selected Date: ${historyState.selectedDate?.toString().split(' ')[0] ?? 'Today'}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: historyState.selectedDate ?? DateTime.now(),
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          historyViewModel.loadDailyData(picked);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Daily summary
                  if (historyState.dailyLogs.isNotEmpty)
                    Card(
                      child: ListTile(
                        title: const Text('Total Intake'),
                        trailing: Text(
                          '${historyState.getDailyTotal()} ml',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),

                  // Logs list
                  if (historyState.dailyLogs.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Text(
                          'No logs for this date',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: historyState.dailyLogs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        return DailyLogTile(
                          log: historyState.dailyLogs[index],
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }
}
