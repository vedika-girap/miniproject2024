import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:phishing_detector/backend_link_manager.dart';

class PhishingPage extends StatefulWidget {
  @override
  _PhishingPageState createState() => _PhishingPageState();
}

class _PhishingPageState extends State<PhishingPage> {
  final TextEditingController _controller = TextEditingController();
  String _result = '';

  // Function to send POST request to Flask backend
  Future<void> checkPhishing(String url) async {
    setState(() {
      _result = 'Checking...';
    });
    try {
      final response = await http.post(
        Uri.parse(BackendLinkManager.baseUrl),
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
      }
    } catch (e) {
      setState(() {
        _result = 'Error: Unable to process request';
      });
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.link, color: Colors.grey),
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
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  backgroundColor: const Color.fromARGB(255, 3, 43, 94),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 5,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Check URL',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              if (_result.isNotEmpty)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: _result == 'phishing'
                        ? Colors.red.shade100
                        : _result == 'safe'
                            ? Colors.green.shade100
                            : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _result == 'phishing'
                            ? '🚨'
                            : _result == 'safe'
                                ? '✅'
                                : 'ℹ️',
                        style: TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _result == 'phishing'
                              ? 'Phishing Detected! 🚨 Avoid this URL.'
                              : _result == 'safe'
                                  ? 'This URL is Safe ✅'
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
      ),
    );
  }
}
