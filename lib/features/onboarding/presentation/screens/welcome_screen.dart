import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Welcome screen - first step of onboarding.
/// Introduces the app and its core value proposition.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    required this.onProceed,
    super.key,
  });

  final VoidCallback onProceed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Flow container has background blooms
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Hero Illustration Area
              Expanded(
                flex: 4,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final height = constraints.maxHeight;
                    return Container(
                      width: double.infinity,
                      height: height,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        image: const DecorationImage(
                          image: NetworkImage(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuBWHV_8dyBnG4RXvaeO4bS1mYJ2tVKvVpPMdcI-xNGZTUaW-PIqQslKjlotIUJ-PSFiwbQVaKu1xlhQwqDwbzlY8KIq-Y3A7NNWw_9MET51U5jeL1CQZPbk9t14lYXAx4u20k10VNUHu7kY1_DDi6LW0ZvhWvwmB5bvR_T14zkbG9Pyum-MZsw1oqC-tCM2ur6xYOUBznGNzKHVqEPhtIlIcvz9fXVVk5zAV4ztFex-ddAzKuMBwhQql7xtueQVjzQ6Sqad2mZGTvF0',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(40),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primaryContainer.withOpacity(0.4),
                                  AppColors.tertiaryContainer.withOpacity(0.3),
                                ],
                              ),
                            ),
                          ),
                          Center(
                            child: ClipOval(
                              child: BackdropFilter(
                                filter: const ColorFilter.mode(Colors.transparent, BlendMode.srcOver),
                                child: Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.15),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.water_drop_outlined,
                                    color: Colors.white,
                                    size: 48,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              
              // Identity Cluster
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    Text(
                      'Raylynnia',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 48,
                            fontWeight: FontWeight.w200,
                            letterSpacing: 6.0,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'FIND YOUR FLOW.',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4.0,
                            color: AppColors.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    // Tonal Divider
                    Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Action Area
              Column(
                children: [
                  GestureDetector(
                    onTap: onProceed,
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDim],
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1F2C3437),
                            blurRadius: 32,
                            offset: Offset(0, 12),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Get Started',
                            style: TextStyle(
                              color: AppColors.onPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                              fontFamily: 'Inter',
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward,
                            color: AppColors.onPrimary,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: onProceed,
                    child: Text(
                      'EXISTING MEMBER LOGIN',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                            color: AppColors.onSurfaceVariant.withOpacity(0.7),
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
