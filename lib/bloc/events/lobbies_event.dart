import 'package:forat/models/lobby.dart';

enum LobbiesEventType { add, delete, deleteAll }

class LobbiesEvent {
  LobbiesEventType type;
  Lobby lobby;

  LobbiesEvent();

  LobbiesEvent.add(Lobby _lobby) {
    this.type = LobbiesEventType.add;
    this.lobby = _lobby;
  }

  LobbiesEvent.delete(Lobby _lobby) {
    this.type = LobbiesEventType.delete;
    this.lobby = _lobby;
  }

  LobbiesEvent.deleteAll() {
    this.type = LobbiesEventType.deleteAll;
  }
}
