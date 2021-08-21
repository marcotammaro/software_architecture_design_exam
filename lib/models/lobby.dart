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

  Lobby.fromMap(Map<String, dynamic> data, {String id}) {
    this.key = id ?? generateRandomKey();
    this.name = data["name"] ?? "";
    this.description = data["description"] ?? "";
    this.topic = TopicsHelper.fromInt(data["topic"]);
    this.users = List<String>.from(data["users"]);
    this.lastMessage = Message(
      text: data["lastMessage"],
      dateTime: DateTime.fromMillisecondsSinceEpoch(
        data["lastMessageTimestamp"],
      ),
      username: data["lastMessageUsername"],
    );
  }
  Lobby.empty() {
    this.key = generateRandomKey();
    this.name = "";
    this.description = "";
    this.topic = null;
    this.users = [];
    this.lastMessage = null;
  }
}
