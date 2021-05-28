import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forat/bloc/events/messages_event.dart';
import 'package:forat/bloc/messages_bloc.dart';
import 'package:forat/firebase_wrappers/auth_wrapper.dart';
import 'package:forat/models/message.dart';

class MessageLogic {
  BuildContext _context;

  // Constructor
  MessageLogic(this._context);

  void didTapOnSendButton(String text) {
    if (FirebaseAuth.instance.currentUser == null) return;
    BlocProvider.of<MessagesBloc>(_context).add(
      MessagesEvent.add(
        Message(
          username: AuthWrapper.instance.getCurrentUsername(),
          dateTime: DateTime.now(),
          text: text,
        ),
      ),
    );
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
