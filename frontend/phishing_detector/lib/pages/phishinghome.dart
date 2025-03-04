import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PhishingPage extends StatefulWidget {
  @override
  _PhishingPageState createState() => _PhishingPageState();
}

class _PhishingPageState extends State<PhishingPage> {
  final TextEditingController _controller = TextEditingController();
  String _result = '';

  // Function to send POST request to Flask backend
  Future<void> checkPhishing(String url) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.235.100:5000'), // Flask API URL
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'url': url}),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        setState(() {
          _result = result['result'] == 'phishing' || result['result'] == 'safe'
              ? result['result']
              : 'unknown'; // Handle unexpected response values
        });
      } else {
        setState(() {
          _result = 'Error: Unable to connect to backend';
        });
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      setState(() {
        _result = 'Error: Unable to process request';
      });
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Phishing Detector',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 26,
            letterSpacing: 1.5,
            color: const Color.fromARGB(255, 84, 22, 95).withOpacity(0.5),
          ),
        ),
        backgroundColor: const Color.fromRGBO(220, 192, 236, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                fillColor: Colors.grey.shade200,
                filled: true,
                hintText: "Enter URL",
                hintStyle: TextStyle(color: Colors.grey[500]),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String url = _controller.text.trim();
                if (url.isNotEmpty) {
                  checkPhishing(url);
                } else {
                  setState(() {
                    _result = 'Please enter a valid URL.';
                  });
                }
              },
              // child: Text('Check URL'),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check, color: Colors.white),
                  SizedBox(width: 18),
                  Text(
                    'Check URL',
                    style: TextStyle(
                        fontSize: 20,
                        color: const Color.fromARGB(255, 84, 22, 95)
                            .withOpacity(0.5),
                        height: 2.5),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            if (_result.isNotEmpty)
              AnimatedContainer(
                duration: Duration(milliseconds: 500),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: _result == 'phishing'
                      ? Colors.red.shade100
                      : _result == 'safe'
                          ? Colors.green.shade100
                          : Colors.grey.shade300,
                  border: Border.all(
                    color: _result == 'phishing'
                        ? Colors.red
                        : _result == 'safe'
                            ? Colors.green
                            : Colors.grey,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      _result == 'phishing'
                          ? Icons.warning
                          : _result == 'safe'
                              ? Icons.check_circle
                              : Icons.error_outline,
                      color: _result == 'phishing'
                          ? Colors.red
                          : _result == 'safe'
                              ? Colors.green
                              : Colors.grey,
                      size: 30,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _result == 'phishing'
                            ? 'Phishing Detected! Please avoid this URL.'
                            : _result == 'safe'
                                ? 'The URL is safe to use.'
                                : _result,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _result == 'phishing'
                              ? Colors.red
                              : _result == 'safe'
                                  ? Colors.green
                                  : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: const Color.fromRGBO(220, 192, 236, 1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
          child: GNav(
            haptic: true,
            tabBorderRadius: 15,
            curve: Curves.easeOutExpo,
            duration: Duration(milliseconds: 900),
            gap: 8,
            color: Colors.grey[300],
            activeColor: const Color.fromARGB(255, 252, 251, 253),
            iconSize: 28,
            tabBackgroundColor:
                const Color.fromARGB(255, 84, 22, 95).withOpacity(0.5),
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            tabs: const [
              GButton(icon: Icons.home),
              GButton(icon: Icons.library_add),
              GButton(icon: Icons.search),
              GButton(icon: Icons.person),
            ],
          ),
        ),
      ),
    );
  }
}
