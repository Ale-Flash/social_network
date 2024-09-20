import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../main.dart';
import '../model/post.dart';
import '../model/comment.dart';
import '../model/user.dart';

class Api {
  static const storage = FlutterSecureStorage();

  Map<String, String> headers = {};

  Api() {
    setHeader(null);
  }

  bool setted = false;
  Future<void> setHeader(String? token) async {
    if (setted) return;

    token ??= await storage.read(key: 'jwt');

    headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
    setted = true;
  }

  void saveToken(String token) {
    storage.write(key: 'jwt', value: token);
    setHeader(token);
  }

  Future<bool> signin(String username, String password) {
    return http
        .post(Uri.parse('$server/login'),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"username": username, "password": password}))
        .then((value) {
      if (value.statusCode != 200) return false;
      saveToken(jsonDecode(value.body)['token']);
      return true;
    });
  }

  Future<bool> signup(String username, String password) {
    return http
        .post(Uri.parse('$server/register'),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"username": username, "password": password}))
        .then((value) {
      if (value.statusCode != 200) return false;
      saveToken(jsonDecode(value.body)['token']);
      return true;
    });
  }

  Future<void> signout() {
    return storage.delete(key: 'jwt');
  }

  Future<bool> getStatus() {
    return http.get(Uri.parse('$server/status'), headers: headers).then(
        (value) => value.statusCode == 200).catchError((e) => false);
  }

  Future<List<Post>> getPosts(int user, int start, int end) async {
    await setHeader(null);

    return http
        .get(Uri.parse('$server/posts/$user/$start/$end'), headers: headers)
        .then((value) {
      if (value.statusCode != 200) return [];
      List<dynamic> data = jsonDecode(value.body);
      List<Post> posts =
          List.generate(data.length, (index) => Post.fromJson(data[index]));
      return posts;
    });
  }

  Future<List<Comment>> getComments(int post, int start, int end) async {
    await setHeader(null);

    return http
        .get(Uri.parse('$server/comments/$post/$start/$end'), headers: headers)
        .then((value) {
      if (value.statusCode != 200) return [];
      List<dynamic> data = jsonDecode(value.body);
      List<Comment> posts =
          List.generate(data.length, (index) => Comment.fromJson(data[index]));
      return posts;
    });
  }

  Future<int> getLikes(int post) async {
    await setHeader(null);

    return http
        .get(Uri.parse('$server/likes/$post'), headers: headers)
        .then((value) {
      if (value.statusCode != 200) return 0;
      return jsonDecode(value.body)['likes'];
    });
  }

  Future<bool> likePost(int post) async {
    await setHeader(null);

    return http
        .post(Uri.parse('$server/like'),
            headers: headers, body: jsonEncode({"post": post}))
        .then((value) {
      return value.statusCode == 200;
    });
  }

  Future<bool> removeLikePost(int post) async {
    await setHeader(null);

    return http
        .delete(Uri.parse('$server/like'),
            headers: headers, body: jsonEncode({"post": post}))
        .then((value) {
      return value.statusCode == 200;
    });
  }

  Future<bool> createPost(String title, String content) async {
    await setHeader(null);

    return http
        .post(Uri.parse('$server/post'),
            headers: headers,
            body: jsonEncode({"title": title, "content": content}))
        .then((value) {
      return value.statusCode == 200;
    });
  }

  Future<bool> createComment(int post, String content) async {
    await setHeader(null);

    return http
        .post(Uri.parse('$server/comment'),
            headers: headers,
            body: jsonEncode({"post": post, "content": content}))
        .then((value) {
      return value.statusCode == 200;
    });
  }

  Future<List> getLikesRanking() async {
    await setHeader(null);

    return http
        .get(Uri.parse('$server/ranking/likes/0/100'), headers: headers)
        .then((value) {
      if (value.statusCode != 200) return [];
      return jsonDecode(value.body);
    });
  }

  Future<List> getPostsRanking() async {
    await setHeader(null);

    return http
        .get(Uri.parse('$server/ranking/posts/0/100'), headers: headers)
        .then((value) {
      if (value.statusCode != 200) return [];
      return jsonDecode(value.body);
    });
  }

  Future<List> getCommentsRanking() async {
    await setHeader(null);

    return http
        .get(Uri.parse('$server/ranking/comments/0/100'), headers: headers)
        .then((value) {
      if (value.statusCode != 200) return [];
      return jsonDecode(value.body);
    });
  }

  Future<Map<String, List>> getRanking() async {
    await setHeader(null);

    return {
      'likes': await getLikesRanking(),
      'posts': await getPostsRanking(),
      'comments': await getCommentsRanking(),
    };
  }

  Future<bool> isLiked(int post) async {
    await setHeader(null);

    return http
        .get(Uri.parse('$server/isliked/$post'), headers: headers)
        .then((value) {
      return value.statusCode == 200;
    });
  }

  Future<bool> deletePost(int post) async {
    await setHeader(null);

    return http
        .delete(Uri.parse('$server/post'),
            body: jsonEncode({'post': post}), headers: headers)
        .then((value) {
      return value.statusCode == 200;
    });
  }

  Future<User> getProfile() async {
    await setHeader(null);

    return http
        .get(Uri.parse('$server/profile'), headers: headers)
        .then((value) => User.fromJson(jsonDecode(value.body)));
  }
}
