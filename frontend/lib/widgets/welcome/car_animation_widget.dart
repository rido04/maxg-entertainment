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

    // Setup floating animation (seperti CSS keyframes float)
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
          delay: Duration(milliseconds: 500), // Delay seperti di CSS animation
          child: AnimatedBuilder(
            animation: _floatAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _floatAnimation.value),
                child: Container(
                  // Shadow effect seperti drop-shadow di CSS
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: Offset(0, -4),
                        blurRadius: 8,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        offset: Offset(-4, 0),
                        blurRadius: 8,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        offset: Offset(4, 0),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Transform.translate(
                    offset: Offset(
                      -150,
                      -100,
                    ), // Positioning seperti margin negatif CSS
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
