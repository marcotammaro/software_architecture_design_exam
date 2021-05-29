import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forat/bloc/messages_bloc.dart';
import 'package:forat/firebase_wrappers/auth_wrapper.dart';
import 'package:forat/logic/lobby_logic.dart';
import 'package:forat/logic/message_logic.dart';
import 'package:forat/models/lobby.dart';
import 'package:forat/models/message.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';

class LobbyDetailsView extends StatefulWidget {
  final Lobby lobby;

  const LobbyDetailsView({Key key, @required this.lobby}) : super(key: key);
  @override
  _LobbyDetailsViewState createState() => _LobbyDetailsViewState();
}

class _LobbyDetailsViewState extends State<LobbyDetailsView> {
  bool _isButtonEnabled = true;
  MessageLogic _messagesController;
  double _bottomBarHeight = 50;
  LobbyLogic _lobbiesController;
  ScrollController _scrollController;
  final _textFieldController = TextEditingController();
  final ButtonStyle style = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 20), primary: Colors.red);
  @override
  void initState() {
    super.initState();

    _messagesController = MessageLogic(context, widget.lobby.name);
    _lobbiesController = LobbyLogic(context);
    _scrollController = ScrollController();
    _lobbiesController
        .checkForUserJoined(lobby: widget.lobby)
        .then((value) => setState(() => _isButtonEnabled = !value));

    KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible) {
        moveListToEnd();
      },
    );
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      moveListToEnd();
    });
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.red),
      backgroundColor: Colors.green,
      body: BlocBuilder<MessagesBloc, List<Message>>(
          builder: (context, messages) {
        return Column(
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
        height: _bottomBarHeight,
        child: ElevatedButton(
          style: style,
          onPressed: () {
            _lobbiesController
                .didTapOnJoinLobbyButton(
                    lobbyName: "",
                    username: AuthWrapper.instance.getCurrentUsername())
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
        height: _bottomBarHeight,
        width: double.infinity,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: _bottomBarHeight - 2,
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
                    AuthWrapper.instance.getCurrentUsername()
                ? Alignment.topLeft
                : Alignment.topRight),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: (messages[index].username !=
                        AuthWrapper.instance.getCurrentUsername()
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
    print(_scrollController.position.maxScrollExtent);
    _scrollController.animateTo(
        _scrollController.position.maxScrollExtent +
            1000 +
            MediaQuery.of(context).viewInsets.bottom,
        duration: Duration(milliseconds: 200),
        curve: Curves.easeIn);
  }
}
