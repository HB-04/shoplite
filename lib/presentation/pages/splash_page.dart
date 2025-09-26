import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../providers/app_state_provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotateController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _loadingAnimation;

  @override
  void initState() {
    super.initState();
    
    // Scale animation controller
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Rotation animation controller
    _rotateController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );

    // Pulse animation controller
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Scale animation
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    // Rotation animation
    _rotateAnimation = Tween<double>(begin: 0.0, end: 2 * 3.14159).animate(
      CurvedAnimation(
        parent: _rotateController,
        curve: Curves.linear,
      ),
    );

    // Pulse animation
    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.2),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0),
        weight: 1,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Fade animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeIn),
      ),
    );

    // Loading animation
    _loadingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeInOut),
      ),
    );

    // Start animations
    _scaleController.forward();
    _rotateController.repeat();
    _pulseController.repeat(reverse: true);
    
    // Add a safety timeout to prevent getting stuck on splash
    Future.delayed(const Duration(seconds: 15), () {
      if (mounted) {
        final appState = Provider.of<AppStateProvider>(context, listen: false);
        if (!appState.isInitialized) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Loading is taking longer than expected...'),
              backgroundColor: Theme.of(context).colorScheme.error,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotateController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary,
              colorScheme.primaryContainer,
              colorScheme.secondary.withOpacity(0.8),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo animation with multiple effects
              AnimatedBuilder(
                animation: Listenable.merge([_scaleAnimation, _rotateAnimation, _pulseAnimation]),
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value * _pulseAnimation.value,
                    child: Transform.rotate(
                      angle: _rotateAnimation.value,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer glow
                            Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    colorScheme.primary.withOpacity(0.2),
                                    colorScheme.primary.withOpacity(0.1),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            // Inner circle with icon
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: colorScheme.primary.withOpacity(0.3),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.shopping_bag_outlined,
                                size: 100,
                                color: colorScheme.onPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              
              // App name animation
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  AppStrings.appName(context),
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              
              // Loading animation
              FadeTransition(
                opacity: _loadingAnimation,
                child: Column(
                  children: [
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(
                        color: colorScheme.onPrimary,
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Consumer<AppStateProvider>(
                      builder: (context, appState, child) {
                        String loadingText = AppStrings.loading(context);
                        
                        if (appState.connectionStatus == AppConnectionStatus.offline) {
                          loadingText = 'Loading offline data...';
                        }
                        
                        return Text(
                          loadingText,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onPrimary,
                            letterSpacing: 0.5,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Offline mode banner
              Consumer<AppStateProvider>(
                builder: (context, appState, child) {
                  if (appState.connectionStatus == AppConnectionStatus.offline) {
                    return FadeTransition(
                      opacity: _loadingAnimation,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        margin: const EdgeInsets.symmetric(horizontal: 32),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.withOpacity(0.5)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.wifi_off,
                              color: Colors.orange,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Offline Mode: Loading demo products',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.orange,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
