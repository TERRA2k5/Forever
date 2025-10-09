import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({super.key, required this.onTap, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      index: currentIndex,
      backgroundColor: Colors.transparent,
      color: Colors.black87,
      animationCurve: Curves.fastOutSlowIn,
      items: const [
        Icon(Icons.home, size: 30, color: Colors.white),
        Icon(Icons.person, size: 30, color: Colors.white),
      ],
      onTap: onTap,
    );
  }
}
