import 'package:flutter/material.dart';

import '../main.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Text _buildText(String text, [bool bold = false]) {
    return Text(
      text,
      style: TextStyle(
          fontSize: 18, fontWeight: bold ? FontWeight.bold : FontWeight.normal),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: user == null
          ? Center(
              child: ElevatedButton(
                  onPressed: () {
                    
                    api.getProfile().then((value) {
                      setState(() {
                        user = value;
                      });
                    });
                  },
                  child: const Text('load profile')),
            )
          : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _buildText('ID: '),
                _buildText(user!.id.toString(), true),
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _buildText('User: '),
                _buildText(user!.username, true),
              ]),
              Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: ElevatedButton(
                      onPressed: () {
                        storage.delete(key: 'jwt');
                        posts = [];
                        liked = {};
                        myposts = [];
                        ranking = {};
                        api.setted = false;
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MyApp()),
                        );
                      },
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              const Color(0xFF369BF4))),
                      child:
                          const Text('logout', style: TextStyle(fontSize: 17))))
            ]),
    );
  }
}
