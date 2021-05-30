import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:forat/bloc/lobbies_bloc.dart';
import 'package:forat/logic/lobby_logic.dart';
import 'package:forat/models/lobby.dart';
import 'package:shimmer/shimmer.dart';

class LobbiesView extends StatefulWidget {
  @override
  _LobbiesViewState createState() => _LobbiesViewState();
}

class _LobbiesViewState extends State<LobbiesView> {
  LobbyLogic _controller;
  bool _haveLobbies;

  @override
  void initState() {
    super.initState();
    _controller = LobbyLogic(context);

    Future.delayed(Duration.zero).then((value) async {
      _controller
          .userHaveLobbies()
          .then((value) => setState(() => _haveLobbies = value));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: BlocBuilder<LobbiesBloc, List<Lobby>>(
        builder: (context, lobbies) {
          return (_haveLobbies == null)
              ? shimmer()
              : !_haveLobbies
                  ? noLobby()
                  : ListView.builder(
                      itemCount: lobbies.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () =>
                              _controller.goToLobbyDetailedView(lobbies[index]),
                          child: lobbyCell(
                            lobbies[index].name,
                            lobbies[index].lastMessage != null
                                ? lobbies[index].lastMessage.text
                                : "",
                          ),
                        );
                      },
                    );
        },
      ),
    );
  }

  Widget noLobby() {
    return Center(
      child: Text(
          'No lobbies found.\n\nStart by adding a lobby\nor serching for one.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          )),
    );
  }

  Widget shimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300],
      highlightColor: Colors.grey[100],
      child: ListView.builder(
        itemCount: 10,
        itemBuilder: (_, __) {
          return lobbyCell("", "");
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

  Widget lobbyCell(String title, String lastMessage) {
    bool hasLastMessage = (lastMessage != null && lastMessage != "");
    return Container(
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
            title ?? "",
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: hasLastMessage ? 5 : 0),
          hasLastMessage
              ? Text(
                  lastMessage ?? "",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
