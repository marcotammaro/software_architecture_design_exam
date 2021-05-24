import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forat/bloc/events/messages_event.dart';
import 'package:forat/bloc/messages_bloc.dart';
import 'package:forat/models/message.dart';
import 'package:forat/models/user.dart';

class MessageLogic {
  BuildContext _context;

  // Constructor
  MessageLogic(this._context);

  void didTapOnSendButton(String text) {
    print(text);
    BlocProvider.of<MessagesBloc>(_context).add(
      MessagesEvent.add(
        Message(
          creator: User.empty(),
          dateTime: DateTime.now(),
          text: text,
        ),
      ),
    );
  }
}
