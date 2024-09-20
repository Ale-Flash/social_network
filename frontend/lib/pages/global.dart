// ignore_for_file: empty_catches

import 'package:flutter/material.dart';

import '../main.dart';
import './comments.dart';
import './createpost.dart';
import '../model/post.dart';

class GlobalPage extends StatefulWidget {
  const GlobalPage({super.key});

  @override
  State<GlobalPage> createState() => _GlobalPageState();
}

int selectedPost = 0;

class _GlobalPageState extends State<GlobalPage> {
  bool isLoading = true;
  bool requested = false;

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

  Future<void> request() {
    return api.getPosts(0, 0, 20).then((value) {
      posts = value;
      for (Post post in posts) {
        api.isLiked(post.postId).then((v) {
          if (v) {
            try {
              setState(() {
                liked.add(post.postId);
              });
            } catch (e) {}
          }
        });
      }
      try {
        setState(() {
          isLoading = false;
        });
      } catch (e) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    if (posts.isNotEmpty) {
      requested = true;
      isLoading = false;
    }

    if (!requested) {
      request();
      requested = true;
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text('Posts'),
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
                onRefresh: request,
                child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        Post p = posts[index];
                        return GestureDetector(
                            onTap: () {
                              selectedPost = p.postId;
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const CommentsPage()));
                            },
                            child: Container(
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          _buildText(p.user),
                                          ElevatedButton(
                                              onPressed: () {
                                                if (liked.contains(p.postId)) {
                                                  liked.remove(p.postId);
                                                  api
                                                      .removeLikePost(p.postId)
                                                      .then((value) {
                                                    try {
                                                      setState(() {});
                                                    } catch (e) {}
                                                  });
                                                } else {
                                                  liked.add(p.postId);
                                                  api
                                                      .likePost(p.postId)
                                                      .then((value) {
                                                    try {
                                                      setState(() {});
                                                    } catch (e) {}
                                                  });
                                                }
                                                setState(() {});
                                              },
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.white,
                                                  elevation: 0,
                                                  shadowColor:
                                                      Colors.transparent,
                                                  padding: EdgeInsets.zero,
                                                  shape: const CircleBorder()),
                                              child: Icon(
                                                  liked.contains(p.postId)
                                                      ? Icons.favorite
                                                      : Icons.favorite_border,
                                                  color:
                                                      liked.contains(p.postId)
                                                          ? Colors.red
                                                          : Colors.grey))
                                        ]),
                                    _buildText(p.title, true),
                                    _buildText(p.content),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        _buildText('Likes: ${p.likes}'),
                                        _buildText('Comments: ${p.comments}'),
                                        _buildText(p.timestamp.toString()),
                                      ],
                                    )
                                  ]),
                            ));
                      },
                    ))),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CreatePostPage()));
          },
          child: const Icon(Icons.add),
        ));
  }
}
