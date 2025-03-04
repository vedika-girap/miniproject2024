import 'package:flutter/material.dart';
import 'package:phishing_detector/pages/community.dart';
import 'package:phishing_detector/pages/history.dart';
import 'package:phishing_detector/pages/hometest.dart';
import 'package:phishing_detector/pages/navbar.dart';
import 'package:phishing_detector/pages/settings.dart';

class NavigationService {
  // Function to return the page based on the index
  static Widget getPage(int index) {
    switch (index) {
      case 0:
        return PhishingPage();   // Phishing Detection Page
      case 1:
        return RecentUrlsPage(); // Recent URLs History Page
      case 2:
        return CommunityPage();  // Community Page
      case 3:
        return SettingsPage();   // Settings Page
      default:
        return PhishingPage();   // Default to PhishingPage
    }
  }
}
