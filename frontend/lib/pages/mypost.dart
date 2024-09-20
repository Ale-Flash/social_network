// ignore_for_file: empty_catches

import 'package:flutter/material.dart';

import '../main.dart';
import './comments.dart';
import '../model/post.dart';
import './global.dart';

class MyPostsPage extends StatefulWidget {
  const MyPostsPage({super.key});

  @override
  State<MyPostsPage> createState() => _MyPostsPageState();
}

class _MyPostsPageState extends State<MyPostsPage> {
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

  @override
  Widget build(BuildContext context) {
    if (myposts.isNotEmpty) {
      requested = true;
      isLoading = false;
    }

    if (!requested) {
      requested = true;
      api.getPosts(user!.id, 0, 20).then((value) {
        myposts = value;
        try {
          setState(() {
            isLoading = false;
          });
        } catch (e) {}
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Posts'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () {
                return api.getPosts(user!.id, 0, 20).then((value) {
                  myposts = value;
                  try {
                    setState(() {
                      isLoading = false;
                    });
                  } catch (e) {}
                });
              },
              child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: myposts.isEmpty
                      ? const Center(
                          child: Text('There is no post, try creating one :)'))
                      : ListView.builder(
                          itemCount: myposts.length,
                          itemBuilder: (context, index) {
                            Post p = myposts[index];
                            return GestureDetector(
                                onTap: () {
                                  selectedPost = p.postId;
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const CommentsPage()));
                                },
                                onLongPress: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text('Delete Post'),
                                          content: const Text(
                                              'Are you sure you want to delete this post?'),
                                          actions: [
                                            TextButton(
                                                onPressed: () {
                                                  api
                                                      .deletePost(p.postId)
                                                      .then((value) {
                                                    if (value) {
                                                      try {
                                                        setState(() {
                                                          myposts
                                                              .removeAt(index);
                                                        });
                                                      } catch (e) {}
                                                    }
                                                  });
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Yes')),
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('No')),
                                          ],
                                        );
                                      });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 15),
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 5),
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
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              _buildText(p.user),
                                              ElevatedButton(
                                                  onPressed: () {
                                                    if (liked
                                                        .contains(p.postId)) {
                                                      liked.remove(p.postId);
                                                      api
                                                          .removeLikePost(
                                                              p.postId)
                                                          .then((value) {
                                                        try {
                                                          setState(() {});
                                                        } catch (e) {}
                                                      });
                                                    } else {
                                                      liked.add(p.postId);
                                                      api
                                                          .likePost(p.postId)
                                                          .then((value) =>
                                                              setState);
                                                    }
                                                    setState(() {});
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          Colors.white,
                                                      elevation: 0,
                                                      shadowColor:
                                                          Colors.transparent,
                                                      padding: EdgeInsets.zero,
                                                      shape:
                                                          const CircleBorder()),
                                                  child: Icon(
                                                      liked.contains(p.postId)
                                                          ? Icons.favorite
                                                          : Icons
                                                              .favorite_border,
                                                      color: liked.contains(
                                                              p.postId)
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
                                            _buildText(
                                                'Comments: ${p.comments}'),
                                            _buildText(p.timestamp.toString()),
                                          ],
                                        )
                                      ]),
                                ));
                          },
                        ))),
    );
  }
}
