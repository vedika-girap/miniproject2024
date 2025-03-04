import 'package:flutter/material.dart';
import 'package:phishing_detector/backend_link_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _currentUsername = '';
  String _profilePicUrl = '';

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  // Fetch current user's profile
  Future<void> _fetchUserProfile() async {
    final response =
        await http.get(Uri.parse('${BackendLinkManager.baseUrl}/get_profile'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _currentUsername = data['username'];
        _profilePicUrl =
            data['profile_pic'] ?? ''; // If you store a profile pic
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch profile')),
      );
    }
  }

  // Update user profile
  Future<void> _updateProfile() async {
    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();

    final response = await http.post(
      Uri.parse('${BackendLinkManager.baseUrl}/update_profile'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
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
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Display current username
              // Text('Current Username: $_currentUsername'),
              SizedBox(height: 80),

              // Username text field for edit
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person, color: Colors.grey),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  fillColor: Colors.grey.shade200,
                  filled: true,
                  hintText: "Enter New Username",
                  hintStyle: TextStyle(color: Colors.grey[500]),
                ),
              ),
              SizedBox(height: 20),

              // Password text field for edit
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.key, color: Colors.grey),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  fillColor: Colors.grey.shade200,
                  filled: true,
                  hintText: "Enter New Password22",
                  hintStyle: TextStyle(color: Colors.grey[500]),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),

              // Save Button
              ElevatedButton(
                onPressed: _updateProfile,
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
