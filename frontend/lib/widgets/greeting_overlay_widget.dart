// lib/widgets/greeting_overlay_widget.dart

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class GreetingOverlayWidget extends StatefulWidget {
  final String message;
  final String gender;
  final VoidCallback? onComplete;

  const GreetingOverlayWidget({
    Key? key,
    required this.message,
    required this.gender,
    this.onComplete,
  }) : super(key: key);

  @override
  State<GreetingOverlayWidget> createState() => _GreetingOverlayWidgetState();
}

class _GreetingOverlayWidgetState extends State<GreetingOverlayWidget> {
  @override
  void initState() {
    super.initState();

    // Auto dismiss after 2.5 seconds (lebih cepat)
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 40,
      right: 40,
      child: FadeInUp(
        from: 20,
        duration: const Duration(milliseconds: 400),
        child: FadeOut(
          delay: const Duration(milliseconds: 2000),
          duration: const Duration(milliseconds: 500),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.85),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF00B14F).withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00B14F).withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/logo/Maxg-ent_white.gif',
                    width: 40,
                    height: 40,
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(width: 12),

                // Divider
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withOpacity(0.2),
                ),

                const SizedBox(width: 12),

                // Text content
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getTitle(widget.gender),
                      style: const TextStyle(
                        color: Color(0xFF00B14F),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getGreeting(widget.message),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getTitle(String gender) {
    switch (gender) {
      case 'male':
        return 'PASSENGER DETECTED';
      case 'female':
        return 'PASSENGER DETECTED';
      default:
        return 'WELCOME';
    }
  }

  String _getGreeting(String message) {
    // Ambil baris pertama aja kalau ada \n
    if (message.contains('\n')) {
      return message.split('\n')[0];
    }
    return message;
  }
}

// Helper function to show greeting overlay
class GreetingOverlay {
  static OverlayEntry? _currentOverlay;

  static void show(
    BuildContext context, {
    required String message,
    required String gender,
  }) {
    // Remove existing overlay if any
    hide();

    _currentOverlay = OverlayEntry(
      builder: (context) => Stack(
        children: [
          GreetingOverlayWidget(
            message: message,
            gender: gender,
            onComplete: () => hide(),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_currentOverlay!);
  }

  static void hide() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }
}
