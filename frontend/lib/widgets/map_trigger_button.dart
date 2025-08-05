import 'package:flutter/material.dart';

class MapTriggerButton extends StatefulWidget {
  final VoidCallback onTap;

  const MapTriggerButton({Key? key, required this.onTap}) : super(key: key);

  @override
  _MapTriggerButtonState createState() => _MapTriggerButtonState();
}

class _MapTriggerButtonState extends State<MapTriggerButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _pingController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation for the green dot
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // Ping animation for the rings
    _pingController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _pingController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _pingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: GestureDetector(
        onTap: () {
          // Scale animation on tap
          setState(() {
            // Add haptic feedback if available
            // HapticFeedback.lightImpact();
          });
          widget.onTap();
        },
        child: Container(
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Background image (tarikan.png equivalent) dengan efek transparan
              // CARA 1: Pakai Opacity widget (paling mudah)
              Opacity(
                opacity: 0.7, // 0.0 = transparan penuh, 1.0 = tidak transparan
                child: SizedBox(
                  width: 180,
                  child: Image.asset(
                    'assets/images/logo/tarikan.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback jika gambar tidak ditemukan
                      return Container(
                        width: 180,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.grey.withOpacity(0.3),
                              Colors.grey.withOpacity(0.6),
                              Colors.grey.withOpacity(0.3),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Content overlay
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // "Live" text
                    Text(
                      'Live',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        shadows: [
                          Shadow(
                            color: Colors.white.withOpacity(0.8),
                            offset: Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 8),

                    // Animated live indicator
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Ping rings
                        AnimatedBuilder(
                          animation: _pingController,
                          builder: (context, child) {
                            return Opacity(
                              opacity: 1.0 - _pingController.value,
                              child: Transform.scale(
                                scale: _scaleAnimation.value,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Color(0xFF00B14F),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        // Second ping ring with delay
                        AnimatedBuilder(
                          animation: _pingController,
                          builder: (context, child) {
                            double delayedValue = (_pingController.value - 0.3)
                                .clamp(0.0, 1.0);
                            return Opacity(
                              opacity: delayedValue > 0
                                  ? 1.0 - delayedValue
                                  : 0.0,
                              child: Transform.scale(
                                scale: 1.0 + delayedValue * 1.5,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Color(0xFF00B14F).withOpacity(0.6),
                                      width: 1,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        // Main pulsing dot
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Color(0xFF00B14F),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF00B14F).withOpacity(0.4),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.location_on,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    SizedBox(width: 8),

                    // "Navigation" text
                    Text(
                      'Navigation',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        shadows: [
                          Shadow(
                            color: Colors.white.withOpacity(0.8),
                            offset: Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
