import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
// import '../../routes/app_routes.dart';

class WelcomeContentWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 48, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInUp(
            duration: Duration(milliseconds: 2000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),

                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      Color(0xFF86efac), // green-300
                      Color(0xFF22c55e), // green-500
                    ],
                  ).createShader(bounds),
                  child: Text(
                    'MaxG',
                    style: TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                Text(
                  'Entertainment Hub',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),

                SizedBox(height: 32),

                Text(
                  'Your Everyday everything App',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFFf3f4f6),
                    height: 1.6,
                  ),
                ),

                SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
