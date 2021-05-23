import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:forat/utility/generate_random_keys.dart';

enum LobbyTopic { sport, university, cinema, art, food }

class Lobby {
  String name;
  String description;
  LobbyTopic topic;
  List<User> users;
  List<Message> messages;
  String key;

  Lobby({this.name, this.description, this.topic, this.users, this.messages})
      : this.key = generateRandomKey();
  Lobby.withKey(
      {this.name,
      this.description,
      this.topic,
      this.users,
      this.messages,
      this.key});
}
