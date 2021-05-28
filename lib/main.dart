import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forat/app_launcher.dart';
import 'package:forat/bloc/events/messages_event.dart';
import 'package:forat/bloc/lobbies_bloc.dart';
import 'package:forat/bloc/messages_bloc.dart';
import 'package:forat/firebase_wrappers/firestore_wrapper.dart';
import 'package:forat/logic/message_logic.dart';
import 'package:forat/models/message.dart';
import 'package:forat/utility/date_time_firebase_helper.dart';
import 'package:forat/views/lobby_details_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiBlocProvider(
      child: MyApp(),
      providers: [
        BlocProvider<LobbiesBloc>(
          create: (BuildContext context) => LobbiesBloc(),
        ),
        BlocProvider<MessagesBloc>(
          create: (BuildContext context) => MessagesBloc(),
        ),
      ],
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
      home: LobbyDetailsView(),
    );
  }
}
