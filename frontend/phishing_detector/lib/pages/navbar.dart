import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class BottomNav extends StatefulWidget {
  final int selectedPage;
  final Function(int) onPageChanged;

  const BottomNav(
      {super.key, required this.selectedPage, required this.onPageChanged});
  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 3, 42, 94),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
        child: GNav(
          haptic: true,
          tabBorderRadius: 15,
          curve: Curves.easeOutExpo,
          duration: const Duration(milliseconds: 900),
          gap: 8,
          color: Colors.grey[300],
          activeColor: Colors.white,
          iconSize: 28,
          tabBackgroundColor:
              const Color.fromARGB(255, 13, 101, 156).withOpacity(1),
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          tabs: const [
          
            GButton(
              icon: Icons.home,
            ),
            GButton(
              icon: Icons.history,
            ),
            GButton(
              icon: Icons.group,
            ),
            GButton(
              icon: Icons.settings,
            ),
          ],
        ),
      ),
    );
  }
}
