import 'package:forat/models/user.dart';
import 'package:forat/utility/generate_random_keys.dart';

class Message {
  String text;
  User creator;
  DateTime dateTime;
  String key;

  Message({this.text, this.creator, this.dateTime})
      : this.key = generateRandomKey();
  Message.withKey({this.text, this.creator, this.dateTime, this.key});
}
