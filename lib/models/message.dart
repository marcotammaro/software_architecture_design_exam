import 'package:forat/utility/generate_random_keys.dart';

class Message {
  String text;
  String username;
  DateTime dateTime;
  String key;

  Message({this.text, this.username, this.dateTime})
      : this.key = generateRandomKey();

  Message.fromMap(Map<String, dynamic> data, {String id}) {
    this.key = id ?? generateRandomKey();
    this.text = data["text"] ?? "";
    this.username = data["creator"] ?? "";
    this.dateTime = DateTime.fromMillisecondsSinceEpoch(data["dateTime"] ?? 0);
  }

  // Message.empty() {
  //   this.key = generateRandomKey();
  //   this.text = "";
  //   this.username = "";
  //   this.dateTime = DateTime.fromMillisecondsSinceEpoch(0);
  // }
}
