// ignore_for_file: empty_catches

import 'package:flutter/material.dart';

import '../main.dart';
import '../model/comment.dart';
import './global.dart';
import './createcomment.dart';

class CommentsPage extends StatefulWidget {
  const CommentsPage({super.key});

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  bool isLoading = true;
  bool requested = false;
  late List<Comment> comments;

  int amountToShow = 20;
  int start = 0;
  int end = 20;

  Text _buildText(String text, [bool bold = false]) {
    return Text(
      text,
      style: TextStyle(
          fontSize: 18, fontWeight: bold ? FontWeight.bold : FontWeight.normal),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!requested) {
      requested = true;
      api.getComments(selectedPost, 0, 20).then((value) {
        comments = value;
        try {
          setState(() {
            isLoading = false;
          });
        } catch (e) {}
      });
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text('Comments'),
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
                onRefresh: () {
                  return api.getComments(selectedPost, 0, 20).then((value) {
                    comments = value;
                    try {
                      setState(() {
                        isLoading = false;
                      });
                    } catch (e) {}
                  });
                },
                child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: comments.isEmpty
                        ? const Center(child: Text('No comments °_°'))
                        : ListView.builder(
                            itemCount: comments.length,
                            itemBuilder: (context, index) {
                              Comment c = comments[index];
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                        blurRadius: 20,
                                        color: Colors.black.withOpacity(.1))
                                  ],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildText(c.user),
                                      _buildText(c.content),
                                      _buildText(c.timestamp.toString()),
                                    ]),
                              );
                            },
                          ))),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CreateCommentPage()));
          },
          child: const Icon(Icons.add),
        ));
  }
}
