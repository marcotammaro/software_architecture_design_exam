import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forat/bloc/events/messages_event.dart';
import 'package:forat/bloc/messages_bloc.dart';
import 'package:forat/firebase_wrappers/firestore_wrapper.dart';
import 'package:forat/models/message.dart';

class MessageLogic {
  // Class Attributes
  BuildContext _context;
  StreamSubscription<QuerySnapshot> _stream;
  String _lobbyName;
  FirestoreWrapper firestoreWrapper;

  // Constructor
  MessageLogic(this._context, this._lobbyName,
      [FirestoreWrapper _firestoreWrapper]) {
    this.firestoreWrapper = _firestoreWrapper ?? FirestoreWrapper.instance;
    startListenMessages();
  }

  // MARK: Utility Functions

  /// This function will start listening for messages snapshot on firebase
  void startListenMessages() async {
    var value = await firestoreWrapper.getMessagesStream(_lobbyName);
    if (value != null) _stream = value.listen(onMessageEvent);
  }

  /// Callback called when the messages snapshot updates
  void onMessageEvent(QuerySnapshot<Object> event) {
    // Removing all previous messages from the bloc
    BlocProvider.of<MessagesBloc>(_context).add(MessagesEvent.deleteAll());
    for (var doc in event.docs) {
      BlocProvider.of<MessagesBloc>(_context).add(
        MessagesEvent.add(Message.fromMap(doc.data(), id: doc.id)),
      );
    }
  }

  /// Function to stop listening from messages snapshot
  /// Should be called once the listening view is dismissed
  void stopListenMessages() {
    if (_stream != null) _stream.cancel();
  }

  // MARK: Navigator Logic

  bool didTapOnSendButton(String text) {
    if (text == "") return false;

    var dateTime = DateTime.now();
    firestoreWrapper.addMessage(
      dateTime: dateTime,
      lobbyName: _lobbyName,
      text: text,
    );
    return true;
  }
}
