import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:phishing_detector/backend_link_manager.dart';

class CommunityPage extends StatefulWidget {
  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final TextEditingController _messageController = TextEditingController();
  List<dynamic> _posts = [];
  bool _isLoading = false;

  // // Function to fetch community posts
  // Future<void> fetchPosts() async {
  //   setState(() {
  //     _isLoading = true;
  //   });

  //   try {
  //     final response = await http.get(
  //       Uri.parse(BackendLinkManager.communitypost),
  //     );

  //     if (response.statusCode == 200) {
  //       setState(() {
  //         _posts = json.decode(response.body);
  //       });
  //     } else {
  //       throw Exception('Failed to load posts');
  //     }
  //   } catch (error) {
  //     print('Error fetching posts: $error');
  //   } finally {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }

  // // Function to submit a new post
  // Future<void> submitPost(String message) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse(BackendLinkManager.communityEndpoint),
  //       headers: {'Content-Type': 'application/json'},
  //       body: json.encode({'message': message}),
  //     );

  //     if (response.statusCode == 201) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Post shared successfully')),
  //       );
  //       _messageController.clear();
  //       fetchPosts(); // Refresh posts
  //     } else {
  //       final responseBody = json.decode(response.body);
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //             content: Text(responseBody['message'] ?? 'Failed to share post')),
  //       );
  //     }
  //   } catch (error) {
  //     print('Error submitting post: $error');
  //   }
  // }
  Future<void> submitPost(String message) async {
    try {
      final response = await http.post(
        Uri.parse(BackendLinkManager.communityEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer <your_token>', // Replace with actual token if needed
        },
        body: json.encode({'message': message}),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Post shared successfully')),
        );
        _messageController.clear();
        fetchPosts();
      } else {
        final responseBody = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(responseBody['message'] ?? 'Failed to share post')),
        );
      }
    } catch (error) {
      print('Error submitting post: $error');
    }
  }

  Future<void> fetchPosts() async {
    try {
      final response = await http.get(
        Uri.parse(BackendLinkManager.communitypost),
        headers: {
          'Authorization':
              'Bearer <your_token>', // Replace with actual token if needed
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _posts = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (error) {
      print('Error fetching posts: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      backgroundColor: Color.fromARGB(255, 3, 43, 94),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: 'Share your thoughts...',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    final message = _messageController.text.trim();
                    if (message.isNotEmpty) {
                      submitPost(message);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Message cannot be empty')),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _posts.length,
                    itemBuilder: (context, index) {
                      final post = _posts[index];
                      return Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ListTile(
                          title: Text(post['username'] ?? 'Anonymous'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(post['message']),
                              SizedBox(height: 5),
                              Text(
                                post['timestamp'],
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
