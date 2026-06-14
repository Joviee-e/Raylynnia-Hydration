import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({
    this.userName,
    super.key,
  });

  final String? userName;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          height: preferredSize.height + topPadding,
          padding: EdgeInsets.only(top: topPadding, left: 20, right: 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            border: Border(
              bottom: BorderSide(
                color: AppColors.outlineVariant.withOpacity(0.1),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: User Profile Avatar + Greeting
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.black.withOpacity(0.05),
                        width: 1,
                      ),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuAcYOJVs4my7_4gjPI3m7USsVBNMJ3vyPLuq9C_KjuQyjgXOuvqucmt3aF6azj_3meNMn55UUed6iBbM_pLZtIbTP-ZwIWQ4Jp5S0ttgJwdCxXDltemcKReiheFW8yxVemRH7srWGrknR26raG3HfchpmXv4dgIi0SLgUFmm73pDgKuZjkFswTfEIiW3bxR_3xbfOQVOAlR4YIkm_9n16_T6LUivn2nnirt8-fOzMrnwTy3xx6NnLQm19aHnzZ8A9Q8hPvkdqxqXysU',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (userName != null) ...[
                    const SizedBox(width: 12),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WELCOME BACK',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontSize: 8,
                            color: AppColors.outline,
                            letterSpacing: 1.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          userName!,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),

              // Center: App Logo
              Text(
                'RAYLYNNIA',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3.0,
                  fontSize: 16,
                  color: AppColors.onSurface,
                ),
              ),

              // Right: Notifications Button
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.onSurface,
                  size: 24,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Quiet sanctuary - notifications are working silently.',
                        style: TextStyle(fontFamily: 'Inter'),
                      ),
                      backgroundColor: AppColors.primaryDim,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);
}
