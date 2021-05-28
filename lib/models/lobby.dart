import 'package:forat/models/topics.dart';
import 'package:forat/utility/generate_random_keys.dart';
import 'package:forat/models/message.dart';

class Lobby {
  String name;
  String description;
  Topics topic;
  List<String> users;
  Message lastMessage;
  String key;

  Lobby({this.name, this.description, this.topic, this.users, this.lastMessage})
      : this.key = generateRandomKey();
  Lobby.withKey(
      {this.name,
      this.description,
      this.topic,
      this.users,
      this.key,
      this.lastMessage});
}
