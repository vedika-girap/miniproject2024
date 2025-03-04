import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:phishing_detector/backend_link_manager.dart';

class RecentUrlsPage extends StatefulWidget {
  @override
  _RecentUrlsPageState createState() => _RecentUrlsPageState();
}

class _RecentUrlsPageState extends State<RecentUrlsPage> {
  List<Map<String, dynamic>> recentUrls = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchRecentUrls();
  }

  Future<void> fetchRecentUrls() async {
    var apiUrl = Uri.parse(
        '${BackendLinkManager.baseUrl}/history'); // Replace with your backend URL
    try {
      final response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        setState(() {
          recentUrls =
              List<Map<String, dynamic>>.from(json.decode(response.body));
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load recent URLs. Please try again later.';
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = 'Error fetching URLs: $error';
        isLoading = false;
      });
      print('Error fetching URLs: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 33, 137, 174),
              Color.fromARGB(255, 3, 43, 94)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
                ? Center(
                    child: Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  )
                : recentUrls.isEmpty
                    ? const Center(
                        child: Text(
                          'No URLs found',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        itemCount: recentUrls.length,
                        itemBuilder: (context, index) {
                          final urlData = recentUrls[index];
                          return Card(
                            color: Colors.white.withOpacity(0.1),
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: ListTile(
                              title: Text(
                                urlData['url'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'Timestamp: ${urlData['timestamp']}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
