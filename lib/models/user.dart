import 'lobby.dart';

class User {
  String username;
  String email;
  DateTime birthdate;
  List<Lobby> lobbies;

  User({this.username, this.email, this.birthdate, this.lobbies});
  User.empty() {
    this.username = "";
    this.email = "";
    this.birthdate = DateTime.now();
    this.lobbies = [];
  }
}
