import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forat/bloc/events/messages_event.dart';
import 'package:forat/bloc/messages_bloc.dart';
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
          username: FirebaseAuth.instance.currentUser.displayName,
          dateTime: DateTime.now(),
          text: text,
        ),
      ),
    );
  }
}
