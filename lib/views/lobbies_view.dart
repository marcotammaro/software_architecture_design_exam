import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:forat/bloc/lobbies_bloc.dart';
import 'package:forat/logic/lobby_logic.dart';
import 'package:forat/models/lobby.dart';
import 'package:forat/views/lobby_creation_view.dart';

class LobbiesView extends StatefulWidget {
  @override
  _LobbiesViewState createState() => _LobbiesViewState();
}

class _LobbiesViewState extends State<LobbiesView> {
  LobbyLogic _controller;

  @override
  void initState() {
    super.initState();
    _controller = LobbyLogic(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: BlocBuilder<LobbiesBloc, List<Lobby>>(
        builder: (context, state) {
          print(state.length);
          return ListView.builder(
            itemCount: state.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _controller.goToLobbyDetailedView(),
                child: lobbyCell(),
              );
            },
          );
        },
      ),
    );
  }

  Widget appBar() => AppBar(
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              FontAwesomeIcons.plus,
              color: Colors.black,
            ),
            onPressed: () => _controller.goToLobbyCreationView(),
          ),
        ],
        title: Text(
          'Lobbies',
          style: TextStyle(color: Colors.black),
        ),
      );

  Widget lobbyCell() => Container(
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.grey.withAlpha(100), blurRadius: 10)
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Title",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Text(
              "Last message",
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      );
}
