import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  // Constructor
  MessageLogic(this._context, this._lobbyName) {
    startListenMessages();
  }

  // MARK: Utility Functions

  /// This function will start listening for messages snapshot on firebase
  void startListenMessages() {
    FirestoreWrapper.instance.getMessagesStream(_lobbyName).then((value) {
      _stream = value.listen(onMessageEvent);
    });
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
    _stream.cancel();
  }

  // MARK: Navigator Logic

  void didTapOnSendButton(String text) {
    if (FirebaseAuth.instance.currentUser == null || text == "") return;

    var dateTime = DateTime.now();
    FirestoreWrapper.instance.addMessage(
      dateTime: dateTime,
      lobbyName: _lobbyName,
      text: text,
    );
  }
}
