import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forat/app_launcher.dart';
import 'package:forat/bloc/lobbies_bloc.dart';
import 'package:forat/bloc/messages_bloc.dart';
import 'package:forat/views/lobby_details_view.dart';

void main() {
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
