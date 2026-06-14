import 'package:flutter/material.dart';
import '../../../../domain/entities/hydration_log.dart';
import '../../../../core/theme/app_colors.dart';

class LogUiMetadata {
  final String title;
  final String category;
  final IconData icon;
  final Color color;
  final Color containerColor;

  LogUiMetadata({
    required this.title,
    required this.category,
    required this.icon,
    required this.color,
    required this.containerColor,
  });
}

LogUiMetadata _getMetadata(HydrationLog log) {
  if (log.volumeMl == 250) {
    return LogUiMetadata(
      title: 'Pure Spring Water',
      category: 'Hydration Boost',
      icon: Icons.water_drop_outlined,
      color: AppColors.primary,
      containerColor: AppColors.primaryContainer.withValues(alpha: 0.4),
    );
  } else if (log.volumeMl == 500) {
    return LogUiMetadata(
      title: 'Electrolyte Infusion',
      category: 'Recovery',
      icon: Icons.opacity_outlined,
      color: AppColors.secondary,
      containerColor: AppColors.secondaryContainer.withValues(alpha: 0.4),
    );
  } else if (log.volumeMl == 350) {
    return LogUiMetadata(
      title: 'Morning Herbal Tea',
      category: 'Steeped Calm',
      icon: Icons.coffee_outlined,
      color: AppColors.tertiary,
      containerColor: AppColors.tertiaryContainer.withValues(alpha: 0.4),
    );
  }
  
  // Dynamic by hour
  final hour = log.timestamp.hour;
  if (hour >= 5 && hour < 11) {
    return LogUiMetadata(
      title: 'Morning Sanctuary',
      category: 'Clean Start',
      icon: Icons.sunny,
      color: AppColors.primary,
      containerColor: AppColors.primaryContainer.withValues(alpha: 0.4),
    );
  } else if (hour >= 11 && hour < 17) {
    return LogUiMetadata(
      title: 'Pure Mineral Water',
      category: 'Afternoon Flow',
      icon: Icons.water_drop_outlined,
      color: AppColors.tertiary,
      containerColor: AppColors.tertiaryContainer.withValues(alpha: 0.4),
    );
  } else if (hour >= 17 && hour < 22) {
    return LogUiMetadata(
      title: 'Evening Calm Sip',
      category: 'Sanctuary Ripple',
      icon: Icons.local_drink_outlined,
      color: AppColors.secondary,
      containerColor: AppColors.secondaryContainer.withValues(alpha: 0.4),
    );
  } else {
    return LogUiMetadata(
      title: 'Restful Hydration',
      category: 'Night Recharge',
      icon: Icons.bedtime_outlined,
      color: AppColors.tertiary,
      containerColor: AppColors.tertiaryContainer.withValues(alpha: 0.4),
    );
  }
}

class DailyLogTile extends StatelessWidget {
  const DailyLogTile({
    required this.log,
    super.key,
  });

  final HydrationLog log;

  String _formatDateSubtitle(DateTime time) {
    final now = DateTime.now();
    final localTime = time.toLocal();
    final formattedTime = '${localTime.hour > 12 ? localTime.hour - 12 : (localTime.hour == 0 ? 12 : localTime.hour)}:${localTime.minute.toString().padLeft(2, '0')} ${localTime.hour >= 12 ? 'PM' : 'AM'}';
    
    if (localTime.year == now.year && localTime.month == now.month && localTime.day == now.day) {
      return 'Today, $formattedTime';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (localTime.year == yesterday.year && localTime.month == yesterday.month && localTime.day == yesterday.day) {
      return 'Yesterday, $formattedTime';
    }
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[localTime.month - 1]} ${localTime.day}, $formattedTime';
  }

  @override
  Widget build(BuildContext context) {
    final meta = _getMetadata(log);

    return Container(
      padding: const EdgeInsets.all(20),
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
        border: Border.all(
          color: AppColors.primaryContainer.withValues(alpha: 0.0),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: meta.containerColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  meta.icon,
                  color: meta.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meta.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: AppColors.onSurface,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDateSubtitle(log.timestamp),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                          color: AppColors.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    log.volumeMl.toString(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontFamily: 'Manrope',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                  ),
                  const SizedBox(width: 1),
                  const Text(
                    'ml',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 11,
                      fontWeight: FontWeight.w300,
                      color: AppColors.outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                meta.category.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 8,
                      fontWeight: FontWeight.w400,
                      color: AppColors.outlineVariant,
                      letterSpacing: 1.0,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
