import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forat/bloc/events/messages_event.dart';
import 'package:forat/bloc/messages_bloc.dart';
import 'package:forat/firebase_wrappers/firestore_wrapper.dart';
import 'package:forat/models/message.dart';
import 'package:forat/utility/date_time_firebase_helper.dart';

class MessageLogic {
  BuildContext _context;
  StreamSubscription<QuerySnapshot> _stream;
  String _lobbyName;

  // Constructor
  MessageLogic(this._context, this._lobbyName) {
    FirestoreWrapper.instance.getMessagesStream(_lobbyName).then(
      (value) {
        _stream = value.listen(onMessageEvent);
      },
    );
  }

  void onMessageEvent(QuerySnapshot<Object> event) {
    BlocProvider.of<MessagesBloc>(_context).add(MessagesEvent.deleteAll());
    for (var y in event.docs) {
      BlocProvider.of<MessagesBloc>(_context).add(
        MessagesEvent.add(
          Message(
            dateTime: DateTimeFirebaseHelper.fromFirestore(y.get('dateTime')),
            text: y.get('text'),
            username: y.get('creator'),
          ),
        ),
      );
    } //bloc
  }

  void stopListenMessages() {
    _stream.cancel();
  }

  void didTapOnSendButton(String text) {
    if (FirebaseAuth.instance.currentUser == null) return;
    var dateTime = DateTime.now();
    FirestoreWrapper.instance
        .addMessage(dateTime: dateTime, lobbyName: 'Lobby2', text: text);
  }

  /*

  FirestoreWrapper.instance.getMessages("Lobby2").then((value) {
      StreamSubscription<QuerySnapshot> stream = value.listen((event) {
        for (var y in event.docs) print(y.get('text'));
        //bloc
      });

      // Per cancellare la subscription:
      // stream.cancel();
    });

  */
}
