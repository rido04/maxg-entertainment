import 'package:flutter/material.dart';
import 'dart:async';

class TimeDisplayWidget extends StatefulWidget {
  @override
  _TimeDisplayWidgetState createState() => _TimeDisplayWidgetState();
}

class _TimeDisplayWidgetState extends State<TimeDisplayWidget> {
  late Timer _timer;
  String _currentTime = '';

  @override
  void initState() {
    super.initState();
    _updateTime();
    // Update setiap detik (seperti setInterval di JavaScript)
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateTime() {
    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute.toString().padLeft(2, '0');
    final amPm = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    setState(() {
      _currentTime = '$displayHour:$minute $amPm';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        // Glass effect seperti backdrop-blur di CSS
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Color(0x5F1F2687), // rgba(31,38,135,0.37)
            blurRadius: 32,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Hover effect dengan setState untuk scale
          setState(() {});
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // "NOW" label
            Text(
              'NOW',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF3b82f6), // blue-500
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),

            SizedBox(height: 4),

            // Current time display
            Text(
              _currentTime,
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF374151), // gray-700
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
