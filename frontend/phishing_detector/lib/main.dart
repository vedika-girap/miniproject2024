import 'package:flutter/material.dart';
import 'package:phishing_detector/pages/community.dart';
import 'package:phishing_detector/pages/history.dart';
import 'package:phishing_detector/pages/home.dart';
import 'package:phishing_detector/pages/hometest.dart';
import 'package:phishing_detector/pages/login.dart';
import 'package:phishing_detector/pages/register.dart';
import 'package:phishing_detector/pages/settings.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phishing Detection',
      initialRoute: '/register', // initial route '/register'
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => const Register(),
        '/history': (context) => RecentUrlsPage(),
        '/': (context) => PhishingPage(),
        '/settings': (context) => SettingsPage(),
        '/community_post': (context) => CommunityPage(),
        '/get_community_posts': (context) => CommunityPage(),
        '/home': (context) => const HomePage(),
      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => Scaffold(
          body: Center(child: Text('Page not found: ${settings.name}')),
        ),
      ),
      // home: Reg  ister(),
    );
  }
}
