import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

enum LobbyTopic { sport, university, cinema, art, food }

class Lobby {
  String name;
  String description;
  LobbyTopic topic;

  List<User> users;
  List<Message> messages;
}
