import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1e293b).withOpacity(0.25),
            Color(0xFF1e40af).withOpacity(0.15),
            Color(0xFF1f2937).withOpacity(0.25),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background Image (sama seperti welcome screen)
          Positioned.fill(
            child: Image.asset(
              'assets/images/background/Background_Color.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: Color(0xFF1e293b));
              },
            ),
          ),

          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.home, size: 100, color: Colors.white),
                SizedBox(height: 20),
                Text(
                  'Home Screen',
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Welcome to MaxG Entertainment Hub',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
