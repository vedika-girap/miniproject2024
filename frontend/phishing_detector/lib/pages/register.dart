import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:phishing_detector/backend_link_manager.dart';
import 'package:phishing_detector/components/my_button.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> registerUser(BuildContext context) async {
    final String username = nameController.text.trim();
    final String password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(BackendLinkManager.registerEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        final responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'])),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: <Widget>[
            const SizedBox(height: 100),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10),
              child: const Text(
                'Register',
                style: TextStyle(
                  color: Color.fromARGB(255, 3, 43, 94),
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Welcome text
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Welcome,  Register to start detecting urls :)',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(height: 25),

            Container(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'User Name',
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: TextField(
                obscureText: true,
                controller: passwordController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                ),
              ),
            ),
            const SizedBox(height: 25),
            MyButton(
              onTap: () => registerUser(context),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text('Already have an account?'),
                TextButton(
                  child: const Text(
                    'Login',
                    style: TextStyle(
                        fontSize: 20, color: Color.fromARGB(255, 3, 43, 94)),
                  ),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';


// class Register extends StatefulWidget {
//   const Register({super.key});

//   @override
//   State<Register> createState() => _RegisterState();
// }

// class _RegisterState extends State<Register> {
//   TextEditingController nameController = TextEditingController();
//   TextEditingController passwordController = TextEditingController();


//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//         padding: const EdgeInsets.all(10),
//         child: ListView(
//           children: <Widget>[
//             Container(
//                 alignment: Alignment.center,
//                 padding: const EdgeInsets.all(10),
//                 child: const Text(
//                   'TutorialKart',
//                   style: TextStyle(
//                       color: Colors.blue,
//                       fontWeight: FontWeight.w500,
//                       fontSize: 30),
//                 )),
//             Container(
//                 alignment: Alignment.center,
//                 padding: const EdgeInsets.all(10),
//                 child: const Text(
//                   'Sign in',
//                   style: TextStyle(fontSize: 20),
//                 )),
//             Container(
//               padding: const EdgeInsets.all(10),
//               child: TextField(
//                 controller: nameController,
//                 decoration: const InputDecoration(
//                   border: OutlineInputBorder(),
//                   labelText: 'User Name',
//                 ),
//               ),
//             ),
//             Container(
//               padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
//               child: TextField(
//                 obscureText: true,
//                 controller: passwordController,
//                 decoration: const InputDecoration(
//                   border: OutlineInputBorder(),
//                   labelText: 'Password',
//                 ),
//               ),
//             ),
//             TextButton(
//               onPressed: () {
//                 //forgot password screen
//               },
//               child: const Text('Forgot Password',),
//             ),
//             Container(
//                 height: 50,
//                 padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
//                 child: ElevatedButton(
//                   child: const Text('Login'),
//                   onPressed: () {
//                     print(nameController.text);
//                     print(passwordController.text);
//                   },
//                 )
//             ),
//             Row(
//               children: <Widget>[
//                 const Text('Does not have account?'),
//                 TextButton(
//                   child: const Text(
//                     'Sign in',
//                     style: TextStyle(fontSize: 20),
//                   ),
//                   onPressed: () {
//                     //signup screen
//                   },
//                 )
//               ],
//               mainAxisAlignment: MainAxisAlignment.center,
//             ),
//           ],
//         ));
//   }
// }
