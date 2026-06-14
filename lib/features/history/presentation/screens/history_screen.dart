import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../core/widgets/app_header.dart';
import '../widgets/daily_log_tile.dart';
import '../widgets/weekly_bar_chart.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  double _calculateDailyAverageLiters(Map<DateTime, int> weeklyData) {
    if (weeklyData.isEmpty) return 0.0;
    final totalMl = weeklyData.values.fold(0, (sum, val) => sum + val);
    // Average over 7 days of the week
    final avgMl = totalMl / 7.0;
    return avgMl / 1000.0;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Today';
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Today';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) {
      return 'Yesterday';
    }
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(historyViewModelProvider);
    final historyViewModel = ref.read(historyViewModelProvider.notifier);

    final avgLiters = _calculateDailyAverageLiters(historyState.weeklyData);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(),
      body: historyState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Editorial Header
                    Text(
                      'History',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontSize: 36,
                            fontWeight: FontWeight.w200,
                            color: AppColors.onSurface,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Reflecting on your fluid rhythms.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        color: AppColors.onSurfaceVariant,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Analytics Bento Grid
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        final isTablet = width > 600;
                        if (isTablet) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Daily Average Card
                              Expanded(
                                flex: 1,
                                child: _buildAverageCard(context, avgLiters),
                              ),
                              const SizedBox(width: 16),
                              // Weekly Chart Card
                              Expanded(
                                flex: 2,
                                child: _buildChartCard(context, historyState.weeklyData),
                              ),
                            ],
                          );
                        } else {
                          return Column(
                            children: [
                              _buildAverageCard(context, avgLiters),
                              const SizedBox(height: 16),
                              _buildChartCard(context, historyState.weeklyData),
                            ],
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 40),

                    // Filter & Daily Logs Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Daily Logs',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontSize: 28,
                                fontWeight: FontWeight.w200,
                                color: AppColors.onSurface,
                              ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today_outlined, color: AppColors.primary, size: 20),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: historyState.selectedDate ?? DateTime.now(),
                              firstDate: DateTime.now().subtract(const Duration(days: 365)),
                              lastDate: DateTime.now(),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: AppColors.primary,
                                      onPrimary: AppColors.onPrimary,
                                      surface: AppColors.surfaceContainerLowest,
                                      onSurface: AppColors.onSurface,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              historyViewModel.loadDailyData(picked);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Selected Date Display Card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.outlineVariant.withValues(alpha: 0.1),
                          width: 0.5,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        title: Text(
                          'Showing: ${_formatDate(historyState.selectedDate)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.onSurface,
                            fontFamily: 'Inter',
                          ),
                        ),
                        trailing: Text(
                          '${historyState.getDailyTotal()} ml total',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Logs List
                    if (historyState.dailyLogs.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 48.0),
                          child: Column(
                            children: [
                              Icon(Icons.eco_outlined, color: AppColors.outlineVariant.withValues(alpha: 0.5), size: 40),
                              const SizedBox(height: 12),
                              Text(
                                'No logs for this date',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                                      fontStyle: FontStyle.italic,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: historyState.dailyLogs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return DailyLogTile(
                            log: historyState.dailyLogs[index],
                          );
                        },
                      ),
                    const SizedBox(height: 80), // spacer for bottom nav bar
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildAverageCard(BuildContext context, double liters) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x052C3437),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DAILY AVERAGE',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: AppColors.outline,
                ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                liters.toStringAsFixed(1),
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 52,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
              ),
              const SizedBox(width: 6),
              Text(
                'Liters',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w300,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Icon(Icons.trending_up, color: AppColors.primary, size: 16),
              const SizedBox(width: 8),
              Text(
                '+12% from last week',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(BuildContext context, Map<DateTime, int> weeklyData) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'WEEKLY RHYTHM',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      color: AppColors.outline,
                    ),
              ),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'INTAKE',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: AppColors.outline,
                          letterSpacing: 1.0,
                        ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          WeeklyBarChart(weeklyData: weeklyData),
        ],
      ),
    );
  }
}
