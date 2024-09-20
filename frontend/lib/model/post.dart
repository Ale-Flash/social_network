import 'package:intl/intl.dart';

String formatTime(String time) {
  final DateTime t = DateTime.parse(time);
  return DateFormat('dd/MM/yyyy').format(t);
}

class Post {
  final int postId, likes, comments;
  final String user, title, content, timestamp;

  Post({
    required this.postId,
    required this.user,
    required this.title,
    required this.content,
    required this.timestamp,
    required this.likes,
    required this.comments,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      postId: json['id'],
      user: json['username'],
      title: json['title'],
      content: json['content'],
      likes: json['likes'],
      comments: json['comments'],
      timestamp: formatTime(json['time_stamp']),
    );
  }
}
