import 'package:flutter/material.dart';
import 'package:phishing_detector/pages/community.dart';
import 'package:phishing_detector/pages/history.dart';
import 'package:phishing_detector/pages/hometest.dart';
import 'package:phishing_detector/pages/navbar.dart';
import 'package:phishing_detector/pages/navigation.dart';
import 'package:phishing_detector/pages/settings.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedPage = 0;

  final List<Widget> _pages = [
    PhishingPage(),
    RecentUrlsPage(),
    CommunityPage(),
    SettingsPage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Phishing Detector',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 26,
            letterSpacing: 1.5,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 38, 145, 184),
      ),
      body: _pages[0],
      bottomNavigationBar: BottomNav(
        selectedPage: _selectedPage,
        onPageChanged: (index) {
          setState(() {
            _selectedPage = index;
          });
        },
      ),
    );
  }
}
