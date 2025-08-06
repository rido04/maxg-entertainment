import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class CarAnimationWidget extends StatefulWidget {
  @override
  _CarAnimationWidgetState createState() => _CarAnimationWidgetState();
}

class _CarAnimationWidgetState extends State<CarAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );

    _floatAnimation = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Start floating animation
    _floatController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(32),
      child: Center(
        child: FadeInRight(
          duration: Duration(milliseconds: 2000),
          delay: Duration(milliseconds: 500),
          child: AnimatedBuilder(
            animation: _floatAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _floatAnimation.value),
                child: Transform.translate(
                  offset: Offset(-50, -50),
                  child: Stack(
                    children: [
                      Transform.translate(
                        offset: Offset(4, 6), // Shadow offset
                        child: ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.3),
                            BlendMode.srcATop,
                          ),
                          child: Image.asset(
                            'assets/images/background/Grabcar_MasAdam.gif',
                            width: MediaQuery.of(context).size.width * 0.4,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(4, 6),
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                          child: ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.2),
                              BlendMode.srcATop,
                            ),
                            child: Image.asset(
                              'assets/images/background/Grabcar_MasAdam.gif',
                              width: MediaQuery.of(context).size.width * 0.4,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      // Main image
                      Image.asset(
                        'assets/images/background/Grabcar_MasAdam.gif',
                        width: MediaQuery.of(context).size.width * 0.4,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// Alternative approach using custom painter for more precise control
class CarAnimationWidgetCustom extends StatefulWidget {
  @override
  _CarAnimationWidgetCustomState createState() =>
      _CarAnimationWidgetCustomState();
}

class _CarAnimationWidgetCustomState extends State<CarAnimationWidgetCustom>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );

    _floatAnimation = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _floatController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(32),
      child: Center(
        child: FadeInRight(
          duration: Duration(milliseconds: 2000),
          delay: Duration(milliseconds: 500),
          child: AnimatedBuilder(
            animation: _floatAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _floatAnimation.value),
                child: Transform.translate(
                  offset: Offset(-150, -100),
                  // Menggunakan Container dengan BoxShadow yang disempurnakan
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: Offset(3, 5),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          offset: Offset(1, 2),
                          blurRadius: 4,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/background/Grabcar_MasAdam.gif',
                      width: MediaQuery.of(context).size.width * 0.4,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
