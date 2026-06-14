import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/water_wave_progress.dart';
import '../viewmodels/home_viewmodel.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _formatMl(int amount) {
    // Format with commas, e.g. 1,600
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return amount.toString().replaceAllMapped(reg, (Match match) => '${match[1]},');
  }

  void _showCustomLogDialog(BuildContext context, HomeViewModel viewModel) {
    int customVolume = 250;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surfaceContainerLowest,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text(
                'Log Custom Volume',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$customVolume ml',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.primary,
                      thumbColor: AppColors.primary,
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: customVolume.toDouble(),
                      min: 50,
                      max: 1000,
                      divisions: 19,
                      onChanged: (val) {
                        setDialogState(() {
                          customVolume = val.toInt();
                        });
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCEL', style: TextStyle(color: AppColors.outline)),
                ),
                ElevatedButton(
                  onPressed: () {
                    viewModel.logDrink(customVolume);
                    Navigator.pop(context);
                    
                    // Show SnackBar Toast
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '+${customVolume}ml added',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            fontFamily: 'Inter',
                          ),
                        ),
                        backgroundColor: AppColors.onSurface.withValues(alpha: 0.9),
                        behavior: SnackBarBehavior.floating,
                        margin: const EdgeInsets.only(bottom: 100, left: 80, right: 80),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: const Text('LOG'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _handleQuickLog(BuildContext context, HomeViewModel viewModel, int amount) {
    viewModel.logDrink(amount);
    
    // Clear existing SnackBars and show toast
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '+${amount}ml added',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            fontFamily: 'Inter',
          ),
        ),
        backgroundColor: AppColors.onSurface.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 100, left: 80, right: 80),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeViewModelProvider);
    final homeViewModel = ref.read(homeViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: homeState.isLoading || homeState.userProfile == null
          ? null
          : AppHeader(userName: homeState.userProfile?.name),
      body: homeState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : homeState.userProfile == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('No profile found. Please set up your profile.'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to onboarding
                        },
                        child: const Text('Get Started'),
                      ),
                    ],
                  ),
                )
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Fluid Hydration Centerpiece
                        const SizedBox(height: 16),
                        Center(
                          child: WaterWaveProgress(
                            percentage: homeState.getProgressPercentage(),
                            goalMl: homeState.userProfile!.dailyGoalMl,
                            totalIntakeMl: homeState.getTotalIntakeMl(),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Asymmetrical Morning Greeting
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text.rich(
                              const TextSpan(
                                children: [
                                  TextSpan(text: 'Your rhythm is\n'),
                                  TextSpan(
                                    text: 'steady and clear',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  TextSpan(text: '.'),
                                ],
                              ),
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w200,
                                    height: 1.25,
                                    color: AppColors.onSurface,
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Goal Metrics Grid (No lines segment)
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.outlineVariant.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  color: AppColors.surfaceContainerLowest,
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'CURRENT',
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 2.0,
                                              color: AppColors.outline,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: [
                                          Text(
                                            _formatMl(homeState.getTotalIntakeMl()),
                                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                                  fontWeight: FontWeight.w300,
                                                  fontSize: 32,
                                                  color: AppColors.onSurface,
                                                ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'ml',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w300,
                                              color: AppColors.outline.withValues(alpha: 0.4),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 80,
                                color: AppColors.outlineVariant.withValues(alpha: 0.1),
                              ),
                              Expanded(
                                child: Container(
                                  color: AppColors.surfaceContainerLowest,
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'TARGET',
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 2.0,
                                              color: AppColors.outline,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: [
                                          Text(
                                            _formatMl(homeState.userProfile!.dailyGoalMl),
                                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                                  fontWeight: FontWeight.w300,
                                                  fontSize: 32,
                                                  color: AppColors.onSurface,
                                                ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'ml',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w300,
                                              color: AppColors.outline.withValues(alpha: 0.4),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Quick Add Buttons Segment
                        Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _QuickAddButton(
                                    icon: Icons.water_drop_outlined,
                                    label: 'Add 250ml',
                                    useGradient: true,
                                    onPressed: () => _handleQuickLog(context, homeViewModel, 250),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _QuickAddButton(
                                    icon: Icons.opacity_outlined,
                                    label: 'Add 500ml',
                                    useGradient: false,
                                    onPressed: () => _handleQuickLog(context, homeViewModel, 500),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Preserved custom logger link
                            TextButton.icon(
                              onPressed: () => _showCustomLogDialog(context, homeViewModel),
                              icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
                              label: const Text(
                                'LOG CUSTOM AMOUNT',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Footer Reminder Section
                        _buildFooterReminder(homeState),
                        const SizedBox(height: 80), // spacer for bottom nav bar
                      ],
                    ),
                  ),
                ),
      bottomNavigationBar: homeState.isLoading || homeState.userProfile == null
          ? null
          : const AppBottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildFooterReminder(HomeState state) {
    final nextReminder = state.getNextReminderTime();
    int minRemaining = 0;
    if (nextReminder != null) {
      minRemaining = nextReminder.difference(DateTime.now()).inMinutes;
      if (minRemaining < 0) minRemaining = 0;
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(9999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.schedule, color: AppColors.primary, size: 16),
              const SizedBox(width: 8),
              Text(
                nextReminder != null
                    ? 'Next sip in $minRemaining min'
                    : 'Rhythm complete for today',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.0),
          child: Text(
            'Maintain your sanctuary by sipping mindfully throughout the day.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w300,
              color: AppColors.outlineVariant,
              height: 1.4,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickAddButton extends StatefulWidget {
  const _QuickAddButton({
    required this.icon,
    required this.label,
    required this.useGradient,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool useGradient;
  final VoidCallback onPressed;

  @override
  State<_QuickAddButton> createState() => _QuickAddButtonState();
}

class _QuickAddButtonState extends State<_QuickAddButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 0.95).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOut),
        ),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: widget.useGradient
                ? const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDim],
                  )
                : null,
            color: widget.useGradient ? null : AppColors.secondaryContainer,
            boxShadow: [
              if (widget.useGradient)
                const BoxShadow(
                  color: Color(0x1F2C3437),
                  blurRadius: 16,
                  offset: Offset(0, 4),
                )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                color: widget.useGradient ? AppColors.onPrimary : AppColors.onSecondaryContainer,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                widget.label.toUpperCase(),
                style: TextStyle(
                  color: widget.useGradient ? AppColors.onPrimary : AppColors.onSecondaryContainer,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  fontSize: 12,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
