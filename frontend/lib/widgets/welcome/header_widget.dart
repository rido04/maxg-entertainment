import 'package:flutter/material.dart';

class HeaderWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo MaxG (bagian kiri)
          Container(
            width: 240,
            height: 80,
            child: Image.asset(
              'assets/images/logo/Maxg-ent_white.gif',
              fit: BoxFit.contain,
            ),
          ),

          // Logo MCM x Grab (bagian kanan)
          Container(
            width: 240,
            height: 80,
            child: Image.asset(
              'assets/images/logo/mcm x grab_.png',
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
