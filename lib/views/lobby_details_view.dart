import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forat/bloc/messages_bloc.dart';
import 'package:forat/logic/lobby_logic.dart';
import 'package:forat/logic/message_logic.dart';
import 'package:forat/models/message.dart';

class LobbyDetailsView extends StatefulWidget {
  @override
  _LobbyDetailsViewState createState() => _LobbyDetailsViewState();
}

class _LobbyDetailsViewState extends State<LobbyDetailsView> {
  bool _isButtonEnabled = true;
  MessageLogic _messagesController;

  LobbyLogic _lobbiesController;
  ScrollController _scrollController;
  final _textFieldController = TextEditingController();
  final ButtonStyle style = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 20), primary: Colors.red);
  @override
  void initState() {
    super.initState();

    _messagesController = MessageLogic(context, "Lobby2");
    _lobbiesController = LobbyLogic(context);
    _scrollController = ScrollController();
    _lobbiesController
        .checkForUserJoined(lobbyName: "")
        .then((value) => setState(() => _isButtonEnabled = !value));
    SchedulerBinding.instance.addPostFrameCallback((_) {
      moveListToEnd();
    });
  }

  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    // This also removes the _printLatestValue listener.
    _textFieldController.dispose();
    _messagesController.stopListenMessages();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.red),
      backgroundColor: Colors.green,
      body: BlocBuilder<MessagesBloc, List<Message>>(
          builder: (context, messages) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: listViewMessage(messages),
            ),
            bottomTab(context),
          ],
        );
      }),
    );
  }

  Visibility bottomTab(BuildContext context) {
    return Visibility(
      visible: (_isButtonEnabled == true) ? true : false,
      child: Container(
        height: 50,
        child: ElevatedButton(
          style: style,
          onPressed: () {
            _lobbiesController
                .didTapOnJoinLobbyButton(
                    lobbyName: "",
                    username: FirebaseAuth.instance.currentUser.displayName)
                .then(
                  (value) => setState(
                    () => _isButtonEnabled = !value,
                  ),
                ); //TODO
          },
          child: const Text('Enabled'),
        ),
      ),
      replacement: Container(
        height: 50,
        width: double.infinity,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: 50,
              width: MediaQuery.of(context).size.width * 0.75,
              color: Colors.white,
              child: TextField(
                controller: _textFieldController,
                enabled: true,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter a search term'),
              ),
            ),
            ElevatedButton(
              style: style,
              onPressed: () {
                _messagesController
                    .didTapOnSendButton(_textFieldController.text);
                _textFieldController.clear();
                moveListToEnd();
              },
              child: const Text('Invia'),
            ),
          ],
        ),
      ),
    );
  }

  ListView listViewMessage(List<Message> messages) {
    messages.sort((a, b) {
      return a.dateTime.compareTo(b.dateTime);
    });
    return ListView.builder(
      itemCount: messages.length,
      shrinkWrap: true,
      padding: EdgeInsets.only(top: 10, bottom: 10),
      physics: const AlwaysScrollableScrollPhysics(),
      controller: _scrollController,
      itemBuilder: (context, index) {
        return Container(
          padding: EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 10),
          child: Align(
            alignment: (messages[index].username !=
                    FirebaseAuth.instance.currentUser.displayName
                ? Alignment.topLeft
                : Alignment.topRight),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: (messages[index].username !=
                        FirebaseAuth.instance.currentUser.displayName
                    ? Colors.grey.shade200
                    : Colors.blue[200]),
              ),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(messages[index].username,
                      style: TextStyle(fontSize: 10),
                      textAlign: TextAlign.left),
                  Text(
                    messages[index].text,
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void moveListToEnd() {
    if (_scrollController.position.maxScrollExtent != null) {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 200), curve: Curves.bounceInOut);
    }
  }
}
