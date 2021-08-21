import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:forat/bloc/lobbies_bloc.dart';
import 'package:forat/logic/lobby_logic.dart';
import 'package:forat/logic/notification_logic.dart';
import 'package:forat/models/lobby.dart';
import 'package:forat/models/topics.dart';
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
    userHaveLobbies();

    /// Start listen for notifications of lobbies messages
    NotificationLogic.instance.start();
    NotificationLogic.instance.resetIsInitializing();
  }

  @override
  void dispose() {
    _controller.stopListenLobbies();
    super.dispose();
  }

  void userHaveLobbies() {
    _controller
        .userHaveLobbies()
        .then((value) => setState(() => _haveLobbies = value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: Container(
        color: Theme.of(context).backgroundColor,
        child: BlocBuilder<LobbiesBloc, List<Lobby>>(
          builder: (context, lobbies) {
            userHaveLobbies();
            return (_haveLobbies == null)
                ? shimmer()
                : !_haveLobbies
                    ? noLobby()
                    : ListView.builder(
                        itemCount: lobbies.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => LobbyLogic.goToLobbyDetailedView(
                              context,
                              lobbies[index],
                            ),
                            child: Container(
                              margin: EdgeInsets.only(top: index == 0 ? 20 : 0),
                              child: lobbyCell(lobbies[index]),
                            ),
                          );
                        },
                      );
          },
        ),
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
          return lobbyCell(Lobby.empty());
        },
      ),
    );
  }

  Widget appBar() => AppBar(
        automaticallyImplyLeading: false, //hide back button
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(FontAwesomeIcons.plus,
                color: Theme.of(context).primaryColor),
            onPressed: () => _controller.goToLobbyCreationView(),
          ),
        ],
        title: Text(
          'Lobbies',
          style: TextStyle(color: Theme.of(context).textTheme.bodyText1.color),
        ),
      );

  Widget lobbyCell(Lobby lobby) {
    bool hasLastMessage = lobby.lastMessage != null;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Theme.of(context).unselectedWidgetColor.withAlpha(100),
              blurRadius: 10)
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lobby.name ?? "",
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: hasLastMessage ? 10 : 0),
          hasLastMessage
              ? Text(
                  "${lobby.lastMessage.username ?? ""}: ${lobby.lastMessage.text ?? ""}",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14),
                )
              : const SizedBox.shrink(),
          SizedBox(height: hasLastMessage ? 5 : 0),
          hasLastMessage
              ? Text(
                  "${lobby.lastMessage.dateTime.hour ?? ""} : ${lobby.lastMessage.dateTime.minute ?? ""}",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10),
                )
              : const SizedBox.shrink(),
          Align(
            alignment: Alignment.bottomRight,
            child: Chip(
              elevation: 0,
              backgroundColor: lobby.topic.color(),
              label: Text(
                lobby.topic.name(),
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyText1.color,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
