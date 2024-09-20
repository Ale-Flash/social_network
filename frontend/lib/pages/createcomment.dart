import 'package:flutter/material.dart';

import '../main.dart';
import './global.dart';

class CreateCommentPage extends StatefulWidget {
  const CreateCommentPage({super.key});

  @override
  State<CreateCommentPage> createState() => _CreateCommentPageState();
}

class _CreateCommentPageState extends State<CreateCommentPage> {
  final TextEditingController _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Comment'),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  hintText: 'Enter your content',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Colors.white,
                      width: 2.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Colors.white,
                      width: 2.0,
                    ),
                  ),
                ),
              )),
          ElevatedButton(
            onPressed: () async {
              String content = _contentController.text;

              if (content.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.red,
                    content: Text('Please fill all fields'),
                  ),
                );
                return;
              }

              api.createComment(selectedPost, content).then((value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: value ? Colors.green : Colors.red,
                    content: Text(value
                        ? 'Comment created successfully'
                        : 'An error occurred'),
                  ),
                );
              });
            },
            child: const Text('comment'),
          )
        ],
      )),
    );
  }
}
