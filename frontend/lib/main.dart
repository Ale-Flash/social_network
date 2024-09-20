import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import './pages/homepage.dart';
import './pages/api.dart';
import './pages/login.dart';
import './pages/register.dart';
import './model/user.dart';
import './model/post.dart';

String server = 'http://204.216.223.6:3030';
const storage = FlutterSecureStorage();
Api api = Api();
User? user;
List<Post> posts = [];
Set<int> liked = {};
List<Post> myposts = [];
Map<String, List> ranking = {};

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final Future<String?> jwtToken = storage.read(key: 'jwt');
    return FutureBuilder<String?>(
      future: jwtToken,
      builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            backgroundColor: const Color(0xFF96F8FF),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(bottom: 32),
                    child: const Text(
                      'Social',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RegisterPage()),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              width: 2.0, color: Color(0xFF3B8DFF)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          'Sign up',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF3B8DFF),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          );
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            api.getStatus().then((value) {
              if (value) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.red,
                    content: Text('Cannot connect to server'),
                  ),
                );
              }
            });
          });
          return Container();
        }
      },
    );
  }
}
