import 'package:flutter/material.dart';
import 'package:forat/models/firebase_wrappers/auth_wrapper.dart';
import 'package:forat/logic/lobby_logic.dart';
import 'package:forat/models/lobby.dart';
import 'package:forat/models/topics.dart';

class LobbyInfoView extends StatefulWidget {
  final Lobby lobby;
  const LobbyInfoView({Key key, @required this.lobby}) : super(key: key);

  @override
  _LobbyInfoViewState createState() => _LobbyInfoViewState();
}

class _LobbyInfoViewState extends State<LobbyInfoView> {
  bool hasJoined;

  @override
  void initState() {
    super.initState();

    hasJoined =
        widget.lobby.users.contains(AuthWrapper.instance.getCurrentUsername());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: appBar(),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(height: 20),
              infoCell(),
              SizedBox(height: 20),
              usersCell(),
              SizedBox(height: 20),
              hasJoined ? leaveButton() : SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      title: Text(widget.lobby.name),
      backgroundColor: Theme.of(context).backgroundColor,
      elevation: 1,
    );
  }

  Widget infoCell() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Text(
            "Info",
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).unselectedWidgetColor.withAlpha(100),
                blurRadius: 10,
              )
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Topic",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(width: 20),
                  Chip(
                    elevation: 0,
                    backgroundColor: widget.lobby.topic.color(),
                    label: Text(
                      widget.lobby.topic.name(),
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyText1.color,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                "Number of people: ${widget.lobby.users.length}",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 20),
              Text(
                "Description",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 10),
              Text(
                widget.lobby.description,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget usersCell() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Text(
            "Users",
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).unselectedWidgetColor.withAlpha(100),
                blurRadius: 10,
              )
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: widget.lobby.users.length,
            itemBuilder: (context, index) {
              return Container(
                height: 20,
                margin: EdgeInsets.symmetric(vertical: 2.5),
                child: Text(
                  widget.lobby.users[index],
                  style: TextStyle(fontSize: 14),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget leaveButton() {
    return MaterialButton(
      onPressed: onLeaveLobby,
      color: Theme.of(context).primaryColor,
      textColor: Theme.of(context).backgroundColor,
      child: Text("Leave Lobby"),
      padding: EdgeInsets.all(12),
      minWidth: 200,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    );
  }

  //MARK: User Actions

  void onLeaveLobby() {
    LobbyLogic(context)
        .didTapOnLeaveLobby(
      lobbyName: widget.lobby.name,
      username: AuthWrapper.instance.getCurrentUsername(),
    )
        .then((leaved) {
      if (leaved) {
        var count = 0;
        Navigator.popUntil(context, (route) {
          return count++ == 2;
        });
      }
    });
  }
}
