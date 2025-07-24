import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../widgets/welcome/header_widget.dart';
import '../widgets/welcome/welcome_content_widget.dart';
import '../widgets/welcome/car_animation_widget.dart';
import '../widgets/welcome/time_display_widget.dart';
import '../routes/app_routes.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Background dengan gradient (seperti CSS gradient di Laravel)
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1e293b).withOpacity(0.25), // slate-900/25
              Color(0xFF1e40af).withOpacity(0.15), // blue-900/15
              Color(0xFF1f2937).withOpacity(0.25), // slate-800/25
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background Image (seperti airplane background di Laravel)
            Positioned.fill(
              child: Image.asset(
                'assets/images/background/Background_Color.png',
                fit: BoxFit.cover,
              ),
            ),

            // Main Content Layout
            Column(
              children: [
                // Header Section (Logo MaxG + Grab/MCM logo)
                HeaderWidget(),

                // Main Content (Welcome text + Car animation)
                Expanded(
                  child: Row(
                    children: [
                      // Left Section - Welcome Text
                      Expanded(flex: 1, child: WelcomeContentWidget()),

                      // Right Section - Car Animation
                      Expanded(flex: 1, child: CarAnimationWidget()),
                    ],
                  ),
                ),
              ],
            ),

            // Time Display (fixed position seperti di Laravel)
            Positioned(bottom: 24, right: 24, child: TimeDisplayWidget()),
          ],
        ),
      ),
    );
  }
}
