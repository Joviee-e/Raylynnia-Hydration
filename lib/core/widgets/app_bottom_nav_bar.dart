import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../routing/route_names.dart';
import '../theme/app_colors.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    required this.currentIndex,
    super.key,
  });

  final int currentIndex;

  void _onTabTapped(BuildContext context, int index) {
    if (index == currentIndex) return;
    
    String route = RouteNames.home;
    switch (index) {
      case 0:
        route = RouteNames.home;
        break;
      case 1:
        route = RouteNames.scheduleSettings;
        break;
      case 2:
        route = RouteNames.history;
        break;
      case 3:
        route = RouteNames.profile;
        break;
    }
    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          height: 64 + bottomPadding + 8,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.75),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A2C3437),
                blurRadius: 32,
                offset: Offset(0, -12),
              ),
            ],
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.15),
              width: 0.5,
            ),
          ),
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 8,
            bottom: bottomPadding > 0 ? bottomPadding : 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavBarItem(
                icon: Icons.water_drop,
                label: 'Dashboard',
                isActive: currentIndex == 0,
                onTap: () => _onTabTapped(context, 0),
              ),
              _NavBarItem(
                icon: Icons.access_time,
                label: 'Schedule',
                isActive: currentIndex == 1,
                onTap: () => _onTabTapped(context, 1),
              ),
              _NavBarItem(
                icon: Icons.analytics,
                label: 'History',
                isActive: currentIndex == 2,
                onTap: () => _onTabTapped(context, 2),
              ),
              _NavBarItem(
                icon: Icons.settings,
                label: 'Settings',
                isActive: currentIndex == 3,
                onTap: () => _onTabTapped(context, 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatefulWidget {
  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  State<_NavBarItem> createState() => _NavBarItemState();
}

class _NavBarItemState extends State<_NavBarItem> with SingleTickerProviderStateMixin {
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
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 0.95).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOut),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isActive
                ? AppColors.primaryContainer.withValues(alpha: 0.5)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(9999),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                color: widget.isActive ? AppColors.primaryDim : AppColors.outlineVariant,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                widget.label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 9,
                  fontWeight: widget.isActive ? FontWeight.bold : FontWeight.w500,
                  color: widget.isActive ? AppColors.primaryDim : AppColors.outlineVariant,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
