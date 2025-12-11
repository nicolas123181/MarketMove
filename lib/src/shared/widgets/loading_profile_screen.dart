import 'package:flutter/material.dart';
import 'dart:math' as math;

/// An interactive and visually appealing loading screen
/// with animated elements to make waiting more pleasant
class LoadingProfileScreen extends StatefulWidget {
  final String? message;
  final String? userName;

  const LoadingProfileScreen({super.key, this.message, this.userName});

  @override
  State<LoadingProfileScreen> createState() => _LoadingProfileScreenState();
}

class _LoadingProfileScreenState extends State<LoadingProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;

  final List<String> _loadingMessages = [
    'Cargando perfil...',
    'Preparando tu espacio de trabajo...',
    'Sincronizando datos...',
    'Casi listo...',
  ];

  int _currentMessageIndex = 0;

  @override
  void initState() {
    super.initState();

    // Pulse animation for the logo
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Rotation animation for the decorative elements
    _rotateController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    // Progress animation
    _progressController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    // Cycle through loading messages
    Future.delayed(const Duration(milliseconds: 800), _cycleMessages);
  }

  void _cycleMessages() {
    if (mounted) {
      setState(() {
        _currentMessageIndex =
            (_currentMessageIndex + 1) % _loadingMessages.length;
      });
      Future.delayed(const Duration(milliseconds: 1200), _cycleMessages);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Decorative rotating circles
              _buildDecorativeElements(),

              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated logo
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            widget.userName?.isNotEmpty == true
                                ? widget.userName![0].toUpperCase()
                                : 'M',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF667eea),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Welcome message
                    if (widget.userName != null) ...[
                      Text(
                        '¡Hola, ${widget.userName}!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    // Animated loading message
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.3),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        widget.message ??
                            _loadingMessages[_currentMessageIndex],
                        key: ValueKey<int>(_currentMessageIndex),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Animated progress indicator
                    _buildProgressIndicator(),

                    const SizedBox(height: 24),

                    // Animated dots
                    _buildAnimatedDots(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDecorativeElements() {
    return AnimatedBuilder(
      animation: _rotateController,
      builder: (context, child) {
        return Stack(
          children: [
            // Large rotating circle
            Positioned(
              top: -100,
              right: -100,
              child: Transform.rotate(
                angle: _rotateController.value * 2 * math.pi,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
            // Medium rotating circle
            Positioned(
              bottom: -50,
              left: -50,
              child: Transform.rotate(
                angle: -_rotateController.value * 2 * math.pi,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
            // Small floating elements
            ..._buildFloatingElements(),
          ],
        );
      },
    );
  }

  List<Widget> _buildFloatingElements() {
    return List.generate(5, (index) {
      final offset = index * 0.2;
      return Positioned(
        top: 100 + (index * 80).toDouble(),
        left: 30 + (index * 50).toDouble(),
        child: AnimatedBuilder(
          animation: _rotateController,
          builder: (context, child) {
            final value = (_rotateController.value + offset) % 1.0;
            return Transform.translate(
              offset: Offset(
                math.sin(value * math.pi * 2) * 10,
                math.cos(value * math.pi * 2) * 10,
              ),
              child: Container(
                width: 8 + (index * 2).toDouble(),
                height: 8 + (index * 2).toDouble(),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildProgressIndicator() {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Container(
          width: 200,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 200 * _progressAnimation.value,
              height: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.white.withValues(alpha: 0.7)],
                ),
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final delay = index * 0.2;
            final value = ((_pulseController.value + delay) % 1.0 * 2 - 1)
                .abs();
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5 + value * 0.5),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}
