import 'package:flutter/material.dart';
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
  MessageLogic _messagesController;
  LobbyLogic _lobbiesController;
  bool _isButtonEnabled = true;
  int _keyboardListnerID;
  double _bottomBarHeight = 50;
  final _scrollController = ScrollController();
  final _keyboardVisibility = KeyboardVisibilityNotification();
  final _textFieldController = TextEditingController();
  final ButtonStyle style = ElevatedButton.styleFrom(
    textStyle: const TextStyle(fontSize: 20),
    primary: Colors.red,
  );

  @override
  void initState() {
    super.initState();

    _messagesController = MessageLogic(context, widget.lobby.name);
    _lobbiesController = LobbyLogic(context);
    _lobbiesController
        .checkForUserJoined(lobby: widget.lobby)
        .then((value) => setState(() => _isButtonEnabled = !value));

    _keyboardListnerID = _keyboardVisibility.addNewListener(
      onChange: (bool visible) {
        moveListToEnd();
      },
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    _textFieldController.dispose();
    _messagesController.stopListenMessages();
    _keyboardVisibility.removeListener(_keyboardListnerID);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.red),
      body: BlocBuilder<MessagesBloc, List<Message>>(
        builder: (context, messages) {
          return SafeArea(
            child: Column(
              children: <Widget>[
                Expanded(child: listViewMessage(messages)),
                bottomTab(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Visibility bottomTab(BuildContext context) {
    return Visibility(
      visible: (_isButtonEnabled) ? true : false,
      child: Container(
        height: _bottomBarHeight,
        child: ElevatedButton(
          style: style,
          onPressed: () {
            _lobbiesController
                .didTapOnJoinLobbyButton(
                    lobbyName: widget.lobby.name,
                    username: AuthWrapper.instance.getCurrentUsername())
                .then(
                  (value) => setState(() => _isButtonEnabled = !value),
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
              height: _bottomBarHeight,
              width: MediaQuery.of(context).size.width * 0.75,
              color: Colors.white,
              child: TextField(
                controller: _textFieldController,
                enabled: true,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter a message',
                ),
              ),
            ),
            ElevatedButton(
              style: style,
              onPressed: () {
                _messagesController
                    .didTapOnSendButton(_textFieldController.text);
                _textFieldController.clear();
              },
              child: const Text('Invia'),
            ),
          ],
        ),
      ),
    );
  }

  ListView listViewMessage(List<Message> messages) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      moveListToEnd();
    });
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 10),
      itemCount: messages.length,
      shrinkWrap: true,
      // physics: const AlwaysScrollableScrollPhysics(),
      controller: _scrollController,
      itemBuilder: (context, index) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent +
          _bottomBarHeight +
          MediaQuery.of(context).viewInsets.bottom,
      duration: Duration(milliseconds: 200),
      curve: Curves.easeIn,
    );
  }
}
