import 'package:intl/intl.dart';

String formatTime(String time) {
  final DateTime t = DateTime.parse(time);
  return DateFormat('dd/MM/yyyy').format(t);
}

class Comment {
  int postId;
  String user, content, timestamp;

  Comment({
    required this.user,
    required this.postId,
    required this.content,
    required this.timestamp,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      user: json['username'],
      postId: json['post_id'],
      content: json['content'],
      timestamp: formatTime(json['time_stamp']),
    );
  }
}
