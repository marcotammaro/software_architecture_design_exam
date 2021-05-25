import 'package:forat/utility/generate_random_keys.dart';

class Message {
  String text;
  String username;
  DateTime dateTime;
  String key;

  Message({this.text, this.username, this.dateTime})
      : this.key = generateRandomKey();
  Message.withKey({this.text, this.username, this.dateTime, this.key});
}
