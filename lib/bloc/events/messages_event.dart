import 'package:forat/models/message.dart';

enum MessagesEventType { add, delete, deleteAll }

class MessagesEvent {
  MessagesEventType type;
  Message message;

  MessagesEvent();

  MessagesEvent.add(Message _message) {
    this.type = MessagesEventType.add;
    this.message = _message;
  }

  MessagesEvent.delete(Message _message) {
    this.type = MessagesEventType.delete;
    this.message = _message;
  }
  MessagesEvent.deleteAll() {
    this.type = MessagesEventType.deleteAll;
  }
}
